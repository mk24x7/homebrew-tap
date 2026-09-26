# mk24x7/homebrew-tap

Homebrew formulae and casks for tools by [mk24x7](https://github.com/mk24x7).

## Prune

[Prune](https://github.com/mk24x7/prune) finds and removes regenerable
developer artifacts (node_modules, Rust target, Xcode DerivedData, package
manager caches and more) on macOS. Pick one of the install paths below, in
order of preference.

### 1. Build from source (recommended)

```sh
brew install mk24x7/tap/prune
```

Compiles Prune.app on your Mac with Xcode. Locally built apps carry no
quarantine attribute, so the app opens with no Gatekeeper prompt. The app is
installed into the Homebrew prefix; `brew info mk24x7/tap/prune` prints the
command to link or copy it into /Applications.

### 2. Direct download

Download `Prune-X.Y.Z-macos-universal.dmg` (or the `.zip`) and
`SHA256SUMS.txt` from the
[latest release](https://github.com/mk24x7/prune/releases/latest), verify it
with `shasum -a 256 -c SHA256SUMS.txt --ignore-missing`, and drag Prune.app to
/Applications. See the Gatekeeper note below before opening it.

### 3. Prebuilt app via cask

```sh
brew install --cask mk24x7/tap/prune-app
xattr -d com.apple.quarantine /Applications/Prune.app
```

Installs the prebuilt universal app from the GitHub release. Homebrew no
longer has a flag to skip quarantine, so clear it yourself with the `xattr`
command above.

### 4. Command-line tool

```sh
npm install -g prune-cli
# or, without installing
npx prune-cli --all --dry-run
```

A Homebrew formula for the CLI is also available:
`brew install mk24x7/tap/prune-cli` (depends on Node.js).

## Gatekeeper note

Prune is ad-hoc signed and not notarized by Apple. Anything you download with
a browser or install with the cask is quarantined, and macOS refuses to open
it the first time. Either:

- run `xattr -d com.apple.quarantine /Applications/Prune.app` once, or
- open the app, dismiss the "Not Opened" dialog, then go to
  System Settings > Privacy & Security and click Open Anyway. The button is
  offered only for about an hour after the blocked launch.

The build-from-source formula (option 1) avoids this entirely.

## Maintenance

Releases of mk24x7/prune update this tap automatically: the prune release
workflow runs `scripts/bump.sh VERSION`, which downloads the new source
tarball and DMG, updates the sha256 values and pushes a `prune VERSION`
commit. To bump by hand:

```sh
scripts/bump.sh 4.1.0
```
