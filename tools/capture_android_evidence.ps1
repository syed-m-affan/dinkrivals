param(
  [string]$DeviceId = "emulator-5554",
  [string]$PackageName = "com.example.dink_rivals",
  [string]$OutputDir = "docs/art/visual-overhaul/evidence/android-capture",
  [switch]$InstallDebugApk
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot "dink_rivals"
$adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"

if (-not (Test-Path $adb)) {
  $adb = "adb"
}

if ($InstallDebugApk) {
  Push-Location $appRoot
  try {
    flutter install -d $DeviceId --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
  } finally {
    Pop-Location
  }
}

$resolvedOutputDir = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

function Invoke-Adb {
  & $adb -s $DeviceId @args
}

function Get-DeviceSize {
  $sizeLine = Invoke-Adb shell wm size | Select-String -Pattern "Physical size:"
  if (-not $sizeLine) {
    throw "Could not read device size from adb shell wm size."
  }
  $parts = ($sizeLine.ToString() -replace ".*Physical size:\s*", "").Split("x")
  return @{
    Width = [int]$parts[0]
    Height = [int]$parts[1]
  }
}

function Tap-Relative([double]$X, [double]$Y) {
  $size = Get-DeviceSize
  $px = [int]($size.Width * $X)
  $py = [int]($size.Height * $Y)
  Invoke-Adb shell input tap $px $py
}

function Capture([string]$Name) {
  $remote = "/sdcard/dink_rivals_$Name.png"
  $local = Join-Path $resolvedOutputDir "$Name.png"
  Invoke-Adb shell screencap -p $remote
  Invoke-Adb pull $remote $local | Out-Null
  Write-Host "Captured $local"
}

Invoke-Adb shell am force-stop $PackageName
Invoke-Adb shell monkey -p $PackageName -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 3
Capture "menu"

Tap-Relative 0.50 0.51
Start-Sleep -Seconds 3
Capture "serve"

Tap-Relative 0.93 0.08
Start-Sleep -Seconds 1
Capture "pause"
