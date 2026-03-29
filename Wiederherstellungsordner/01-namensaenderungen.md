# 01 – Namensänderungen: VSCodium → Kullisa Stage

**Erstellt:** 2026-03-24
**Überarbeitet:** 2026-03-25
**Autor:** VSCODIUM-EXPERT
**Zweck:** Vollständige, risikobewertet dokumentierte Übersicht aller Namensänderungen — was geändert werden soll, wo es liegt, wie riskant die Änderung ist, und was auf keinen Fall angefasst werden darf.

---

## Projektdaten (Kullisa Stage)

| Eigenschaft | Wert |
|-------------|------|
| **Produktname** | Kullisa Stage |
| **Binärname / .exe** | kullisa |
| **Installationsordner** | Kullisa Stage *(nicht abkürzen!)* |
| **Organisation** | KullisaLabs |
| **Website** | https://www.kullisalabs.com |
| **E-Mail** | info@kullisalabs.at |
| **GitHub Repository** | https://github.com/BaronButter/Kullisa-Stage |
| **GitHub Org/Repo-Pfad** | BaronButter/Kullisa-Stage |

---

## Grundprinzip: Was wir ändern — und was nicht

Wir ändern nur das **äußere Erscheinungsbild** (Branding) der Anwendung.  
Den technischen Kern von VSCodium lassen wir unangetastet.

> **Faustregel:**  
> Wenn ein Wert sichtbar für den Nutzer ist (Programmname, Fenstertitel, Installationsordner) → kann geändert werden.  
> Wenn ein Wert intern für den Build-Prozess oder externe Infrastruktur verwendet wird → nicht anfassen ohne genaue Prüfung.

---

## Risikoampel

| Symbol | Bedeutung |
|--------|-----------|
| 🟢 **SICHER** | Kann problemlos geändert werden — kein Risiko |
| 🟡 **VORSICHT** | Kann geändert werden, aber genau testen |
| 🔴 **NICHT ÄNDERN** | Darf nicht geändert werden — würde Build oder Funktion zerstören |

---

## Alle Fundstellen mit Risikowert

### 1. [`utils.sh`](../utils.sh) — Zentrale Build-Variablen

**Was ist das?**  
Diese Datei definiert die Grundvariablen des gesamten Build-Systems. Alle anderen Skripte lesen ihre Werte von hier. Das ist die wichtigste Konfigurationsdatei für das Branding.

**Warum ist sie wichtig?**  
Die Variablen hier sind Fallback-Werte (mit `:-` Syntax). Das bedeutet: Wenn keine Umgebungsvariable gesetzt ist, wird dieser Wert verwendet. Im normalen Build-Prozess werden diese Fallback-Werte aktiv.

| Variable | Aktueller Wert | Soll-Wert | Risiko |
|----------|---------------|-----------|--------|
| `APP_NAME` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER |
| `BINARY_NAME` | `codium` | `kullisa` | 🟡 VORSICHT — bestimmt den Namen der .exe-Datei |
| `ORG_NAME` | `VSCodium` | `KullisaLabs` | 🟢 SICHER |
| `GH_REPO_PATH` | `VSCodium/vscodium` | `KullisaLabs/kullisa-stage` | 🟡 VORSICHT — muss mit dem echten GitHub-Repo übereinstimmen |
| `ASSETS_REPOSITORY` | `VSCodium/vscodium` | `KullisaLabs/kullisa-stage` | 🟡 VORSICHT — muss mit dem echten GitHub-Repo übereinstimmen |

**Datei:** `utils.sh` (Zeilen 3–8)

---

### 2. [`prepare_vscode.sh`](../prepare_vscode.sh) — Build-Konfiguration für product.json

**Was ist das?**  
Dieses Skript läuft während des Build-Prozesses und setzt alle wichtigen Felder in der `product.json` (der "Visitenkarte" des Programms). Es enthält zwei Blöcke: einen für **Stable** und einen für **Insider**.  
Wir arbeiten primär mit dem **Stable**-Block (Zeilen 101–128).

