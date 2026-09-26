class Prune < Formula
  desc "Native macOS app that finds and removes regenerable developer artifacts"
  homepage "https://github.com/mk24x7/prune"
  url "https://github.com/mk24x7/prune/archive/refs/tags/v4.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/mk24x7/prune.git", branch: "main"

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
    prefix.install "dist/Prune.app"
  end

  def caveats
    <<~EOS
      Prune.app was compiled on this Mac, so it carries no quarantine attribute
      and opens without a Gatekeeper prompt.

      Open it directly:
        open "#{opt_prefix}/Prune.app"

      Or make it available in /Applications with a symlink (follows upgrades):
        ln -sf "#{opt_prefix}/Prune.app" /Applications/Prune.app

      Or copy it (Spotlight and Launchpad index copies more reliably, but you
      must copy again after each upgrade):
        cp -R "#{opt_prefix}/Prune.app" /Applications/
    EOS
  end

  test do
    app = prefix/"Prune.app"
    executable = app/"Contents/MacOS/Prune"
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
