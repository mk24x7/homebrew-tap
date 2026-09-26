class Histclean < Formula
  desc "Find secrets in shell and REPL history files and redact them in place"
  homepage "https://github.com/mk24x7/histclean"
  url "https://github.com/mk24x7/histclean/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/mk24x7/histclean.git", branch: "main"

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
    bin.install "dist/histclean"
    prefix.install "dist/Histclean.app"
  end

  def caveats
    <<~EOS
      The histclean command line tool is on your PATH. Scanning is read-only;
      nothing changes until you pass --redact or --delete-lines.

      Histclean.app was compiled on this Mac, so it carries no quarantine
      attribute and opens without a Gatekeeper prompt.

      Open it directly:
        open "#{opt_prefix}/Histclean.app"

      Or make it available in /Applications with a symlink (follows upgrades):
        ln -sf "#{opt_prefix}/Histclean.app" /Applications/Histclean.app
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/histclean --version") unless version.head?
    assert_match "Usage: histclean", shell_output("#{bin}/histclean --help")
    assert_match "No secrets found", pipe_output("#{bin}/histclean --stdin", "ls\n", 0)
    pipe_output("#{bin}/histclean --stdin", "PGPASSWORD=EXAMPLEpass psql\n", 3)
    shell_output("#{bin}/histclean --no-such-flag 2>&1", 2)
    app = prefix/"Histclean.app"
    assert_path_exists app/"Contents/MacOS/Histclean"
    system "codesign", "--verify", "--deep", "--strict", app
  end
end
