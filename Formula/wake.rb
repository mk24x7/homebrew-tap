class Wake < Formula
  desc "Explain wake reasons, sleep blockers and battery drain in plain English"
  homepage "https://github.com/mk24x7/wake"
  url "https://github.com/mk24x7/wake/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "5a3eb2921c9ad203bc53eba9df3e38578e3136f6680df20e9f261d3fcb86c894"
  license "MIT"
  head "https://github.com/mk24x7/wake.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on xcode: ["15.0", :build]
  depends_on macos: :ventura

  def install
    # The source tarball carries no git metadata, so pass the version and build
    # number explicitly instead of letting build.sh derive them from git.
    if build.head?
      ENV["VERSION"] = (buildpath/"VERSION").read.strip
      ENV["BUILD_NUMBER"] = "1"
    else
      ENV["VERSION"] = version.to_s
      ENV["BUILD_NUMBER"] = version.to_s
    end
    ENV["OUT_DIR"] = "dist"
    # SwiftPM's own sandbox cannot be nested inside Homebrew's build sandbox.
    ENV["SWIFT_FLAGS"] = "--disable-sandbox"

    system "./build.sh"
    bin.install "dist/wake"
    prefix.install "dist/Wake.app"
  end

  def caveats
    <<~EOS
      The wake command is on your PATH. Wake.app was compiled on this Mac, so it
      carries no quarantine attribute and opens without a Gatekeeper prompt.

      Open it directly:
        open "#{opt_prefix}/Wake.app"

      Or make it available in /Applications with a symlink (follows upgrades):
        ln -sf "#{opt_prefix}/Wake.app" /Applications/Wake.app

      Or copy it (Spotlight and Launchpad index copies more reliably, but you
      must copy again after each upgrade):
        cp -R "#{opt_prefix}/Wake.app" /Applications/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wake --version") unless version.head?
    assert_match "Usage", shell_output("#{bin}/wake --help")
    # Unknown options are usage errors (exit status 2).
    shell_output("#{bin}/wake --bogus 2>&1", 2)
    app = prefix/"Wake.app"
    executable = app/"Contents/MacOS/Wake"
    assert_path_exists executable
    assert_predicate executable, :executable?
    system "codesign", "--verify", "--deep", "--strict", app
    unless version.head?
      plist_version = shell_output(
        "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' '#{app}/Contents/Info.plist'",
      ).strip
      assert_equal version.to_s, plist_version
    end
  end
end
