/**
 * VSCODIUM-EXPERT | 2026-03-12 22:08
 * Manuelle Branding-Anwendung für Windows
 */

const fs = require('fs');
const path = require('path');

const productPath = path.join(__dirname, '..', 'vscode', 'product.json');

console.log('Lese product.json...');
let product = JSON.parse(fs.readFileSync(productPath, 'utf8'));

console.log('Wende Kullisa Stage Branding an...');

// Stable Branding
product.nameShort = 'Kullisa Stage';
product.nameLong = 'Kullisa Stage';
product.applicationName = 'kullisa';
product.linuxIconName = 'kullisa';
product.urlProtocol = 'kullisa';
product.serverApplicationName = 'kullisa-server';
product.serverDataFolderName = '.kullisa-server';
product.darwinBundleIdentifier = 'com.kullisa.kullisa-labs';
product.win32AppUserModelId = 'KullisaLabs.KullisaLabs';
product.win32DirName = 'Kullisa Stage';
product.win32MutexName = 'kullisa';
product.win32NameVersion = 'Kullisa Stage';
product.win32RegValueName = 'KullisaStage';
product.win32ShellNameShort = 'Kullisa Stage';
product.tunnelApplicationName = 'kullisa-tunnel';
product.win32TunnelServiceMutex = 'kullisa-tunnelservice';
product.win32TunnelMutex = 'kullisa-tunnel';

// Extension Gallery auf Open VSX
product.extensionsGallery = {
  serviceUrl: 'https://open-vsx.org/vscode/gallery',
  itemUrl: 'https://open-vsx.org/vscode/item',
  latestUrlTemplate: 'https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest',
  controlUrl: 'https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json'
};

// Weitere Anpassungen
product.linkProtectionTrustedDomains = ['https://open-vsx.org'];
product.licenseUrl = 'https://github.com/KullisaLabs/kullisa-desktop/blob/master/LICENSE';
product.reportIssueUrl = 'https://github.com/KullisaLabs/kullisa-desktop/issues/new';

console.log('Speichere product.json...');
fs.writeFileSync(productPath, JSON.stringify(product, null, '\t'));

console.log('✅ Branding erfolgreich angewendet!');
console.log('Produktname:', product.nameShort);
console.log('Application:', product.applicationName);
