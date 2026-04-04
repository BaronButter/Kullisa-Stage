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

# [VSCODIUM-EXPERT] Kullisa: Vorinstallierte Extensions im Portable Data Ordner integrieren
if [ -d "../extensions" ]; then
  echo "=== Kullisa: Erstelle Portable Data Struktur ==="
  mkdir -p "../VSCode-win32-${VSCODE_ARCH}/data/extensions"
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/data/extensions/"
  echo "=== Kullisa: Extensions erfolgreich injiziert ==="
fi

# [KULLISA-STAGE-EXPERT | 2026-04-04 03:45] Kopiere Betriebsanleitung in den Hauptordner
if [ -f "../Betriebsanleitung.txt" ]; then
  cp "../Betriebsanleitung.txt" "../VSCode-win32-${VSCODE_ARCH}/"
  echo "=== Kullisa: Betriebsanleitung injiziert ==="
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
