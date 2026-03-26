#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

tar -xzf ./vscode.tar.gz

cd vscode || { echo "'vscode' dir not found"; exit 1; }

for i in {1..5}; do # try 5 times
  npm ci && break
  if [[ $i == 5 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

node build/azure-pipelines/distro/mixin-npm.ts

# delete native files built in the `compile` step
find .build/extensions -type f -name '*.node' -print -delete

. ../build/windows/rtf/make.sh

# generate Group Policy definitions
npm run copy-policy-dto --prefix build
node build/lib/policies/policyGenerator.ts build/lib/policies/policyData.jsonc win32

npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

# [VSCODIUM-EXPERT | 2026-03-26 15:58] Iteration 2 – First-Run Autoinstaller
# Ziel: Kuratierte Extensions sollen als "Installiert" (User) erscheinen, nicht als Built-in.
# Maßnahme: Keine Kopie nach resources/app/extensions mehr. Stattdessen:
#  1) Kuratierte Extensions nach resources/app/kullisa-curated legen
#  2) First-Run Bootstrap-Skript nach resources/app/kullisa/
#  3) Hook in out/main.js injizieren, der das Bootstrap lädt

# 1) Kuratierte Extensions vorbereiten
if [ -d "../extensions" ]; then
  echo "=== Kullisa: Kuratierte Extensions für User-Installation vorbereiten ==="
  mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa-curated"
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa-curated/"
  echo "=== Kullisa: $(ls ../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa-curated/ | wc -l) kuratierte Extensions vorbereitet ==="
fi

# Auch wenn keine Extensions mitgeliefert werden: Zielordner immer anlegen
mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa-curated"

# 2) Bootstrap-Skript ablegen
mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa"
cp ../kullisa/kullisa-first-run.js "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa/"

# 3) First-Run Hook robust injizieren (frühester Entry + Fallback)
inject_hook() {
  local target_js="$1"
  local hook_line="$2"
  if [ -f "$target_js" ]; then
    if grep -q "kullisa-first-run.js" "$target_js"; then
      echo "=== Kullisa: Hook bereits vorhanden in $target_js ==="
    else
      echo "=== Kullisa: Injiziere First-Run Hook in $target_js ==="
      local tmp_file="${target_js}.kullisa.tmp"
      printf "\n;%s\n" "$hook_line" > "$tmp_file"
      cat "$target_js" >> "$tmp_file"
      mv "$tmp_file" "$target_js"
    fi
  else
    echo "=== Kullisa: WARNUNG: Zieldatei nicht gefunden: $target_js ==="
  fi
}

# Preferierter Entry: out/vs/code/electron-main/main.js (sehr früh im Main-Prozess)
MAIN_ENTRY_A="../VSCode-win32-${VSCODE_ARCH}/resources/app/out/vs/code/electron-main/main.js"
HOOK_A="try{require('../../../../kullisa/kullisa-first-run.js');if(typeof console!=='undefined'&&console.log){console.log('[KULLISA] First-Run Hook A geladen')}}catch(e){if(typeof console!=='undefined'&&console.error){console.error('[KULLISA] First-Run require A failed',e)}}"
inject_hook "$MAIN_ENTRY_A" "$HOOK_A"

# Fallback: out/main.js (ältere Distro-Einstiegspunkte)
MAIN_ENTRY_B="../VSCode-win32-${VSCODE_ARCH}/resources/app/out/main.js"
HOOK_B="try{require('../kullisa/kullisa-first-run.js');if(typeof console!=='undefined'&&console.log){console.log('[KULLISA] First-Run Hook B geladen')}}catch(e){if(typeof console!=='undefined'&&console.error){console.error('[KULLISA] First-Run require B failed',e)}}"
inject_hook "$MAIN_ENTRY_B" "$HOOK_B"

. ../build_cli.sh

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    echo "Building REH"
    npm run gulp minify-vscode-reh
    npm run gulp "vscode-reh-win32-${VSCODE_ARCH}-min-ci"
  fi

  if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
    echo "Building REH-web"
    npm run gulp minify-vscode-reh-web
    npm run gulp "vscode-reh-web-win32-${VSCODE_ARCH}-min-ci"
  fi
fi

cd ..
