# Clears stale Flutter Android assets, then runs the app.
# Use this (or the no-spaces junction path) if `flutter run` shows an old build.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$staleDirs = @(
  "build\app\intermediates\flutter",
  "build\app\intermediates\assets",
  ".dart_tool\flutter_build"
)

foreach ($dir in $staleDirs) {
  $path = Join-Path $PSScriptRoot $dir
  if (Test-Path $path) {
    Remove-Item $path -Recurse -Force
    Write-Host "Cleared $dir"
  }
}

fvm flutter run --purge-persistent-cache @args
