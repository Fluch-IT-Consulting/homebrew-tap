class Rechnungsgenerator < Formula
  desc "Erzeugt aus YAML eine deutsche Rechnung als geprüftes PDF/A-1b"
  homepage "https://github.com/Fluch-IT-Consulting/rechnungsgenerator"
  url "https://github.com/Fluch-IT-Consulting/rechnungsgenerator/releases/download/v0.7.3/rechnungsgenerator-0.7.3.zip"
  sha256 "b7dea9ae14f9d5a505474ac4497eab07f382c2f134a370a802ccf0115fc7d705"
  license "Apache-2.0"

  # Bewusst kein depends_on "openjdk": Bottles davon führt Homebrew nur für
  # Apple Silicon ab macOS 15. Auf Intel-Macs und auf macOS 14 begänne es, JDK
  # 27 samt cairo, glib und harfbuzz aus dem Quelltext zu bauen – auf macOS 14
  # nachgemessen bricht das nach Minuten ab, weil die Metal-Toolchain aus
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
          Auf Intel-Macs und auf macOS 14 baut Homebrew openjdk aus dem
          Quelltext – dort ist ein fertiges JDK, etwa von Temurin, der
          schnellere Weg.

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
