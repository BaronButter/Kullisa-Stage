# 00 – Wiederherstellung: Schnellstart nach Projekt-Reset

**Erstellt:** 2026-03-27  
**Autor:** VSCODIUM-EXPERT  
**Zweck:** Wenn der Projektordner gelöscht oder zurückgesetzt wurde, erklärt dieses Dokument Schritt für Schritt wie man in 10 Minuten wieder auf dem letzten guten Stand ist.

---

## WARUM DIESES DOKUMENT EXISTIERT

Der Ordner `Kullisa-Stage-Doc/` ist unser **Sicherheitsanker**. Er ist in der `.gitignore` eingetragen und überlebt jeden Projekt-Reset. Er enthält:
- Alle kuratierten Extensions (Unterordner `extensions/` falls vorhanden)
- Alle angepassten Icons und Wasserzeichen (`icons-wasserzeichen/`)
- Diese Dokumentation

---

## VOR DEM RESET: WAS SICHERN?

Bevor du den Projektordner leerst, kopiere folgende Ordner in `Kullisa-Stage-Doc/`:

| Was sichern | Von (Projektordner) | Nach (Sicherungsordner) |
|-------------|---------------------|------------------------|
| Kuratierte Extensions | `extensions/` | `Kullisa-Stage-Doc/extensions/` |
| Angepasste Icons | `icons/stable/` und `icons/insider/` | `Kullisa-Stage-Doc/icons-stable/` und `icons-insider/` |
| Angepasste Patches | `patches/user/` | `Kullisa-Stage-Doc/patches/user/` |
| Angepasste src-Dateien | `src/stable/` und `src/insider/` | `Kullisa-Stage-Doc/src/` |

**Dann** den Projektordner leeren (außer `Kullisa-Stage-Doc/`).

---

## SCHRITT 1: FRISCHES VSCODIUM HERUNTERLADEN

VSCodium-Quellcode als ZIP herunterladen und entpacken.

**PowerShell-Befehl (in den leeren Projektordner):**
```powershell
Set-Location 'c:/Users/AlexL/Desktop/KullisaLabs/Kullisa-Stage'
Invoke-WebRequest -Uri 'https://github.com/VSCodium/vscodium/archive/refs/heads/master.zip' -OutFile 'vscodium.zip'
Expand-Archive -Path 'vscodium.zip' -DestinationPath '.' -Force
Move-Item -Path 'vscodium-master/*' -Destination '.' -Force
Remove-Item -Path 'vscodium-master' -Recurse -Force
Remove-Item -Path 'vscodium.zip' -Force
```

---

## SCHRITT 2: GITIGNORE PRÜFEN

Sicherstellen dass `Kullisa-Stage-Doc` in der `.gitignore` steht (letzte Zeile):

```
Kullisa-Stage-Doc
```

Falls nicht vorhanden, am Ende der `.gitignore` hinzufügen.

---

## SCHRITT 3: GESICHERTE ORDNER ZURÜCKKOPIEREN

Nach dem Entpacken diese Ordner aus `Kullisa-Stage-Doc/` zurück ins Projekt kopieren:

| Von (Sicherungsordner) | Nach (Projektordner) |
|------------------------|---------------------|
| `Kullisa-Stage-Doc/extensions/` | `extensions/` |
| `Kullisa-Stage-Doc/icons-stable/` | `icons/stable/` (überschreiben) |
| `Kullisa-Stage-Doc/icons-insider/` | `icons/insider/` (überschreiben) |
| `Kullisa-Stage-Doc/patches/user/` | `patches/user/` |
| `Kullisa-Stage-Doc/src/` | `src/` (überschreiben) |

---

## SCHRITT 4: BRANDING-ÄNDERUNGEN ANWENDEN

### 4a. `prepare_vscode.sh` — Stable-Block (Zeilen ~95-122)

Den VSCodium-Block ersetzen durch:

