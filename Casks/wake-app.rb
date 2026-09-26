cask "wake-app" do
  version "1.0.0"
  sha256 "485cfe8784b88f105b03e02b1866fbd8bb7fd66972975d721895ce95dd39226f"

  url "https://github.com/mk24x7/wake/releases/download/v#{version}/Wake-#{version}-macos-universal.dmg"
  name "Wake"
  desc "Shows wake reasons, sleep blockers and battery drain in plain English"
  homepage "https://github.com/mk24x7/wake"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Wake.app"

  zap trash: [
    "~/Library/Preferences/com.mk24x7.wake.plist",
    "~/Library/Saved Application State/com.mk24x7.wake.savedState",
  ]

  caveats <<~EOS
    Wake is ad-hoc signed and not notarized, and Homebrew no longer offers a
    way to skip quarantine, so macOS will refuse to open it the first time.

    Clear the quarantine attribute after installing:
      xattr -d com.apple.quarantine /Applications/Wake.app

    Or install the build-from-source formula instead, which compiles Wake on
    this Mac, adds the wake command and opens without any Gatekeeper prompt:
      brew uninstall --cask wake-app
      brew install mk24x7/tap/wake
  EOS
end
