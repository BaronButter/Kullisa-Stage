# 02 – Vorinstallierte Extensions — Vollständige Analyse

**Erstellt:** 2026-03-24  
**Überarbeitet:** 2026-03-26  
**Autor:** VSCODIUM-EXPERT  
**Status:** ❌ NOCH NICHT KORREKT GELÖST — Vollständige Analyse aller Wege, Fehler und Lösungen

---

## ZUSAMMENFASSUNG

| Was | Status |
|-----|--------|
| Extensions im Repository `extensions/` vorhanden | ✅ 19 Extensions lokal vorhanden |
| Extensions werden beim Build kopiert | ❌ Wahrscheinlich falsche Stelle im Build |
| Extensions im installierten Programm sichtbar | ❌ Erscheinen nicht |

---

## WAS SIND "VORINSTALLIERTE EXTENSIONS"?

### Der Unterschied zwischen zwei Extension-Typen

VSCode/VSCodium unterscheidet zwischen:

**Typ 1: Built-in System-Extensions**
- Liegen unter: `C:\Program Files\Kullisa Stage\resources\app\extensions\`
- Werden mit dem Programm mitgeliefert
- Nicht deinstallierbar, erscheinen als "Built-in"
- Beispiel: `vscode.theme-defaults`, `ms-python.python`, usw.

**Typ 2: User-Extensions** (NICHT was wir wollen)
- Liegen unter: `C:\Users\[Name]\.vscode-oss\extensions\`
- Werden vom Nutzer selbst installiert
- Können deinstalliert werden
- Diese Datei `extensions.json` war leer `[]`

**Was wir wollen:** Unsere 19 Extensions als **Typ 1 (Built-in)** ins Programm einbauen.

---

## DIE 19 EXTENSIONS IM REPOSITORY

Aktuell im Ordner `extensions/` des Repositories:

| Extension-ID | Version | Ordner |
|-------------|---------|--------|
| `alefragnani.project-manager` | 13.0.0 | `alefragnani.project-manager-13.0.0-universal/` |
| `bierner.markdown-mermaid` | 1.32.0 | `bierner.markdown-mermaid-1.32.0-universal/` |
| `cweijan.vscode-office` | 3.5.4 | `cweijan.vscode-office-3.5.4-universal/` |
| `eamodio.gitlens` | 17.11.1 | `eamodio.gitlens-17.11.1-universal/` |
| `grapecity.gc-excelviewer` | 4.2.58 | `grapecity.gc-excelviewer-4.2.58-universal/` |
| `gruntfuggly.todo-tree` | 0.0.215 | `gruntfuggly.todo-tree-0.0.215-universal/` |
| `hediet.vscode-drawio` | 1.6.6 | `hediet.vscode-drawio-1.6.6-universal/` |
| `humao.rest-client` | 0.25.0 | `humao.rest-client-0.25.0-universal/` |
| `kisstkondoros.vscode-gutter-preview` | 0.32.2 | `kisstkondoros.vscode-gutter-preview-0.32.2-universal/` |
| `ms-toolsai.jupyter` | 2025.9.1 | `ms-toolsai.jupyter-2025.9.1-universal/` |
| `ms-toolsai.jupyter-keymap` | 1.1.2 | `ms-toolsai.jupyter-keymap-1.1.2-universal/` |
| `ms-toolsai.jupyter-renderers` | 1.3.0 | `ms-toolsai.jupyter-renderers-1.3.0-universal/` |
| `ms-toolsai.vscode-jupyter-cell-tags` | 0.1.9 | `ms-toolsai.vscode-jupyter-cell-tags-0.1.9-universal/` |
| `ms-toolsai.vscode-jupyter-slideshow` | 0.1.6 | `ms-toolsai.vscode-jupyter-slideshow-0.1.6-universal/` |
| `pkief.material-icon-theme` | 5.32.0 | `pkief.material-icon-theme-5.32.0-universal/` |
| `saoudrizwan.claude-dev` | 3.75.0 | `saoudrizwan.claude-dev-3.75.0-universal/` |
| `streetsidesoftware.code-spell-checker` | 4.5.6 | `streetsidesoftware.code-spell-checker-4.5.6-universal/` |
| `yzane.markdown-pdf` | 1.5.0 | `yzane.markdown-pdf-1.5.0-universal/` |
| `yzhang.markdown-all-in-one` | 3.6.2 | `yzhang.markdown-all-in-one-3.6.2-universal/` |

---

## BUILD-ABLAUF — WO WERDEN EXTENSIONS INTEGRIERT?

### Gesamtablauf (GitHub Actions)

```
JOB 1: compile (läuft auf Windows runner)
  1. get_repo.sh        → Klont VSCode Quellcode nach vscode/
  2. prepare_vscode.sh  → Anpassungen (HIER versuchen wir Extensions zu kopieren)
  3. build.sh           → Kompiliert VSCode mit npm run gulp
  4. vscode.tar.gz      → Archiv des compile-Ergebnisses (NUR bestimmte Dateien!)
  
  Das tar.gz enthält NICHT: resources/app/extensions/ (noch nicht befüllt)

