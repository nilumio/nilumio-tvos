# NOTICE – nilumio für Apple TV

nilumio (tvOS) ist ein Fork von **Swiftfin** (https://github.com/jellyfin/Swiftfin),
dem freien Jellyfin-Client der Jellyfin-Community.

- Basis: Swiftfin `main` vom 21.10.2026 (Commit `04e0aa10812385be55831cbf925dbee925056976`, nach Release 1.6.1).
  Release 1.6.1 selbst baut mit Xcode 27.1 nicht (Paket CoreStore 9.3.0: „ambiguous use of cs_sync“, dazu VLCKit über Carthage).
- Upstream-Remote: `upstream` → https://github.com/jellyfin/Swiftfin.git
- Branch mit unseren Änderungen: `nilumio`
- Lizenz: Mozilla Public License 2.0 (siehe `LICENSE.md`). Alle Swiftfin-Dateien –
  auch die von uns geänderten – bleiben MPL-2.0, ihre Lizenzköpfe bleiben stehen.
- „Jellyfin“ und „Swiftfin“ sind Namen der Jellyfin-Projekte. nilumio ist kein
  offizielles Jellyfin-Produkt; Name und Logo von Jellyfin/Swiftfin werden in der App
  nicht verwendet (Markenregeln: https://jellyfin.org/docs/general/contributing/branding/).
- Abhängigkeiten behalten ihre eigenen Lizenzen (u. a. SwiftVLC/libVLC, MPVUI, Nuke,
  Factory, Defaults, CoreStore, jellyfin-sdk-swift); siehe die jeweiligen Pakete.

## Neue Dateien (nilumio)

| Datei | Zweck |
|---|---|
| `Shared/Nilumio/Nilumio.swift` | Farben (Türkis #22ABD8, Lila #4B3DB8, Grund #070A12), Herkunftshinweis für „Über“ |
| `Shared/Nilumio/NilumioIntro.swift` | Start-Animation (Video, weiche Überblendung) |
| `Swiftfin tvOS/Resources/nilumio-intro.mp4` | Intro-Video |
| `Swiftfin tvOS/Resources/Assets.xcassets/LaunchScreenBackground.colorset` | Startbildschirm-Farbe #070A12 |
| `Translations/en-GB.lproj/Localizable.strings` | britische Schreibweise (colour, favourite, licence …) |
| `NOTICE.md` | diese Datei |
| `docs/screenshots/` | Simulator-Screenshots |

Bilder und Video von nilumio (Icons, Top-Shelf, Intro) stehen nicht unter MPL;
alle Rechte vorbehalten.

## Geänderte Swiftfin-Dateien

Jede Änderung im Code ist mit `// nilumio` markiert.

| Datei | Änderung |
|---|---|
| `XcodeConfig/Shared.xcconfig` | Bundle-ID `com.held0.nilumio` |
| `Swiftfin tvOS/Resources/Info.plist` | Anzeigename „nilumio“ |
| `Swiftfin tvOS/App/SwiftfinApp.swift` | `.nilumioIntro()` um die App |
| `Shared/Extensions/Color.swift` | `jellyfinPurple` zeigt auf nilumio-Türkis (Standard-Akzentfarbe) |
| `Shared/Strings/ProperNouns.swift` | sichtbarer Name „Swiftfin“ → „nilumio“ |
| `Scripts/Translations/GenerateStrings.swift` | Generator schreibt in `L10n.tr` die Ersetzung „Swiftfin“ → „nilumio“ |
| `Shared/Strings/Strings.swift` | davon erzeugt (eine Zeile) |
| `Shared/Views/AboutAppView.swift` | Herkunfts-/Lizenzhinweis in „Über“ |
| `Shared/Views/ContentGroupView.swift` | meldet „Startseite geladen“ an das Intro |
| `Shared/Components/PosterIndicators/ProgressIndicator.swift` | Fortschrittsbalken Lila |
| `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackProgress.swift` | Player-Fortschritt Lila |
| `Shared/Views/AppSettingsView.swift` | App-Icon-Auswahl auf tvOS ausgeblendet (Alternativ-Icons zeigen das Jellyfin-Logo) |
| `Swiftfin tvOS/Components/ColorPicker/ColorPickerDefaults.swift` | Farbvorgabe heißt „nilumio“ statt „Jellyfin“ |
| `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/**` | App-Icon (Ebenen) und Top-Shelf-Bilder ersetzt |
| `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/*` | Jellyfin-Logo durch nilumio-Zeichen ersetzt (Asset-Name bleibt) |
| `README.md` | nilumio-Abschnitt oben |

Prüfen: `git diff --stat 04e0aa10..nilumio`

Hinweis: Jeder Build lässt `Scripts/Translations/GenerateStrings.swift` laufen; das kann `Translations/en.lproj/Localizable.strings`
minimal umformatieren (Upstream-Verhalten). Diese Änderung nicht committen (`git checkout Translations/en.lproj`).
