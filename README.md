<!-- nilumio: Anfang -->
# nilumio für Apple TV

**nilumio** ist ein Jellyfin-Client für Apple TV. Er ist ein Fork von
[Swiftfin](https://github.com/jellyfin/Swiftfin) (Basis: `main` vom 21.10.2026, nach Release 1.6.1) und steht wie
Swiftfin unter der [Mozilla Public License 2.0](LICENSE.md). nilumio ist kein offizielles
Jellyfin-Projekt. Herkunft, Lizenz und die Liste aller geänderten Swiftfin-Dateien
stehen in [NOTICE.md](NOTICE.md).

*English: nilumio is a Jellyfin client for Apple TV, forked from Swiftfin (main, October 2026) and
licensed under the MPL-2.0. See NOTICE.md for origin, licence and the list of changes.*

## Bauen

Voraussetzung: Xcode 26.6 oder neuer (getestet mit Xcode 27.1, tvOS-27-Simulator).

```sh
xcodebuild -project Swiftfin.xcodeproj -scheme "Swiftfin tvOS" -configuration Debug \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  -skipMacroValidation -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO build
```

Auf einem echten Apple TV: In Xcode das Schema „Swiftfin tvOS“ öffnen, unter
Signing & Capabilities das eigene Team wählen (oder `XcodeConfig/DevelopmentTeam.xcconfig`
mit `DEVELOPMENT_TEAM = …` anlegen, steht in `.gitignore`) und das gekoppelte Apple TV als Ziel nehmen.

## Gemeinsam schauen (SyncPlay)

Menüpunkt „Gemeinsam schauen“: Gruppe anlegen oder beitreten (auch gemeinsam mit Jellyfin-Web, Android usw.).
In einer Gruppe gehen Pause, Weiter und Spulen als Anfrage an den Server; ausgeführt wird der Befehl des
Servers auf allen Geräten zur selben Serverzeit. Wer in der Gruppe etwas startet, gibt es allen vor.
Voraussetzung: SyncPlay ist für den Benutzer auf dem Server erlaubt.

Upstream einspielen: `git fetch upstream --tags && git merge <neues-release-tag>`.
Eigener Code liegt in `Shared/Nilumio/`, Eingriffe in Swiftfin-Dateien sind mit `// nilumio` markiert.

---
<!-- nilumio: Ende – ab hier die ursprüngliche Swiftfin-README -->

<div align="center">
  <img alt="Swiftfin" src="./Resources/primary-wide.svg">

  <h1>Swiftfin</h1>
  <img src="https://img.shields.io/badge/iOS-18+-red"/>
  <img src="https://img.shields.io/badge/tvOS-26+-red"/>
  <img src="https://img.shields.io/badge/Jellyfin-12.0-9962be"/>
  
  <a href="https://translate.jellyfin.org/engage/swiftfin/">
    <img src="https://translate.jellyfin.org/widgets/swiftfin/-/svg-badge.svg"/>
  </a>
  <a href="https://matrix.to/#/#jellyfin:matrix.org">
    <img src="https://img.shields.io/matrix/jellyfin:matrix.org">
  </a>
  <a href="https://discord.gg/zHBxVSXdBV">
    <img src="https://img.shields.io/badge/Talk%20on-Discord-brightgreen">
  </a>
</div>

<p align="center">
  <b>Swiftfin</b> is a modern video client for the <a href="https://github.com/jellyfin/jellyfin">Jellyfin</a> media server. Made using Swift to maximize direct play with the power of <b>VLC</b> and look <b>native</b> on all classes of Apple devices.
</p>

## ⚡️ Download

<a href="https://apps.apple.com/us/app/swiftfin/id1604098728">
  <img height=75 alt="Download on the Apple App Store" src="./Resources/Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg"/>
</a>

## 🛠️ TestFlight

Use the TestFlight version to test new features and bug fixes before being published to the App Store. We are grateful for your time and resources for reporting new bugs.

<a href="https://testflight.apple.com/join/SqNPfdxq">
  <img height=75 alt="Get the beta on TestFlight" src="./Resources/testflight.svg"/>
</a>

## 📖 Documentation

Swiftfin provides detailed documentation to help you understand key aspects of the app and its development approach:

- [🎞️ Library Support](https://github.com/jellyfin/Swiftfin/blob/main/Documentation/libraries.md) — Information on **library compatibility** and supported media types in Swiftin.
- [🎬 Media Playback](https://github.com/jellyfin/Swiftfin/blob/main/Documentation/players.md) — Learn about Swiftfin's **Native** and **VLC** players and how their features vary.
- [🧩 OS Version Support](https://github.com/jellyfin/Swiftfin/blob/main/Documentation/version.md) — Read about how we determine the **minimum supported OS** and which versions of iOS & tvOS are supported.
- [🐞 Common Issues](https://github.com/jellyfin/Swiftfin/blob/main/Documentation/common_issues.md) — If you are experiencing an issue with Swiftfin, this is the best place to start.
- [💜 Supporting Development](https://jellyfin.org/docs/general/contributing/direct-donations) — Learn how you can **support the project developers** and help keep Swiftfin improving.

## ⚙️ Development

Thank you for your interest in Swiftfin! Please check out the [Contribution Guidelines](https://github.com/jellyfin/Swiftfin/blob/main/Documentation/contributing.md) to get started.

## 📚 Translations

**Don't see Swiftfin in your language?**

Check out our [Weblate instance](https://translate.jellyfin.org/projects/swiftfin/) to help translate Swiftfin and other Jellyfin projects.

<a href="https://translate.jellyfin.org/engage/swiftfin/">
<img src="https://translate.jellyfin.org/widgets/swiftfin/-/multi-auto.svg"/>
</a>
