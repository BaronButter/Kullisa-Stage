# 07 – Patch-Inventur: Lückenlose Übersicht aller Build-Patches

**Erstellt:** 2026-03-27  
**Überarbeitet:** 2026-03-28 (RADIKALE BEREINIGUNG)  
**Autor:** VSCODIUM-EXPERT  
**Zweck:** Dokumentation ALLER 64 Patches. Nach massiven Build-Problemen wurden alle nicht-essenziellen Patches archiviert, um den Erfolg des Brandings zu garantieren.

---

## 1. DIE "UNVERZICHTBAREN VIER" (Aktiv im Root)
Nur diese 4 Patches sind aktuell aktiv, um einen stabilen Build zu ermöglichen.

| Datei | Zweck | Herkunft | Status |
|-------|-------|----------|--------|
| `telemetry.patch` | Deaktiviert Microsoft Telemetrie | VSCodium | ✅ AKTIV |
| `disable-cloud.patch` | Deaktiviert Cloud-Dienste & Sync | VSCodium | ✅ AKTIV |
| `fix-gallery.patch` | Stellt Open-VSX als Store ein | VSCodium | ✅ AKTIV |
| `disable-signature-verification.patch` | Erlaubt Open-VSX Extensions | VSCodium | ✅ AKTIV |

---

## 2. ARCHIVIERTE PATCHES (In `patches/archive/`)
Alle anderen 60 Dateien wurden archiviert, um Konflikte zu vermeiden. Dies schließt nun auch die Windows-spezifischen Patches ein, um einen absolut minimalen Build zu testen.

### Wichtige archivierte Patches (bei Bedarf reaktivieren)
- `patches/archive/windows/cli.patch`: Windows CLI Anpassungen (verursachte Konflikt).
- `patches/archive/windows/appx.patch`: Windows Store Support.
- `patches/archive/windows/win7.patch`: Windows 7 Support.
- `feat-announcements.patch`: Eigene Ankündigungen.
- `report-issue.patch`: Umleitung Fehlermeldungen.
- `cli.patch`: CLI Anpassungen.
- `fix-policies.patch`: Gruppenrichtlinien.
- `fix-keymap.patch`: Tastatur-Mapping.
- `fix-build-vsce.patch`: Build-Abhängigkeiten.
- `brand.patch.disabled`: VSCodium Branding (ersetzt durch Skripte).
- `feat-experimental-font.patch`: Riesiger Font-Patch.

### Plattformfremde & Backups
- Alle Linux, macOS und Alpine Patches.
- Alle `.bak`, `.disabled`, `.no`, `.yet` Dateien.

---

## 3. ZUSAMMENFASSUNG (Zahlen)
- **Gesamtanzahl Dateien im Projekt:** 64
- **Aktive Patches im Root:** 4
- **Archivierte Dateien:** 60
- **Status:** Radikal bereinigt für maximalen Build-Erfolg.
