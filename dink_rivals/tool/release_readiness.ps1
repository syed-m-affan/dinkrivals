param(
  [string]$ReleaseApkPath = "build/app/outputs/flutter-apk/app-release.apk",
  [switch]$RequireProductionSecrets,
  [switch]$RequirePhysicalDevice,
  [switch]$RequireReleaseApk,
  [switch]$RequireProductionAdMode,
  [switch]$RunAnalyze,
  [switch]$RunTests,
  [switch]$BuildRelease
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$androidRoot = Join-Path $projectRoot "android"
$repoRoot = Split-Path -Parent $projectRoot
$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
  param(
    [string]$Name,
    [string]$Status,
    [string]$Detail
  )
  $script:checks.Add([pscustomobject]@{
    Name = $Name
    Status = $Status
    Detail = $Detail
  }) | Out-Null
}

function Resolve-Adb {
  $sdkAdb = Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe"
  if (Test-Path $sdkAdb) {
    return $sdkAdb
  }
  return "adb"
}

function Get-PropertyFileValues {
  param([string]$Path)
  $values = @{}
  if (-not (Test-Path $Path)) {
    return $values
  }
  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#") -or -not $line.Contains("=")) {
      return
    }
    $parts = $line.Split("=", 2)
    $values[$parts[0].Trim()] = $parts[1].Trim()
  }
  return $values
}

function Resolve-AndroidRelativePath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $null
  }
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }
  return Join-Path $androidRoot $Path
}

function Resolve-ProjectRelativePath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $null
  }
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }
  return Join-Path $projectRoot $Path
}

function Is-Present {
  param([string]$Value)
  return -not [string]::IsNullOrWhiteSpace($Value)
}

function Is-ProductionAdMobValue {
  param(
    [string]$Value,
    [string]$TestValue
  )
  return (Is-Present $Value) -and $Value.Trim() -ne $TestValue
}

function Invoke-ToolCheck {
  param(
    [string]$Name,
    [string]$Command,
    [string[]]$Arguments
  )
  try {
    & $Command @Arguments
    if ($LASTEXITCODE -eq 0) {
      Add-Check $Name "PASS" "$Command $($Arguments -join ' ')"
    } else {
      Add-Check $Name "FAIL" "Exited with code $LASTEXITCODE."
    }
  } catch {
    Add-Check $Name "FAIL" $_.Exception.Message
  }
}

function Add-DartDefineIfPresent {
  param(
    [System.Collections.Generic.List[string]]$Target,
    [string]$Name,
    [string]$Value
  )
  if (Is-Present $Value) {
    $Target.Add("--dart-define") | Out-Null
    $Target.Add("$Name=$Value") | Out-Null
  }
}

Set-Location $projectRoot

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -eq $flutter) {
  Add-Check "Flutter CLI" "FAIL" "flutter is not on PATH."
} else {
  Add-Check "Flutter CLI" "PASS" $flutter.Source
}

if ($null -ne $flutter -and $RunAnalyze) {
  Invoke-ToolCheck "Flutter analyze" $flutter.Source @("analyze")
}

if ($null -ne $flutter -and $RunTests) {
  Invoke-ToolCheck "Flutter tests" $flutter.Source @("test")
}

if ($null -ne $flutter -and $BuildRelease) {
  $buildArgs = New-Object System.Collections.Generic.List[string]
  $buildArgs.Add("build") | Out-Null
  $buildArgs.Add("apk") | Out-Null
  $buildArgs.Add("--release") | Out-Null
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_USE_ADMOB" $env:DINK_RIVALS_USE_ADMOB
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_SHOW_AD_PLACEHOLDERS" $env:DINK_RIVALS_SHOW_AD_PLACEHOLDERS
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_USE_PRODUCTION_ADMOB_IDS" $env:DINK_RIVALS_USE_PRODUCTION_ADMOB_IDS
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_ADMOB_BANNER_AD_UNIT_ID" $env:DINK_RIVALS_ADMOB_BANNER_AD_UNIT_ID
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_ADMOB_REWARDED_AD_UNIT_ID" $env:DINK_RIVALS_ADMOB_REWARDED_AD_UNIT_ID
  Add-DartDefineIfPresent $buildArgs "DINK_RIVALS_ADMOB_INTERSTITIAL_AD_UNIT_ID" $env:DINK_RIVALS_ADMOB_INTERSTITIAL_AD_UNIT_ID
  Invoke-ToolCheck "Release build" $flutter.Source $buildArgs.ToArray()
}

$releaseApk = Resolve-ProjectRelativePath $ReleaseApkPath
if (Test-Path $releaseApk) {
  Add-Check "Release APK" "PASS" $releaseApk
} elseif ($RequireReleaseApk) {
  Add-Check "Release APK" "FAIL" "Missing release APK at $releaseApk."
} else {
  Add-Check "Release APK" "WARN" "Missing release APK at $releaseApk."
}

$keyPropertiesPath = Join-Path $androidRoot "key.properties"
$keyProperties = Get-PropertyFileValues $keyPropertiesPath
$storeFileValue = if (Is-Present ($keyProperties["storeFile"])) {
  $keyProperties["storeFile"]
} else {
  $env:DINK_RIVALS_UPLOAD_STORE_FILE
}
$storePassword = if (Is-Present ($keyProperties["storePassword"])) {
  $keyProperties["storePassword"]
} else {
  $env:DINK_RIVALS_UPLOAD_STORE_PASSWORD
}
$keyAlias = if (Is-Present ($keyProperties["keyAlias"])) {
  $keyProperties["keyAlias"]
} else {
  $env:DINK_RIVALS_UPLOAD_KEY_ALIAS
}
$keyPassword = if (Is-Present ($keyProperties["keyPassword"])) {
  $keyProperties["keyPassword"]
} else {
  $env:DINK_RIVALS_UPLOAD_KEY_PASSWORD
}
$storeFile = Resolve-AndroidRelativePath $storeFileValue
$hasSigning = (Is-Present $storeFileValue) -and
  (Test-Path $storeFile) -and
  (Is-Present $storePassword) -and
  (Is-Present $keyAlias) -and
  (Is-Present $keyPassword)
