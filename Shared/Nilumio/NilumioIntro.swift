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

extension Notification.Name {

    /// Wird von `ContentGroupView` gesendet, sobald die erste Seite Inhalte (oder einen Fehler) zeigt.
    static let nilumioStartseiteGeladen = Notification.Name("nilumioStartseiteGeladen")
}

extension View {

    func nilumioIntro() -> some View {
        modifier(NilumioIntro())
    }
}

private struct NilumioIntro: ViewModifier {

    @InjectedObject(\.userSessionManager)
    private var userSessionManager

    @State
    private var sichtbar = true
    @State
    private var videoZuEnde = false
    @State
    private var startseiteGeladen = false

    func body(content: Content) -> some View {
        ZStack {
            Color.nilumioGrund.ignoresSafeArea()

            content

            if sichtbar {
                IntroVideo { videoZuEnde = true }
                    .background(Color.nilumioGrund)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .nilumioStartseiteGeladen)) { _ in
            startseiteGeladen = true
        }
        .onChange(of: videoZuEnde && (startseiteGeladen || userSessionManager.state == .signedOut)) { _, bereit in
            if bereit { ausblenden() }
        }
        .task {
            try? await Task.sleep(for: .seconds(15))
            ausblenden()
        }
    }

    private func ausblenden() {
        withAnimation(.easeInOut(duration: 0.6)) { sichtbar = false }
    }
}

/// AVPlayerLayer ohne Bedienelemente; meldet das Videoende (oder fehlendes Video).
private struct IntroVideo: UIViewRepresentable {

    let zuEnde: () -> Void

    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        var beobachter: NSObjectProtocol?
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        guard let url = Bundle.main.url(forResource: "nilumio-intro", withExtension: "mp4") else {
            DispatchQueue.main.async(execute: zuEnde)
            return view
        }
        let player = AVPlayer(url: url)
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.beobachter = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: player.currentItem,
            queue: .main
        ) { _ in zuEnde() }
        player.play()
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerView, coordinator: ()) {
        uiView.playerLayer.player?.pause()
        if let beobachter = uiView.beobachter { NotificationCenter.default.removeObserver(beobachter) }
    }
}
