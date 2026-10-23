//
// nilumio – Start-Animation (neue Datei, nicht von Swiftfin).
// Spielt nilumio-intro.mp4 vollbild über der App ab und blendet weich aus,
// sobald das Video zu Ende ist UND die Startseite geladen ist
// (bzw. niemand angemeldet ist). Spätestens nach 15 s ist Schluss.
//
// Copyright (c) 2026 Niklas Held
//

import AVFoundation
import FactoryKit
import SwiftUI

private extension Notification.Name {

    static let nilumioHomeLoaded = Notification.Name("nilumioHomeLoaded")
}

extension View {

    func nilumioIntro() -> some View {
        modifier(NilumioIntro())
    }

    /// Für `ContentGroupView`: Sobald die Startseite fertig ist, darf das Intro ausblenden.
    func nilumioReportHomeLoaded(_ isLoaded: Bool) -> some View {
        onChange(of: isLoaded) { _, isLoaded in
            if isLoaded {
                NotificationCenter.default.post(name: .nilumioHomeLoaded, object: nil)
            }
        }
    }
}

private struct NilumioIntro: ViewModifier {

    @InjectedObject(\.userSessionManager)
    private var userSessionManager

    @State
    private var isVisible = true
    @State
    private var videoEnded = false
    @State
    private var homeLoaded = false

    func body(content: Content) -> some View {
        ZStack {
            Color.nilumioBackground.ignoresSafeArea()

            content

            if isVisible {
                IntroVideo { videoEnded = true }
                    .background(Color.nilumioBackground)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .nilumioHomeLoaded)) { _ in
            homeLoaded = true
        }
        .onChange(of: videoEnded && (homeLoaded || userSessionManager.state == .signedOut)) { _, isReady in
            if isReady {
                hide()
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(15))
            hide()
        }
    }

    private func hide() {
        withAnimation(.easeInOut(duration: 0.6)) { isVisible = false }
    }
}

/// AVPlayerLayer ohne Bedienelemente; meldet das Videoende (oder fehlendes Video).
private struct IntroVideo: UIViewRepresentable {

    let onEnd: () -> Void

    final class PlayerView: UIView {
        override static var layerClass: AnyClass {
            AVPlayerLayer.self
        }

        var playerLayer: AVPlayerLayer {
            layer as! AVPlayerLayer
        }

        var endObserver: NSObjectProtocol?
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        guard let url = Bundle.main.url(forResource: "nilumio-intro", withExtension: "mp4") else {
            DispatchQueue.main.async(execute: onEnd)
            return view
        }

        let player = AVPlayer(url: url)
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.endObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: player.currentItem,
            queue: .main
        ) { _ in onEnd() }
        player.play()
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerView, coordinator: ()) {
        uiView.playerLayer.player?.pause()
        uiView.endObserver.map(NotificationCenter.default.removeObserver)
    }
}
