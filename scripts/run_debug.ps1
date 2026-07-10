# Executa o app com logs verbosos para depurar crashes no iOS/Android.
param(
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=== Flutter doctor ===" -ForegroundColor Cyan
flutter doctor -v

Write-Host "=== pub get ===" -ForegroundColor Cyan
flutter pub get

$argsList = @("run", "--verbose", "--debug")
if ($Device -ne "") {
    $argsList += @("-d", $Device)
}

Write-Host "=== flutter $($argsList -join ' ') ===" -ForegroundColor Cyan
Write-Host "Dica: em outro terminal use 'flutter logs' e filtre por FlutterError / PlatformError / EXCEPTION"
flutter @argsList
