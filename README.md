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

Upstream einspielen: `git fetch upstream --tags && git merge <neues-release-tag>`.
Eigener Code liegt in `Shared/Nilumio/`, Eingriffe in Swiftfin-Dateien sind mit `// nilumio` markiert.

---
<!-- nilumio: Ende – ab hier die ursprüngliche Swiftfin-README -->

