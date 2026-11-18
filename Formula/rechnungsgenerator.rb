class Rechnungsgenerator < Formula
  desc "Erzeugt aus YAML eine deutsche Rechnung als geprüftes PDF/A-1b"
  homepage "https://github.com/Fluch-IT-Consulting/rechnungsgenerator"
  url "https://github.com/Fluch-IT-Consulting/rechnungsgenerator/releases/download/v0.10.0/rechnungsgenerator-0.10.0.zip"
  sha256 "096f135094d582aa2191d75da6d11967b56591a7c982decb40e1dc9f329c7bae"
  license "Apache-2.0"

  # Bewusst kein depends_on "openjdk": Bottles davon führt Homebrew nur für
  # Apple Silicon ab macOS 15. Auf Intel-Macs und auf macOS 14 begänne es, JDK
  # 27 samt cairo, glib und harfbuzz aus dem Quelltext zu bauen – auf macOS 14
  # nachgemessen bricht das nach Minuten ab, weil die Metal-Toolchain aus
  # vollem Xcode fehlt. Der Gewinn wäre, dass niemand über Java nachdenken
  # muss; der Preis ist ein langer Bau, der in einer Xcode-Meldung endet. Ein
  # Satz in den caveats ist die bessere Fehlermeldung.

  def install
    # Das Archiv ist eine fertige Gradle-Distribution: bin/, lib/, der
    # rechnung-Skill unter skill/ und daneben LICENSE, NOTICE und
    # THIRD-PARTY.md.
    libexec.install Dir["*"]

    # Ein Startskript und kein Symlink: Es reicht dem Programm den Ort des
    # rechnung-Skills über opt/ herein. `skill installieren` legt darauf einen
    # Link an, und nur dieser Pfad überlebt ein `brew upgrade` – das Programm
    # selbst sieht sich unter Cellar/<fassung>. Fassungen vor 0.8.0 kennen die
    # Variable nicht und übergehen sie.
    (bin/"rechnungsgenerator").write_env_script libexec/"bin/rechnungsgenerator",
                                                RECHNUNGSGENERATOR_SKILL: opt_libexec/"skill/rechnung"
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

      Das Paket bringt den Skill "rechnung" für Claude Code mit. Eingehängt
      wird er einmal, als Link unter ~/.claude/skills:
        rechnungsgenerator skill installieren
      Seine Skripte brauchen python3 ab 3.9 mit PyYAML.

      Vor einem "brew uninstall rechnungsgenerator" nimmt
        rechnungsgenerator skill entfernen
      den Link wieder weg; danach gibt es das Kommando nicht mehr. Ist das
      vergessen, genügt
        rm ~/.claude/skills/rechnung

      Die Lizenzen der mitgelieferten Bibliotheken stehen in
        #{libexec}/THIRD-PARTY.md
    EOS
  end

  test do
    assert_match "rechnungsgenerator #{version}", shell_output("#{bin}/rechnungsgenerator --version")

    # Ohne Unterkommando zeigt das Programm die Hilfe und endet mit 1.
    assert_match "Usage: rechnungsgenerator", shell_output("#{bin}/rechnungsgenerator 2>&1", 1)

    # Homebrew gibt dem Test ein leeres Heimatverzeichnis, dort ist nichts
    # eingehängt. Geprüft wird, dass das Kommando da ist und der Skill im
    # Paket liegt, auf den das Startskript zeigt. Verglichen wird ohne Umlaut:
    # Unter der Locale des Tests schreibt Java statt "ä" ein "?".
    assert_match "skills/rechnung gibt es nicht", shell_output("#{bin}/rechnungsgenerator skill status")
    assert_path_exists libexec/"skill/rechnung/SKILL.md"
  end
end
