#!/usr/bin/env bash
# Executa o app com logs verbosos para depurar crashes no iOS/Android.
set -euo pipefail

echo "=== Flutter doctor ==="
flutter doctor -v

echo "=== pub get ==="
flutter pub get

DEVICE="${1:-}"
ARGS=(run --verbose --debug)

if [[ -n "$DEVICE" ]]; then
  ARGS+=(-d "$DEVICE")
fi

echo "=== flutter ${ARGS[*]} ==="
echo "Dica: filtre erros com: flutter logs | grep -E 'FlutterError|PlatformError|EXCEPTION|Fatal'"
flutter "${ARGS[@]}"
