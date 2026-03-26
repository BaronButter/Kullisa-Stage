/*
  Author: VSCODIUM-EXPERT
  Date: 2026-03-26
  Time: 15:55 CET
  Description: First-Run Bootstrap. Installiert kuratierte Extensions in das Benutzerprofil
               (Installed Extensions) und setzt das Standard-Theme auf "Default Light Modern".
               Läuft beim App-Start sehr früh im Electron Main-Prozess, ist idempotent und
               löst bei tatsächlichen Änderungen einen einmaligen Neustart aus.
*/
'use strict';

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Core-Imports
const fs = require('fs');
const path = require('path');
const os = require('os');
let electronApp = null;
try { electronApp = require('electron').app; } catch { /* no electron in some contexts */ }

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Utilities
function ensureDirSync(p) {
  try {
    fs.mkdirSync(p, { recursive: true });
  } catch (_) { /* no-op */ }
}

function copyDirSync(src, dest) {
  const stat = fs.statSync(src);
  if (!stat.isDirectory()) throw new Error(`Source is not a directory: ${src}`);
  ensureDirSync(dest);
  for (const entry of fs.readdirSync(src)) {
    const s = path.join(src, entry);
    const d = path.join(dest, entry);
    const st = fs.statSync(s);
    if (st.isDirectory()) {
      copyDirSync(s, d);
    } else if (st.isSymbolicLink && st.isSymbolicLink()) {
      try {
        const link = fs.readlinkSync(s);
        fs.symlinkSync(link, d);
      } catch { /* ignore */ }
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

function readJSON(file, fallback) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return fallback;
  }
}

function writeJSON(file, obj) {
  ensureDirSync(path.dirname(file));
  fs.writeFileSync(file, JSON.stringify(obj, null, 2));
}

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Installer-Log
let logFile = null;
function log(...args) {
  try {
    const line = `[KULLISA] ${new Date().toISOString()} ${args.join(' ')}\n`;
    if (logFile) fs.appendFileSync(logFile, line);
    // Auch zur Konsole ausgeben, um in devtools/Logs sichtbar zu sein
    // eslint-disable-next-line no-console
    console.log(line.trim());
  } catch { /* ignore */ }
}

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Zielpfade für User-Extensions ermitteln
function getCandidateUserExtensionsDirs(userDataDir) {
  const candidates = [];
  const home = os.homedir && os.homedir() || process.env.HOME || process.env.USERPROFILE || '';

  // Portable Mode
  if (process.env.VSCODE_PORTABLE) {
    candidates.push(path.join(process.env.VSCODE_PORTABLE, 'data', 'extensions'));
  }

  // Historische und gängige Speicherorte
  if (home) {
    candidates.push(path.join(home, '.vscode', 'extensions'));
    candidates.push(path.join(home, '.vscode-oss', 'extensions'));
    candidates.push(path.join(home, '.vscodium', 'extensions'));
  }

  // Moderne Pfade relativ zum userData (je nach Distro/Branding)
  if (userDataDir) {
    candidates.push(path.join(userDataDir, 'extensions'));
  }

  // Entduplizieren
  return Array.from(new Set(candidates.filter(Boolean)));
}

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Kernlogik
function installCuratedExtensions(curatedDir, userExtensionsDirs) {
  const aggregate = { installed: [], skipped: [], errors: [], changed: false };
  if (!fs.existsSync(curatedDir)) {
    log('Kuratiertes Verzeichnis nicht vorhanden:', curatedDir);
    return aggregate;
  }

  const entries = fs.readdirSync(curatedDir).filter(n => !n.startsWith('.'));
  for (const entry of entries) {
    for (const userExtensionsDir of userExtensionsDirs) {
      try {
        ensureDirSync(userExtensionsDir);
        const src = path.join(curatedDir, entry);
        const pkg = readJSON(path.join(src, 'package.json'), null);
        if (!pkg || !pkg.name || !pkg.publisher || !pkg.version) {
          if (!aggregate.skipped.includes(entry)) aggregate.skipped.push(entry);
          log('Übersprungen (keine gültige package.json):', entry);
          break; // für diesen Eintrag nicht erneut versuchen
        }
        const folderName = `${pkg.publisher}.${pkg.name}-${pkg.version}`;
        const dest = path.join(userExtensionsDir, folderName);
        if (fs.existsSync(dest)) {
          // Bereits vorhanden in diesem Ziel. Weiter zum nächsten Zielpfad.
          continue;
        }
        log('Installiere Extension:', folderName, '→', userExtensionsDir);
        copyDirSync(src, dest);
        if (!aggregate.installed.includes(folderName)) aggregate.installed.push(folderName);
        aggregate.changed = true;
        // Keine weitere Kopie desselben Eintrags in andere Zielpfade nötig
        break;
      } catch (e) {
        aggregate.errors.push({ entry, error: String(e && e.stack || e) });
        log('FEHLER bei Extension-Installation:', entry, String(e && e.stack || e));
      }
    }
  }

  return aggregate;
}

function setDefaultTheme(userDataDir) {
  try {
    const userSettingsDir = path.join(userDataDir, 'User');
    const userSettingsFile = path.join(userSettingsDir, 'settings.json');
    const settings = readJSON(userSettingsFile, {});
    const desired = 'Default Light Modern';
    if (settings['workbench.colorTheme'] === desired) {
      return false; // keine Änderung
    }
    settings['workbench.colorTheme'] = desired;
    writeJSON(userSettingsFile, settings);
    log('Theme gesetzt auf:', desired);
    return true;
  } catch (e) {
    log('FEHLER beim Setzen des Themes:', String(e && e.stack || e));
    return false;
  }
}

function main() {
  if (!electronApp) {
    // Sicherheit: Nur im Electron Main sinnvoll
    return;
  }

  const start = () => {
    try {
      const userDataDir = electronApp.getPath('userData');
      const logsDir = path.join(userDataDir, 'logs');
      ensureDirSync(logsDir);
      logFile = path.join(logsDir, 'kullisa-first-run.log');

      const curatedDir = path.resolve(__dirname, '..', 'kullisa-curated');
      const userExtensionsDirs = getCandidateUserExtensionsDirs(userDataDir);

      log('First-Run Prüfen… Kandidaten:', String(userExtensionsDirs));
      const installRes = installCuratedExtensions(curatedDir, userExtensionsDirs);
      const themeChanged = setDefaultTheme(userDataDir);

      // Neustart falls Änderungen vorgenommen wurden, damit Extensions sofort aktiv sind
      if (installRes.changed || themeChanged) {
        log('Änderungen erkannt. Starte Anwendung in 3s neu…');
        setTimeout(() => {
          try {
            electronApp.relaunch();
            electronApp.exit(0);
          } catch (e) {
            log('FEHLER beim Neustart:', String(e && e.stack || e));
          }
        }, 3000);
      } else {
        log('Keine Änderungen erforderlich.');
      }
    } catch (e) {
      log('Unerwarteter Fehler in First-Run:', String(e && e.stack || e));
    }
  };

  if (electronApp.isReady && electronApp.isReady()) {
    start();
  } else {
    electronApp.once('ready', start);
  }
}

// [VSCODIUM-EXPERT | 2026-03-26 15:55] Startpunkt
main();

