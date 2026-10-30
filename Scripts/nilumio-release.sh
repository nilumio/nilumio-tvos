#!/usr/bin/env bash
# nilumio: Apple-TV-Build archivieren und zu App Store Connect hochladen.
# Aufruf: Scripts/nilumio-release.sh <Version> <Build>   z. B. Scripts/nilumio-release.sh 1.0.0 3
# Voraussetzung: XcodeConfig/DevelopmentTeam.xcconfig gesetzt, Zertifikat „Apple Distribution“ im Schlüsselbund,
# Profil „nilumio tvOS App Store“ installiert und ~/.appstoreconnect/nilumio.env mit ASC_KEY_ID/ASC_ISSUER_ID
# (API-Schlüssel, Rolle App-Manager, unter ~/.appstoreconnect/private_keys/AuthKey_<ID>.p8).
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION=${1:?Version fehlt}; BUILD=${2:?Build-Nummer fehlt}
TEAM=$(sed -n 's/^DEVELOPMENT_TEAM *= *//p' XcodeConfig/DevelopmentTeam.xcconfig)
OUT=$(mktemp -d)
ARCHIVE=$OUT/nilumio.xcarchive

# Swiftfins alternative Icons zeigen das Jellyfin-Logo und fehlen im Paket → weglassen
xcodebuild -project Swiftfin.xcodeproj -scheme "Swiftfin tvOS" -configuration Release \
  -destination "generic/platform=tvOS" -archivePath "$ARCHIVE" \
  -skipMacroValidation -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO \
  MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD" \
  ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES= ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS=NO archive
git checkout -q Translations/en.lproj 2>/dev/null || true

# Apple nimmt für tvOS kein arm64e an (Libmpv bringt es mit)
for fw in "$ARCHIVE"/Products/Applications/*.app/Frameworks/*.framework; do
  bin="$fw/$(basename "$fw" .framework)"
  if lipo -info "$bin" | grep -q arm64e; then lipo -remove arm64e "$bin" -o "$bin"; fi
done

cat > "$OUT/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>app-store-connect</string>
<key>destination</key><string>upload</string>
<key>teamID</key><string>$TEAM</string>
<key>signingStyle</key><string>manual</string>
<key>signingCertificate</key><string>Apple Distribution</string>
<key>provisioningProfiles</key><dict><key>com.held0.nilumio</key><string>nilumio tvOS App Store</string></dict>
</dict></plist>
PLIST
# shellcheck disable=SC1090
source ~/.appstoreconnect/nilumio.env
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportOptionsPlist "$OUT/ExportOptions.plist" \
  -exportPath "$OUT/export" -authenticationKeyPath ~/.appstoreconnect/private_keys/AuthKey_"$ASC_KEY_ID".p8 \
  -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID"
echo "Hochgeladen: $VERSION ($BUILD)"
