//
// nilumio – SyncPlay (Jellyfin SyncPlay) für tvOS.
// Neu geschrieben nach dem öffentlich dokumentierten Jellyfin-API (OpenAPI:
// /SyncPlay/*, /GetUtcTime, WebSocket-Nachrichten SyncPlayCommand/SyncPlayGroupUpdate).
// Endpunkte, Datentypen und WebSocket kommen aus dem Jellyfin Swift SDK.
// Steht wie das übrige Projekt unter der Mozilla Public License 2.0.
//
// Copyright (c) 2026 Niklas Held
//

import Combine
import FactoryKit
import Foundation
import Get
import JellyfinAPI

/// Hält die SyncPlay-Gruppe, gleicht die Uhr mit dem Server ab und führt Serverbefehle
/// zur Serverzeit im Player aus. Nutzereingaben im Player gehen in einer Gruppe als
/// Anfrage an den Server (`request(_:from:)`), nicht direkt an den Player.
@MainActor
final class SyncPlayManager: ObservableObject {

    static let shared = SyncPlayManager()

    @Published
    private(set) var group: GroupInfoDto?
    @Published
    private(set) var groups: [GroupInfoDto] = []
    @Published
    private(set) var errorMessage: String?

    /// Warteschlange der Gruppe (vom Server)
    private var queue: PlayQueueUpdate?
    private var clock = SyncPlayClock()
    private var clockTask: Task<Void, Never>?
    private var commandTask: Task<Void, Never>?
    private var readyTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    @Injected(\.userSessionManager)
    private var sessionManager

    private var session: UserSession? {
        sessionManager.currentSession
    }

    private var player: MediaPlayerManager? {
        sessionManager.mediaPlayerManager
    }

    private var playingItem: SyncPlayQueueItem? {
        queue?.playingItemIndex.flatMap { queue?.playlist?[safe: $0] }
    }

    private init() {
        sessionManager.$currentSession
            .map { $0?.serverSocketManager.events ?? Combine.Empty().eraseToAnyPublisher() }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard case let .message(message) = event else { return }

                switch message {
                case let .syncPlayGroupUpdateMessage(m): m.data.map { self?.handle($0) }
                case let .syncPlayCommandMessage(m): m.data.map { self?.handle($0) }
                default: break
                }
            }
            .store(in: &cancellables)

        // Startet jemand hier selbst etwas, wird es die neue Warteschlange der Gruppe.
        Container.shared
            .mediaPlayerManagerPublisher()
            .compactMap { $0?.$playbackItem }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self, group != nil, let id = item?.baseItem.id, id != playingItem?.itemID else { return }

