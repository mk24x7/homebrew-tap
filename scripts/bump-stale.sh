#!/bin/bash
# Point the stale formula and the stale-app cask at a new release: download
# the source tarball and the DMG, compute their SHA-256, rewrite the files,
# commit "stale VERSION" and push.
#
# Usage: scripts/bump-stale.sh VERSION  (for example 1.1.0, with or without v)
#
# Environment:
#   NO_PUSH=1   commit locally but do not push
#   NO_COMMIT=1 only rewrite the files
#   SOURCE_URL, DMG_URL  override the download URLs (testing only)
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "usage: $0 VERSION" >&2
    exit 2
fi
VERSION="${1#v}"
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "error: '$1' is not a version of the form X.Y.Z" >&2
    exit 2
fi

cd "$(dirname "$0")/.."

REPO="mk24x7/stale"
SOURCE_URL="${SOURCE_URL:-https://github.com/$REPO/archive/refs/tags/v$VERSION.tar.gz}"
DMG_URL="${DMG_URL:-https://github.com/$REPO/releases/download/v$VERSION/Stale-$VERSION-macos-universal.dmg}"
FORMULAE=(Formula/stale.rb)
CASK="Casks/stale-app.rb"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    else
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

fetch() {
    echo "Downloading $1" >&2
    curl --fail --silent --show-error --location \
        --retry 5 --retry-delay 5 --retry-all-errors \
        --output "$2" "$1"
}

fetch "$SOURCE_URL" "$WORK/source.tar.gz"
fetch "$DMG_URL" "$WORK/app.dmg"
SOURCE_SHA="$(sha256_of "$WORK/source.tar.gz")"
DMG_SHA="$(sha256_of "$WORK/app.dmg")"
echo "source tarball sha256: $SOURCE_SHA"
echo "dmg sha256:            $DMG_SHA"

for formula in "${FORMULAE[@]}"; do
    VERSION="$VERSION" SHA="$SOURCE_SHA" perl -i -pe '
        s{^(\s*url "https://github\.com/mk24x7/stale/archive/refs/tags/v)[^"]+(\.tar\.gz")}{$1$ENV{VERSION}$2};
        s{^(\s*sha256 ")[0-9a-f]{64}(")}{$1$ENV{SHA}$2};
    ' "$formula"
done

VERSION="$VERSION" SHA="$DMG_SHA" perl -i -pe '
    s{^(\s*version ")[^"]+(")}{$1$ENV{VERSION}$2};
    s{^(\s*sha256 ")[0-9a-f]{64}(")}{$1$ENV{SHA}$2};
' "$CASK"

for file in "${FORMULAE[@]}"; do
    grep -q "refs/tags/v$VERSION.tar.gz" "$file" || { echo "error: failed to update url in $file" >&2; exit 1; }
    grep -q "sha256 \"$SOURCE_SHA\"" "$file" || { echo "error: failed to update sha256 in $file" >&2; exit 1; }
done
grep -q "version \"$VERSION\"" "$CASK" || { echo "error: failed to update version in $CASK" >&2; exit 1; }
grep -q "sha256 \"$DMG_SHA\"" "$CASK" || { echo "error: failed to update sha256 in $CASK" >&2; exit 1; }

git --no-pager diff --stat -- "${FORMULAE[@]}" "$CASK"

if git diff --quiet -- "${FORMULAE[@]}" "$CASK"; then
    echo "Already at $VERSION; nothing to commit."
    exit 0
fi
if [ "${NO_COMMIT:-0}" = "1" ]; then
    exit 0
fi

git add -- "${FORMULAE[@]}" "$CASK"
git commit -m "stale $VERSION"
if [ "${NO_PUSH:-0}" = "1" ]; then
    echo "Committed locally (NO_PUSH=1)."
    exit 0
fi
git push origin HEAD
