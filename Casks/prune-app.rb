cask "prune-app" do
  version "4.0.0"
  sha256 "2f08630ac48875ae4c1e4580024d03097c2e4d1df224ad10a0b74fb7e52b41b4"

  url "https://github.com/mk24x7/prune/releases/download/v#{version}/Prune-#{version}-macos-universal.dmg"
  name "Prune"
  desc "Finds and removes regenerable developer artifacts"
  homepage "https://github.com/mk24x7/prune"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Prune.app"

  zap trash: [
    "~/Library/Preferences/com.mk24x7.prune.plist",
    "~/Library/Saved Application State/com.mk24x7.prune.savedState",
  ]

  caveats <<~EOS
    Prune is ad-hoc signed and not notarized, and Homebrew no longer offers a
    way to skip quarantine, so macOS will refuse to open it the first time.

    Clear the quarantine attribute after installing:
      xattr -d com.apple.quarantine /Applications/Prune.app

    Or install the build-from-source formula instead, which compiles Prune on
    this Mac and opens without any Gatekeeper prompt:
      brew uninstall --cask prune-app
      brew install mk24x7/tap/prune
  EOS
end
