# 09 – Skript-Inventur: Übersicht aller Build-Skripte

**Erstellt:** 2026-03-27  
**Autor:** VSCODIUM-EXPERT  
**Zweck:** Dokumentation aller Skripte im Projekt-Root, um den Build-Prozess von Kullisa Stage zu verstehen und zu steuern.

---

## 1. ZENTRALE BUILD-STEUERUNG

| Datei | Zweck | Status | Empfehlung |
|-------|-------|--------|------------|
| `utils.sh` | Definiert globale Variablen (APP_NAME, BINARY_NAME) | ✅ KRITISCH | **Anpassen:** Kullisa-Werte als Fallback setzen. |
| `check_tags.sh` | Prüft auf neue VSCodium-Versionen | 🟡 VORSICHT | **Anpassen:** Automatik deaktivieren, Version einfrieren. |
| `version.sh` | Generiert die Build-Source-Version | ✅ STABIL | Behalten. |

---

## 2. VORBEREITUNG & BRANDING

| Datei | Zweck | Status | Empfehlung |
|-------|-------|--------|------------|
| `prepare_src.sh` | Bereitet den Quellcode-Download vor | ✅ STABIL | Behalten. |
| `prepare_vscode.sh` | Wendet Patches an und konfiguriert `product.json` | ✅ KRITISCH | **Erweitern:** `sed`-Ersetzungen für Branding hinzufügen. |
| `prepare_assets.sh` | Verpackt die fertigen Binärdateien (MSI/EXE) | 🟡 VORSICHT | **Anpassen:** EXE-Namen korrigieren. |

---

## 3. BUILD & RELEASE

| Datei | Zweck | Status | Empfehlung |
|-------|-------|--------|------------|
| `build.sh` | Haupt-Build-Skript (ruft Gulp auf) | ✅ KRITISCH | **Erweitern:** Portable ZIP-Erzeugung priorisieren. |
| `release.sh` | Erstellt das GitHub-Release | 🟡 VORSICHT | Erst nutzen, wenn Build stabil ist. |
| `build_cli.sh` | Baut das Command-Line-Interface | ✅ STABIL | Behalten. |

---

## 4. STRATEGIE FÜR KULLISA STAGE
Wir werden die Skripte so anpassen, dass sie **unabhängig** von Upstream-Änderungen funktionieren. Jedes Skript erhält einen Header mit dem VSCODIUM-EXPERT Kommentar, sobald wir es anpassen.

---

## 5. NÄCHSTE AKTION
Wechsel in den Code-Modus, um `check_tags.sh` und `utils.sh` anzupassen (Version einfrieren).
