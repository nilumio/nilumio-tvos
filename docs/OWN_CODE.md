# nilumio's own work in this repository

An overview for maintainers: how much of nilumio for Apple TV is Swiftfin and how much
was added or changed by nilumio. Counted with `git diff --numstat` against the upstream
branch point (`git merge-base HEAD upstream/main`), as of 22 October 2026.

## By category

"New own files" are files that do not exist in Swiftfin. "Upstream files touched" are
Swiftfin files that nilumio modified or removed; for those, the added and removed lines are
counted. Binary files (images, video) are counted as files only.

| Category | New own files | Lines in new files | Upstream files touched | Lines added there | Lines removed there |
|---|---:|---:|---:|---:|---:|
| code | 5 | 627 | 16 | 25 | 11 |
| build and configuration | 0 | 0 | 3 | 11 | 2 |
| UI texts and translations | 1 | 28 | 0 | 0 | 0 |
| images and media (5 binary new, 14 binary changed) | 6 | 12 | 16 | 1 | 16 |
| documentation and store texts | 9 | 401 | 4 | 76 | 167 |
| **total** | **21** | **1068** | **39** | **113** | **196** |

## In proportion

- Swiftfin's Swift code for the shared and tvOS targets at the branch point: about **66,800 lines** (`Shared/` and `Swiftfin tvOS/`).
- nilumio added **about 520 lines of Swift** in four new files (`Shared/Nilumio/`: colours, about notice, start-up intro and SyncPlay) and changed **25 lines** (11 removed) in 16 Swiftfin files, each marked with `// nilumio`. That is under 1 % of the code.
- Everything else is artwork (app icon, top shelf, intro video), the British English strings, configuration and this documentation.

## Keeping these numbers current

```sh
python3 docs/tools/nilumio_changes.py stats   # table above
python3 docs/tools/nilumio_changes.py list    # file list for NILUMIO_CHANGES.md
```
