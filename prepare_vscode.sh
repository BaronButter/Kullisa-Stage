#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# Author: VSCODIUM-EXPERT
# Date: 2026-03-27
# Time: 21:05 CET
# Description: Implementierung der dynamischen Namensersetzung (Branding) und Theme-Vorgabe.

# Branding-Ersetzungen im gesamten Quellcode
# Wir führen dies erst am Ende aus, nachdem alle Patches angewendet wurden.
function rebrand() {
  echo "Starte Branding-Prozess: VSCodium -> ${APP_NAME}..."
  # Wir nutzen find mit einem Loop, um die 'replace' Funktion aus utils.sh zu nutzen (sicherer für macOS/Linux)
  # Wir schließen .iss, .wxs, .wxl (Windows MSI/Inno) und .desktop (Linux) mit ein.
  local patterns="*.json *.ts *.js *.nls.json *.iss *.wxs *.wxl *.desktop *.appdata.xml *.spec.template *.yaml"
  
  if is_gnu_sed; then
    find . -type f \( -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.nls.json" -o -name "*.iss" -o -name "*.wxs" -o -name "*.wxl" -o -name "*.desktop" -o -name "*.appdata.xml" -o -name "*.spec.template" -o -name "*.yaml" \) -print0 | xargs -0 -r sed -i "s/VSCodium/${APP_NAME}/g"
    find . -type f \( -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.nls.json" -o -name "*.iss" -o -name "*.wxs" -o -name "*.wxl" -o -name "*.desktop" -o -name "*.appdata.xml" -o -name "*.spec.template" -o -name "*.yaml" \) -print0 | xargs -0 -r sed -i "s/codium/${BINARY_NAME}/g"
  else
    find . -type f \( -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.nls.json" -o -name "*.iss" -o -name "*.wxs" -o -name "*.wxl" -o -name "*.desktop" -o -name "*.appdata.xml" -o -name "*.spec.template" -o -name "*.yaml" \) -print0 | xargs -0 -r sed -i '' "s/VSCodium/${APP_NAME}/g"
    find . -type f \( -name "*.json" -o -name "*.ts" -o -name "*.js" -o -name "*.nls.json" -o -name "*.iss" -o -name "*.wxs" -o -name "*.wxl" -o -name "*.desktop" -o -name "*.appdata.xml" -o -name "*.spec.template" -o -name "*.yaml" \) -print0 | xargs -0 -r sed -i '' "s/codium/${BINARY_NAME}/g"
  fi
}

{ set +x; } 2>/dev/null

# {{{ product.json
cp product.json{,.bak}

setpath() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath_json() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --argjson 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://go.microsoft.com/fwlink/?LinkID=533484#vscode"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item", "latestUrlTemplate": "https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest", "controlUrl": "https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json"}'

setpath "product" "introductoryVideosUrl" "https://go.microsoft.com/fwlink/?linkid=832146"
setpath "product" "keyboardShortcutsUrlLinux" "https://go.microsoft.com/fwlink/?linkid=832144"
setpath "product" "keyboardShortcutsUrlMac" "https://go.microsoft.com/fwlink/?linkid=832143"
setpath "product" "keyboardShortcutsUrlWin" "https://go.microsoft.com/fwlink/?linkid=832145"
setpath "product" "licenseUrl" "https://github.com/${GH_REPO_PATH}/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/${GH_REPO_PATH}/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"

if [[ "${DISABLE_UPDATE}" != "yes" ]]; then
  setpath "product" "updateUrl" "https://raw.githubusercontent.com/${VERSIONS_REPOSITORY}/refs/heads/master"

  setpath "product" "downloadUrl" "https://github.com/${ASSETS_REPOSITORY}/releases"
fi

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "product" "nameShort" "${APP_NAME} - Insiders"
  setpath "product" "nameLong" "${APP_NAME} - Insiders"
  setpath "product" "applicationName" "${BINARY_NAME}-insiders"
  setpath "product" "dataFolderName" ".${BINARY_NAME}-insiders"
  setpath "product" "linuxIconName" "${BINARY_NAME}-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "${BINARY_NAME}-insiders"
  setpath "product" "serverApplicationName" "${BINARY_NAME}-server-insiders"
  setpath "product" "serverDataFolderName" ".${BINARY_NAME}-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.${BINARY_NAME}.${APP_NAME_LC}Insiders"
  setpath "product" "win32AppUserModelId" "${APP_NAME_LC}.${APP_NAME_LC}Insiders"
  setpath "product" "win32DirName" "${APP_NAME} Insiders"
  setpath "product" "win32MutexName" "${BINARY_NAME}insiders"
  setpath "product" "win32NameVersion" "${APP_NAME} Insiders"
  setpath "product" "win32RegValueName" "${APP_NAME_LC}Insiders"
  setpath "product" "win32ShellNameShort" "${APP_NAME} Insiders"
  setpath "product" "win32AppId" "{{EF35BB36-FA7E-4BB9-B7DA-D1E09F2DA9C9}"
  setpath "product" "win32x64AppId" "{{B2E0DDB2-120E-4D34-9F7E-8C688FF839A2}"
  setpath "product" "win32arm64AppId" "{{44721278-64C6-4513-BC45-D48E07830599}"
  setpath "product" "win32UserAppId" "{{ED2E5618-3E7E-4888-BF3C-A6CCC84F586F}"
  setpath "product" "win32x64UserAppId" "{{20F79D0D-A9AC-4220-9A81-CE675FFB6B41}"
  setpath "product" "win32arm64UserAppId" "{{2E362F92-14EA-455A-9ABD-3E656BBBFE71}"
  setpath "product" "tunnelApplicationName" "${BINARY_NAME}-insiders-tunnel"
  setpath "product" "win32TunnelServiceMutex" "${BINARY_NAME}insiders-tunnelservice"
  setpath "product" "win32TunnelMutex" "${BINARY_NAME}insiders-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "90AAD229-85FD-43A3-B82D-8598A88829CF"
  setpath "product" "win32ContextMenu.arm64.clsid" "7544C31C-BDBF-4DDF-B15E-F73A46D6723D"
else
  setpath "product" "nameShort" "${APP_NAME}"
  setpath "product" "nameLong" "${APP_NAME}"
  setpath "product" "applicationName" "${BINARY_NAME}"
  setpath "product" "linuxIconName" "${BINARY_NAME}"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "${BINARY_NAME}"
  setpath "product" "serverApplicationName" "${BINARY_NAME}-server"
  setpath "product" "serverDataFolderName" ".${BINARY_NAME}-server"
  setpath "product" "darwinBundleIdentifier" "com.${BINARY_NAME}"
  setpath "product" "win32AppUserModelId" "${APP_NAME_LC}.${APP_NAME_LC}"
  setpath "product" "win32DirName" "${APP_NAME}"
  setpath "product" "win32MutexName" "${BINARY_NAME}"
  setpath "product" "win32NameVersion" "${APP_NAME}"
  setpath "product" "win32RegValueName" "${APP_NAME_LC}"
  setpath "product" "win32ShellNameShort" "${APP_NAME}"
  setpath "product" "win32AppId" "{{763CBF88-25C6-4B10-952F-326AE657F16B}"
  setpath "product" "win32x64AppId" "{{88DA3577-054F-4CA1-8122-7D820494CFFB}"
  setpath "product" "win32arm64AppId" "{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}"
  setpath "product" "win32UserAppId" "{{0FD05EB4-651E-4E78-A062-515204B47A3A}"
  setpath "product" "win32x64UserAppId" "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}"
  setpath "product" "win32arm64UserAppId" "{{57FD70A5-1B8D-4875-9F40-C5553F094828}"
  setpath "product" "tunnelApplicationName" "${BINARY_NAME}-tunnel"
  setpath "product" "win32TunnelServiceMutex" "${BINARY_NAME}-tunnelservice"
  setpath "product" "win32TunnelMutex" "${BINARY_NAME}-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "D910D5E6-B277-4F4A-BDC5-759A34EEE25D"
  setpath "product" "win32ContextMenu.arm64.clsid" "4852FC55-4A84-4EA1-9C86-D53BE3DF83C0"
  
  # Theme-Vorgabe: Default Light Modern
  setpath_json "product" "configurationDefaults" '{"workbench.colorTheme": "Default Light Modern"}'
fi

echo "Kopiere Kullisa Extensions..."
mkdir -p resources/app/extensions
cp -rp ../extensions/* resources/app/extensions/ 2>/dev/null || true

echo "Initialisiere product.json..."
setpath_json "product" "tunnelApplicationConfig" '{}'

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

echo "Wende Patches an..."
# include common functions
. ../utils.sh

# {{{ apply patches

echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "ASSETS_REPOSITORY=\"${ASSETS_REPOSITORY}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "GLOBAL_DIRNAME=\"${GLOBAL_DIRNAME}\""
echo "ORG_NAME=\"${ORG_NAME}\""
echo "TUNNEL_APP_NAME=\"${TUNNEL_APP_NAME}\""

if [[ "${DISABLE_UPDATE}" == "yes" ]]; then
  mv ../patches/disable-update.patch.yet ../patches/disable-update.patch
fi

for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for file in ../patches/insider/*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

if [[ -d "../patches/${OS_NAME}/" ]]; then
  for file in "../patches/${OS_NAME}/"*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

for file in ../patches/user/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done
# }}}

set -x

# {{{ install dependencies
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

if [[ "${OS_NAME}" == "linux" ]]; then
  export VSCODE_SKIP_NODE_VERSION_CHECK=1

   if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
else
  if [[ "${CI_BUILD}" != "no" ]]; then
    clang++ --version
  fi
fi

node build/npm/preinstall.ts

mv .npmrc .npmrc.bak
cp ../npmrc .npmrc

for i in {1..5}; do # try 5 times
  if [[ "${CI_BUILD}" != "no" && "${OS_NAME}" == "osx" ]]; then
    CXX=clang++ npm install && break
  else
    npm install && break
  fi

  if [[ $i == 5 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."

  sleep $(( 15 * (i + 1)))
done

mv .npmrc.bak .npmrc
# }}}

# package.json
cp package.json{,.bak}

setpath "package" "version" "${RELEASE_VERSION%-insider}"

replace "s|Microsoft Corporation|${APP_NAME}|" package.json
...
replace "s|Microsoft Corporation|${APP_NAME}|" build/lib/electron.ts
replace "s|([0-9]) Microsoft|\\1 ${APP_NAME}|" build/lib/electron.ts
...
  # fix the packages metadata
  # code.appdata.xml
  sed -i "s|Visual Studio Code|${APP_NAME}|g" resources/linux/code.appdata.xml
  sed -i "s|https://code.visualstudio.com/docs/setup/linux|https://github.com/${GH_REPO_PATH}#download-install|" resources/linux/code.appdata.xml
  sed -i "s|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://raw.githubusercontent.com/${GH_REPO_PATH}/master/icons/code.png|" resources/linux/code.appdata.xml
...
  # control.template
  sed -i "s|Microsoft Corporation <vscode-linux@microsoft.com>|${APP_NAME} Team https://github.com/${GH_REPO_PATH}/graphs/contributors|"  resources/linux/debian/control.template
  sed -i "s|Visual Studio Code|${APP_NAME}|g" resources/linux/debian/control.template
  sed -i "s|https://code.visualstudio.com/docs/setup/linux|https://github.com/${GH_REPO_PATH}#download-install|" resources/linux/debian/control.template
...
  # code.spec.template
  sed -i "s|Microsoft Corporation|${APP_NAME} Team|" resources/linux/rpm/code.spec.template
  sed -i "s|Visual Studio Code Team <vscode-linux@microsoft.com>|${APP_NAME} Team https://github.com/${GH_REPO_PATH}/graphs/contributors|" resources/linux/rpm/code.spec.template
  sed -i "s|Visual Studio Code|${APP_NAME}|" resources/linux/rpm/code.spec.template
  sed -i "s|https://code.visualstudio.com/docs/setup/linux|https://github.com/${GH_REPO_PATH}#download-install|" resources/linux/rpm/code.spec.template
...
  # snapcraft.yaml
  sed -i "s|Visual Studio Code|${APP_NAME}|" resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' build/win32/code.iss
  sed -i "s|Microsoft Corporation|${APP_NAME}|" build/win32/code.iss
  # Deaktiviere AppX-Referenzen in code.iss, da wir kein AppX bauen (verursacht Fehler in Inno Setup)
  # Wir löschen alle Zeilen, die "appx" und ".appx" enthalten.
  sed -i '/appx.*\.appx/d' build/win32/code.iss
fi

# announcements
replace "s|\\[\\/\\* BUILTIN_ANNOUNCEMENTS \\*\\/\\]|$( tr -d '\n' < ../announcements-builtin.json )|" src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts

../undo_telemetry.sh

replace 's|Microsoft Corporation|VSCodium|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 VSCodium|' build/lib/electron.ts

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i "s/code-oss/codium-insiders/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
  fi

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://vscodium.com/img/vscodium.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|Microsoft Corporation|VSCodium Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|VSCodium|' build/win32/code.iss
  # Deaktiviere AppX-Referenzen in code.iss, da wir kein AppX bauen (verursacht Fehler in Inno Setup)
  # Wir löschen alle Zeilen, die "appx" und ".appx" enthalten
  sed -i '/appx.*\.appx/d' build/win32/code.iss
fi

rebrand

cd ..
