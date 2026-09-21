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
  version "0.1.0"
  sha256 "11d1f3b80392131acc773b66566ba86e055b5d0f143247697749a979c4648cc0"
  license "Apache-2.0"

  depends_on "openjdk"

  def install
    # Das Archiv ist eine fertige Gradle-Distribution: bin/, lib/ und daneben
    # LICENSE, NOTICE und THIRD-PARTY.md.
    libexec.install Dir["*"]

    # Nicht bin.install_symlink: Das Startskript sucht sein JAVA. Ohne gesetztes
    # JAVA_HOME nähme es das erste java im PATH – und das kann jede Fassung sein
    # oder keine.
    (bin/"rechnungsgenerator").write_env_script libexec/"bin/rechnungsgenerator",
                                                JAVA_HOME: Formula["openjdk"].opt_prefix
  end

  def caveats
    <<~EOS
      Der Generator setzt mit LuaLaTeX. TeX Live muss im PATH liegen:

        brew install --cask mactex-no-gui

      Das Programm prüft das beim Start und sagt, was fehlt.

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
