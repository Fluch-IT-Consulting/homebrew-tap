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

**2. Tap hinzufügen** – mit der SSH-Adresse dahinter:

```
brew tap fluch-it-consulting/tap git@github.com:Fluch-IT-Consulting/homebrew-tap.git
brew install fluch-it-consulting/tap/rechnungsgenerator
```

Die Adresse ist nötig, weil der Tap privat ist: `brew tap` allein klont über
HTTPS und findet dort keine Zugangsdaten. Wer `gh auth setup-git` eingerichtet
hat, kommt auch ohne sie aus.

**3. Ein JDK 21 oder neuer.** Ein vorhandenes genügt – die Formel verlangt
keines als Abhängigkeit und setzt auch kein JAVA_HOME. Wer keines hat:

```
brew install openjdk
```

Auf macOS 14 und älter führt Homebrew dafür keine fertigen Pakete mehr (Tier 3)
und baut das JDK aus dem Quelltext; das dauert lange und verlangt volles Xcode.
Dort ist ein fertiges JDK, etwa von [Temurin](https://adoptium.net/), der
schnellere Weg.

**4. TeX Live**, denn gesetzt wird mit LuaLaTeX:

```
brew install --cask mactex-no-gui
```

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
- **„Unable to locate a Java Runtime"** – es ist kein JDK im PATH und kein
  JAVA_HOME gesetzt, siehe Schritt 3.
- **`brew tap` fragt nach einem Benutzernamen** – die SSH-Adresse aus Schritt 2
  fehlt, oder der eigene Zugang reicht nicht bis zu diesem Repository.

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
