class PruneCli < Formula
  desc "Find and remove regenerable developer artifacts from the command-line"
  homepage "https://github.com/mk24x7/prune"
  url "https://github.com/mk24x7/prune/archive/refs/tags/v4.0.0.tar.gz"
  sha256 "a89057d295c67e25bedccd91f1783272d17ad83ff5a217d762b34af64b2b7436"
  license "MIT"
  head "https://github.com/mk24x7/prune.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "node"

  def install
    # The npm package ships artifacts.json next to package.json. npm normally
    # copies it there in prepack, but Homebrew packs with scripts disabled, so
    # copy it from the repository root here.
    cp "Definitions/artifacts.json", "cli/artifacts.json"
    cd "cli" do
      system "npm", "install", *std_npm_args
    end
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/prune --version")
    assert_match "Usage", shell_output("#{bin}/prune --help")
  end
end
