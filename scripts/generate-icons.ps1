# =============================================================================
# Kullisa Labs Icon Generator
# =============================================================================
# Author: VSCODIUM-EXPERT
# Date: 2026-03-12
# Time: 19:16 CET
# Description: Konvertiert Quellbild in alle benötigten Icon-Formate
# Requirements: ImageMagick (magick command)
# Usage: .\generate-icons.ps1 -SourceImage "..\logo-source.png"
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceImage,
    
    [string]$OutputDir = "..\icons\generated"
)

# Prüfen ob ImageMagick installiert ist
if (!(Get-Command magick -ErrorAction SilentlyContinue)) {
    Write-Host "Fehler: ImageMagick ist nicht installiert!" -ForegroundColor Red
    Write-Host "Bitte installieren Sie ImageMagick von: https://imagemagick.org/script/download.php#windows"
    exit 1
}

# Ausgabeverzeichnis erstellen
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "Generiere Icons aus: $SourceImage" -ForegroundColor Green

# Windows ICO (mehrere Größen)
Write-Host "Erstelle Windows ICO..." -ForegroundColor Yellow
$icoSizes = @(16, 24, 32, 48, 64, 128, 256)
$icoImages = @()
foreach ($size in $icoSizes) {
    $tempFile = "$OutputDir\temp_$size.png"
    magick convert "$SourceImage" -resize ${size}x${size} -background transparent "$tempFile"
    $icoImages += "$tempFile"
}
magick convert $icoImages "$OutputDir\kullisa.ico"
Remove-Item "$OutputDir\temp_*.png"

# macOS ICNS
Write-Host "Erstelle macOS ICNS..." -ForegroundColor Yellow
$iconsetDir = "$OutputDir\kullisa.iconset"
New-Item -ItemType Directory -Force -Path $iconsetDir | Out-Null
$macSizes = @(16, 32, 64, 128, 256, 512, 1024)
foreach ($size in $macSizes) {
    $doubleSize = $size * 2
    magick convert "$SourceImage" -resize ${size}x${size} -background transparent "$iconsetDir\icon_${size}x${size}.png"
    if ($doubleSize -le 1024) {
        magick convert "$SourceImage" -resize ${doubleSize}x${doubleSize} -background transparent "$iconsetDir\icon_${size}x${size}@2x.png"
    }
}
# Hinweis: iconutil ist nur auf macOS verfügbar
Write-Host "Hinweis: Für ICNS-Erstellung wird macOS benötigt oder ein Online-Konverter" -ForegroundColor Cyan

# Linux PNG
Write-Host "Erstelle Linux PNGs..." -ForegroundColor Yellow
magick convert "$SourceImage" -resize 512x512 -background transparent "$OutputDir\kullisa-512.png"
magick convert "$SourceImage" -resize 256x256 -background transparent "$OutputDir\kullisa-256.png"
magick convert "$SourceImage" -resize 128x128 -background transparent "$OutputDir\kullisa-128.png"

# Linux SVG (Kopie falls Quelle SVG, sonst Hinweis)
if ($SourceImage -match "\.svg$") {
    Copy-Item "$SourceImage" "$OutputDir\kullisa.svg"
} else {
    Write-Host "Hinweis: Für optimale SVG-Unterstützung sollte das Logo als Vektorgrafik vorliegen" -ForegroundColor Cyan
}

# Windows BMP für Installer
Write-Host "Erstelle Windows BMPs..." -ForegroundColor Yellow
$bmpSizes = @(100, 125, 150, 175, 200, 225, 250)
foreach ($size in $bmpSizes) {
    # Big BMP
    magick convert "$SourceImage" -resize ${size}x${size} -background white -gravity center -extent ${size}x${size} "$OutputDir\inno-big-$size.bmp"
    # Small BMP
    $smallSize = [math]::Round($size * 0.4)
    magick convert "$SourceImage" -resize ${smallSize}x${smallSize} -background white -gravity center -extent ${smallSize}x${smallSize} "$OutputDir\inno-small-$([math]::Round($size/2.5)).bmp"
}

# Server Icons
Write-Host "Erstelle Server Icons..." -ForegroundColor Yellow
magick convert "$SourceImage" -resize 192x192 -background transparent "$OutputDir\kullisa-server-192.png"
magick convert "$SourceImage" -resize 512x512 -background transparent "$OutputDir\kullisa-server-512.png"
magick convert "$OutputDir\kullisa.ico" "$OutputDir\favicon.ico"

Write-Host "`nIcon-Generierung abgeschlossen!" -ForegroundColor Green
Write-Host "Ausgabeverzeichnis: $OutputDir" -ForegroundColor Gray
Write-Host "`nErstellte Dateien:" -ForegroundColor Cyan
Get-ChildItem "$OutputDir\*" -Include *.ico,*.png,*.bmp | ForEach-Object {
    Write-Host "  - $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)"
}

Write-Host "`nNächste Schritte:" -ForegroundColor Yellow
Write-Host "1. Kopieren Sie die generierten Icons nach src/stable/resources/" -ForegroundColor White
Write-Host "2. Ersetzen Sie die VSCodium-Icons mit den Kullisa Labs Icons" -ForegroundColor White
Write-Host "3. Führen Sie build_icons.sh aus (falls verfügbar)" -ForegroundColor White
