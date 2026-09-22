# Homebrew-Tap von Fluch IT Consulting

Formeln für Werkzeuge aus privaten Repositories.

## rechnungsgenerator

Erzeugt aus einer YAML-Beschreibung eine deutsche Rechnung als valides
PDF/A-1b-Dokument. Quelle:
<https://github.com/Fluch-IT-Consulting/rechnungsgenerator>

### Installieren

Dieser Tap ist öffentlich, das Repository des Generators ist **privat**. Dafür
braucht es zweierlei: Lesezugriff darauf und einen GitHub-Token in der
Umgebung. Den Token legst du nicht an – die GitHub-CLI hat ihn schon.

Wer sich die Schritte lieber abnehmen lässt, nimmt [`setup.sh`](setup.sh) –
dasselbe in fünf Stufen, mit Prüfung nach jedem Schritt.

**1. Bei GitHub angemeldet sein.**

```
gh auth login   # falls noch nicht geschehen
gh auth token   # muss einen Wert ausgeben
```

**2. Tap hinzufügen und installieren:**

```
brew tap fluch-it-consulting/tap
HOMEBREW_GITHUB_API_TOKEN=$(gh auth token) brew install fluch-it-consulting/tap/rechnungsgenerator
```

Beim Anheben braucht Homebrew den Token wieder – es lädt dann ein neues
Archiv. Wer nicht jedes Mal daran denken will, setzt ihn in der
Shell-Konfiguration für genau den einen Aufruf; so steht er in keinem anderen
Prozess und nicht in `env`:

```sh
brew() {
  HOMEBREW_GITHUB_API_TOKEN="$(gh auth token 2>/dev/null)" command brew "$@"
}
```

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

### Warum der Token von `gh` kommt

Der engere Schlüssel wäre ein eigens angelegter *Fine-grained* Personal Access
Token, lesend auf genau dieses eine Repository. Anlegen kann ihn aber nur, wer
**Mitglied der Organisation** ist: Als *Resource owner* steht nur zur Wahl,
wo man Mitglied ist, und den Fall „Zugriff auf ein einzelnes fremdes
Repository" führt GitHub ausdrücklich als offene Lücke. Wer von außen
hinzugefügt wurde, landet damit beim **klassischen** PAT mit `repo`-Scope –
genauso breit wie der Token der GitHub-CLI, aber mit einem Ablaufdatum im
Kalender und ohne Schlüsselbund. Der bequemere Weg ist hier auch der engere.

Breit ist der Scope ohnehin nur als Obergrenze. Was ein Token auf *diesem*
Repository darf, entscheidet die Rolle, die dort für das Konto eingetragen
ist: Wer Leserecht hat, liest – gleich was im Token steht.

Auf macOS legt `gh` den Token in den Schlüsselbund; `gh auth status` schreibt
dann `keyring` dahinter, und im Klartext steht er in keiner Datei. Homebrew
setzt ihn erst beim Herunterladen ein, er landet weder im Cache noch in den
Protokollen.

### Prüfen

```
rechnungsgenerator --version
rechnungsgenerator erzeuge rechnung.yaml
```

### Wenn es klemmt

- **401 beim Herunterladen** – in der Umgebung stand kein Token. `gh auth
  token` muss einen Wert ausgeben, und der `brew`-Aufruf muss ihn tragen.
- **403 oder 404 beim Herunterladen** – das Konto sieht das Repository nicht.
  Entweder fehlt der Lesezugriff darauf, dann kümmert sich Fluch IT Consulting
  darum; oder die Organisation hat die GitHub-CLI als Anwendung nicht
  freigegeben.
- **„lualatex nicht gefunden"** – TeX Live fehlt oder liegt nicht im PATH.
  `/Library/TeX/texbin` gehört dann hinein.
- **„Unable to locate a Java Runtime"** – es ist kein JDK im PATH und kein
  JAVA_HOME gesetzt, siehe Schritt 3.

### Anheben auf eine neue Fassung

Das geschieht von selbst. Wird im Repository des Generators ein Release
**veröffentlicht**, hebt ein Workflow dort `url`, `version` und `sha256` in
dieser Formel an und pusht die Änderung hierher. Commits von
`github-actions[bot]` in diesem Repository kommen daher.

Ausgelöst wird vom Veröffentlichen und nicht vom Tag: Der Tag baut nur einen
Entwurf, und eine Formel, die auf ein noch unveröffentlichtes Asset zeigt,
ließe jeden `brew upgrade` ins Leere laufen. Ein Prerelease hebt nichts an.

Warum überhaupt drei Zeilen und nicht eine: Die URL trägt eine numerische
**Asset-ID** statt einer Fassungsnummer – nur so lässt sich ein Asset aus einem
privaten Repository laden –, und GitHub vergibt sie je Release neu.

#### Von Hand, falls die Automatik ausfällt

Die Asset-ID eines Releases nennt:

```
gh api repos/Fluch-IT-Consulting/rechnungsgenerator/releases \
  --jq '.[] | select(.tag_name=="vX.Y.Z") | .assets[] | "\(.id) \(.name)"'
```

Die Prüfsumme lässt sich aus dem Quelltext nachbauen, statt das Archiv zu
laden: `./gradlew distZip` liefert dasselbe Archiv Byte für Byte, unabhängig
von Maschine und Betriebssystem – nachgemessen zwischen macOS und dem
Ubuntu-Runner.
