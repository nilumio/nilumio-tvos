# Third-party notices

nilumio for Apple TV is a fork of **Swiftfin** and is distributed under the
[Mozilla Public License 2.0](LICENSE.md). This file lists what nilumio uses from other
projects. Origin and licence of the fork are summarised in [NOTICE.md](NOTICE.md), every
added or changed file is listed in [NILUMIO_CHANGES.md](NILUMIO_CHANGES.md).

## Base project

| Project | Licence | Use in nilumio |
|---|---|---|
| [Swiftfin](https://github.com/jellyfin/Swiftfin) by the Jellyfin community | MPL-2.0 | The whole app. Swiftfin's files keep their licence headers; nilumio's changes to them are also MPL-2.0. Translations come from Jellyfin's [Weblate project](https://translate.jellyfin.org/engage/swiftfin/). |

## Code written for nilumio

The code in `Shared/Nilumio/` was written for nilumio and is licensed under the MPL-2.0.
SyncPlay (`Shared/Nilumio/SyncPlay/`) is implemented from the public Jellyfin API
(`/SyncPlay/*`, `/GetUtcTime`, WebSocket messages `SyncPlayCommand` and
`SyncPlayGroupUpdate`) using jellyfin-sdk-swift (MPL-2.0) and Swiftfin's socket manager.
No code from jellyfin-web (GPL-2.0) or from nilumio's Android app (GPL-2.0) has been copied into this repository.

## Libraries

nilumio adds no libraries of its own. The Swift packages are inherited from Swiftfin and
pinned in `Swiftfin.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
Each package keeps its own licence (see its repository); the most important ones:

| Package | Licence |
|---|---|
| [jellyfin-sdk-swift](https://github.com/jellyfin/jellyfin-sdk-swift) | MPL-2.0 |
| [SwiftVLC](https://github.com/harflabs/SwiftVLC) with libVLC | libVLC: LGPL-2.1 or later; see the package for the wrapper |
| [MPVUI](https://github.com/LePips/MPVUI) with libmpv | libmpv: LGPL-2.1 or later; see the package for the wrapper |
| [Nuke](https://github.com/kean/Nuke), [Get](https://github.com/kean/Get), [Pulse](https://github.com/kean/Pulse) | MIT |
| [Factory](https://github.com/hmlongco/Factory), [Defaults](https://github.com/sindresorhus/Defaults), [CoreStore](https://github.com/JohnEstropia/CoreStore) | MIT |
| [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) | BSD-3-Clause |
| Apple swift-* packages (algorithms, collections, log, nio and others) | Apache-2.0 |

All other packages listed in `Package.resolved`: see their repositories.

## Artwork

| Material | Licence | Where |
|---|---|---|
| nilumio logo, app icon layers, top shelf images, intro video and sound | All rights reserved, made for nilumio, not licensed for use in other apps | `Swiftfin tvOS/Resources/Assets.xcassets/App Icon & Top Shelf Image.brandassets/`, `Shared/Resources/Assets.xcassets/jellyfin-blob-blue.imageset/`, `Swiftfin tvOS/Resources/nilumio-intro.mp4` |
| Other images and icons | as in Swiftfin | inherited from Swiftfin |

## Trademarks

Jellyfin and Swiftfin are names of the Jellyfin project. nilumio is not an official
Jellyfin product and does not use the Jellyfin or Swiftfin logos
(see https://jellyfin.org/docs/general/contributing/branding/).