#### Block A: URLs (Zeilen 43–66) — Verweise auf externe Seiten

| Feld | Aktueller Wert | Soll-Wert | Risiko |
|------|---------------|-----------|--------|
| `licenseUrl` | `github.com/VSCodium/vscodium/.../LICENSE` | `github.com/KullisaLabs/kullisa-stage/.../LICENSE` | 🟡 VORSICHT — URL muss existieren |
| `reportIssueUrl` | `github.com/VSCodium/vscodium/issues/new` | `github.com/KullisaLabs/kullisa-stage/issues/new` | 🟡 VORSICHT — URL muss existieren |
| `updateUrl` | `raw.githubusercontent.com/VSCodium/versions/...` | Erst ändern wenn eigener Update-Server steht | 🔴 NICHT ÄNDERN (noch nicht) |
| `downloadUrl` | `github.com/VSCodium/vscodium/releases` | `github.com/KullisaLabs/kullisa-stage/releases` | 🟡 VORSICHT — erst wenn Releases existieren |

> **Wichtiger Hinweis zu `updateUrl` und `downloadUrl`:**  
> Diese URLs dürfen erst geändert werden, wenn das KullisaLabs GitHub-Repository tatsächlich existiert und Releases veröffentlicht hat. Falsche URLs würden dazu führen, dass Updates nicht gefunden werden.

#### Block B: Programm-Identität (Zeilen 101–128) — Was der Nutzer sieht

| Feld | Aktueller Wert | Soll-Wert | Risiko |
|------|---------------|-----------|--------|
| `nameShort` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER — Anzeigename |
| `nameLong` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER — Anzeigename |
| `applicationName` | `codium` | `kullisa` | 🟡 VORSICHT — Name der ausführbaren Datei |
| `dataFolderName` | *(nicht gesetzt, Standard: `.vscode-oss`)* | `.kullisa` | 🟡 VORSICHT — Ordner für Nutzereinstellungen |
| `linuxIconName` | `vscodium` | `kullisa` | 🟢 SICHER — Icon-Dateiname unter Linux |
| `urlProtocol` | `vscodium` | `kullisa` | 🟢 SICHER — `kullisa://`-Links |
| `serverApplicationName` | `codium-server` | `kullisa-server` | 🟡 VORSICHT — Remote-Server-Binärname |
| `serverDataFolderName` | `.vscodium-server` | `.kullisa-server` | 🟡 VORSICHT — Server-Datenpfad |
| `darwinBundleIdentifier` | `com.vscodium` | `com.kullisalabs.kullisastage` | 🟡 VORSICHT — macOS App-Identifier |
| `win32AppUserModelId` | `VSCodium.VSCodium` | `KullisaLabs.KullisaStage` | 🟢 SICHER — Windows Taskleisten-ID |
| `win32DirName` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER — Installations-Ordnername |
| `win32MutexName` | `vscodium` | `kullisa` | 🟡 VORSICHT — verhindert Doppelstart |
| `win32NameVersion` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER — Anzeigename in Windows |
| `win32RegValueName` | `VSCodium` | `KullisaStage` | 🟡 VORSICHT — Windows Registry-Eintrag |
| `win32ShellNameShort` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER — Kontextmenü-Name |
| `win32AppId` | `{763CBF88-25C6-4B10-952F-326AE657F16B}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32x64AppId` | `{88DA3577-054F-4CA1-8122-7D820494CFFB}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32arm64AppId` | `{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32UserAppId` | `{0FD05EB4-651E-4E78-A062-515204B47A3A}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32x64UserAppId` | `{2E1F05D1-C245-4562-81EE-28188DB6FD17}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32arm64UserAppId` | `{57FD70A5-1B8D-4875-9F40-C5553F094828}` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `tunnelApplicationName` | `codium-tunnel` | `kullisa-tunnel` | 🟡 VORSICHT — Remote Tunnel |
| `win32TunnelServiceMutex` | `vscodium-tunnelservice` | `kullisa-tunnelservice` | 🟡 VORSICHT |
| `win32TunnelMutex` | `vscodium-tunnel` | `kullisa-tunnel` | 🟡 VORSICHT |
| `win32ContextMenu.x64.clsid` | `D910D5E6-B277-4F4A-BDC5-759A34EEE25D` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |
| `win32ContextMenu.arm64.clsid` | `4852FC55-4A84-4EA1-9C86-D53BE3DF83C0` | **Neue GUID erforderlich** | 🔴 KRITISCH — Neue GUID generieren! |

