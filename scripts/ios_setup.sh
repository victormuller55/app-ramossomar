#!/usr/bin/env bash
# Prepara o projeto iOS localmente (Mac) antes do primeiro build.
set -euo pipefail

flutter pub get
cd ios
pod install
cd ..
echo "iOS pronto. Abra ios/Runner.xcworkspace no Xcode ou rode: flutter run -d <iphone>"
