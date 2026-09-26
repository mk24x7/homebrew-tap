class Shadow < Formula
  desc "Explain which node, python and java run in each shell, and why"
  homepage "https://github.com/mk24x7/shadow"
  url "https://github.com/mk24x7/shadow/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/mk24x7/shadow.git", branch: "main"

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
    bin.install "dist/shadow"
    prefix.install "dist/Shadow.app"
  end

  def caveats
    <<~EOS
      The shadow command line tool is on your PATH. Shadow.app was compiled on
      this Mac, so it carries no quarantine attribute and opens without a
      Gatekeeper prompt.

      Open it directly:
        open "#{opt_prefix}/Shadow.app"

      Or make it available in /Applications with a symlink (follows upgrades):
        ln -sf "#{opt_prefix}/Shadow.app" /Applications/Shadow.app
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/shadow --version") unless version.head?
    assert_match "usage: shadow", shell_output("#{bin}/shadow --help")
    shell_output("#{bin}/shadow --shell nosuchshell 2>&1", 2)
    app = prefix/"Shadow.app"
    assert_path_exists app/"Contents/MacOS/Shadow"
    system "codesign", "--verify", "--deep", "--strict", app
  end
end
