#!/usr/bin/env bash
/*
  Author: VSCODIUM-EXPERT
  Date: 2026-03-24
  Time: 15:12 CET
  Description: Lädt 15 Extensions von Open VSX und entpackt sie nach extensions/
*/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
EXTENSIONS_DIR="${ROOT_DIR}/extensions"

echo "=== Kullisa Extensions Downloader ==="
echo "Zielordner: ${EXTENSIONS_DIR}"

# Extensions-Liste erstellen
mkdir -p "${EXTENSIONS_DIR}"

# 15 Extensions für Kullisa Desktop
EXTENSIONS=(
  "saoudrizwan.claude-dev"
  "eamodio.gitlens"
  "alefragnani.project-manager"
  "yzhang.markdown-all-in-one"
  "yzane.markdown-pdf"
  "streetsidesoftware.code-spell-checker"
  "bierner.markdown-mermaid"
  "hediet.vscode-drawio"
  "cweijan.vscode-office"
  "grapecity.gc-excelviewer"
  "kisstkondoros.vscode-gutter-preview"
  "gruntfuggly.todo-tree"
  "humao.rest-client"
  "pkief.material-icon-theme"
  "ms-toolsai.jupyter"
)

# Open VSX API URL
OPEN_VSX_API="https://open-vsx.org/api"

download_extension() {
  local ext="$1"
  local publisher="${ext%.*}"
  local name="${ext#*.}"
  
  echo ""
  echo "Downloading: ${ext}"
  
  # API Response holen
  local api_url="${OPEN_VSX_API}/${publisher}/${name}/latest"
  local response=$(curl -s "${api_url}")
  
  if [ -z "${response}" ] || [ "${response}" = "null" ]; then
    echo "  [FEHLER] Keine Antwort von API für ${ext}"
    return 1
  fi
  
  # Download URL extrahieren
  local download_url=$(echo "${response}" | jq -r '.download')
  local version=$(echo "${response}" | jq -r '.version')
  
  if [ -z "${download_url}" ] || [ "${download_url}" = "null" ]; then
    echo "  [FEHLER] Keine Download-URL für ${ext}"
    return 1
  fi
  
  echo "  Version: ${version}"
  echo "  URL: ${download_url}"
  
  # .vsix herunterladen
  local vsix_file="${EXTENSIONS_DIR}/${ext}-${version}.vsix"
  curl -sL "${download_url}" -o "${vsix_file}"
  
  if [ ! -f "${vsix_file}" ] || [ ! -s "${vsix_file}" ]; then
    echo "  [FEHLER] Download fehlgeschlagen für ${ext}"
    return 1
  fi
  
  # Dateigröße anzeigen
  local size=$(du -h "${vsix_file}" | cut -f1)
  echo "  Größe: ${size}"
  
  # .vsix entpacken (Extension-Ordner erstellen)
  local ext_dir="${EXTENSIONS_DIR}/${ext}"
  rm -rf "${ext_dir}"
  mkdir -p "${ext_dir}"
  
  unzip -q "${vsix_file}" -d "${ext_dir}"
  
  if [ -f "${ext_dir}/package.json" ]; then
    echo "  [ERFOLG] Extension entpackt nach ${ext}/"
  else
    echo "  [FEHLER] Keine package.json gefunden"
    return 1
  fi
  
  # .vsix löschen (nur entpackte Ordner behalten)
  rm -f "${vsix_file}"
  
  return 0
}

# Alle Extensions herunterladen
total=${#EXTENSIONS[@]}
current=0
failed=0

for ext in "${EXTENSIONS[@]}"; do
  current=$((current + 1))
  echo ""
  echo "[${current}/${total}] ${ext}"
  
  if ! download_extension "${ext}"; then
    failed=$((failed + 1))
    echo "  [WARNUNG] ${ext} konnte nicht heruntergeladen werden"
  fi
done

echo ""
echo "=== Download abgeschlossen ==="
echo "Erfolgreich: $((total - failed))/${total}"
echo "Fehlgeschlagen: ${failed}"

if [ ${failed} -gt 0 ]; then
  echo ""
  echo "[WARNUNG] ${failed} Extensions konnten nicht heruntergeladen werden."
  echo "Bitte prüfe die Netzwerkverbindung und die Extension-IDs."
  exit 1
fi

echo ""
echo "Alle Extensions wurden erfolgreich heruntergeladen und entpackt."
echo "Ordner: ${EXTENSIONS_DIR}/"

exit 0