> **Warum sind neue GUIDs so wichtig?**  
> Eine GUID (Globally Unique Identifier) ist eine weltweit einzigartige Nummer. Windows verwendet diese, um Programme voneinander zu unterscheiden. Wenn Kullisa Stage die gleichen GUIDs wie VSCodium verwendet, denkt Windows, es sei dasselbe Programm. Das führt zu Konflikten beim Installieren, Deinstallieren und Updaten — und war vermutlich der Grund, warum die App beim letzten Versuch kaputt gegangen ist.  
> **GUIDs können hier kostenlos generiert werden:** https://www.guidgenerator.com/ (jeweils auf "Generate GUID" klicken)

#### Block C: Server-Manifest (Zeilen 241–245)

| Feld | Aktueller Wert | Soll-Wert | Risiko |
|------|---------------|-----------|--------|
| `resources/server/manifest.name` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER |
| `resources/server/manifest.short_name` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER |

#### Block D: `electron.ts` (Zeilen 253–254)

| Was | Aktuell | Soll | Risiko |
|-----|---------|------|--------|
| Hersteller-Name in electron.ts | `Microsoft Corporation → VSCodium` | `Microsoft Corporation → Kullisa Labs` | 🟢 SICHER — nur Anzeige |

---

### 3. [`build/windows/msi/build.sh`](../build/windows/msi/build.sh) — Windows Installer

**Was ist das?**  
Dieses Skript erstellt den Windows-Installationsassistenten (.msi-Datei). Enthält ebenfalls GUIDs die eindeutig sein müssen.

| Variable | Aktueller Wert | Soll-Wert | Risiko |
|----------|---------------|-----------|--------|
| `PRODUCT_NAME` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER |
| `PRODUCT_CODE` | `VSCodium` | `KullisaStage` | 🟡 VORSICHT |
| `PRODUCT_UPGRADE_CODE` | `965370CD-253C-4720-82FC-2E6B02A53808` | **Neue GUID erforderlich** | 🔴 KRITISCH |
| `OUTPUT_BASE_FILENAME` | `VSCodium-${ARCH}-...` | `KullisaStage-${ARCH}-...` | 🟢 SICHER — Dateiname des Installers |
| `-dManufacturerName` | `VSCodium` | `KullisaLabs` | 🟢 SICHER |

---

### 4. [`dev/build.sh`](../dev/build.sh) — Lokales Entwickler-Build-Skript

**Was ist das?**  
Wird nur für lokale Entwicklung verwendet — nicht im offiziellen Build-Prozess auf GitHub Actions.

| Variable | Aktueller Wert | Soll-Wert | Risiko |
|----------|---------------|-----------|--------|
| `APP_NAME` | `VSCodium` | `Kullisa Stage` | 🟢 SICHER |
| `ASSETS_REPOSITORY` | `VSCodium/vscodium` | `KullisaLabs/kullisa-stage` | 🟡 VORSICHT |
| `BINARY_NAME` | `codium` | `kullisa` | 🟡 VORSICHT |
| `GH_REPO_PATH` | `VSCodium/vscodium` | `KullisaLabs/kullisa-stage` | 🟡 VORSICHT |
| `ORG_NAME` | `VSCodium` | `KullisaLabs` | 🟢 SICHER |

---

### 5. 🔴 Diese Stellen NICHT ändern — Technische Infrastruktur

