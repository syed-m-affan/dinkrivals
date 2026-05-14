param(
  [string]$DeviceId = "emulator-5554",
  [string]$PackageName = "com.example.dink_rivals",
  [string]$OutputDir = "docs/art/visual-overhaul/evidence/projection-environment-v1-physical",
  [switch]$SkipBuild,
  [int]$SmokeSeconds = 0
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot "dink_rivals"
$adb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"

if (-not (Test-Path $adb)) {
  $adb = "adb"
}

$resolvedOutputDir = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

function Invoke-Adb {
  & $adb -s $DeviceId @args
}

function Build-Apk([string[]]$DartDefines) {
  if ($SkipBuild) {
    return
  }

  Push-Location $appRoot
  try {
    $args = @("build", "apk", "--debug")
    foreach ($define in $DartDefines) {
      $args += "--dart-define=$define"
    }
    & flutter @args
  } finally {
    Pop-Location
  }
}

function Install-Apk {
  Push-Location $appRoot
  try {
    & flutter install -d $DeviceId --use-application-binary="build/app/outputs/flutter-apk/app-debug.apk"
  } finally {
    Pop-Location
  }
}

function Start-App([int]$WaitSeconds = 3) {
  Invoke-Adb shell am force-stop $PackageName | Out-Null
  Invoke-Adb shell monkey -p $PackageName -c android.intent.category.LAUNCHER 1 | Out-Null
  Start-Sleep -Seconds $WaitSeconds
}

function Capture([string]$Name) {
  $remote = "/sdcard/dink_rivals_$Name.png"
  $local = Join-Path $resolvedOutputDir "$Name.png"
  Invoke-Adb shell screencap -p $remote | Out-Null
  Invoke-Adb pull $remote $local | Out-Null
  Write-Host "Captured $local"
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
  Invoke-Adb shell input tap $px $py | Out-Null
}

function Swipe-Relative(
  [double]$StartX,
  [double]$StartY,
  [double]$EndX,
  [double]$EndY,
  [int]$DurationMs = 160
) {
  $size = Get-DeviceSize
  $sx = [int]($size.Width * $StartX)
  $sy = [int]($size.Height * $StartY)
  $ex = [int]($size.Width * $EndX)
  $ey = [int]($size.Height * $EndY)
  Invoke-Adb shell input swipe $sx $sy $ex $ey $DurationMs | Out-Null
}

function Build-Install-Launch([string[]]$DartDefines, [int]$WaitSeconds = 3) {
  Build-Apk $DartDefines
  Install-Apk
  Start-App $WaitSeconds
}

Write-Host "Capturing projection environment V1 evidence on $DeviceId"
Write-Host "Output: $resolvedOutputDir"

Build-Install-Launch @() 3
Capture "menu"

Tap-Relative 0.50 0.51
Start-Sleep -Seconds 3
Capture "serve"
Tap-Relative 0.93 0.08
Start-Sleep -Seconds 1
Capture "pause"

Build-Install-Launch @("DINK_RIVALS_INITIAL_ROUTE=/settings") 3
Capture "settings"

Build-Install-Launch @("DINK_RIVALS_INITIAL_ROUTE=/roster") 3
Capture "roster"

Build-Install-Launch @("DINK_RIVALS_INITIAL_ROUTE=/debug-rally") 3
Capture "debug-rally"
Start-Sleep -Seconds 3
Capture "dink"

Start-App 2
Swipe-Relative 0.50 0.45 0.72 0.45
Start-Sleep -Seconds 1
Capture "drive"

Start-App 2
Swipe-Relative 0.50 0.48 0.50 0.33
Start-Sleep -Seconds 1
Capture "lob"

Start-App 2
Swipe-Relative 0.50 0.38 0.50 0.55
Start-Sleep -Seconds 1
Capture "smash"

if ($SmokeSeconds -gt 0) {
  Start-App 3
  $checkpoints = [Math]::Ceiling($SmokeSeconds / 30)
  for ($i = 1; $i -le $checkpoints; $i++) {
    Start-Sleep -Seconds ([Math]::Min(30, $SmokeSeconds - (($i - 1) * 30)))
    $appPid = Invoke-Adb shell pidof $PackageName
    if (-not $appPid) {
      throw "App process was not alive at smoke checkpoint $i."
    }
    Write-Host "Smoke checkpoint $i pid=$appPid"
  }
  Capture "smoke-5min"
}

Build-Install-Launch @(
  "DINK_RIVALS_INITIAL_ROUTE=/end-match",
  "DINK_RIVALS_QA_END_MATCH=true",
  "DINK_RIVALS_QA_END_MATCH_WINNER=player"
) 3
Capture "end-match-live"

Build-Apk @()
Install-Apk
Start-App 3
Capture "normal-menu-after-qa"

Write-Host "Projection environment V1 evidence capture complete."
