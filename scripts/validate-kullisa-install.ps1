<#!
  Author: VSCODIUM-EXPERT
  Date: 2026-03-26
  Time: 22:26 CET
  Description: Validiert eine lokal installierte Kullisa Stage Installation.
               Prüft:
               1) Kuratierte Add-ons aus resources/app/kullisa-curated sind als "Installiert" im Benutzerprofil vorhanden
               2) Theme ist auf "Default Light Modern" (User-Settings)
               Außerdem: Erstlauf-Log und Basisartefakte (kullisa-first-run.js) werden geprüft.
!#>
param(
  [switch]$VerboseLog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg){ Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Ok($msg){ Write-Host "[ OK ] $msg" -ForegroundColor Green }

function Get-InstallRoots() {
  $roots = @()
  $user = Join-Path $env:LOCALAPPDATA 'Programs/Kullisa Stage/resources/app'
  $sys  = 'C:/Program Files/Kullisa Stage/resources/app'
  if (Test-Path $user) { $roots += [pscustomobject]@{ Path=$user; Variant='UserSetup' } }
  if (Test-Path $sys)  { $roots += [pscustomobject]@{ Path=$sys;  Variant='SystemSetup' } }
  if (-not $roots) { Write-Err 'Keine Installation gefunden (weder UserSetup noch SystemSetup)'; }
  return $roots
}

function Read-Json($path){ try { if (Test-Path $path){ (Get-Content -Raw -LiteralPath $path | ConvertFrom-Json) } } catch { $null } }

function Get-UserDataCandidates(){
  $base = $env:APPDATA
  $names = @('Kullisa Stage','VSCodium','Code - OSS','Kullisa','KullisaStage')
  $cands = @()
  foreach($n in $names){
    $p = Join-Path $base $n
    $cands += [pscustomobject]@{ Base=$p; User=Join-Path $p 'User'; Logs=Join-Path $p 'logs' }
  }
  return $cands
}

function Get-UserExtensionsCandidates($userDataBase){
  $home = $env:USERPROFILE
  $cands = @(
    Join-Path $home '.vscode/extensions'),
    (Join-Path $home '.vscode-oss/extensions'),
    (Join-Path $home '.vscodium/extensions')
  if ($userDataBase) { $cands += (Join-Path $userDataBase 'extensions') }
  return ($cands | Select-Object -Unique)
}

function Load-CuratedList($curatedDir){
  $list = @()
  if (-not (Test-Path $curatedDir)) { return $list }
  Get-ChildItem -LiteralPath $curatedDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $pkgPath = Join-Path $_.FullName 'package.json'
    $pkg = Read-Json $pkgPath
    if ($pkg -and $pkg.publisher -and $pkg.name -and $pkg.version) {
      $folderName = "{0}.{1}-{2}" -f $pkg.publisher,$pkg.name,$pkg.version
      $list += [pscustomobject]@{ Publisher=$pkg.publisher; Name=$pkg.name; Version=$pkg.version; Folder=$folderName }
    }
  }
  return $list
}

function Test-ExtensionsInstalled($curated, $extDirs){
  $result = [pscustomobject]@{ Installed=@(); Missing=@(); CheckedDirs=$extDirs }
  foreach($item in $curated){
    $found = $false
    foreach($d in $extDirs){
      $candidate = Join-Path $d $item.Folder
      if (Test-Path $candidate) { $found = $true; break }
    }
    if ($found) { $result.Installed += $item } else { $result.Missing += $item }
  }
  return $result
}

function Get-UserSettings($userDataUserDir){
  $settingsPath = Join-Path $userDataUserDir 'settings.json'
  $settings = Read-Json $settingsPath
  return [pscustomobject]@{ Path=$settingsPath; Data=$settings }
}

