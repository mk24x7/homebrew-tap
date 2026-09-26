cask "stale-app" do
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/mk24x7/stale/releases/download/v#{version}/Stale-#{version}-macos-universal.dmg"
  name "Stale"
  desc "Finds uncommitted and unpushed git work that exists nowhere else"
  homepage "https://github.com/mk24x7/stale"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Stale.app"

  zap trash: [
    "~/Library/Preferences/com.mk24x7.stale.plist",
    "~/Library/Saved Application State/com.mk24x7.stale.savedState",
  ]

  caveats <<~EOS
    Stale is ad-hoc signed and not notarized, and Homebrew no longer offers a
    way to skip quarantine, so macOS will refuse to open it the first time.

    Clear the quarantine attribute after installing:
      xattr -d com.apple.quarantine /Applications/Stale.app

    Or install the build-from-source formula instead, which compiles Stale on
    this Mac, installs the stale command, and opens without any Gatekeeper prompt:
      brew uninstall --cask stale-app
      brew install mk24x7/tap/stale
  EOS
end
