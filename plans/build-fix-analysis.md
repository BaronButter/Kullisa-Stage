# Build-Fehler Analyse

## Problem

Der Build erstellt keine `.exe` Dateien. Das Artifact enthält nur `vscode.tar.gz` (Extensions).

## Ursache

`prepare_assets.sh` wird nicht ausgeführt wegen der Bedingung:

```yaml
if: env.SHOULD_BUILD == 'yes' && (env.SHOULD_DEPLOY == 'yes' || github.event.inputs.generate_assets == 'true')
```

Bei einem normalen Push:
- `SHOULD_BUILD=yes` ✅
- `SHOULD_DEPLOY=no` ❌
- `generate_assets` nicht gesetzt ❌

→ Bedingung = FALSE → `prepare_assets.sh` wird übersprungen

## Was macht prepare_assets.sh?

Erstellt die finalen Installationsdateien:
- ZIP-Datei
- System-Setup EXE
- User-Setup EXE
- MSI-Installer

## Lösung

Die Bedingung muss geändert werden zu:

```yaml
if: env.SHOULD_BUILD == 'yes'
```

Damit läuft `prepare_assets.sh` bei jedem Build.

## Betroffene Schritte

1. `Prepare assets` - Bedingung ändern
2. `Upload unsigned artifacts` - Bedingung ändern
3. `Prepare checksums` - Bedingung ändern

## Dateien

- `.github/workflows/stable-windows.yml`
- `.github/workflows/stable-linux.yml`
- `.github/workflows/stable-macos.yml`

## Test-Plan

1. Bedingungen ändern
2. Push zu master
3. Build starten
4. Prüfen ob `prepare_assets.sh` läuft
5. Artifact herunterladen
6. Prüfen ob .exe vorhanden

## Risiken

- MSI-Build könnte fehlschlagen (benötigt Windows SDK)
- EXE-Build könnte fehlschlagen (benötigt Inno Setup)
- Wir sollten zuerst nur ZIP aktivieren