param(
  [string]$DeviceId = "",
  [string]$ApkPath = "build/app/outputs/flutter-apk/app-debug.apk",
  [int]$DurationSeconds = 900,
  [switch]$Build,
  [switch]$Offline,
  [switch]$NoInstall
)

$ErrorActionPreference = "Stop"

function Resolve-Adb {
  $sdkAdb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
  if (Test-Path $sdkAdb) {
    return $sdkAdb
  }
  return "adb"
}

function Invoke-Checked {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed ($LASTEXITCODE): $FilePath $($Arguments -join ' ')"
  }
}

function Resolve-DeviceId {
  param([string]$RequestedDeviceId)
  if ($RequestedDeviceId -ne "") {
    return $RequestedDeviceId
  }

  $devices = & $script:adb devices | Select-Object -Skip 1 |
    Where-Object { $_ -match "\tdevice$" } |
    ForEach-Object { ($_ -split "\s+")[0] }
  if ($devices.Count -eq 0) {
    throw "No Android device is visible to adb."
  }
  if ($devices.Count -gt 1) {
    throw "Multiple Android devices are visible. Pass -DeviceId explicitly."
  }
  return $devices[0]
}

function Get-LogcatFailure {
  param([string]$Device)
  $log = & $script:adb -s $Device logcat -d -v brief
  $failure = $log | Select-String -Pattern `
    "FATAL EXCEPTION", `
    "ANR in com.example.dink_rivals", `
    "ActivityManager.*am_crash.*com.example.dink_rivals", `
    "AndroidRuntime.*com.example.dink_rivals" |
    Select-Object -First 1
  return $failure
}

$script:adb = Resolve-Adb
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot
$device = Resolve-DeviceId $DeviceId

Write-Host "Using Android device: $device"
Invoke-Checked $script:adb @("-s", $device, "get-state")

if ($Build) {
  Invoke-Checked "flutter" @("build", "apk", "--debug")
}

if (-not $NoInstall) {
  if (-not (Test-Path $ApkPath)) {
    throw "APK not found: $ApkPath"
  }
  Invoke-Checked "flutter" @(
    "install",
    "-d",
    $device,
    "--use-application-binary=$ApkPath"
  )
}

Invoke-Checked $script:adb @("-s", $device, "logcat", "-c")

$offlineChanged = $false
try {
  if ($Offline) {
    Write-Host "Disabling device network transports for offline QA."
    & $script:adb -s $device shell svc wifi disable | Out-Null
    & $script:adb -s $device shell svc data disable | Out-Null
    $offlineChanged = $true
  }

  Invoke-Checked $script:adb @(
    "-s",
    $device,
    "shell",
    "monkey",
    "-p",
    "com.example.dink_rivals",
    "-c",
    "android.intent.category.LAUNCHER",
    "1"
  )

  $endAt = (Get-Date).AddSeconds($DurationSeconds)
  Write-Host "Monitoring logcat for $DurationSeconds seconds."
  while ((Get-Date) -lt $endAt) {
    Start-Sleep -Seconds 5
    $failure = Get-LogcatFailure $device
    if ($null -ne $failure) {
      throw "QA failure detected: $($failure.Line)"
    }
  }

  Write-Host "Android QA completed without crash or ANR signatures."
} finally {
  if ($offlineChanged) {
    Write-Host "Restoring device network transports."
    & $script:adb -s $device shell svc data enable | Out-Null
    & $script:adb -s $device shell svc wifi enable | Out-Null
  }
}
