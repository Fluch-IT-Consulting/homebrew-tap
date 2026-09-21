# Homebrew-Tap von Fluch IT Consulting

Formeln für Werkzeuge aus privaten Repositories.

## rechnungsgenerator

Erzeugt aus einer YAML-Beschreibung eine deutsche Rechnung als valides
PDF/A-1b-Dokument. Quelle:
<https://github.com/Fluch-IT-Consulting/rechnungsgenerator>

### Installieren

Beide Repositories sind **privat**. Dafür braucht es dreierlei: Lesezugriff auf
dieses Tap-Repository, Lesezugriff auf das Repository des Generators und einen
GitHub-Token in der Umgebung.

**1. Token anlegen.** Ein Personal Access Token mit Leserecht auf
`Fluch-IT-Consulting/rechnungsgenerator` (Scope `repo` beim klassischen Token,
oder `Contents: Read` bei einem Fine-grained Token). Er gehört in die eigene
Shell-Konfiguration:

```
export HOMEBREW_GITHUB_API_TOKEN=ghp_…
```

Homebrew setzt den Wert erst beim Herunterladen ein; er landet nicht im Cache
und nicht in den Protokollen.

**2. Tap hinzufügen und installieren:**

```
brew tap fluch-it-consulting/tap
brew install fluch-it-consulting/tap/rechnungsgenerator
```

**3. TeX Live**, denn gesetzt wird mit LuaLaTeX:

```
brew install --cask mactex-no-gui
```

Das Java bringt die Formel als Abhängigkeit mit; darum muss sich niemand
kümmern.

### Prüfen

```
rechnungsgenerator --version
rechnungsgenerator erzeuge rechnung.yaml
```

### Wenn es klemmt

- **401 oder 404 beim Herunterladen** – der Token fehlt, ist abgelaufen oder
  hat kein Leserecht auf das Repository des Generators.
- **„lualatex nicht gefunden"** – TeX Live fehlt oder liegt nicht im PATH.
  `/Library/TeX/texbin` gehört dann hinein.

### Anheben auf eine neue Fassung

Die URL der Formel trägt eine numerische **Asset-ID**, keine Fassungsnummer –
nur so lässt sich ein Asset aus einem privaten Repository laden. GitHub vergibt
sie je Release neu. Beim Anheben also drei Zeilen ändern: `url`, `version` und
`sha256`.

Die ID nennt:

```
gh api repos/Fluch-IT-Consulting/rechnungsgenerator/releases \
  --jq '.[] | select(.tag_name=="v0.1.0") | .assets[] | "\(.id) \(.name)"'
```

Die Prüfsumme lässt sich aus dem Quelltext nachbauen: `./gradlew distZip`
liefert dasselbe Archiv Byte für Byte, unabhängig von Maschine und
Betriebssystem – nachgemessen zwischen macOS und dem Ubuntu-Runner.
