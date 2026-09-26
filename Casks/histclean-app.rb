cask "histclean-app" do
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/mk24x7/histclean/releases/download/v#{version}/Histclean-#{version}-macos-universal.dmg"
  name "Histclean"
  desc "Finds and redacts secrets in shell and REPL history files"
  homepage "https://github.com/mk24x7/histclean"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Histclean.app"

  zap trash: [
    "~/.histclean",
    "~/Library/Logs/Histclean",
    "~/Library/Preferences/com.mk24x7.histclean.plist",
    "~/Library/Saved Application State/com.mk24x7.histclean.savedState",
  ]

  caveats <<~EOS
    Histclean is ad-hoc signed and not notarized, and Homebrew no longer offers a
    way to skip quarantine, so macOS will refuse to open it the first time.

    Clear the quarantine attribute after installing:
      xattr -d com.apple.quarantine /Applications/Histclean.app

    Or install the build-from-source formula instead, which compiles Histclean on
    this Mac and opens without any Gatekeeper prompt:
      brew uninstall --cask histclean-app
      brew install mk24x7/tap/histclean
  EOS
end
