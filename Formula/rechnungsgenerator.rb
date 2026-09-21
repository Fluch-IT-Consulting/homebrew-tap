# Formel für ein Werkzeug aus einem PRIVATEN Repository.
#
# Homebrew brachte dafür früher GitHubPrivateRepositoryReleaseDownloadStrategy
# mit. Die gibt es seit Homebrew 7 nicht mehr – nachgesehen im Quellbaum von
# 7.0.1, kein Treffer mehr auf GitHubPrivate. Der Weg ist jetzt die GitHub-API
# als URL plus ein Authorization-Header.
#
# Der Token steht nicht in dieser Datei. Homebrew ersetzt beim Auswerten der
# Formel jede Umgebungsvariable, deren Name nach token|key|auth|password
# aussieht, durch einen Platzhalter und setzt den echten Wert erst beim
# Herunterladen ein; er landet damit weder im Cache noch in den Protokollen.
# Nach einem Redirect wirft Homebrew den Authorization-Header weg – nötig,
# weil die API auf S3 umleitet und S3 einen fremden Auth-Header ablehnt.
#
# Die URL trägt eine numerische Asset-ID, keine Fassungsnummer: Nur so lässt
# sich ein Asset aus einem privaten Repository laden. Die ID vergibt GitHub je
# Release neu, sie gehört also bei jedem Anheben mit erneuert.
class Rechnungsgenerator < Formula
  desc "Erzeugt aus YAML eine deutsche Rechnung als geprüftes PDF/A-1b"
  homepage "https://github.com/Fluch-IT-Consulting/rechnungsgenerator"
  url "https://api.github.com/repos/Fluch-IT-Consulting/rechnungsgenerator/releases/assets/579016019",
      headers: [
        "Accept: application/octet-stream",
        "Authorization: Bearer #{ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", "")}",
      ]
  version "0.0.9"
  sha256 "11d1f3b80392131acc773b66566ba86e055b5d0f143247697749a979c4648cc0"
  license "Apache-2.0"

  # Bewusst kein depends_on "openjdk": Auf macOS 14 und älter führt Homebrew
  # keine Bottles mehr (Tier 3) und begänne, JDK 27 aus dem Quelltext zu bauen
  # – nachgemessen bricht das nach Minuten ab, weil die Metal-Toolchain aus
  # vollem Xcode fehlt. Der Gewinn wäre, dass niemand über Java nachdenken
  # muss; der Preis ist ein langer Bau, der in einer Xcode-Meldung endet. Ein
  # Satz in den caveats ist die bessere Fehlermeldung.

  def install
    # Das Archiv ist eine fertige Gradle-Distribution: bin/, lib/ und daneben
    # LICENSE, NOTICE und THIRD-PARTY.md.
    libexec.install Dir["*"]

    # Das Startskript löst Symlinks selbst auf und findet so seine JARs; sein
    # Java sucht es über JAVA_HOME oder den PATH.
    bin.install_symlink libexec/"bin/rechnungsgenerator"
  end

  def caveats
    <<~EOS
      Der Generator braucht zweierlei im PATH:

        * Ein JDK 21 oder neuer. Ein vorhandenes genügt; sonst
            brew install openjdk
          Auf macOS 14 und älter baut Homebrew openjdk aus dem Quelltext –
          dort ist ein fertiges JDK, etwa von Temurin, der schnellere Weg.

        * TeX Live mit lualatex, denn gesetzt wird mit LuaLaTeX:
            brew install --cask mactex-no-gui

      LuaLaTeX prüft das Programm beim Start und sagt, wenn es fehlt.

      Die Lizenzen der mitgelieferten Bibliotheken stehen in
        #{libexec}/THIRD-PARTY.md
    EOS
  end

  test do
    assert_match "rechnungsgenerator #{version}", shell_output("#{bin}/rechnungsgenerator --version")

    # Ohne Unterkommando zeigt das Programm die Hilfe und endet mit 1.
    assert_match "Usage: rechnungsgenerator", shell_output("#{bin}/rechnungsgenerator 2>&1", 1)
  end
end
