# Homebrew-Tap von Fluch IT Consulting

Formeln für Werkzeuge aus privaten Repositories.

## rechnungsgenerator

Erzeugt aus einer YAML-Beschreibung eine deutsche Rechnung als valides
PDF/A-1b-Dokument. Quelle:
<https://github.com/Fluch-IT-Consulting/rechnungsgenerator>

### Installieren

Dieser Tap ist öffentlich, das Repository des Generators ist **privat**. Dafür
braucht es zweierlei: Lesezugriff darauf und einen GitHub-Token in der
Umgebung.

Wer sich die Schritte unten nicht von Hand zusammensuchen will, nimmt
[`setup.sh`](setup.sh) – dasselbe in sechs Stufen, mit Prüfung nach jedem
Schritt.

**1. Token anlegen.** Einen *Fine-grained* Personal Access Token auf
<https://github.com/settings/personal-access-tokens/new>:

- **Resource owner: `Fluch-IT-Consulting`** – nicht das eigene Konto. Dieser
  Schritt wird am häufigsten übersehen, und mit dem falschen Owner antwortet
  die API später mit 404.
- **Expiration:** höchstens 366 Tage; mehr lässt die Organisation nicht zu.
- **Repository access:** „Only select repositories" → Knopf
  `Select repositories` → `Fluch-IT-Consulting/rechnungsgenerator`. In der
  Liste steht womöglich auch `homebrew-tap`; das wird hier **nicht** gebraucht,
  denn der Tap ist öffentlich.
- **Permissions:** `+ Add permissions`, im Suchfeld `Contents` eintippen – die
  Liste ist alphabetisch und lang. Danach ist nur zu **prüfen**, dass
  `Contents` und das automatisch ergänzte `Metadata` auf *Access: Read-only*
  stehen; einstellen muss man nichts.

Unter dem Knopf `Generate token` steht, ob der Token sofort gilt. Für
Mitglieder der Organisation ist die Freigabe durch einen Administrator nötig –
sie erfolgt unter Organisationseinstellungen → *Personal access tokens* →
Reiter *Pending requests*. GitHub zeigt den Wert genau einmal.

**Nicht** im Klartext in die `.zshrc`: Solche Dateien landen in
Time-Machine-Sicherungen und, der häufigste Unfall, in Dotfiles-Repos. Auf
macOS gehört der Token in die Keychain:

```
security add-generic-password -a "$USER" -s homebrew-github-api-token \
  -w '<token>' -D "Homebrew GitHub API token" -T /usr/bin/security -U
```

Dazu in die Shell-Konfiguration eine Funktion, die ihn nur für den einen
`brew`-Aufruf setzt – so steht er in keinem anderen Prozess und nicht in `env`:

```sh
brew() {
  HOMEBREW_GITHUB_API_TOKEN="$(security find-generic-password -a "$USER" -s homebrew-github-api-token -w 2>/dev/null)" \
    command brew "$@"
}
```

`-T /usr/bin/security` setzt genau dieses Programm auf die Zugriffsliste des
Eintrags; deshalb fragt macOS beim Lesen in der Regel nicht nach. Kommt doch
ein Dialog, ist „Immer erlauben" die Antwort.

Homebrew setzt den Wert erst beim Herunterladen ein; er landet nicht im Cache
und nicht in den Protokollen.

**2. Tap hinzufügen und installieren:**

```
brew tap fluch-it-consulting/tap
brew install fluch-it-consulting/tap/rechnungsgenerator
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

### Prüfen

```
rechnungsgenerator --version
rechnungsgenerator erzeuge rechnung.yaml
```

### Wenn es klemmt

- **401 beim Herunterladen** – der Token fehlt, ist abgelaufen oder falsch
  kopiert.
- **403 beim Herunterladen** – der Token wartet vermutlich noch auf die
  Freigabe durch einen Administrator.
- **404 beim Herunterladen** – der Token sieht das Repository nicht. Fast
  immer stand als *Resource owner* das eigene Konto statt
  `Fluch-IT-Consulting`; dann hilft nur, ihn neu anzulegen.
- **„lualatex nicht gefunden"** – TeX Live fehlt oder liegt nicht im PATH.
  `/Library/TeX/texbin` gehört dann hinein.
- **„Unable to locate a Java Runtime"** – es ist kein JDK im PATH und kein
  JAVA_HOME gesetzt, siehe Schritt 3.

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
