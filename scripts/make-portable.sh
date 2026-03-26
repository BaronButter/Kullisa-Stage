#!/usr/bin/env bash
/*
  Author: VSCODIUM-EXPERT
  Date: 2026-03-26
  Time: 23:50 CET
  Description: Erzeugt ein Windows-Portable-ZIP aus einem vorhandenen VSCode-win32-<arch> Ordner.
               - Legt data/ und data/extensions an
               - Kopiert kuratierte Add-ons nach data/extensions (Quelle: resources/app/kullisa-curated oder ./extensions/*)
               - Schreibt data/user/settings.json mit workbench.colorTheme = "Default Light Modern"
               - Packt alles zu assets/KullisaStage-Portable-<arch>-<version>.zip
*/

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="${ROOT_DIR}/assets"
mkdir -p "${ASSETS_DIR}"

if [[ $# -lt 1 ]]; then
  echo "Nutzung: $0 <Pfad zu VSCode-win32-<arch>> [RELEASE_VERSION]"
  echo "Beispiel: $0 ./VSCode-win32-x64 1.112.02043"
  exit 2
fi

IN_DIR="${1%/}"
if [[ ! -d "${IN_DIR}" ]]; then
  echo "Eingabeordner nicht gefunden: ${IN_DIR}" >&2
  exit 2
fi

ARCH="$(basename "${IN_DIR}" | sed -E 's/.*win32-([^-]+).*/\1/')"
RELEASE_VERSION="${2:-dev}"

PORT_DIR="${ROOT_DIR}/KullisaStage-Portable-${ARCH}"
rm -rf "${PORT_DIR}"
cp -a "${IN_DIR}" "${PORT_DIR}"

# Portable-Datenordner
mkdir -p "${PORT_DIR}/data/extensions"
mkdir -p "${PORT_DIR}/data/user"

# Kuratierte Add-ons bevorzugt aus App-Payload kopieren
CURATED_SRC="${PORT_DIR}/resources/app/kullisa-curated"
if [[ -d "${CURATED_SRC}" ]]; then
  cp -a "${CURATED_SRC}/." "${PORT_DIR}/data/extensions/" 2>/dev/null || true
else
  # Fallback: Repo-Ordner ./extensions verwenden, falls vorhanden
  if [[ -d "${ROOT_DIR}/extensions" ]]; then
    cp -a "${ROOT_DIR}/extensions/." "${PORT_DIR}/data/extensions/" 2>/dev/null || true
  fi
fi

# Theme-Default in Portable-User-Settings setzen
SETTINGS_JSON="${PORT_DIR}/data/user/settings.json"
mkdir -p "$(dirname "${SETTINGS_JSON}")"
cat > "${SETTINGS_JSON}" <<'JSON'
{
  "workbench.colorTheme": "Default Light Modern"
}
JSON

# ZIP erzeugen (PowerShell bevorzugt auf Windows, sonst zip)
ZIP_OUT="${ASSETS_DIR}/KullisaStage-Portable-${ARCH}-${RELEASE_VERSION}.zip"
rm -f "${ZIP_OUT}"
if command -v powershell.exe >/dev/null 2>&1; then
  POWERSHELL_CMD="Compress-Archive -Path \"${PORT_DIR}/*\" -DestinationPath \"${ZIP_OUT}\" -Force"
  powershell -NoProfile -Command "${POWERSHELL_CMD}"
elif command -v zip >/dev/null 2>&1; then
  (cd "${PORT_DIR}" && zip -qr "${ZIP_OUT}" .)
else
  echo "Weder powershell noch zip verfügbar – bitte manuell packen: ${PORT_DIR} -> ${ZIP_OUT}" >&2
fi

echo "[ OK ] Portable ZIP erstellt: ${ZIP_OUT}"
echo "Test: ZIP entpacken, EXE im Ordner starten → Tab 'Installiert' zeigt Add-ons, Theme ist hell."

