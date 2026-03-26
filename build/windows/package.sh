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

# 2) Bootstrap-Skript ablegen
mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa"
cp ../kullisa/kullisa-first-run.js "../VSCode-win32-${VSCODE_ARCH}/resources/app/kullisa/"

# 3) First-Run Hook in Main-Prozess injizieren
MAIN_OUT="../VSCode-win32-${VSCODE_ARCH}/resources/app/out/main.js"
if [ -f "$MAIN_OUT" ]; then
  printf "\n;try{require('../kullisa/kullisa-first-run.js')}catch(e){}\n" >> "$MAIN_OUT"
  echo "=== Kullisa: First-Run Hook in main.js injiziert ==="
else
  echo "=== Kullisa: WARNUNG: main.js nicht gefunden: $MAIN_OUT ==="
fi

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
