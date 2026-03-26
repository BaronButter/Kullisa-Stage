<#
  Author: VSCODIUM-EXPERT
  Date: 2026-03-26
  Time: 23:25 CET
  Description: Entfernt automatisch alle lokalen Kullisa- und VSCode-Altartefakte,
               damit eine saubere Neuinstallation/Erststart-Validierung möglich ist.
               Schritte:
               - Prozesse von Kullisa/Code beenden
               - Benutzerprofil von Kullisa Stage löschen (%APPDATA%\Kullisa Stage)
               - Programmordner (UserSetup/SystemSetup) löschen
               - User-Extensions-Ordner (.vscode, .vscode-oss, .vscodium) leeren
#>
param(
  [switch]$WhatIfOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

function Write-Info($msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Ok($msg){ Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Write-Warn($msg){ Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Fail($msg){ Write-Host "[FAIL] $msg" -ForegroundColor Red }

Write-Info 'Beende laufende Kullisa/Code Prozesse…'
$procNames = @('KullisaStage','Kullisa','codium','Code','code','code-oss')
foreach($n in $procNames){
  Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Write-Ok 'Prozesse gestoppt (falls vorhanden)'

# Zielpfade sammeln
$paths = @()
$paths += Join-Path $env:APPDATA 'Kullisa Stage'                       # Benutzerprofil
$paths += Join-Path $env:LOCALAPPDATA 'Programs/Kullisa Stage'         # UserSetup Programmordner
$paths += 'C:\Program Files\Kullisa Stage'                            # SystemSetup Programmordner
$paths += Join-Path $env:USERPROFILE '.vscode/extensions'               # VSCode User-Extensions
$paths += Join-Path $env:USERPROFILE '.vscode-oss/extensions'           # Code - OSS User-Extensions
$paths += Join-Path $env:USERPROFILE '.vscodium/extensions'             # VSCodium User-Extensions

Write-Info 'Lösche Altordner…'
$deleted = @()
$skipped  = @()
foreach($p in $paths){
  if (Test-Path -LiteralPath $p){
    if ($WhatIfOnly){
      Write-Info ("WhatIf: Würde löschen → {0}" -f $p)
    } else {
      try {
        Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction Stop
        Write-Ok ("Gelöscht: {0}" -f $p)
        $deleted += $p
      } catch {
        Write-Warn ("Konnte nicht löschen: {0} → {1}" -f $p, $_.Exception.Message)
        $skipped += $p
      }
    }
  } else {
    Write-Info ("Nicht vorhanden (übersprungen): {0}" -f $p)
  }
}

Write-Host ''
Write-Host 'Zusammenfassung' -ForegroundColor White
Write-Host '==============' -ForegroundColor White
Write-Host ("Gelöscht:   {0}" -f ($deleted.Count)) -ForegroundColor Green
Write-Host ("Überspr.:  {0}" -f ($skipped.Count)) -ForegroundColor Yellow

if (-not $WhatIfOnly) { Write-Ok 'Bereinigung abgeschlossen. Du kannst jetzt UserSetup neu installieren.' } else { Write-Info 'WhatIf‑Durchlauf beendet (nichts gelöscht).' }

exit 0

