# Task Tracker - Kullisa Stage (INSTALLER VERSION - EXE/MSI)

## Status: ⚠️ GEPAUST (Fokus liegt auf Portabler Version)

## Phase 1: Risiko-Analyse & Vorbereitung
- [ ] Mikroskopische Analyse der Schreibrechte in `C:\Program Files` (Dokumentation `02-extensions-install.md` beachten)
- [ ] Prüfung der `build/win32/code.iss` (Inno Setup) auf `data`-Ordner Kompatibilität
- [ ] Entscheidung über Injektions-Methode (Data-Folder vs. Built-in vs. Bootstrap)

## Phase 2: Technisches Prototyping (Installation)
- [ ] Signing reaktivieren (Zertifikate prüfen)
- [ ] Test-Installation auf sauberem Windows-System (VM)
- [ ] Validierung der Extension-Sichtbarkeit im installierten Zustand

## Phase 3: Branding & GUI
- [ ] Anpassung der MSI-Installer Grafiken (BMP-Banner/Dialoge)
- [ ] GUID-Abgleich für Registry-Einträge