function Main(){
  Write-Info 'Starte Validierung Kullisa Stage…'
  $roots = Get-InstallRoots()
  if (-not $roots) { exit 2 }

  $overallPass = $true
  foreach($root in $roots){
    Write-Info ("Prüfe Installation: {0} ({1})" -f $root.Path, $root.Variant)
    $kullisaDir   = Join-Path $root.Path 'kullisa'
    $curatedDir   = Join-Path $root.Path 'kullisa-curated'
    $prodJsonPath = Join-Path $root.Path 'product.json'

    if (Test-Path (Join-Path $kullisaDir 'kullisa-first-run.js')){ Write-Ok 'Bootstrap vorhanden (kullisa-first-run.js)' } else { Write-Warn 'Bootstrap fehlt (kullisa-first-run.js)' }
    if (Test-Path $curatedDir){ Write-Ok 'Curated-Ordner vorhanden' } else { Write-Warn 'Curated-Ordner fehlt' }

    $product = Read-Json $prodJsonPath
    $prodTheme = $product.configurationDefaults.'workbench.colorTheme'
    if ($prodTheme -eq 'Default Light Modern') { Write-Ok 'Produkt-Default Theme: Default Light Modern' } else { Write-Warn ("Produkt-Default Theme nicht gesetzt (gefunden: {0})" -f $prodTheme) }

    $curated = Load-CuratedList $curatedDir
    if ($curated.Count -eq 0) { Write-Warn 'Keine kuratierten Extensions im Installer gefunden' }

    $userData = $null; $userLogs = $null; $userDataUser = $null
    foreach($cand in (Get-UserDataCandidates())){
      if (Test-Path $cand.Base) { $userData = $cand.Base; $userLogs = $cand.Logs; $userDataUser = $cand.User; break }
    }
    if ($userData) { Write-Ok ("UserData-Kandidat: {0}" -f $userData) } else { Write-Warn 'Kein UserData-Kandidat gefunden (verwende nur HOME-basierten Extensions-Pfad)' }

    $extDirs = Get-UserExtensionsCandidates $userData
    $extDirsExisting = @($extDirs | Where-Object { Test-Path $_ })
    if ($extDirsExisting.Count -eq 0) { Write-Warn 'Keine vorhandenen User-Extensions-Verzeichnisse gefunden' } else { if($VerboseLog){ $extDirsExisting | ForEach-Object { Write-Info ("User-Extensions: {0}" -f $_) } } }

    $check = Test-ExtensionsInstalled $curated $extDirsExisting
    $missCount = $check.Missing.Count
    $instCount = $check.Installed.Count
    Write-Info ("Kuratiert: {0}, Installiert: {1}, Fehlend: {2}" -f $curated.Count, $instCount, $missCount)
    if ($missCount -eq 0 -and $curated.Count -gt 0) { Write-Ok 'Alle kuratierten Extensions sind im Benutzerprofil installiert' } else { $overallPass = $false; Write-Err 'Nicht alle kuratierten Extensions wurden gefunden' }

    if ($userDataUser){
      $userSettings = Get-UserSettings $userDataUser
      $theme = $userSettings.Data.'workbench.colorTheme'
      if ($theme -eq 'Default Light Modern') { Write-Ok 'User-Theme: Default Light Modern' } else { $overallPass = $false; Write-Err ("User-Theme nicht gesetzt (gefunden: {0})" -f $theme) }
    } else {
      $overallPass = $false; Write-Err 'Kein User-Settings-Verzeichnis gefunden (UserData/User)'
    }

    if ($userLogs){
      $logPath = Join-Path $userLogs 'kullisa-first-run.log'
      if (Test-Path $logPath) { Write-Ok ("First-Run Log gefunden: {0}" -f $logPath); if($VerboseLog){ Get-Content -LiteralPath $logPath | Select-Object -Last 20 } } else { Write-Warn 'First-Run Log nicht gefunden' }
    }
  }

  if ($overallPass) { Write-Ok 'VALIDIERUNG BESTANDEN'; exit 0 } else { Write-Err 'VALIDIERUNG FEHLGESCHLAGEN'; exit 1 }
}

Main

