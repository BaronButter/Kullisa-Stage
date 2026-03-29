# 10 – Refactoring & Cleanup: Projekt-Bereinigung

**Erstellt:** 2026-03-28  
**Autor:** VSCODIUM-EXPERT  
**Zweck:** Dokumentation der Bereinigung des Projekts, um Komplexität abzubauen und Fehlerquellen zu minimieren.

---

## 1. STRATEGIE
Wir trennen den aktiven Code von "Ballast" (Backups, inaktive Patches, andere Plattformen). Nichts wird gelöscht, aber alles Irrelevante wird in Archiv-Ordner verschoben, die nicht mehr vom Build-System gescannt werden.

---

## 2. NEUE ORDNERSTRUKTUR (ARCHIV)

### Patches (`patches/archive/`)
In diesen Ordner verschieben wir:
- Alle `.bak` Dateien (Backups).
- Alle `.disabled` oder `.no` Dateien.
- Alle Patches für Plattformen, die wir aktuell nicht bauen (Linux, macOS, Alpine), sofern sie nicht im Root liegen.
- **Spezialfall:** Den riesigen `feat-experimental-font.patch` (250k Zeilen), um Build-Konflikte zu vermeiden.

### Skripte (`scripts/archive/`)
In diesen Ordner verschieben wir:
- Veraltete Build-Skripte oder Test-Skripte, die nicht mehr Teil des Masterplans sind.

---

## 3. GITIGNORE ERWEITERUNG
Die Archiv-Ordner werden in die `.gitignore` aufgenommen, damit sie lokal erhalten bleiben, aber nicht mehr auf GitHub gepusht werden. Dies hält das Repository schlank.

```text
patches/archive/
scripts/archive/
```

---

## 4. NUTZEN DER BEREINIGUNG
1. **Build-Geschwindigkeit:** Das System muss weniger Dateien scannen.
2. **Fehlerminimierung:** Es können keine falschen Patches mehr "aus Versehen" angewendet werden.
3. **Übersichtlichkeit:** Wir sehen nur noch die ca. 20-25 Patches, die wirklich für Kullisa Stage (Windows) relevant sind.

---

## 5. NÄCHSTE AKTIONEN
1. Erstellen der Archiv-Ordner.
2. Verschieben der Dateien gemäß Patch-Index (07).
3. Update der `.gitignore`.
