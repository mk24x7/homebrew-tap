cask "shadow-app" do
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/mk24x7/shadow/releases/download/v#{version}/Shadow-#{version}-macos-universal.dmg"
  name "Shadow"
  desc "Explains which toolchain binaries run in each shell and why"
  homepage "https://github.com/mk24x7/shadow"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Shadow.app"

  zap trash: [
    "~/Library/Preferences/com.mk24x7.shadow.plist",
    "~/Library/Saved Application State/com.mk24x7.shadow.savedState",
  ]

  caveats <<~EOS
    Shadow is ad-hoc signed and not notarized, and Homebrew no longer offers a
    way to skip quarantine, so macOS will refuse to open it the first time.

    Clear the quarantine attribute after installing:
      xattr -d com.apple.quarantine /Applications/Shadow.app

    Or install the build-from-source formula instead, which compiles Shadow on
    this Mac, adds the shadow CLI, and opens without any Gatekeeper prompt:
      brew uninstall --cask shadow-app
      brew install mk24x7/tap/shadow
  EOS
end
