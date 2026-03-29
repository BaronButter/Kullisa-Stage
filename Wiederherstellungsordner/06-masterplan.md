# 06 – Strategischer Masterplan: Kullisa Stage Branding

**Erstellt:** 2026-03-27  
**Autor:** VSCODIUM-EXPERT  
**Status:** PLANUNGSPHASE  

---

## 1. ZIELSETZUNG
Erstellung einer stabilen, gebrandeten Version von **Kullisa Stage** auf Basis einer fixierten VSCodium-Version. Fokus auf Schnelligkeit (Portable Version) und Wartbarkeit (Skripte statt Patches).

---

## 2. DER MASTERPLAN (SCHRITT FÜR SCHRITT)

### PHASE 1: Fundament & Sicherheit (ERLEDIGT ✅)
- [x] **Version einfrieren:** Fixierung der VSCodium-Version in `check_tags.sh` und Workflows.
- [x] **Patch-Inventur:** Erstellung einer Index-Datei für alle Patches im `patches/` Ordner.
- [x] **brand.patch deaktivieren:** Entfernen des fehlerhaften Patches zugunsten von Skripten.
- [x] **Skript-Inventur:** Übersicht aller Build-Skripte erstellt.
- [x] **Patch-Header:** Dokumentation in den Kern-Patches eingefügt.

### PHASE 2: Portable Version (Schnelle Iteration - IN ARBEIT 🏗️)
- [x] **Portable Build-Logik:** Anpassung der Skripte, um primär eine portable ZIP-Version zu erzeugen.
- [ ] **Test-Zyklus:** Validierung der Icons und Basisfunktionen in der portablen Version.

### PHASE 3: Branding & Texte (Die "Skript-Methode")
- [ ] **Dynamische Ersetzung:** Implementierung von `sed`-Befehlen in `prepare_vscode.sh` für Namensänderungen.
- [ ] **product.json Finalisierung:** Alle Metadaten (URLs, Namen, IDs) korrekt setzen.

### PHASE 4: Extensions & Theme
- [ ] **Extension-Integration:** Skript zum Kopieren der 19 Extensions in den Built-in Ordner.
- [ ] **Theme-Enforcement:** Standard-Theme auf "Light Modern" fixieren.

### PHASE 5: Installer & Release
- [ ] **MSI-Build:** Finalisierung des Windows-Installers mit korrektem EXE-Namen.
- [ ] **Release-Workflow:** Automatisierung des Uploads auf GitHub.

---

## 3. WARUM DIE PORTABLE VERSION?
Die portable Version ist unser "Testlabor":
1. **Geschwindigkeit:** Kein langwieriger MSI-Verpackungsprozess nötig.
2. **Transparenz:** Wir sehen sofort die Ordnerstruktur (`resources/app/extensions`).
3. **Garantie:** Wenn die portable Version perfekt aussieht, wird auch der Installer (der nur diese Dateien kopiert) perfekt funktionieren.

---

## 4. NÄCHSTE AKTION
Erstellung der Datei `Wiederherstellungsordner/07-patch-index.md`.
