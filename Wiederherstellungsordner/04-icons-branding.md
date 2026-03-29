# 04 - Icons und Branding

**Erstellt:** 2026-03-24  
**Aktualisiert:** 2026-03-24  
**Autor:** VSCODIUM-EXPERT  
**Zweck:** Anleitung zum Austausch aller Icons, Logos und Branding-Elemente

---

## Was ist Branding?

Branding bedeutet, das Programm optisch als "Kullisa Stage" erkennbar zu machen:
- Eigenes Logo statt VSCodium-Logo
- Eigenes Icon in der Taskleiste
- Eigenes Wasserzeichen im Editor
- Eigene Farben

---

## Alle Branding-Dateien im Überblick

**Quell-Ordner (neu erstellt):**
```
Kullisa-Stage-Doc/icons-wasserzeichen/
```
Hier liegen alle originalen Kullisa Branding-Dateien.

---

## 1. Programm-Icon (Taskleiste, Desktop)

### Windows

| Datei | Pfad | Format | Größe |
|-------|------|--------|-------|
| `code.ico` | `src/stable/resources/win32/` | ICO | Multi-Size |
| `code.ico` | `src/insider/resources/win32/` | ICO | Multi-Size |

**Was ist ICO?**  
Eine ICO-Datei enthält mehrere Bilder in verschiedenen Größen (16x16, 32x32, 64x64, 128x128, 256x256 Pixel). Windows wählt automatisch die passende Größe.

**Quelle:** `kullisa-logo-700x700.ico`

### Linux

| Datei | Pfad | Format | Größe |
|-------|------|--------|-------|
| `code.png` | `src/stable/resources/linux/` | PNG | 512x512 Pixel |
| `code.png` | `src/insider/resources/linux/` | PNG | 512x512 Pixel |

**Quelle:** `code-512.png`

### macOS

| Datei | Pfad | Format |
|-------|------|--------|
| `code.icns` | `src/stable/resources/darwin/` | ICNS |

**Hinweis:** ICNS wird auf macOS benötigt. Noch nicht erstellt.

---

## 2. Fenster-Icon (oben links im Programmfenster)

Dieses Icon erscheint in der Titelleiste des Programms.

| Datei | Pfad | Format |
|-------|------|--------|
| `code-icon.svg` | `src/stable/src/vs/workbench/browser/media/` | SVG |
| `code-icon.svg` | `src/insider/src/vs/workbench/browser/media/` | SVG |

**Quelle:** `kullisa logo 700x700.svg`

---

## 3. Wasserzeichen (im Editor-Hintergrund)

Das Wasserzeichen erscheint groß und ausgegraut im Editor, wenn keine Datei geöffnet ist.

### Stable-Version

| Datei | Pfad | Verwendung |
|-------|------|------------|
| `letterpress-light.svg` | `src/stable/src/vs/workbench/browser/parts/editor/media/` | Helles Theme |
| `letterpress-dark.svg` | `src/stable/src/vs/workbench/browser/parts/editor/media/` | Dunkles Theme |
| `letterpress-hcLight.svg` | `src/stable/src/vs/workbench/browser/parts/editor/media/` | High Contrast Hell |
| `letterpress-hcDark.svg` | `src/stable/src/vs/workbench/browser/parts/editor/media/` | High Contrast Dunkel |

### Insider-Version

| Datei | Pfad | Verwendung |
|-------|------|------------|
| `letterpress-light.svg` | `src/insider/src/vs/workbench/browser/parts/editor/media/` | Helles Theme |
| `letterpress-dark.svg` | `src/insider/src/vs/workbench/browser/parts/editor/media/` | Dunkles Theme |
| `letterpress-hcLight.svg` | `src/insider/src/vs/workbench/browser/parts/editor/media/` | High Contrast Hell |
| `letterpress-hcDark.svg` | `src/insider/src/vs/workbench/browser/parts/editor/media/` | High Contrast Dunkel |

**Insgesamt:** 8 Wasserzeichen-Dateien (4 pro Version)

**Quelle:** `kullisa logo 700x700.svg` (angepasst für jedes Theme)

---

## 4. SVG Icons (für Build-Prozess)

Diese SVGs werden während des Builds zu ICO/PNG konvertiert.

### Stable

