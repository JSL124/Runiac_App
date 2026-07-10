#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

flutter pub get

package_manifest="ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"
if [[ -f "$package_manifest" ]]; then
  perl -0pi -e 's/\.iOS\("13\.0"\)/.iOS("15.0")/g' "$package_manifest"
fi

(cd ios && pod install)

flutter run \
  -d "${RUNIAC_QA_DEVICE:-F2239630-B316-4124-B490-3EAE123B0ECF}" \
  --dart-define=RUNIAC_QA_SURFACE=feed_mvp
