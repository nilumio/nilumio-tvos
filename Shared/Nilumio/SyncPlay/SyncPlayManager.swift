//
// nilumio – „Gemeinsam schauen“ (Jellyfin SyncPlay) für tvOS.
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
/// Anfrage an den Server (`requestPlayback`, `requestSeek`), nicht direkt an den Player.
@MainActor
final class SyncPlayManager: ObservableObject {

    static let shared = SyncPlayManager()

    @Published
    private(set) var group: GroupInfoDto?
    @Published
    private(set) var groups: [GroupInfoDto] = []
    @Published
    private(set) var fehler: String?

    /// Aktuelle Warteschlange der Gruppe (vom Server).
    private var queue: PlayQueueUpdate?
    /// Serverzeit minus lokale Zeit (Sekunden).
    private var offset: TimeInterval = 0
    /// Messungen (Laufzeit, Versatz); die mit der kürzesten Laufzeit gilt.
    private var messungen: [(rtt: TimeInterval, offset: TimeInterval)] = []
    private var zeitTask: Task<Void, Never>?
    private var befehlTask: Task<Void, Never>?
    private var readyTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    private var sessionManager: UserSessionManager { Container.shared.userSessionManager() }
    private var session: UserSession? { sessionManager.currentSession }
    private var player: MediaPlayerManager? { sessionManager.mediaPlayerManager }

