# Cask für MacVocTrain aus dem öffentlichen Repository MacVocTrainNg.
#
# Die App ist mit einem Apple-Development-Zertifikat signiert, aber nicht
# notarisiert. Homebrew stellt jede App aus einer Cask unter Quarantäne, also
# muss der erste Start einmal erlaubt werden. Bei `brew upgrade` übernimmt
# Homebrew diese Freigabe, solange die neue Fassung dieselbe Signatur trägt.
#
# version und sha256 hebt der Release-Workflow der App an (tap-bump.yml); die
# URL folgt der Fassung.
cask "macvoctrain" do
  version "0.7.0"
  sha256 "549e97aa87b41f4b7280011aa91a5a66ce34f811113da93c48b4a9b91828abac"

  url "https://github.com/Fluch-IT-Consulting/MacVocTrainNg/releases/download/v#{version}/MacVocTrain-#{version}.dmg"
  name "MacVocTrain"
  desc "Vokabeltrainer mit verteilter Wiederholung nach FSRS"
  homepage "https://github.com/Fluch-IT-Consulting/MacVocTrainNg"

  depends_on macos: :sonoma

  app "MacVocTrain.app"

  zap trash: [
    "~/Library/Application Scripts/com.mfluch.MacVocTrainNg",
    "~/Library/Containers/com.mfluch.MacVocTrainNg",
  ]

  caveats <<~EOS
    MacVocTrain ist nicht notarisiert. Beim ersten Start blockiert macOS die
    App; erlauben lässt sie sich einmalig unter

      Systemeinstellungen → Datenschutz & Sicherheit → Dennoch öffnen

    Nach einem `brew upgrade` startet die neue Fassung ohne Rückfrage.
  EOS
end
