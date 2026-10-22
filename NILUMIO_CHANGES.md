# Changes made by nilumio

nilumio for Apple TV is a modified version of [Swiftfin](https://github.com/jellyfin/Swiftfin)
(MPL-2.0). This file lists which files nilumio has added or changed and when. All changes
were made by the nilumio project (Niklas Held) and are licensed under the MPL-2.0; Swiftfin's
licence headers stay in place. In Swiftfin files, every code change is marked with `// nilumio`.

Base: Swiftfin `main` at commit `04e0aa10812385be55831cbf925dbee925056976` (21 October 2026, after release 1.6.1).
To see every change in detail: `git diff 04e0aa10..HEAD` or `git log 04e0aa10..HEAD`.

## Summary by area

| Area | What changed | Files |
|---|---|---|
| Name and identity | Bundle ID `com.held0.nilumio`, display name nilumio | `XcodeConfig/Shared.xcconfig`, `Swiftfin tvOS/Resources/Info.plist` |
| Visible name | "Swiftfin" shown as "nilumio" in all texts | `Shared/Strings/ProperNouns.swift`, `Scripts/Translations/GenerateStrings.swift`, `Shared/Strings/Strings.swift` (generated) |
| Colours | Turquoise accent (#22ABD8, replaces `jellyfinPurple` as default), purple progress bars (#4B3DB8), launch background (#070A12), colour preset named nilumio | `Shared/Nilumio/Nilumio.swift`, `Shared/Extensions/Color.swift`, `ProgressIndicator.swift`, `PlaybackProgress.swift`, `ColorPickerDefaults.swift`, `LaunchScreenBackground.colorset` |
| Artwork | App icon layers and top shelf images replaced, Jellyfin logo replaced by the nilumio mark (asset name kept) | `App Icon & Top Shelf Image.brandassets/**`, `jellyfin-blob-blue.imageset/*` |
| Start-up intro | Intro video that fades into the app once the home screen has loaded | `Shared/Nilumio/NilumioIntro.swift`, `Swiftfin tvOS/Resources/nilumio-intro.mp4`, `Swiftfin tvOS/App/SwiftfinApp.swift`, `Shared/Views/ContentGroupView.swift` |
| About and settings | Origin and licence notice under About; app icon picker hidden on tvOS (alternative icons show the Jellyfin logo) | `Shared/Views/AboutAppView.swift`, `Shared/Views/AppSettingsView.swift` |
| British English | New `en-GB` strings (colour, favourite, licence) | `Translations/en-GB.lproj/Localizable.strings` |
| Watch together (SyncPlay) | Groups, clock sync and server commands in the player, written against the public Jellyfin API | `Shared/Nilumio/SyncPlay/`, `Shared/Coordinators/Tabs/MainTabView.swift`, `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift`, `Shared/Views/VideoPlayer/Container/*`, `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackControls+Scrubbing.swift` |
| Docs and repository | Fork documentation, issue templates, ignore rules | `README.md`, `NOTICE.md`, `NILUMIO_CHANGES.md`, `THIRD_PARTY_NOTICES.md`, `CONTRIBUTING.md`, `SECURITY.md`, `docs/`, `.github/ISSUE_TEMPLATE/`, `.gitignore` |

## All added, modified, removed and renamed files

Generated with `python3 docs/tools/nilumio_changes.py list`. Please regenerate after each change.

| Status | File | Changed |
|---|---|---|
| removed | `.github/ISSUE_TEMPLATE/bug-report.yaml` | 2026-10-22 |
| added | `.github/ISSUE_TEMPLATE/bug.yml` | 2026-10-22 |
| modified | `.github/ISSUE_TEMPLATE/config.yml` | 2026-10-22 |
| removed | `.github/ISSUE_TEMPLATE/feature-request.yaml` | 2026-10-22 |
| added | `.github/ISSUE_TEMPLATE/idea.yml` | 2026-10-22 |
| modified | `.gitignore` | 2026-10-22 |
| added | `CONTRIBUTING.md` | 2026-10-22 |
| added | `NILUMIO_CHANGES.md` | 2026-10-22 |
| added | `NOTICE.md` | 2026-10-22 |
| modified | `README.md` | 2026-10-22 |
| added | `SECURITY.md` | 2026-10-22 |
| modified | `Scripts/Translations/GenerateStrings.swift` | 2026-10-22 |
| modified | `Shared/Components/PosterIndicators/ProgressIndicator.swift` | 2026-10-22 |
| modified | `Shared/Coordinators/Tabs/MainTabView.swift` | 2026-10-22 |
| modified | `Shared/Extensions/Color.swift` | 2026-10-22 |
| added | `Shared/Nilumio/Nilumio.swift` | 2026-10-22 |
| added | `Shared/Nilumio/NilumioIntro.swift` | 2026-10-22 |
| added | `Shared/Nilumio/SyncPlay/SyncPlayManager.swift` | 2026-10-22 |
| added | `Shared/Nilumio/SyncPlay/SyncPlayView.swift` | 2026-10-22 |
| modified | `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/Contents.json` | 2026-10-22 |
| removed | `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/jellyfin-blob.svg` | 2026-10-22 |
| added | `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/nilumio-zeichen.png` | 2026-10-22 |
| modified | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift` | 2026-10-22 |
| modified | `Shared/Strings/ProperNouns.swift` | 2026-10-22 |
| modified | `Shared/Strings/Strings.swift` | 2026-10-22 |
| modified | `Shared/Views/AboutAppView.swift` | 2026-10-22 |
| modified | `Shared/Views/AppSettingsView.swift` | 2026-10-22 |
| modified | `Shared/Views/ContentGroupView.swift` | 2026-10-22 |
| modified | `Shared/Views/VideoPlayer/Container/VideoPlayer+Container.swift` | 2026-10-22 |
| modified | `Shared/Views/VideoPlayer/Container/VideoPlayer+ViewState.swift` | 2026-10-22 |
| modified | `Swiftfin tvOS/App/SwiftfinApp.swift` | 2026-10-22 |
| modified | `Swiftfin tvOS/Components/ColorPicker/ColorPickerDefaults.swift` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon - App Store.imagestack/Back.imagestacklayer/Content.imageset/1280x768-back.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon - App Store.imagestack/Front.imagestacklayer/Content.imageset/512.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon.imagestack/Back.imagestacklayer/Content.imageset/back.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon.imagestack/Back.imagestacklayer/Content.imageset/back@2x.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon.imagestack/Front.imagestacklayer/Content.imageset/front.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/App Icon.imagestack/Front.imagestacklayer/Content.imageset/front@2x.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image Wide.imageset/Untitled-1.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image Wide.imageset/Untitled-2.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image Wide.imageset/top shelf-1.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image Wide.imageset/top shelf.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image.imageset/Untitled-1.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image.imageset/Untitled-2.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image.imageset/top shelf-1.png` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/Top Shelf Image.imageset/top shelf.png` | 2026-10-22 |
| added | `Swiftfin tvOS/Resources/Assets.xcassets/LaunchScreenBackground.colorset/Contents.json` | 2026-10-22 |
| modified | `Swiftfin tvOS/Resources/Info.plist` | 2026-10-22 |
| added | `Swiftfin tvOS/Resources/nilumio-intro.mp4` | 2026-10-22 |
| modified | `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackControls+Scrubbing.swift` | 2026-10-22 |
| modified | `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackProgress.swift` | 2026-10-22 |
| added | `THIRD_PARTY_NOTICES.md` | 2026-10-22 |
| added | `Translations/en-GB.lproj/Localizable.strings` | 2026-10-22 |
| modified | `XcodeConfig/Shared.xcconfig` | 2026-10-22 |
| added | `docs/OWN_CODE.md` | 2026-10-22 |
| added | `docs/UPSTREAM.md` | 2026-10-22 |
| added | `docs/screenshots/01-intro.png` | 2026-10-22 |
| added | `docs/screenshots/02-start.png` | 2026-10-22 |
| added | `docs/screenshots/03-homescreen.png` | 2026-10-22 |
| added | `docs/tools/nilumio_changes.py` | 2026-10-22 |
