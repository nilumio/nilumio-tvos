//
// nilumio – eigene Ergänzungen zum Swiftfin-Fork.
// Diese Datei ist neu (nicht von Swiftfin) und enthält alles, was die
// Swiftfin-Dateien an nilumio-Werten brauchen: Farben, Herkunftshinweis.
//
// Copyright (c) 2026 Niklas Held
//

import SwiftUI

extension Color {

    /// Akzent und Fokus (ersetzt Swiftfins Jellyfin-Lila über `jellyfinPurple`)
    static let nilumioAccent = Color(hex: "#22ABD8")
    static let nilumioProgress = Color(hex: "#4B3DB8")
    static let nilumioBackground = Color(hex: "#070A12")
}

enum Nilumio {

    static let name = "nilumio"

    /// Text in der Gerätesprache: Deutsch, sonst Englisch.
    static func text(de: String, en: String) -> String {
        Locale.preferredLanguages.first?.hasPrefix("de") == true ? de : en
    }
}

/// Herkunftshinweis für „Über“ (MPL-2.0, Markenregeln von Jellyfin).
struct NilumioOriginSection: View {

    var body: some View {
        Section(Nilumio.text(de: "Herkunft und Lizenz", en: "Origin and licence")) {
            Text(Nilumio.text(
                de: "nilumio basiert auf Swiftfin, dem freien Jellyfin-Client der Jellyfin-Community, und steht unter der Mozilla Public License 2.0.",
                en: "nilumio is based on Swiftfin, the free Jellyfin client by the Jellyfin community, and is licensed under the Mozilla Public License 2.0."
            ))
            LabeledContent(Nilumio.text(de: "Quelltext", en: "Source code"), value: "github.com/nilumio/nilumio-tvos")
        }
    }
}