JOB 2: build (läuft auf SEPERATEM Windows runner)
  1. vscode.tar.gz entpacken     → vscode/ Verzeichnis neu erstellt
  2. npm ci auf neuem Runner     → Dependencies neu installiert
  3. npm run gulp vscode-win32-x64-min-ci → ERST HIER entstehen die finalen Ordner
  4. prepare_assets.sh           → Verpackt alles in MSI/EXE
```

### Das Problem

Der Kopier-Befehl in `prepare_vscode.sh`:
```bash
cp -r ../extensions/* resources/app/extensions/ 2>/dev/null || true
```

Läuft in **JOB 1**, also in `prepare_vscode.sh`. Das `vscode/` Verzeichnis existiert noch nicht mit `resources/app/extensions/` — das entsteht erst beim Gulp-Build.

**Mögliche Szenarien:**

**Szenario A: Ordner existiert nicht → cp schlägt fehl → wird durch `|| true` unterdrückt**
```
vscode/resources/app/extensions/ → existiert noch nicht
cp -r ../extensions/* resources/app/extensions/ → FEHLER (still)
2>/dev/null || true → Fehler versteckt, keine Extensions kopiert
```

**Szenario B: Ordner existiert → Extensions werden kopiert → tar.gz enthalten**
Wenn `resources/app/extensions/` schon existiert (aus dem geklonten VSCode-Quellcode):
- Extensions werden kopiert
- Aber: `vscode.tar.gz` wird erstellt mit einer Dateiliste die evtl. nicht alle Files enthält
- Im JOB 2 wird `vscode.tar.gz` entpackt → unsere Extensions sind drin
- Dann läuft `npm run gulp vscode-win32-x64-min-ci` → **Überschreibt extensions?**

---

## ALLE WEGE UM EXTENSIONS EINZUBINDEN

### Weg 1: Aktueller Ansatz — `cp` in `prepare_vscode.sh` Zeile 19-22

**Beschreibung:** Kopiert Extension-Ordner nach `resources/app/extensions/`

**Vorteile:**
- Einfach
- Bereits implementiert

**Nachteile:**
- Läuft VOR dem Gulp-Build → Pfad könnte noch nicht existieren
- `2>/dev/null || true` verschluckt alle Fehler — wir wissen nicht ob es funktioniert hat
- Unklar ob tar.gz die kopierten Dateien enthält

**Risiko:** Hoch — stille Fehler durch `2>/dev/null || true`

**Verbesserung:** Fehler-Ausgabe aktivieren, Kopier-Zeitpunkt prüfen

---

### Weg 2: Kopieren NACH dem Gulp-Build in `build.sh`

**Beschreibung:** Extensions nach dem Gulp-Schritt kopieren, wenn `VSCode-win32-x64/` Ordner bereits existiert

**Wo in `build.sh` (nach Zeile 23, für Windows):**
```bash
# NACH: npm run gulp vscode-win32-${VSCODE_ARCH}-min-ci
# Unsere Extensions in den fertigen Build kopieren
if [ -d "../extensions" ]; then
  echo "Kopiere Extensions in fertigen Build..."
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions/"
fi
```

**Vorteile:**
- Ziel-Ordner existiert zu diesem Zeitpunkt garantiert
- Besser testbar
- Keine stille Fehler

**Nachteile:**
- Muss für jeden OS-Typ (win32, darwin, linux) separat gemacht werden
- Ordner heißt je nach OS anders: `VSCode-win32-x64`, `VSCode-darwin-arm64`, etc.

**Risiko:** Mittel

---

### Weg 3: Extensions im packaging job kopieren (`build/windows/package.sh`)

**Beschreibung:** In `build/windows/package.sh` nach dem Gulp-Schritt kopieren

**Wo:**
```bash
# NACH: npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"
# Extensions kopieren
if [ -d "../extensions" ]; then
  echo "Kopiere vorinstallierte Extensions..."
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions/"
fi
```

**Vorteile:**
- Läuft im packaging-Job → direkt vor dem MSI/EXE erstellen
- Garantiert dass Extensions im endgültigen Installer sind

**Nachteile:**
- Funktioniert nur für Windows
- Linux und macOS müssen separat behandelt werden

**Risiko:** Niedrig für Windows

---

### Weg 4: `product.json` — `additionalBuiltinExtensions` (OFFIZIELL NICHT UNTERSTÜTZT in Build)

**Beschreibung:** VSCode hat intern eine Möglichkeit Extensions als Built-in zu markieren

**Warum das nicht geht:**
VSCode/VSCodium lädt Built-in Extensions aus dem physischen Ordner, nicht aus einer Liste in `product.json`. Das Feld `additionalBuiltinExtensions` existiert nur für Remote-Server und nicht für den Desktop-Build.

**Risiko:** Gelöschte Option, nicht anwendbar

---

### Weg 5: `vscode.tar.gz` Inhaltsliste prüfen (Diagnose-Weg)

**Beschreibung:** Prüfen ob die Extensions überhaupt im Archiv landen

**In `.github/workflows/stable-windows.yml`:**
```yaml
- name: Compress vscode artifact
  run: |
    find vscode -type f -not -path "*/node_modules/*" > vscode.txt
    echo "vscode/.build/extensions/node_modules" >> vscode.txt
    tar -czf vscode.tar.gz -T vscode.txt
```

Die Datei `vscode.txt` wird automatically generiert. Extensions aus `resources/app/extensions/` werden eingeschlossen **wenn sie dort existieren wenn `find` läuft**.

**Diagnose:** Log-Zeile hinzufügen um zu sehen ob Extensions kopiert werden:
```bash
if [ -d "../extensions" ]; then
  echo "=== EXTENSIONS VERFÜGBAR: $(ls ../extensions/ | wc -l) Ordner ==="
  cp -r ../extensions/* resources/app/extensions/ || echo "=== FEHLER beim Kopieren ==="
  echo "=== EXTENSIONS KOPIERT: $(ls resources/app/extensions/ | wc -l) total ==="
fi
```

---

## WARUM DER AKTUELLE CODE WAHRSCHEINLICH NICHT FUNKTIONIERT

### Analyse des `2>/dev/null || true` Problems

Dieser Code:
```bash
cp -r ../extensions/* resources/app/extensions/ 2>/dev/null || true
```

Bedeutet:
- `2>/dev/null` → Alle Fehlermeldungen werden weggeworfen
- `|| true` → Wenn `cp` einen Fehler zurückgibt, wird er ignoriert

**Wenn `resources/app/extensions/` nicht existiert:**
```
cp: cannot stat 'resources/app/extensions/': No such file or directory
→ Fehler wird durch 2>/dev/null unterdrückt
→ || true macht Fehlercode zu 0
→ Script läuft weiter, als wäre nichts passiert
→ Extensions werden NICHT kopiert
→ Keine Fehlermeldung im Build-Log
```

**Deswegen erscheinen keine Extensions und wir sehen keinen Fehler.**

---

## DIAGNOSE: Was muss zuerst geprüft werden

Bevor wir den Code ändern, müssen wir wissen **wann** der Ordner existiert:

1. **Existiert `vscode/resources/app/extensions/` nach `get_repo.sh`?**
   - VSCode-Quellcode enthält diesen Ordner mit Built-in Extensions

2. **Existiert er am Anfang von `prepare_vscode.sh`?**
   - `cd vscode` passiert auf Zeile 14
   - Extensions-Kopie passiert auf Zeile 19
   - Der Ordner sollte existieren (VSCode hat eigene Built-in Extensions drin)

3. **Werden unsere Extensions in das `vscode.tar.gz` gepackt?**
   - Wenn `find vscode -type f` die kopierten Extensions findet → ja
   - Wenn der Ordner bei `find` noch existiert → ja

---

## EMPFOHLENE LÖSUNG: Verbesserte Fehlerbehandlung + Zeitpunkt-Prüfung

### Schritt 1: Diagnostic-Logging hinzufügen

In `prepare_vscode.sh` Zeilen 18-22 ersetzen durch:
```bash
# Extensions vorinstallieren (Kullisa Desktop)
if [ -d "../extensions" ]; then
  echo "=== Kullisa: Kopiere vorinstallierte Extensions ==="
  EXT_TARGET="resources/app/extensions"
  if [ -d "${EXT_TARGET}" ]; then
    cp -r ../extensions/* "${EXT_TARGET}/"
    echo "=== Kullisa: $(ls "${EXT_TARGET}" | wc -l) Extensions im Zielordner ==="
  else
    echo "=== WARNUNG: Zielordner ${EXT_TARGET} existiert nicht! ==="
    echo "=== Build-Pfad: $(pwd) ==="
    echo "=== Verfügbare Ordner: $(ls) ==="
  fi
fi
```

**Ziel:** Fehler sichtbar machen, um zu wissen was wirklich passiert.

### Schritt 2: Extensions-Kopie in `prepare_assets.sh` als Backup

Falls der Ordner in `prepare_vscode.sh` noch nicht existiert, ein zweiter Kopier-Befehl in `prepare_assets.sh` (Windows-Abschnitt) nach Zeile 96:

```bash
# Kullisa: Vorinstallierte Extensions sicherstellen
if [[ -d "../extensions" ]]; then
  echo "Kopiere vorinstallierte Extensions in VSCode-Ordner..."
  mkdir -p "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions"
  cp -r ../extensions/* "../VSCode-win32-${VSCODE_ARCH}/resources/app/extensions/"
  echo "Extensions kopiert: $(ls ../extensions/ | wc -l) Stück"
fi
```

---

## TEST-PROTOKOLL

| Datum | Methode | Ergebnis | Notiz |
|-------|---------|----------|-------|
| 2026-03-24 | `cp` in `prepare_vscode.sh` | ❓ Unbekannt | `2>/dev/null` versteckt alle Fehler |
| 2026-03-26 | Analyse | ❌ Wahrsch. fehlerhaft | `resources/app/extensions/` existiert möglicherweise noch nicht |
| 2026-03-26 | Diagnostic-Logging geplant | ⏳ Ausstehend | Muss implementiert und getestet werden |

---

## NACH DER IMPLEMENTIERUNG: PRÜFEN OB EXTENSIONS DA SIND

Nach Installation von Kullisa Stage:

1. Öffnen: `C:\Program Files\Kullisa Stage\resources\app\extensions\`
2. Prüfen: Sind Ordner wie `saoudrizwan.claude-dev-3.75.0-universal` vorhanden?
3. In Kullisa Stage öffnen: Extensions-Ansicht 
4. Filter `@builtin` eingeben
5. Unsere Extensions sollten als "Built-in" erscheinen

---

*[Letzte Aktualisierung: 2026-03-26 03:15 CET | Autor: VSCODIUM-EXPERT]*  
*[Vollständige Analyse aller Wege dokumentiert]*
<!--
  Author: VSCODIUM-EXPERT
  Date: 2026-03-26
  Time: 15:05 CET
  Description: Iteration 2 – App-First-Run Autoinstaller: Kuratierte Extensions unter "Installiert" (User) bereitstellen
-->

# Iteration 2 – App-First-Run Autoinstaller (Ziel: Installiert-Tab)

Ziel dieser Iteration: Unsere kuratierten Erweiterungen erscheinen nach der Installation beim ersten Start im Tab „Installiert“ (User-Extensions), ohne dass der Benutzer Skripte ausführt oder Internetzugang benötigt.

Kernidee: Statt die Erweiterungen als Built-in in `resources/app/extensions` zu kopieren (führt zu „Eingebaut“), werden die Erweiterungen paketiert in `resources/app/kullisa-curated` abgelegt und beim ersten App-Start automatisch in das Benutzer-Extensionsverzeichnis kopiert.

## Änderungen (Code und Build)

- First-Run Bootstrap (lädt beim App-Start im Main-Prozess):
  - Datei: [kullisa-first-run.js](kullisa/kullisa-first-run.js)
  - Aufgabe: Kopiert alle Extensions aus `resources/app/kullisa-curated` in das User-Extensionsverzeichnis (plattformtypische Pfade werden berücksichtigt) und ist idempotent. Zusätzlich wird das Standard-Theme in den User-Settings gesetzt (Details siehe Theme-Dokument).

- Packaging Hook (Windows):
  - Datei: [package.sh](build/windows/package.sh)
  - Maßnahmen:
    - Kopiert beim Packaging die kuratierten Extensions aus dem Repo-Ordner `extensions/` in `VSCode-win32-<arch>/resources/app/kullisa-curated/`.
    - Legt den Bootstrap unter `VSCode-win32-<arch>/resources/app/kullisa/kullisa-first-run.js` ab.
    - Injiziert am Ende von `resources/app/out/main.js` einen `require('../kullisa/kullisa-first-run.js')`-Hook, damit der Bootstrap beim Start geladen wird.

Wichtig: Es sind keine Benutzeraktionen nötig. Alles ist im Installer enthalten und wird automatisch beim ersten Start ausgeführt.

## Laufzeitverhalten

- Zielverzeichnisse für User-Extensions: Der Bootstrap prüft mehrere Kandidaten (u. a. `%APPDATA%/…/extensions`, `~/.vscode/extensions`, `~/.vscodium/extensions`, Portable-Mode) und installiert dort, sofern noch nicht vorhanden.
- Idempotenz: Existierende `<publisher>.<name>-<version>`-Ordner werden übersprungen. Bei Änderungen wird einmalig ein Neustart ausgelöst, damit die Erweiterungen sofort aktiv sind. Ohne Änderungen erfolgt kein Neustart.
- Logging: Logdatei unter `<userData>/logs/kullisa-first-run.log` (z. B. Windows: `%APPDATA%/Kullisa Stage/logs/kullisa-first-run.log` je nach Datenpfad der Distribution).

## Testplan (Windows)

1. Frische Installation starten (UserSetup oder SystemSetup).
2. Erster Start: Kurz warten (ggf. automatischer Neustart, falls neue Extensions installiert wurden).
3. Extensions-Ansicht öffnen → „Installiert“: Die kuratierte Liste muss sichtbar sein (z. B. GitLens, Draw.io, Todo Tree …).
4. Log prüfen: Datei `kullisa-first-run.log` sollte „Installiere Extension: …“ bzw. „Keine Änderungen erforderlich.“ enthalten.

## Bekannte Stolpersteine

- Unterschiedliche User-Datenpfade (VSCodium/Code-OSS/Kullisa) werden vom Bootstrap abgedeckt, dennoch bitte echte Pfade im Log verifizieren.
- Einige .vsix packen Inhalte in einen Unterordner `extension/`. Unsere kuratierten Pakete im Repo wurden so gewählt, dass `package.json` im Wurzelordner liegt (Kompatibilität geprüft).

## Gründe für diese Lösung

- „Installiert“-Tab erzwingen: Nur Kopie ins Benutzerverzeichnis führt zuverlässig zur Kategorisierung als „Installiert“.
- Offline-fähig: Keine Marktplatzabhängigkeit beim ersten Start.
- Rollback-freundlich: Änderungen beschränken sich auf Installer-Payload und einen minimalen Hook, keine tiefen Quellcode-Patches in VSCode-Kernmodulen.

## Referenzen

- First-Run Bootstrap: [kullisa-first-run.js](kullisa/kullisa-first-run.js)
- Packaging/Hook-Injektion (Windows): [build/windows/package.sh](build/windows/package.sh)
- Kuratierte Quellen (Repo): [extensions/](extensions)

## Commit-Richtlinie

- Empfehlung: `[VSCODIUM-EXPERT] Iteration 2: First-Run Autoinstaller für kuratierte Extensions (Installiert-Tab)`
