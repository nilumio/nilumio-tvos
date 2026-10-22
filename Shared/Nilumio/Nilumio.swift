//
// nilumio – eigene Ergänzungen zum Swiftfin-Fork.
// Diese Datei ist neu (nicht von Swiftfin) und enthält alles, was die
// Swiftfin-Dateien an nilumio-Werten brauchen: Farben, Herkunftshinweis.
//
// Copyright (c) 2026 Niklas Held
//

import SwiftUI

extension Color {

    /// Akzent/Fokus: Türkis #22ABD8 (ersetzt Swiftfins Jellyfin-Lila über `jellyfinPurple`)
    static let nilumioAkzent = Color(red: 34 / 255, green: 171 / 255, blue: 216 / 255)
    /// Fortschrittsbalken: Lila #4B3DB8
    static let nilumioFortschritt = Color(red: 75 / 255, green: 61 / 255, blue: 184 / 255)
    /// Hintergrund dunkel #070A12
    static let nilumioGrund = Color(red: 7 / 255, green: 10 / 255, blue: 18 / 255)
}

enum Nilumio {

    static let name = "nilumio"

    /// Quelltext dieses Forks (MPL-2.0 verlangt den Hinweis).
    static let quelltext = "github.com/nilumio/nilumio-tvos"

    static var istDeutsch: Bool {
        Locale.preferredLanguages.first?.hasPrefix("de") ?? false
    }
}

/// Herkunftshinweis für „Über“ (MPL-2.0, Markenregeln von Jellyfin).
struct NilumioHerkunftSection: View {

    var body: some View {
        Section {
            Text(
                Nilumio.istDeutsch
                    ? "nilumio basiert auf Swiftfin, dem freien Jellyfin-Client der Jellyfin-Community, und steht unter der Mozilla Public License 2.0."
                    : "nilumio is based on Swiftfin, the free Jellyfin client by the Jellyfin community, and is licensed under the Mozilla Public License 2.0."
            )
            LabeledContent(Nilumio.istDeutsch ? "Quelltext" : "Source code", value: Nilumio.quelltext)
        } header: {
            Text(Nilumio.istDeutsch ? "Herkunft und Lizenz" : "Origin and licence")
        }
    }
}
