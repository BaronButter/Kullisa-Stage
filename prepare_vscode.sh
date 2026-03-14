#!/usr/bin/env bash
# =============================================================================
# VSCodium Prepare Script
# =============================================================================
# Description: Bereitet VSCode-Quellcode für VSCodium vor
#              Kopiert stabile/insider-Quelldateien und passt product.json an
# Usage: Wird automatisch von build.sh aufgerufen
# Requirements: jq, VSCode-Quelldateien in src/
# =============================================================================
# shellcheck disable=SC1091,2154

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

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
setpath "product" "licenseUrl" "https://github.com/VSCodium/vscodium/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/VSCodium/vscodium/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"

if [[ "${DISABLE_UPDATE}" != "yes" ]]; then
  setpath "product" "updateUrl" "https://raw.githubusercontent.com/VSCodium/versions/refs/heads/master"

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    setpath "product" "downloadUrl" "https://github.com/VSCodium/vscodium-insiders/releases"
  else
    setpath "product" "downloadUrl" "https://github.com/VSCodium/vscodium/releases"
  fi

  # if [[ "${OS_NAME}" == "windows" ]]; then
  #   setpath_json "product" "win32VersionedUpdate" "true"
  # fi
fi

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  # [VSCODIUM-EXPERT | 2026-03-12 19:54] Kullisa Stage Insider Branding
  setpath "product" "nameShort" "Kullisa Stage - Insiders"
  setpath "product" "nameLong" "Kullisa Stage - Insiders"
  setpath "product" "applicationName" "kullisa-insiders"
  setpath "product" "dataFolderName" ".kullisa-insiders"
  setpath "product" "linuxIconName" "kullisa-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "kullisa-insiders"
  setpath "product" "serverApplicationName" "kullisa-server-insiders"
  setpath "product" "serverDataFolderName" ".kullisa-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.kullisa.kullisa-labs-insiders"
  setpath "product" "win32AppUserModelId" "KullisaLabs.KullisaLabsInsiders"
  setpath "product" "win32DirName" "Kullisa Stage Insiders"
  setpath "product" "win32MutexName" "kullisainsiders"
  setpath "product" "win32NameVersion" "Kullisa Stage Insiders"
  setpath "product" "win32RegValueName" "KullisaStageInsiders"
  setpath "product" "win32ShellNameShort" "Kullisa Stage Insiders"
  setpath "product" "win32AppId" "{{1A2B3C4D-5E6F-7890-ABCD-EF1234567890}"
  setpath "product" "win32x64AppId" "{{2B3C4D5E-6F7A-8901-BCDE-F12345678901}"
  setpath "product" "win32arm64AppId" "{{3C4D5E6F-7A8B-9012-CDEF-123456789012}"
  setpath "product" "win32UserAppId" "{{4D5E6F7A-8B9C-0123-DEF1-234567890123}"
  setpath "product" "win32x64UserAppId" "{{5E6F7A8B-9C0D-1234-EF12-345678901234}"
  setpath "product" "win32arm64UserAppId" "{{6F7A8B9C-0D1E-2345-F123-456789012345}"
  setpath "product" "tunnelApplicationName" "kullisa-insiders-tunnel"
  setpath "product" "win32TunnelServiceMutex" "kullisainsiders-tunnelservice"
  setpath "product" "win32TunnelMutex" "kullisainsiders-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "1A2B3C4D-5E6F-7890-ABCD-EF1234567890"
  setpath "product" "win32ContextMenu.arm64.clsid" "2B3C4D5E-6F7A-8901-BCDE-F1234567890"
else
  # [VSCODIUM-EXPERT | 2026-03-12 19:50] Kullisa Stage Stable Branding
  setpath "product" "nameShort" "Kullisa Stage"
  setpath "product" "nameLong" "Kullisa Stage"
  setpath "product" "applicationName" "kullisa"
  setpath "product" "linuxIconName" "kullisa"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "kullisa"
  setpath "product" "serverApplicationName" "kullisa-server"
  setpath "product" "serverDataFolderName" ".kullisa-server"
  setpath "product" "darwinBundleIdentifier" "com.kullisa.kullisa-labs"
  setpath "product" "win32AppUserModelId" "KullisaLabs.KullisaLabs"
  setpath "product" "win32DirName" "Kullisa Stage"
  setpath "product" "win32MutexName" "kullisa"
  setpath "product" "win32NameVersion" "Kullisa Stage"
  setpath "product" "win32RegValueName" "KullisaStage"
  setpath "product" "win32ShellNameShort" "Kullisa Stage"
  setpath "product" "win32AppId" "{{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}"
  setpath "product" "win32x64AppId" "{{B2C3D4E5-F6A7-8901-BCDE-F12345678901}"
  setpath "product" "win32arm64AppId" "{{C3D4E5F6-A7B8-9012-CDEF-123456789012}"
  setpath "product" "win32UserAppId" "{{D4E5F6A7-B8C9-0123-DEF1-234567890123}"
  setpath "product" "win32x64UserAppId" "{{E5F6A7B8-C9D0-1234-EF12-345678901234}"
  setpath "product" "win32arm64UserAppId" "{{F6A7B8C9-D0E1-2345-F123-456789012345}"
  setpath "product" "tunnelApplicationName" "kullisa-tunnel"
  setpath "product" "win32TunnelServiceMutex" "kullisa-tunnelservice"
  setpath "product" "win32TunnelMutex" "kullisa-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
  setpath "product" "win32ContextMenu.arm64.clsid" "B2C3D4E5-F6A7-8901-BCDE-F1234567890"
fi

setpath_json "product" "tunnelApplicationConfig" '{}'

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cat product.json
# }}}

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
    CXX=clang++ npm ci && break
  else
    npm ci && break
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

replace 's|Microsoft Corporation|VSCodium|' package.json

cp resources/server/manifest.json{,.bak}

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "resources/server/manifest" "name" "VSCodium - Insiders"
  setpath "resources/server/manifest" "short_name" "VSCodium - Insiders"
else
  setpath "resources/server/manifest" "name" "VSCodium"
  setpath "resources/server/manifest" "short_name" "VSCodium"
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
fi

cd ..