```bash
setpath "product" "nameShort" "Kullisa Stage"
setpath "product" "nameLong" "Kullisa Stage"
setpath "product" "applicationName" "codium"
setpath "product" "linuxIconName" "kullisa"
setpath "product" "quality" "stable"
setpath "product" "urlProtocol" "kullisa"
setpath "product" "serverApplicationName" "codium-server"
setpath "product" "serverDataFolderName" ".vscodium-server"
setpath "product" "darwinBundleIdentifier" "com.vscodium"
setpath "product" "win32AppUserModelId" "KullisaLabs.KullisaStage"
setpath "product" "win32DirName" "Kullisa Stage"
setpath "product" "win32MutexName" "vscodium"
setpath "product" "win32NameVersion" "Kullisa Stage"
setpath "product" "win32RegValueName" "VSCodium"
setpath "product" "win32ShellNameShort" "Kullisa Stage"
setpath "product" "win32AppId" "{{763CBF88-25C6-4B10-952F-326AE657F16B}"
setpath "product" "win32x64AppId" "{{88DA3577-054F-4CA1-8122-7D820494CFFB}"
setpath "product" "win32arm64AppId" "{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}"
setpath "product" "win32UserAppId" "{{0FD05EB4-651E-4E78-A062-515204B47A3A}"
setpath "product" "win32x64UserAppId" "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}"
setpath "product" "win32arm64UserAppId" "{{57FD70A5-1B8D-4875-9F40-C5553F094828}"
setpath "product" "tunnelApplicationName" "codium-tunnel"
setpath "product" "win32TunnelServiceMutex" "vscodium-tunnelservice"
setpath "product" "win32TunnelMutex" "vscodium-tunnel"
setpath "product" "win32ContextMenu.x64.clsid" "D910D5E6-B277-4F4A-BDC5-759A34EEE25D"
setpath "product" "win32ContextMenu.arm64.clsid" "4852FC55-4A84-4EA1-9C86-D53BE3DF83C0"
```

### 4b. `product.json` — Am Ende vor der letzten `}` hinzufügen

```json
"configurationDefaults": {
  "workbench.colorTheme": "Default Light Modern"
}
```

### 4c. `utils.sh` — Zeilen 3-8

```bash
APP_NAME="${APP_NAME:-Kullisa Stage}"
APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"
ASSETS_REPOSITORY="${ASSETS_REPOSITORY:-VSCodium/vscodium}"
BINARY_NAME="${BINARY_NAME:-codium}"
GH_REPO_PATH="${GH_REPO_PATH:-VSCodium/vscodium}"
ORG_NAME="${ORG_NAME:-KullisaLabs}"
```

### 4d. `.github/workflows/stable-windows.yml` — Zeile 28

```yaml
APP_NAME: Kullisa Stage
```

---

## SCHRITT 5: EXTENSIONS ALS BUILT-INS EINBINDEN

In `build/windows/package.sh` nach dem Gulp-Schritt (nach `npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"`) hinzufügen:

```bash
# [VSCODIUM-EXPERT] Kullisa: Extensions als Built-ins einbinden
if [ -d "../extensions" ]; then
  echo "=== Kullisa: Kopiere Extensions als Built-ins ==="
  mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions"
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions/"
  echo "=== Kullisa: $(ls ../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions/ | wc -l) Extensions kopiert ==="
fi
```

---

## SCHRITT 6: EXE-NAMEN ANPASSEN

In `prepare_assets.sh` (Windows-Abschnitt, Zeilen ~126-135):

```bash
# System EXE
mv "vscode\.build\win32-${VSCODE_ARCH}\system-setup\VSCodeSetup.exe" "assets\KullisaStageSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"

# User EXE
mv "vscode\.build\win32-${VSCODE_ARCH}\user-setup\VSCodeSetup.exe" "assets\KullisaStageUserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
```

---

## SCHRITT 7: LIZENZ ANPASSEN

In `LICENSE` (Zeilen 3-5) ersetzen durch:

```
Copyright (c) 2026-present KullisaLabs (https://kullisalabs.com)
Copyright (c) 2015-present Microsoft Corporation
```

---

## SCHRITT 8: BUILD STARTEN

GitHub Actions Workflow `stable-windows` auf Branch `master` auslösen.

---

## ERWARTETES ERGEBNIS NACH DEM BUILD

| Was | Erwartung |
|-----|-----------|
| Installer-Name | `KullisaStageUserSetup-x64-...exe` |
| Installer-Titel | "Setup - Kullisa Stage" |
| Lizenztext | "Copyright (c) 2026-present KullisaLabs" |
| Theme beim Start | "Default Light Modern" (heller Hintergrund) |
| Extensions | Erscheinen unter "Eingebaut" (Built-in) |

---

## BEKANNTE PROBLEME UND LÖSUNGEN

| Problem | Ursache | Lösung |
|---------|---------|--------|
| Theme bleibt dunkel | `configurationDefaults` fehlt in `product.json` | Schritt 4b wiederholen |
| Extensions fehlen | Kopier-Schritt in `build/windows/package.sh` fehlt | Schritt 5 wiederholen |
| EXE heißt noch VSCodiumSetup | `prepare_assets.sh` nicht angepasst | Schritt 6 wiederholen |
| Build schlägt fehl wegen Patch | Patch-Datei korrupt | Alle `.patch`-Dateien in `patches/user/` prüfen |

---

## PROJEKTDATEN

| Eigenschaft | Wert |
|-------------|------|
| Produktname | Kullisa Stage |
| Organisation | KullisaLabs |
| Website | https://kullisalabs.com |
| E-Mail | info@kullisalabs.at |
| GitHub | https://github.com/BaronButter/Kullisa-Stage |

---

*[Erstellt: 2026-03-27 | Autor: VSCODIUM-EXPERT]*
