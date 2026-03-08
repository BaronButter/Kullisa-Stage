# VSCodium - Anpassungen VOR der Kompilierung

**Projektname:** Kullisa Labs  
**Letzte Aktualisierung:** 2026-03-08

---

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

## 💡 Tipp

**Erst kompilieren, wenn alle Vorab-Anpassungen gemacht sind!**

Jeder Rebuild dauert 1-2 Stunden.