Diese Dateien enthalten "VSCodium" oder "codium" — dürfen aber **nicht** angefasst werden:

| Datei | Inhalt | Warum NICHT ändern |
|-------|--------|-------------------|
| [`build/linux/package_reh.sh`](../build/linux/package_reh.sh) | `vscodium/vscodium-linux-build-agent` | Externe Docker-Images auf Docker Hub — gehören VSCodium, nicht uns |
| [`build/alpine/package_reh.sh`](../build/alpine/package_reh.sh) | `vscodium/vscodium-linux-build-agent` | Externe Docker-Images auf Docker Hub — gehören VSCodium, nicht uns |
| [`dev/update_patches.sh`](../dev/update_patches.sh) | `VSCODIUM HELPER` | Interner Git-Commit-Marker für das Patch-Verwaltungssystem |
| [`dev/patch.sh`](../dev/patch.sh) | `VSCODIUM HELPER` | Interner Git-Commit-Marker für das Patch-Verwaltungssystem |
| [`dev/merge-patches.sh`](../dev/merge-patches.sh) | `VSCODIUM HELPER` | Interner Git-Commit-Marker für das Patch-Verwaltungssystem |

> **Erklärung `VSCODIUM HELPER`:**  
> Das ist ein interner Git-Commit-Name, den das Patch-Verwaltungssystem verwendet, um seine eigenen temporären Commits zu erkennen und wieder zu entfernen. Dieser Name ist fest im Skript-Code verdrahtet. Eine Änderung würde das gesamte Patch-System zerstören — die Patches würden nicht mehr korrekt angewendet werden können.

> **Erklärung externe Docker-Images:**  
> Beim Linux-Build werden Docker-Container von `vscodium/vscodium-linux-build-agent` auf Docker Hub heruntergeladen. Diese Container enthalten die nötige Compiler-Umgebung. Wir haben keinen Zugriff auf diese Images — eine Änderung des Namens würde den Linux-Build vollständig zerstören, da die Images unter dem neuen Namen nicht existieren.

---

## Zusammenfassung: Alle benötigten neuen GUIDs

Vor der Umsetzung müssen **9 neue GUIDs** generiert werden:

| Verwendungszweck | Feld in Datei |
|-----------------|--------------|
| Windows 32-bit Installer | `win32AppId` in `prepare_vscode.sh` |
| Windows 64-bit Installer | `win32x64AppId` in `prepare_vscode.sh` |
| Windows ARM64 Installer | `win32arm64AppId` in `prepare_vscode.sh` |
| Windows 32-bit User-Installer | `win32UserAppId` in `prepare_vscode.sh` |
| Windows 64-bit User-Installer | `win32x64UserAppId` in `prepare_vscode.sh` |
| Windows ARM64 User-Installer | `win32arm64UserAppId` in `prepare_vscode.sh` |
| Windows Kontextmenü 64-bit | `win32ContextMenu.x64.clsid` in `prepare_vscode.sh` |
| Windows Kontextmenü ARM64 | `win32ContextMenu.arm64.clsid` in `prepare_vscode.sh` |
| MSI Upgrade-Code | `PRODUCT_UPGRADE_CODE` in `build/windows/msi/build.sh` |

**→ GUIDs generieren unter:** https://www.guidgenerator.com/

---

## Umsetzungs-Strategie: 2 Iterationen

Da ein Build ca. 1 Stunde dauert, arbeiten wir in zwei Runden.  
Nach Iteration 1 testen wir — erst dann gehen wir an die komplexeren Stellen.

### ✅ Iteration 1 — Nur 🟢 SICHERE Änderungen (umgesetzt 2026-03-25)

Alle risikofreien Anzeigenamen wurden geändert. Diese Änderungen haben keinen Einfluss auf die Funktionalität.

