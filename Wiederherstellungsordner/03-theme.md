# 03 – Standard-Farbschema: Default Light Modern — Vollständige Analyse

**Erstellt:** 2026-03-24  
**Überarbeitet:** 2026-03-26  
**Autor:** VSCODIUM-EXPERT  
**Status:** ❌ NOCH NICHT GELÖST — Alle bisherigen Versuche dokumentiert, Lösung identifiziert

---

## ZUSAMMENFASSUNG: Was funktioniert, was nicht

| Was | Status | Wo |
|-----|--------|-----|
| Installer zeigt "Setup - Kullisa Stage" | ✅ | `prepare_vscode.sh` Namensänderungen |
| Theme beim Start: Dark Modern | ❌ | Alle bisherigen Versuche gescheitert |
| Extensions vorinstalliert | ❌ | Separate Analyse in `02-extensions.md` |

---

## WAS IST EIN FARBSCHEMA UND WO WIRD ES GESETZT?

### Das Farbschema-System in VSCode/VSCodium

VSCode verwendet drei verschiedene Orte um ein Standard-Farbschema zu setzen. **Die Reihenfolge bestimmt wer "gewinnt":**

```
Priorität (höchste zuerst):
1. Benutzereinstellungen        → %APPDATA%\Kullisa\User\settings.json
2. product.json configurationDefaults → In unserem Repo-Root: product.json
3. Extension configurationDefaults   → In: vscode/extensions/theme-defaults/package.json
```

**Wer zuerst setzt, gewinnt NICHT — wer am höchsten in der Priorität steht, gewinnt.**

Die `vscode.theme-defaults` Extension (Priorität 3, niedrigste) setzt standardmäßig:
```json
"workbench.colorTheme": "Default Dark Modern"
```

Wir wollen das auf "Default Light Modern" ändern.

---

## DIE EXTENSION: vscode.theme-defaults

### Was ist sie?

| Eigenschaft | Wert |
|-------------|------|
| Name in UI | Default Themes |
| Identifier | `vscode.theme-defaults` |
| Typ | Built-in (fest eingebaut, kann nicht deinstalliert werden) |
| Sichtbar unter | Extensions → `@id:vscode.theme-defaults` |
| Zweck | Stellt alle Standard-Farbschemas bereit |

### Wo liegt sie im VSCode-Quellcode?

```
GitHub: https://github.com/microsoft/vscode/tree/main/extensions/theme-defaults/
```

Während des Builds (nach `get_repo.sh`):
```
vscode/
└── extensions/
    └── theme-defaults/
        ├── package.json          ← HIER steht der Standard-Theme-Wert
        ├── themes/
        │   ├── light_modern.json
        │   ├── dark_modern.json
        │   ├── hc_black.json
        │   └── hc_light.json
        └── ...
```

### Der relevante Abschnitt in ihrer package.json

```json
"contributes": {
  "configurationDefaults": {
    "workbench.colorTheme": "Default Dark Modern",
    "workbench.preferredDarkColorTheme": "Default Dark Modern",
    "workbench.preferredLightColorTheme": "Default Light Modern",
    "workbench.preferredHighContrastColorTheme": "Default High Contrast",
    "workbench.preferredHighContrastLightColorTheme": "Default High Contrast Light"
  }
}
```

**Die erste Zeile** ist der Standard-Theme-Wert denn wir ändern wollen.

### Wo liegt sie nach der Installation?

```
C:\Program Files\Kullisa Stage\
└── resources\
    └── app\
        └── extensions\
            └── theme-defaults\     ← Fertig kompiliert
                ├── package.json    ← Diese Datei enthält den Standard-Theme-Wert
                └── themes\
```

---

## BUILD-REIHENFOLGE — Warum bisherige Versuche scheiterten

```
build.sh ruft prepare_vscode.sh auf, dann:

SCHRITT 1: prepare_vscode.sh läuft
  └── Extensions kopieren (Zeile 19)
  └── product.json anpassen (Zeile 24-137)
  └── [unser jq-Block ändert extensions/theme-defaults/package.json]  ← HIER
  └── utils.sh einbinden
  └── Patches anwenden

SCHRITT 2: build.sh kompiliert VSCode
  └── npm run gulp compile-extensions-build  ← ÜBERSCHREIBT theme-defaults/package.json!
  └── npm run gulp minify-vscode
```

**Das Problem:** Gulp kompiliert `theme-defaults` neu aus dem Original-Quellcode. Unsere Änderung aus Schritt 1 wird überschrieben.

---

## ALLE BISHERIGEN VERSUCHE — Was wir probiert haben

### Versuch 1: Patch-Datei (2026-03-25)

**Was wir gemacht haben:**
Datei `patches/user/theme-defaults-light-modern.patch` erstellt.

**Fehler 1:** `/* */` Kommentar am Anfang der Patch-Datei → `error: corrupt patch at line 22`  
**Fehler 2:** Fehlende `index`-Zeile (Git-Hash) → `error: corrupt patch at line 11`  
**Grundproblem:** Selbst ein korrekter Patch würde nicht funktionieren, weil:
- Der Patch wird VOR dem Gulp-Build angewendet
- Gulp kompiliert theme-defaults neu → Patch-Änderung wird überschrieben

**Status:** Patch-Datei gelöscht. Dieser Weg funktioniert nicht.

---

### Versuch 2: `jq`-Block in `prepare_vscode.sh` (2026-03-25)

**Was wir gemacht haben:**
```bash
THEME_DEFAULTS_PKG="extensions/theme-defaults/package.json"
if [[ -f "${THEME_DEFAULTS_PKG}" ]]; then
  jsonTmp=$( jq --arg v "Default Light Modern" '.configurationDefaults["workbench.colorTheme"]=$v' "${THEME_DEFAULTS_PKG}" )
  echo "${jsonTmp}" > "${THEME_DEFAULTS_PKG}"
fi
```

