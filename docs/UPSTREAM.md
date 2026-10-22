# Taking over upstream updates

nilumio for Apple TV follows [Swiftfin](https://github.com/jellyfin/Swiftfin).
Our work lives on the branch `nilumio` (published as `main` on GitHub); Swiftfin is the
remote `upstream`.

## One-time setup

```sh
git remote add upstream https://github.com/jellyfin/Swiftfin.git   # already set in the original checkout
git config remote.upstream.tagOpt --no-tags                        # keep Swiftfin's tags out of our repo
```

## Regular update

```sh
git switch nilumio
git status                      # must be clean
git fetch upstream
git log --oneline nilumio..upstream/main     # what is new upstream
git merge upstream/main         # or a release: git fetch upstream tag v1.7.0 && git merge v1.7.0
```

Use **merge**, not rebase: the branch is public, and a rebase would rewrite published history.
Swiftfin's tagged releases do not always build with the newest Xcode; `main` after a
release is often the better base (see the note in [NOTICE.md](../NOTICE.md)).

## Resolving conflicts

Conflicts should only appear where nilumio touched Swiftfin files. Every such change in
code is marked with `// nilumio`; the full list is in [NILUMIO_CHANGES.md](../NILUMIO_CHANGES.md).

| Area | Files | Keep from nilumio |
|---|---|---|
| App identity | `XcodeConfig/Shared.xcconfig`, `Swiftfin tvOS/Resources/Info.plist` | bundle ID `com.held0.nilumio`, display name |
| Branding | `Shared/Strings/ProperNouns.swift`, `Scripts/Translations/GenerateStrings.swift`, `Shared/Strings/Strings.swift`, `ColorPickerDefaults.swift`, `Color.swift` | the name nilumio and the accent colour |
| Start and about | `Swiftfin tvOS/App/SwiftfinApp.swift`, `Shared/Views/ContentGroupView.swift`, `Shared/Views/AboutAppView.swift`, `Shared/Views/AppSettingsView.swift` | intro hook, origin notice, hidden icon picker |
| Player and SyncPlay | `Shared/Views/VideoPlayer/**`, `PlaybackControls+Scrubbing.swift`, `PlaybackProgress.swift`, `UserSessionManager+SocketCommands.swift`, `MainTabView.swift` | the `// nilumio` lines |
| Artwork | `Assets.xcassets/App Icon & Top Shelf Image.brandassets/**`, `jellyfin-blob-blue.imageset/*` | ours |
| Docs | `README.md` | only the block between the `nilumio:` markers at the top |
| Issue templates | `.github/ISSUE_TEMPLATE/` | ours (upstream templates were removed on purpose) |

Rules of thumb:

- Inside a `// nilumio` line or block keep ours, everywhere else take upstream.
- `Shared/Nilumio/` only exists in nilumio and never conflicts, but may need adapting when upstream changes an API.
- `Swiftfin.xcodeproj/project.pbxproj`: take upstream's version and re-add nilumio's files if Xcode lost them (the project uses synchronised folders for most sources, so this is rarely needed).
- `Shared/Strings/Strings.swift` is generated; resolve the generator first, then build once to regenerate it.
- Do not commit the reformatted `Translations/en.lproj/Localizable.strings` that each build produces (`git checkout Translations/en.lproj`).

## After the merge

```sh
xcodebuild -project Swiftfin.xcodeproj -scheme "Swiftfin tvOS" -configuration Debug \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  -skipMacroValidation -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO build
python3 docs/tools/nilumio_changes.py list    # refresh the table in NILUMIO_CHANGES.md
python3 docs/tools/nilumio_changes.py stats   # refresh the numbers in docs/OWN_CODE.md
git push origin nilumio:main                  # no --tags, no --force
```

Note the new upstream base commit in `NOTICE.md` and `README.md`.

## GitHub Actions

The workflows in `.github/workflows/` (`ci.yml`, `testflight.yml`, `validate-pr.yaml`) are
Swiftfin's and expect Swiftfin's secrets. They are left untouched to keep merges simple;
disable Actions in the repository settings of the nilumio repo.