if ($hasSigning) {
  Add-Check "Release signing" "PASS" "Upload signing config is complete."
} elseif ($RequireProductionSecrets) {
  Add-Check "Release signing" "FAIL" "Missing key.properties/env signing values or keystore file."
} else {
  Add-Check "Release signing" "WARN" "Missing production signing config; release builds will use debug signing."
}

$applicationId = $env:DINK_RIVALS_APPLICATION_ID
if ((Is-Present $applicationId) -and $applicationId.Trim() -ne "com.example.dink_rivals") {
  Add-Check "Application ID" "PASS" $applicationId.Trim()
} elseif ($RequireProductionSecrets) {
  Add-Check "Application ID" "FAIL" "DINK_RIVALS_APPLICATION_ID is missing or still com.example.dink_rivals."
} else {
  Add-Check "Application ID" "WARN" "Using default QA id com.example.dink_rivals."
}

$testAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
$testBannerId = "ca-app-pub-3940256099942544/6300978111"
$testRewardedId = "ca-app-pub-3940256099942544/5224354917"
$testInterstitialId = "ca-app-pub-3940256099942544/1033173712"
$hasProductionAdMob = (Is-ProductionAdMobValue $env:DINK_RIVALS_ADMOB_APP_ID $testAdMobAppId) -and
  (Is-ProductionAdMobValue $env:DINK_RIVALS_ADMOB_BANNER_AD_UNIT_ID $testBannerId) -and
  (Is-ProductionAdMobValue $env:DINK_RIVALS_ADMOB_REWARDED_AD_UNIT_ID $testRewardedId) -and
  (Is-ProductionAdMobValue $env:DINK_RIVALS_ADMOB_INTERSTITIAL_AD_UNIT_ID $testInterstitialId)
if ($hasProductionAdMob) {
  Add-Check "AdMob IDs" "PASS" "Production-looking app and unit IDs are present."
} elseif ($RequireProductionSecrets) {
  Add-Check "AdMob IDs" "FAIL" "Production AdMob app/unit IDs are missing or still Google test IDs."
} else {
  Add-Check "AdMob IDs" "WARN" "Production AdMob IDs are not present; native test IDs remain the default."
}

$showPlaceholders = if (Is-Present $env:DINK_RIVALS_SHOW_AD_PLACEHOLDERS) {
  $env:DINK_RIVALS_SHOW_AD_PLACEHOLDERS.Trim().ToLowerInvariant()
} else {
  "true"
}
$useAdMob = if (Is-Present $env:DINK_RIVALS_USE_ADMOB) {
  $env:DINK_RIVALS_USE_ADMOB.Trim().ToLowerInvariant()
} else {
  "false"
}
$productionAdModeOk = ($useAdMob -eq "true") -or ($showPlaceholders -eq "false")
if ($productionAdModeOk) {
  Add-Check "Production ad mode" "PASS" "AdMob is enabled or fake placeholders are disabled for this build environment."
} elseif ($RequireProductionAdMode -or $RequireProductionSecrets) {
  Add-Check "Production ad mode" "FAIL" "Set DINK_RIVALS_USE_ADMOB=true or DINK_RIVALS_SHOW_AD_PLACEHOLDERS=false before production release builds."
} else {
  Add-Check "Production ad mode" "WARN" "Current defaults allow fake ad placeholders in non-AdMob builds."
}

$adb = Resolve-Adb
try {
  $deviceLines = & $adb devices -l | Select-Object -Skip 1 |
    Where-Object { $_ -match "\sdevice\s" }
  $physical = $deviceLines | Where-Object {
    $_ -notmatch "^emulator-" -and $_ -notmatch "model:sdk_"
  }
  if ($physical.Count -gt 0) {
    Add-Check "Physical Android device" "PASS" ($physical -join "; ")
  } elseif ($RequirePhysicalDevice) {
    Add-Check "Physical Android device" "FAIL" "No non-emulator Android device is visible to adb."
  } else {
    Add-Check "Physical Android device" "WARN" "No non-emulator Android device is visible to adb."
  }
} catch {
  if ($RequirePhysicalDevice) {
    Add-Check "Physical Android device" "FAIL" "adb check failed: $($_.Exception.Message)"
  } else {
    Add-Check "Physical Android device" "WARN" "adb check failed: $($_.Exception.Message)"
  }
}

$auditPath = Join-Path $repoRoot "docs\release-candidate-audit.md"
if (Test-Path $auditPath) {
  Add-Check "Release audit doc" "PASS" $auditPath
} else {
  Add-Check "Release audit doc" "WARN" "Missing docs/release-candidate-audit.md."
}

foreach ($check in $checks) {
  $prefix = "[{0}]" -f $check.Status
  Write-Host "$prefix $($check.Name): $($check.Detail)"
}

$failures = $checks | Where-Object { $_.Status -eq "FAIL" }
if ($failures.Count -gt 0) {
  exit 1
}
exit 0