                let ticks = item?.baseItem.startSeconds?.ticks ?? 0
                send(Paths.syncPlaySetNewQueue(.init(playingItemPosition: 0, playingQueue: [id], startPositionTicks: ticks)))
            }
            .store(in: &cancellables)
    }

    // MARK: Seite

    func loadGroups() async {
        guard let session else {
            groups = []
            return
        }

        do {
            groups = try await session.client.send(Paths.syncPlayGetGroups).value
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createGroup() async {
        guard let session else { return }

        let name = Nilumio.text(de: "Gruppe von ", en: "Group of ") + session.user.username
        do {
            _ = try await session.client.send(Paths.syncPlayCreateGroup(.init(groupName: name)))
        } catch is DecodingError {
            // Ältere Server antworten ohne Inhalt; die Gruppe kommt über den WebSocket.
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func join(_ group: GroupInfoDto) {
        send(Paths.syncPlayJoinGroup(.init(groupID: group.groupID)))
    }

    func leave() {
        send(Paths.syncPlayLeaveGroup)
        reset()
    }

    // MARK: Anfragen aus dem Player

    /// Spielt `manager` das Gruppen-Item, geht die Eingabe als Anfrage an den Server (`true`).
    func request(_ request: Request<Void>, from manager: MediaPlayerManager) -> Bool {
        guard group != nil, manager.playbackItem?.baseItem.id == playingItem?.itemID else { return false }

        send(request)
        return true
    }

    // MARK: Gruppen-Updates

    private func handle(_ update: GroupUpdate) {
        switch update {
        case let .syncPlayGroupJoinedUpdate(u):
            group = u.data
            startClockSync()

        case let .syncPlayUserJoinedUpdate(u):
            if let name = u.data, group?.participants?.contains(name) == false {
                group?.participants?.append(name)
            }

        case let .syncPlayUserLeftUpdate(u):
            group?.participants?.removeAll { $0 == u.data }

        case .syncPlayGroupLeftUpdate, .syncPlayNotInGroupUpdate, .syncPlayGroupDoesNotExistUpdate:
            reset()

        case .syncPlayLibraryAccessDeniedUpdate:
            errorMessage = Nilumio.text(de: "Kein Zugriff auf diese Mediathek.", en: "No access to this library.")

        case let .syncPlayStateUpdate(u):
            group?.state = u.data?.state

        case let .syncPlayPlayQueueUpdate(u):
            guard let newQueue = u.data else { return }

            queue = newQueue
            if [.newPlaylist, .setCurrentItem, .nextItem, .previousItem].contains(newQueue.reason) {
                playGroupItem()
            }
        }
    }

    /// Lädt das Gruppen-Item (falls nötig) und meldet „bereit“, sobald es spielbereit ist.
    private func playGroupItem() {
        guard let queue, let itemID = playingItem?.itemID, let session else { return }

        var startTicks = queue.startPositionTicks ?? 0
        if queue.isPlaying == true, let lastUpdate = queue.lastUpdate {
            startTicks += Int(clock.serverNow.timeIntervalSince(lastUpdate) * 10_000_000)
        }
        if player?.playbackItem?.baseItem.id != itemID || !sessionManager.hasActivePlayback {
            report(isReady: false, ticks: startTicks)
            sessionManager.playItem(id: itemID, startPositionTicks: startTicks, userSession: session)
        }

        readyTask?.cancel()
        readyTask = Task { [weak self] in
            for _ in 0 ..< 240 {
                try? await Task.sleep(for: .milliseconds(500))
                guard let self, !Task.isCancelled else { return }

                if let player, player.playbackItem?.baseItem.id == itemID, player.state == .playback,
                   player.proxy?.isBuffering.value == false
                {
                    await player.setPlaybackRequestStatus(status: .paused)
                    report(isReady: true, ticks: player.seconds.ticks)
                    return
                }
            }
        }
    }

    // MARK: Serverbefehle

    private func handle(_ command: SendCommand) {
        guard group != nil, command.playlistItemID == nil || command.playlistItemID == playingItem?.playlistItemID else { return }

        let localTime = (command.when ?? clock.serverNow).addingTimeInterval(-clock.offset)
        commandTask?.cancel()
        commandTask = Task { [weak self] in
            let delay = localTime.timeIntervalSinceNow
            if delay > 0 {
                try? await Task.sleep(for: .seconds(delay))
            }
            guard let self, !Task.isCancelled, let player else { return }

            let ticks = command.positionTicks ?? player.seconds.ticks
            switch command.command {
            case .unpause:
                // Ist der Zeitpunkt schon vorbei, um die verstrichene Zeit weiter vorn einsetzen.
                let target = Duration.ticks(ticks) + .seconds(max(0, -localTime.timeIntervalSinceNow))
                if abs(player.seconds - target) > .milliseconds(500) {
                    player.proxy?.setSeconds(target)
                }
                await player.setPlaybackRequestStatus(status: .playing)

            case .pause, .seek:
                await player.setPlaybackRequestStatus(status: .paused)
                player.proxy?.setSeconds(.ticks(ticks))
                guard command.command == .seek else { return }

                try? await Task.sleep(for: .milliseconds(500))
                while player.proxy?.isBuffering.value == true, !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(250))
                }
                report(isReady: true, ticks: ticks)

            case .stop:
                await player.stop()

            case .none:
                break
            }
        }
    }

    private func report(isReady: Bool, ticks: Int) {
        let info = PlaybackQueueStateInfo(
            isPlaying: false,
            playlistItemID: playingItem?.playlistItemID,
            positionTicks: ticks,
            when: clock.serverNow
        )
        send(isReady ? Paths.syncPlayReady(info) : Paths.syncPlayBuffering(info))
    }

    // MARK: Uhrabgleich

    /// Drei schnelle Messungen, danach jede Minute; die halbe Laufzeit geht als Ping an den Server.
    private func startClockSync() {
        clockTask?.cancel()
        clock = SyncPlayClock(offset: clock.offset)
        clockTask = Task { [weak self] in
            for round in 0... {
                guard let self, !Task.isCancelled, group != nil, let session else { return }

                let sent = Date()
                if let response = try? await session.client.send(Paths.getUtcTime).value,
                   let serverReceived = response.requestReceptionTime, let serverSent = response.responseTransmissionTime
                {
                    clock.add(sent: sent, serverReceived: serverReceived, serverSent: serverSent, received: Date())
                    send(Paths.syncPlayPing(.init(ping: Int(clock.roundTrip * 500))))
                }
                try? await Task.sleep(for: .seconds(round < 2 ? 1 : 60))
            }
        }
    }

    // MARK: Hilfen

    private func reset() {
        group = nil
        queue = nil
        clockTask?.cancel()
        commandTask?.cancel()
        readyTask?.cancel()
    }

    private func send(_ request: Request<Void>) {
        guard let session else { return }

        Task { [weak self] in
            do {
                try await session.client.send(request)
            } catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }
}

/// Eingaben aus dem Player (Swiftfin-Stellen mit `// nilumio`): in einer SyncPlay-Gruppe
/// als Anfrage an den Server, sonst wie bei Swiftfin direkt an den Player.
extension MediaPlayerManager {

    func nilumioSetPlayback(_ status: PlaybackRequestStatus) {
        if !SyncPlayManager.shared.request(status == .playing ? Paths.syncPlayUnpause : Paths.syncPlayPause, from: self) {
            setPlaybackRequestStatus(status: status)
        }
    }

    /// Nach dem Scrubben: an die Stelle springen und weiterspielen.
    func nilumioSeekAndPlay(to position: Duration) {
        if !requestSyncPlaySeek(to: position) {
            proxy?.setSeconds(position)
            setPlaybackRequestStatus(status: .playing)
        }
    }

    func nilumioJump(by offset: Duration) {
        guard !requestSyncPlaySeek(to: seconds + offset) else { return }

        if offset < .zero {
            proxy?.jumpBackward(.zero - offset)
        } else {
            proxy?.jumpForward(offset)
        }
    }

    private func requestSyncPlaySeek(to position: Duration) -> Bool {
        SyncPlayManager.shared.request(Paths.syncPlaySeek(.init(positionTicks: max(position, .zero).ticks)), from: self)
    }
}