- [x] **utils.sh:** `APP_NAME` → `Kullisa Stage`, `ORG_NAME` → `KullisaLabs`
- [x] **prepare_vscode.sh Stable-Block:** `nameShort`, `nameLong`, `linuxIconName`, `urlProtocol`, `win32AppUserModelId`, `win32DirName`, `win32NameVersion`, `win32ShellNameShort`
- [x] **prepare_vscode.sh Server-Manifest:** `name` → `Kullisa Stage`, `short_name` → `Kullisa Stage`
- [x] **prepare_vscode.sh electron.ts-Block:** `Microsoft Corporation → Kullisa Labs`
- [x] **build/windows/msi/build.sh:** `PRODUCT_NAME` → `Kullisa Stage`, `OUTPUT_BASE_FILENAME`, `-dManufacturerName` → `KullisaLabs`
- [x] **dev/build.sh:** `APP_NAME` → `Kullisa Stage`, `ORG_NAME` → `KullisaLabs`
- [ ] **Test-Build durchführen** — ausstehend

### ⏳ Iteration 2 — 🟡 VORSICHT-Änderungen (nach erfolgreichem Build aus Iteration 1)

**Voraussetzung:** Iteration-1-Build war erfolgreich und alle Tests in der Test-Prüfliste bestanden.  
**Vorarbeit nötig:** 9 neue GUIDs generieren unter https://www.guidgenerator.com/

- [ ] **Vorarbeit:** 9 neue GUIDs generieren und in GUID-Tabelle oben eintragen
- [ ] **utils.sh:** `BINARY_NAME` → `kullisa`, `GH_REPO_PATH` → `BaronButter/Kullisa-Stage`, `ASSETS_REPOSITORY` → `BaronButter/Kullisa-Stage`
- [ ] **prepare_vscode.sh:** `applicationName` → `kullisa`, `dataFolderName` → `.kullisa`, `serverApplicationName` → `kullisa-server`, `serverDataFolderName` → `.kullisa-server`, `darwinBundleIdentifier` → `com.kullisalabs.kullisastage`
- [ ] **prepare_vscode.sh:** `win32MutexName` → `kullisa`, `win32RegValueName` → `KullisaStage`, alle GUIDs ersetzen, `tunnelApplicationName` → `kullisa-tunnel`, `win32TunnelServiceMutex` → `kullisa-tunnelservice`, `win32TunnelMutex` → `kullisa-tunnel`, `win32ContextMenu.*` → neue GUIDs
- [ ] **build/windows/msi/build.sh:** `PRODUCT_CODE` → `KullisaStage`, `PRODUCT_UPGRADE_CODE` → neue GUID
- [ ] **dev/build.sh:** `BINARY_NAME` → `kullisa`, `GH_REPO_PATH` → `BaronButter/Kullisa-Stage`, `ASSETS_REPOSITORY` → `BaronButter/Kullisa-Stage`
- [ ] **prepare_vscode.sh Linux-Abschnitt:** URLs auf KullisaLabs anpassen *(erst wenn GitHub-Releases live)*
- [ ] **prepare_vscode.sh URL-Block:** `licenseUrl`, `reportIssueUrl`, `downloadUrl` → KullisaLabs *(erst wenn GitHub live)*
- [ ] **Test-Build durchführen** — ausstehend

---

## Test-Prüfliste nach der Umsetzung

**Wie prüfen wir, ob alles korrekt ist?**

- [ ] Fenstertitel zeigt "Kullisa Stage"
- [ ] Taskleiste zeigt "Kullisa Stage"
- [ ] Nutzereinstellungen werden im Ordner `.kullisa` gespeichert (nicht `.vscode-oss`)
- [ ] Ausführbare Datei heißt `kullisa.exe` (nicht `codium.exe`)
- [ ] Installationsassistent zeigt "Kullisa Stage" als Produktname
- [ ] Windows Registry enthält Eintrag unter `KullisaStage` (nicht `VSCodium`)
- [ ] Rechtsklick-Kontextmenü zeigt "Mit Kullisa Stage öffnen"
- [ ] Keine Konflikte mit bestehender VSCodium-Installation

---

*[Letzte Aktualisierung: 2026-03-25 | Autor: VSCODIUM-EXPERT]*
