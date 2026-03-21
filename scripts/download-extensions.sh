#!/usr/bin/env bash
# =============================================================================
# Kullisa Stage - Extension Downloader
# =============================================================================
# Description: Lädt 15 Extensions von Open VSX herunter für Vorinstallation
# Usage: ./scripts/download-extensions.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
EXTENSIONS_DIR="${ROOT_DIR}/extensions"

# Extensions-Verzeichnis erstellen
mkdir -p "${EXTENSIONS_DIR}"

# Array mit 15 Extension-IDs von Open VSX
EXTENSIONS=(
  "saoudrizwan.claude-dev"           # Claude Dev - AI
  "eamodio.gitlens"                  # GitLens - Git
  "alefragnani.project-manager"      # Project Manager - Projekt
  "yzhang.markdown-all-in-one"       # Markdown All in One - Markdown
  "yzane.markdown-pdf"               # Markdown PDF - Markdown
  "streetsidesoftware.code-spell-checker" # Code Spell Checker - Text
  "bierner.markdown-mermaid"         # Mermaid Preview - Diagramme
  "hediet.vscode-drawio"             # Draw.io Integration - Diagramme
  "cweijan.vscode-office"            # Office Viewer - Viewer
  "grapecity.gc-excelviewer"         # Excel Viewer - Viewer
  "kisstkondoros.vscode-gutter-preview" # Image Preview - Viewer
  "gruntfuggly.todo-tree"            # Todo Tree - Produktivität
  "humao.rest-client"                # REST Client - API
  "pkief.material-icon-theme"        # Material Icon Theme - UX
  "ms-toolsai.jupyter"               # Jupyter - Notebooks
)

echo "=========================================="
echo "Kullisa Stage - Extensions Downloader"
echo "=========================================="
echo "Zielverzeichnis: ${EXTENSIONS_DIR}"
echo "Anzahl Extensions: ${#EXTENSIONS[@]}"
echo "=========================================="
echo ""

SUCCESS_COUNT=0
FAILED_COUNT=0

for ext in "${EXTENSIONS[@]}"; do
  publisher=$(echo "$ext" | cut -d. -f1)
  name=$(echo "$ext" | cut -d. -f2)
  output_file="${EXTENSIONS_DIR}/${publisher}.${name}.vsix"
  
  echo "[${SUCCESS_COUNT}/${#EXTENSIONS[@]}] Downloading: ${ext}..."
  
  # Open VSX API-Endpunkt für die neueste Version
  download_url="https://open-vsx.org/api/${publisher}/${name}/latest"
  
  if curl -fsSL --retry 3 --retry-delay 2 "${download_url}" -o "${output_file}"; then
    # Prüfen ob die Datei gültig ist (mindestens 1KB)
    # Cross-platform: wc -c funktioniert auf Linux, macOS und Windows (Git Bash)
    file_size=$(wc -c < "${output_file}" 2>/dev/null || echo "0")
    file_size=$(echo "${file_size}" | tr -d ' ')  # Whitespace entfernen
    
    if [[ "${file_size}" -gt 1024 ]]; then
      echo "  ✓ Erfolgreich: ${file_size} Bytes"
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      echo "  ✗ Fehlgeschlagen: Datei zu klein (${file_size} Bytes)"
      rm -f "${output_file}"
      FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
  else
    echo "  ✗ Fehlgeschlagen: Download fehlgeschlagen"
    rm -f "${output_file}"
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
done

echo ""
echo "=========================================="
echo "Download abgeschlossen!"
echo "=========================================="
echo "Erfolgreich: ${SUCCESS_COUNT}/${#EXTENSIONS[@]}"
echo "Fehlgeschlagen: ${FAILED_COUNT}/${#EXTENSIONS[@]}"
echo "=========================================="

if [[ ${FAILED_COUNT} -gt 0 ]]; then
  echo "WARNUNG: ${FAILED_COUNT} Extension(s) konnten nicht heruntergeladen werden!"
  exit 1
fi

exit 0