    private init() {
        sessionManager.$currentSession
            .map { $0?.serverSocketManager.events ?? Combine.Empty<JellyfinSocket.Session.Event, Never>().eraseToAnyPublisher() }
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
        Container.shared.mediaPlayerManagerPublisher()
            .compactMap { $0?.$playbackItem }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self, self.group != nil, let id = item?.baseItem.id, id != self.aktuellesItem?.itemID else { return }
                let ticks = item?.baseItem.startSeconds?.ticks ?? 0
                self.senden(Paths.syncPlaySetNewQueue(.init(playingItemPosition: 0, playingQueue: [id], startPositionTicks: ticks)))
            }
            .store(in: &cancellables)
    }

    // MARK: Seite

    func laden() async {
        guard let session else { groups = []; return }
        do {
            groups = try await session.client.send(Paths.syncPlayGetGroups).value
            fehler = nil
        } catch {
            fehler = error.localizedDescription
        }
    }

    func erstellen() async {
        guard let session else { return }
        let name = (Nilumio.istDeutsch ? "Gruppe von " : "Group of ") + session.user.username
        do {
            _ = try await session.client.send(Paths.syncPlayCreateGroup(.init(groupName: name)))
        } catch is DecodingError {
            // Ältere Server antworten ohne Inhalt; die Gruppe kommt über den WebSocket.
        } catch {
            fehler = error.localizedDescription
        }
    }

    func beitreten(_ gruppe: GroupInfoDto) {
        senden(Paths.syncPlayJoinGroup(.init(groupID: gruppe.groupID)))
    }

    func verlassen() {
        senden(Paths.syncPlayLeaveGroup)
        zuruecksetzen()
    }

    // MARK: Anfragen aus dem Player

    /// Spielt das Gerät gerade das Gruppen-Item?
    private func imGruppenItem(_ manager: MediaPlayerManager?) -> Bool {
        group != nil && manager?.playbackItem?.baseItem.id == aktuellesItem?.itemID
    }

    /// Play/Pause im Player. Gibt `true` zurück, wenn die Anfrage an den Server ging.
    func requestPlayback(_ playing: Bool, manager: MediaPlayerManager?) -> Bool {
        guard imGruppenItem(manager) else { return false }
        senden(playing ? Paths.syncPlayUnpause : Paths.syncPlayPause)
        return true
    }

    /// Spulen im Player. Gibt `true` zurück, wenn die Anfrage an den Server ging.
    func requestSeek(_ position: Duration, manager: MediaPlayerManager?) -> Bool {
        guard imGruppenItem(manager) else { return false }
        senden(Paths.syncPlaySeek(.init(positionTicks: max(position, .zero).ticks)))
        return true
    }

    // MARK: Gruppen-Updates

    private var aktuellesItem: SyncPlayQueueItem? {
        guard let queue, let index = queue.playingItemIndex else { return nil }
        return queue.playlist?[safe: index]
    }

    private func handle(_ update: GroupUpdate) {
        switch update {
        case let .syncPlayGroupJoinedUpdate(u):
            group = u.data
            zeitabgleich()
        case let .syncPlayUserJoinedUpdate(u):
            if let name = u.data, group?.participants?.contains(name) == false { group?.participants?.append(name) }
        case let .syncPlayUserLeftUpdate(u):
            group?.participants?.removeAll { $0 == u.data }
        case .syncPlayGroupLeftUpdate, .syncPlayNotInGroupUpdate, .syncPlayGroupDoesNotExistUpdate:
            zuruecksetzen()
        case .syncPlayLibraryAccessDeniedUpdate:
            fehler = Nilumio.istDeutsch ? "Kein Zugriff auf diese Mediathek." : "No access to this library."
        case let .syncPlayStateUpdate(u):
            group?.state = u.data?.state
        case let .syncPlayPlayQueueUpdate(u):
            guard let neu = u.data else { return }
            queue = neu
            switch neu.reason {
            case .newPlaylist, .setCurrentItem, .nextItem, .previousItem: abspielen()
            default: break
            }
        }
    }

    /// Lädt das Gruppen-Item (falls nötig) und meldet „bereit“, sobald es spielbereit ist.
    private func abspielen() {
        guard let queue, let item = aktuellesItem, let itemID = item.itemID, let session else { return }
        var start = queue.startPositionTicks ?? 0
        if queue.isPlaying == true, let last = queue.lastUpdate {
            start += Int((serverJetzt.timeIntervalSince(last)) * 10_000_000)
        }
        if player?.playbackItem?.baseItem.id != itemID || !sessionManager.hasActivePlayback {
            melden(bereit: false, ticks: start, playing: false)
            sessionManager.playItem(id: itemID, startPositionTicks: start, userSession: session)
        }
        readyTask?.cancel()
        readyTask = Task { [weak self] in
            for _ in 0 ..< 240 {
                try? await Task.sleep(for: .milliseconds(500))
                guard let self, !Task.isCancelled else { return }
                if let m = self.player, m.playbackItem?.baseItem.id == itemID, m.state == .playback,
                   m.proxy?.isBuffering.value == false
                {
                    await m.setPlaybackRequestStatus(status: .paused)
                    self.melden(bereit: true, ticks: m.seconds.ticks, playing: false)
                    return
                }
            }
        }
    }

    // MARK: Serverbefehle

    private func handle(_ befehl: SendCommand) {
        guard group != nil, befehl.playlistItemID == nil || befehl.playlistItemID == aktuellesItem?.playlistItemID else { return }
        let lokal = (befehl.when ?? serverJetzt).addingTimeInterval(-offset)
        befehlTask?.cancel()
        befehlTask = Task { [weak self] in
            let warten = lokal.timeIntervalSinceNow
            if warten > 0 { try? await Task.sleep(for: .seconds(warten)) }
            guard let self, !Task.isCancelled, let m = self.player else { return }
            let ticks = befehl.positionTicks ?? m.seconds.ticks
            switch befehl.command {
            case .unpause:
                // Ist der Zeitpunkt schon vorbei, um die verstrichene Zeit weiter vorn einsetzen.
                let ziel = Duration.ticks(ticks) + .seconds(max(0, -lokal.timeIntervalSinceNow))
                if abs(m.seconds - ziel) > .milliseconds(500) { m.proxy?.setSeconds(ziel) }
                await m.setPlaybackRequestStatus(status: .playing)
            case .pause:
                await m.setPlaybackRequestStatus(status: .paused)
                m.proxy?.setSeconds(.ticks(ticks))
            case .seek:
                await m.setPlaybackRequestStatus(status: .paused)
                m.proxy?.setSeconds(.ticks(ticks))
                try? await Task.sleep(for: .milliseconds(500))
                while m.proxy?.isBuffering.value == true, !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(250))
                }
                self.melden(bereit: true, ticks: ticks, playing: false)
            case .stop:
                await m.stop()
            case .none:
                break
            }
        }
    }

    private func melden(bereit: Bool, ticks: Int, playing: Bool) {
        let info = PlaybackQueueStateInfo(
            isPlaying: playing,
            playlistItemID: aktuellesItem?.playlistItemID,
            positionTicks: ticks,
            when: serverJetzt
        )
        senden(bereit ? Paths.syncPlayReady(info) : Paths.syncPlayBuffering(info))
    }

    // MARK: Zeitabgleich

    private var serverJetzt: Date { Date().addingTimeInterval(offset) }

    /// NTP-artig: Versatz = ((Empfang Server − Senden) + (Antwort Server − Empfang)) / 2.
    /// Drei schnelle Messungen, danach jede Minute; die halbe Laufzeit geht als Ping an den Server.
    private func zeitabgleich() {
        zeitTask?.cancel()
        messungen = []
        zeitTask = Task { [weak self] in
            var runde = 0
            while !Task.isCancelled {
                guard let self, self.group != nil, let session = self.session else { return }
                let gesendet = Date()
                if let antwort = try? await session.client.send(Paths.getUtcTime).value,
                   let t1 = antwort.requestReceptionTime, let t2 = antwort.responseTransmissionTime
                {
                    let empfangen = Date()
                    let rtt = empfangen.timeIntervalSince(gesendet) - t2.timeIntervalSince(t1)
                    let versatz = (t1.timeIntervalSince(gesendet) + t2.timeIntervalSince(empfangen)) / 2
                    self.messungen = Array((self.messungen + [(rtt, versatz)]).suffix(8))
                    if let beste = self.messungen.min(by: { $0.rtt < $1.rtt }) {
                        self.offset = beste.offset
                        self.senden(Paths.syncPlayPing(.init(ping: Int(beste.rtt * 500))))
                    }
                }
                runde += 1
                try? await Task.sleep(for: .seconds(runde < 3 ? 1 : 60))
            }
        }
    }

    // MARK: Hilfen

    private func zuruecksetzen() {
        group = nil
        queue = nil
        zeitTask?.cancel()
        befehlTask?.cancel()
        readyTask?.cancel()
    }

    private func senden(_ request: Request<Void>) {
        guard let session else { return }
        Task { [weak self] in
            do {
                try await session.client.send(request)
            } catch {
                self?.fehler = error.localizedDescription
            }
        }
    }
}

extension MediaPlayerManager {

    /// Play/Pause aus der Fernbedienung: in einer SyncPlay-Gruppe als Anfrage an den Server.
    func nilumioSetPlayback(_ status: PlaybackRequestStatus) {
        guard !SyncPlayManager.shared.requestPlayback(status == .playing, manager: self) else { return }
        setPlaybackRequestStatus(status: status)
    }
}
