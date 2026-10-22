# Contributing to nilumio for Apple TV

Thank you for helping. A few rules keep this fork easy to maintain:

1. **Upstream first.** If a bug or idea also concerns Swiftfin, please report it to [Swiftfin](https://github.com/jellyfin/Swiftfin) first (their guide: [Documentation/contributing.md](Documentation/contributing.md)). Fixes that land there reach nilumio with the next upstream merge.
2. **Small changes.** One topic per pull request, with a short note on what you tested (simulator or device, tvOS version).
3. **Own code separate.** nilumio code lives in `Shared/Nilumio/`. When a Swiftfin file has to change, keep the change small and mark it with `// nilumio`, so upstream merges stay simple (see [docs/UPSTREAM.md](docs/UPSTREAM.md)).
4. **Record changes.** If you add or modify a file, update [NILUMIO_CHANGES.md](NILUMIO_CHANGES.md) (`python3 docs/tools/nilumio_changes.py list` prints the current table). Code from other projects goes into [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) with its licence; only MPL-compatible code can be accepted.
5. **Licence.** By submitting a pull request you agree that your contribution is licensed under the [MPL-2.0](LICENSE.md).
6. **No secrets.** Never commit signing certificates, provisioning profiles, `XcodeConfig/DevelopmentTeam.xcconfig`, personal paths or e-mail addresses.
7. **Texts.** English texts use British spelling (colour, favourite, licence); `Translations/en-GB.lproj` holds the British strings.

Swiftfin's [code of conduct](https://jellyfin.org/docs/general/community-standards/) and the [Jellyfin LLM policy](https://jellyfin.org/docs/general/contributing/llm-policies/) apply here too.
