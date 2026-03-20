# VSCodium - Anpassungen VOR der Kompilierung

**Projektname:** Kullisa Labs  
**Letzte Aktualisierung:** 2026-03-08

----

## 🎯 Ziel

Anpassungen VOR der Kompilierung vornehmen, damit das Endprodukt "Kullisa Labs" heißt und unsere Farben verwendet.

---

## ✅ Anpassbare Bereiche (vor Kompilierung)

### 1. Produkt-Name ändern

| Datei | Ändern zu |
|-------|-----------|
| `product.json` | "Kullisa Labs" |
| `product.name` | "kullisa-labs" |
| `product.appName` | "Kullisa Labs" |

### 2. Icons und Logos

| Datei | Beschreibung |
|-------|--------------|
| `icons/stable/codium_cnl.svg` | Logo ändern |
| `icons/insider/codium_cnl.svg` | Insider-Logo |
| `assets/` | Weitere Assets |

### 3. Farben und Themes

| Datei | Beschreibung |
|-------|--------------|
| `src/vs/workbench/contrib/themeRe<brandation/browser/media/` | Theme-Farben |
| `src/vs/platform/theme/common/` | Theme-Konfiguration |

### 4. Standard-Theme einstellen

```
Light Mode als Standard setzen
→ VSCode startet im weißen Modus
```

---

## 📝 Checkliste vor der Kompilierung

- [ ] Produktname auf "Kullisa Labs" ändern
- [ ] Icons durch eigene ersetzen
- [ ] Light Mode als Standard setzen
- [ ] Farben anpassen (falls im Quellcode)
- [ ] Build-Skripte prüfen

---

## 🚀 Nach der Kompilierung

### Einfache Änderungen (kein Rebuild nötig):
- CSS-Anpassungen
- Themes installieren
- Extensions hinzufügen

### Erfordert Rebuild:
- Quellcode-Änderungen
- Neue Features
- Icon-Änderungen (im Quellcode)

---

## 📂 Wichtige Dateien

```
vscodium/
├── product.json           # Produktname
├── build.sh              # Build-Skript
├── src/                  # Quellcode
│   └── vs/
│       ├── workbench/   # UI/Theming
│       └── platform/    # Core
├── icons/               # Logos
└── docs/                # Dokumentation
```

---

## 5. Standard-Theme konfigurieren

**Ziel:** "Default Light Modern" als Standard-Theme

| Einstellung | Wert | Beschreibung |
|-------------|------|--------------|
| `workbench.colorTheme` | `Default Light Modern` | Helles modernes Theme |

**Datei:** `prepare_vscode.sh`

---

## 6. Wasserzeichen (Editor Background)

**Ziel:** Kullisa Logo statt VSCodium Logo im Editor-Hintergrund

| Datei | Format | Beschreibung |
|-------|--------|--------------|
| `vscode/src/vs/workbench/browser/media/watermark.svg` | SVG | Editor-Hintergrundlogo |

**Quelldatei:** `kullisa logo 700x700.svg`

---

## 7. Pre-Installed Extensions

**Quelle:** Open VSX Registry (open-vsx.org)  
**Lizenz:** Alle MIT/Apache (sicher vorinstallierbar)

### 7.1 AI & Code-Assistenz

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `saoudrizwan.claude-dev` | Claude Dev | AI Code-Assistenz | MIT |

### 7.2 Versionierung & Projekte

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `eamodio.gitlens` | GitLens | Erweiterte Git-Integration | MIT |
| `alefragnani.project-manager` | Project Manager | Projektverwaltung | MIT |

### 7.3 Dokumente & Markdown

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `yzhang.markdown-all-in-one` | Markdown All in One | Markdown-Unterstützung | MIT |
| `yzane.markdown-pdf` | Markdown PDF | Markdown → PDF Export | MIT |
| `streetsidesoftware.code-spell-checker` | Code Spell Checker | Rechtschreibprüfung | MIT |

### 7.4 Diagramme & Visualisierung

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `bierner.markdown-mermaid` | Mermaid Preview | Diagramme in Markdown | MIT |
| `hediet.vscode-drawio` | Draw.io Integration | Diagramme erstellen | MIT |

### 7.5 Datei-Viewer

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `cweijan.vscode-office` | Office Viewer | Word/Excel/PowerPoint | MIT |
| `grapecity.gc-excelviewer` | Excel Viewer | CSV/Excel Ansicht | MIT |
| `kisstkondoros.vscode-gutter-preview` | Image Preview | Bilder im Editor | MIT |

### 7.6 Produktivität

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `gruntfuggly.todo-tree` | Todo Tree | TODOs im Projekt | MIT |
| `humao.rest-client` | REST Client | API-Testing | MIT |

### 7.7 UX & Icons

| Extension ID | Name | Beschreibung | Lizenz |
|--------------|------|--------------|--------|
| `pkief.material-icon-theme` | Material Icon Theme | Datei-Icons | MIT |
| `ms-toolsai.jupyter` | Jupyter | Notebooks | MIT |

**Gesamt:** 15 Extensions für Branchenübergreifende Nutzung

---

## 8. Phase 2 Checkliste

- [x] Theme: "Default Light Modern" als Standard
- [ ] Window Icon (links oben) ersetzen
- [ ] Walkthrough Tab Icon ersetzen
- [ ] Wasserzeichen (Editor) ersetzen
- [ ] 15 Extensions vorinstallieren

---

## 💡 Tipp

**Erst kompilieren, wenn alle Vorab-Anpassungen gemacht sind!**

Jeder Rebuild dauert 1-2 Stunden.

---

*Letzte Aktualisierung: 2026-03-20*  
*Autor: VSCODIUM-EXPERT*  
*Version: Phase 2*
