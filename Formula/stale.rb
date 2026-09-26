class Stale < Formula
  desc "Find uncommitted and unpushed git work that exists nowhere else"
  homepage "https://github.com/mk24x7/stale"
  url "https://github.com/mk24x7/stale/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/mk24x7/stale.git", branch: "main"

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
    bin.install "dist/stale"
    prefix.install "dist/Stale.app"
  end

  def caveats
    <<~EOS
      Stale.app was compiled on this Mac, so it carries no quarantine attribute
      and opens without a Gatekeeper prompt.

      Open it directly:
        open "#{opt_prefix}/Stale.app"

      Or make it available in /Applications with a symlink (follows upgrades):
        ln -sf "#{opt_prefix}/Stale.app" /Applications/Stale.app

      Or copy it (Spotlight and Launchpad index copies more reliably, but you
      must copy again after each upgrade):
        cp -R "#{opt_prefix}/Stale.app" /Applications/
    EOS
  end

  test do
    assert_match "stale #{version}", shell_output("#{bin}/stale --version") unless build.head?

    # A repository with a commit and no remote is at risk: exit code 3.
    repo = testpath/"scan/project"
    repo.mkpath
    cd repo do
      system "git", "init", "--quiet"
      system "git", "-c", "user.name=Test", "-c", "user.email=test@example.com",
             "commit", "--quiet", "--allow-empty", "-m", "initial"
    end
    output = shell_output("#{bin}/stale #{testpath}/scan --json", 3)
    assert_match "\"noremote\"", output

    app = prefix/"Stale.app"
    executable = app/"Contents/MacOS/Stale"
    assert_path_exists executable
    assert_predicate executable, :executable?
    system "codesign", "--verify", "--deep", "--strict", app
    unless build.head?
      plist_version = shell_output(
        "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' '#{app}/Contents/Info.plist'",
      ).strip
      assert_equal version.to_s, plist_version
    end
  end
end
