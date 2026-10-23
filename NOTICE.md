# NOTICE – nilumio for Apple TV

nilumio (tvOS) is a fork of **Swiftfin** (https://github.com/jellyfin/Swiftfin),
the free Jellyfin client made by the Jellyfin community.

- Base: Swiftfin `main` of 21 October 2026 (commit `04e0aa10812385be55831cbf925dbee925056976`, after release 1.6.1).
  Release 1.6.1 itself does not build with Xcode 27.1 (package CoreStore 9.3.0: "ambiguous use of cs_sync", plus VLCKit via Carthage).
- Upstream remote: `upstream` → https://github.com/jellyfin/Swiftfin.git
- Licence: Mozilla Public License 2.0 (see `LICENSE.md`). All Swiftfin files,
  including those we changed, stay under the MPL-2.0 and keep their licence headers.
- "Jellyfin" and "Swiftfin" are names of the Jellyfin projects. nilumio is not an
  official Jellyfin product; the Jellyfin and Swiftfin names and logos are not used in the app
  (branding rules: https://jellyfin.org/docs/general/contributing/branding/).
- Dependencies keep their own licences (including SwiftVLC/libVLC, MPVUI, Nuke,
  Factory, Defaults, CoreStore and jellyfin-sdk-swift); see the respective packages.

## New files (nilumio)

| File | Purpose |
|---|---|
| `Shared/Nilumio/Nilumio.swift` | Colours (turquoise #22ABD8, purple #4B3DB8, background #070A12), source notice for "About" |
| `Shared/Nilumio/NilumioIntro.swift` | Start-up animation (video with soft cross-fade) |
| `Shared/Nilumio/SyncPlay/SyncPlayManager.swift` | SyncPlay: groups, clock sync, server commands in the player |
| `Shared/Nilumio/SyncPlay/SyncPlayView.swift` | "SyncPlay" page and menu entry |
| `Swiftfin tvOS/Resources/nilumio-intro.mp4` | Intro video |
| `Swiftfin tvOS/Resources/Assets.xcassets/LaunchScreenBackground.colorset` | Launch screen colour #070A12 |
| `Translations/en-GB.lproj/Localizable.strings` | British spelling (colour, favourite, licence …) |
| `NOTICE.md` | this file |
| `docs/screenshots/` | Simulator screenshots |

nilumio's images and video (icons, top shelf, intro) are not covered by the MPL;
all rights reserved.

## Changed Swiftfin files

Every change in code is marked with `// nilumio`.

| File | Change |
|---|---|
| `XcodeConfig/Shared.xcconfig` | Bundle ID `com.held0.nilumio` |
| `Swiftfin tvOS/Resources/Info.plist` | Display name "nilumio" |
| `Swiftfin tvOS/App/SwiftfinApp.swift` | `.nilumioIntro()` around the app |
| `Shared/Extensions/Color.swift` | `jellyfinPurple` points to nilumio turquoise (default accent colour) |
| `Shared/Strings/ProperNouns.swift` | Visible name "Swiftfin" → "nilumio" |
| `Scripts/Translations/GenerateStrings.swift` | Generator writes the replacement "Swiftfin" → "nilumio" into `L10n.tr` |
| `Shared/Strings/Strings.swift` | Generated from the above (one line) |
| `Shared/Views/AboutAppView.swift` | Origin and licence notice in "About" |
| `Shared/Views/ContentGroupView.swift` | Tells the intro that the home screen has loaded |
| `Shared/Components/PosterIndicators/ProgressIndicator.swift` | Purple progress bar |
| `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackProgress.swift` | Purple player progress |
| `Shared/Views/AppSettingsView.swift` | App icon picker hidden on tvOS (the alternative icons show the Jellyfin logo) |
| `Swiftfin tvOS/Components/ColorPicker/ColorPickerDefaults.swift` | Colour preset named "nilumio" instead of "Jellyfin" |
| `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/**` | App icon layers and top shelf images replaced |
| `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/*` | Jellyfin logo replaced by the nilumio mark (asset name unchanged) |
| `Shared/Coordinators/Tabs/MainTabView.swift` | "SyncPlay" menu entry (tvOS) |
| `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift` | `playItem` no longer `private` (SyncPlay starts the group's item through it) |
| `Shared/Views/VideoPlayer/Container/VideoPlayer+Container.swift` | Remote play/pause goes through `nilumioSetPlayback` (a request to the server when in a group) |
| `Shared/Views/VideoPlayer/Container/VideoPlayer+ViewState.swift` | Scrubbing sent to the server as a request when in a group |
| `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/Components/PlaybackControls+Scrubbing.swift` | Skipping forward/back sent to the server as a request when in a group |
| `README.md` | nilumio section at the top |

## SyncPlay ("SyncPlay") and licensing

Swiftfin has no SyncPlay (issue jellyfin/Swiftfin#688). The implementation in `Shared/Nilumio/SyncPlay/`
was written from scratch against the public Jellyfin API (OpenAPI: `/SyncPlay/*`, `/GetUtcTime`,
WebSocket messages `SyncPlayCommand`/`SyncPlayGroupUpdate`). It uses endpoints, data types and the
WebSocket from jellyfin-sdk-swift (MPL-2.0) and Swiftfin's `ServerSocketManager`. No code was taken from
jellyfin-web (GPL-2.0) or from the Android app; the clock sync is the well-known NTP method.
These files are therefore licensed under the MPL-2.0.

Check: `git diff --stat 04e0aa10..HEAD`

Note: every build runs `Scripts/Translations/GenerateStrings.swift`, which can slightly reformat
`Translations/en.lproj/Localizable.strings` (upstream behaviour). Do not commit that change (`git checkout Translations/en.lproj`).