| Datei | Pfad |
|-------|------|
| `codium_cnl.svg` | `icons/stable/` |
| `codium_clt.svg` | `icons/stable/` |
| `codium_cnl_w80_b8.svg` | `icons/stable/` |

### Insider

| Datei | Pfad |
|-------|------|
| `codium_cnl.svg` | `icons/insider/` |
| `codium_clt.svg` | `icons/insider/` |
| `codium_cnl_w80_b8.svg` | `icons/insider/` |

**Quelle:** `kullisa logo 700x700.svg`

---

## 5. Installer-Grafiken (Windows MSI)

### Wichtige Info zu BMP-Dateien

BMP ist ein Bildformat ohne Kompression. Die MSI-Installer benötigen spezielle Größen:

| Datei | Pfad | Größe | Verwendung |
|-------|------|-------|------------|
| `wix-banner.bmp` | `build/windows/msi/resources/stable/` | 493x58 Pixel | Banner oben im Installer |
| `wix-dialog.bmp` | `build/windows/msi/resources/stable/` | 493x312 Pixel | Hintergrund im Installer |
| `wix-banner.bmp` | `build/windows/msi/resources/insider/` | 493x58 Pixel | Banner (Insider) |
| `wix-dialog.bmp` | `build/windows/msi/resources/insider/` | 493x312 Pixel | Hintergrund (Insider) |

**Wie erstellt man BMP-Dateien?**

1. **Mit GIMP (kostenlos):**
   - Logo als PNG öffnen
   - Größe ändern auf 493x58 (Banner) oder 493x312 (Dialog)
   - Als BMP exportieren (24-bit Farbtiefe)

2. **Mit Paint (Windows):**
   - Bild öffnen
   - Größe ändern
   - "Speichern unter" → BMP auswählen

3. **Online-Konverter:**
   - PNG zu BMP konvertieren
   - Auf richtige Größe achten!

**Status:** Noch nicht erstellt (⏳ TODO)

---

## 6. Zusammenfassung aller geänderten Dateien

### ✅ Bereits erledigt (2026-03-24):

| Bereich | Anzahl | Status |
|---------|--------|--------|
| Windows Icons (ICO) | 2 Dateien | ✅ Ersetzt |
| Windows PNGs | 4 Dateien | ✅ Ersetzt |
| Linux PNGs | 2 Dateien | ✅ Ersetzt |
| SVG Icons (stable) | 3 Dateien | ✅ Ersetzt |
| SVG Icons (insider) | 3 Dateien | ✅ Ersetzt |
| Fenster-Icons | 2 Dateien | ✅ Ersetzt |
| Wasserzeichen (stable) | 4 Dateien | ✅ Ersetzt |
| Wasserzeichen (insider) | 4 Dateien | ✅ Ersetzt |

**Gesamt:** 24 Dateien erfolgreich ausgetauscht!

### ⏳ Noch zu erledigen:

| Bereich | Anzahl | Status |
|---------|--------|--------|
| Installer-Banner (BMP) | 2 Dateien | ⏳ TODO |
| Installer-Dialog (BMP) | 2 Dateien | ⏳ TODO |
| macOS Icons (ICNS) | 1 Datei | ⏳ Optional |

---

## 7. Wichtige Dateien im Überblick

### Quell-Dateien (in `Kullisa-Stage-Doc/icons-wasserzeichen/`):
- `kullisa logo 700x700.svg` (Hauptquelle)
- `kullisa logo 500x500.png`
- `kullisa-logo-700x700.ico`
- `letterpress-light.svg`
- `letterpress-dark.svg`
- `letterpress-hcLight.svg`
- `letterpress-hcDark.svg`

### Ziel-Dateien (im Projekt):
Alle oben aufgeführten Pfade unter `src/`, `icons/` und `build/`

---

## 8. Test nach der Umsetzung

**Wie prüfen wir, ob alles funktioniert?**

1. Programm installieren
2. **Prüfen:** Kullisa Logo in der Taskleiste?
3. **Prüfen:** Kullisa Logo in der Titelleiste?
4. **Prüfen:** Kullisa Wasserzeichen im Editor?
5. **Prüfen:** Installer zeigt richtige Grafiken?

---

*[Letzte Aktualisierung: 2026-03-24 - Alle konkreten Dateien und Pfade hinzugefügt]*