**Warum es nicht funktioniert:**  
Dieser Block läuft in Zeile 139-151 von `prepare_vscode.sh`, also VOR dem Gulp-Compile-Schritt in `build.sh`. Gulp überschreibt die Datei. Das Theme bleibt dunkel.

**Status:** Code noch in `prepare_vscode.sh`, aber wirkungslos für das Theme. Sollte entfernt werden.

---

### Versuch 3: Geplant aber noch nicht umgesetzt — `product.json` configurationDefaults

**Was geplant ist:**
In unserer [`product.json`](../product.json) (im Repo-Root) hinzufügen:
```json
"configurationDefaults": {
  "workbench.colorTheme": "Default Light Modern"
}
```

**Warum das funktionieren würde:**
- In `prepare_vscode.sh` Zeile 133: `jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )`
- Unsere `product.json` wird mit der VSCode-`product.json` zusammengeführt
- Werte aus UNSERER Datei überschreiben VSCode-Werte
- Dieser Wert hat **Priorität 2** — höher als Extension-Defaults (Priorität 3)
- Gulp kann das nicht überschreiben — es ist in der kompilierten `product.json`

**Status:** NOCH NICHT UMGESETZT — Das ist die finale Lösung.

---

## LÖSUNG A: Richtige Methode — `product.json` (Priorität 2)

### Was zu tun ist

In [`product.json`](../product.json) (im Repo-Root) diesen Abschnitt am Ende des JSON-Objekts vor der letzten `}` hinzufügen:

```json
"configurationDefaults": {
  "workbench.colorTheme": "Default Light Modern"
}
```

### Warum das der richtige Weg ist

```
product.json Merge-Ablauf in prepare_vscode.sh:

Unsere ../product.json    +    VSCode's product.json
        │                           │
        └──────── jq -s merge ──────┘
                      │
              Fertige product.json
              (unsere Werte gewinnen bei Konflikten)
                      │
              In VSCode kompiliert
                      │
        configurationDefaults.workbench.colorTheme
                = "Default Light Modern"        ← NICHT mehr überschreibbar
```

### Was nach dieser Änderung noch zu tun ist

1. Den `jq`-Block aus `prepare_vscode.sh` (Zeilen 139-151) entfernen — er ist jetzt überflüssig
2. Build testen
3. Prüfen: Im Log erscheint nichts mehr über Theme — es wird direkt über `product.json` gesetzt

---

## LÖSUNG B (Backup): post-Gulp Änderung in `build.sh`

Falls Lösung A nicht funktioniert (z.B. product.json configurationDefaults werden von VSCode ignoriert):

**Ort in `build.sh` nach Zeile 23:**
```bash
# NACH: npm run gulp minify-vscode
# VOR: Packaging

# Theme: Default Light Modern (nach Gulp-Kompilierung gesetzt)
sed -i 's/"workbench.colorTheme": "Default Dark Modern"/"workbench.colorTheme": "Default Light Modern"/g' \
  .build/extensions/theme-defaults/package.json
```

**Vorteil:** Passiert NACH Gulp → kann nicht mehr überschrieben werden  
**Nachteil:** Fragiler `sed`-Befehl

---

## LÖSUNG C (Hack, letzter Ausweg): Direkte Änderung der installierten Extension

Falls alle anderen Wege scheitern, kann die Extension in der installierten Anwendung direkt bearbeitet werden:

**Pfad nach Installation:**
```
C:\Program Files\Kullisa Stage\resources\app\extensions\theme-defaults\package.json
```

**Zeile ändern:**
```json
"workbench.colorTheme": "Default Dark Modern"
→
"workbench.colorTheme": "Default Light Modern"
```

**Nachteil:** Muss nach jedem Update wiederholt werden. Kein nachhaltiger Weg.

---

## EMPFEHLUNG: Lösungsreihenfolge

```
1. ZUERST: Lösung A (product.json configurationDefaults)   ← Sauber, offiziell
2. FALLS A nicht wirkt: Lösung B (post-Gulp in build.sh)   ← Technisch, aber stabil
3. NUR ALS LETZTER AUSWEG: Lösung C (direkte Datei)        ← Nicht nachhaltig
```

---

## TEST-PROTOKOLL

| Datum | Methode | Ergebnis | Notiz |
|-------|---------|----------|-------|
| 2026-03-25 | Patch-Datei | ❌ Fehlgeschlagen | corrupt patch Fehler |
| 2026-03-25 | jq-Block in prepare_vscode.sh | ❌ Fehlgeschlagen | Gulp überschreibt die Änderung |
| 2026-03-26 | product.json configurationDefaults | ⏳ Ausstehend | Noch nicht getestet |

---

## PRÜFEN OB ES FUNKTIONIERT

Nach dem Build und der Installation:

1. Kullisa Stage starten (frische Installation, kein bestehendes `settings.json`)
2. Prüfen: Ist der Hintergrund **weiß/hell**?
3. Gehe zu: Datei → Einstellungen → Farbschema
4. Prüfen: Hat "Default Light Modern" ein **✓** Häkchen?

Falls das Theme immer noch dunkel ist:
- `C:\Program Files\Kullisa Stage\resources\app\product.json` öffnen
- Suchen nach `configurationDefaults`
- Ist `workbench.colorTheme: Default Light Modern` drin?

---

*[Letzte Aktualisierung: 2026-03-26 03:00 CET | Autor: VSCODIUM-EXPERT]*  
*[Alle bisherigen Versuche dokumentiert — keine Information verloren gegangen]*
