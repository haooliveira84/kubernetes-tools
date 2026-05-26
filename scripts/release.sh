#!/usr/bin/env bash
# Release helper: bumps the version in bin/__common, commits, tags and pushes.
# The remote tag push triggers .github/workflows/release.yml which creates
# the GitHub Release and opens a PR bumping the Homebrew formula.
#
# Usage:
#   scripts/release.sh <version>   # e.g. scripts/release.sh 2.3.0
#
# Requirements: clean working tree, git remote configured, push permission.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>  (e.g. $0 2.3.0)" >&2
  exit 1
fi

VERSION="${1#v}"
TAG="v${VERSION}"

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$ ]]; then
  echo "Invalid version: $VERSION (expected MAJOR.MINOR.PATCH[-pre])" >&2
  exit 1
fi

cd "$(git rev-parse --show-toplevel)"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash changes first." >&2
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists." >&2
  exit 1
fi

echo "==> Bumping bin/__common to $TAG"
sed -i.bak -E "s/^__version=\"v[^\"]+\"/__version=\"${TAG}\"/" bin/__common
rm -f bin/__common.bak

if git diff --quiet -- bin/__common; then
  echo "Version in bin/__common already at $TAG, nothing to commit."
else
  git add bin/__common
  git commit -m "Release ${TAG}"
fi

echo "==> Tagging ${TAG}"
git tag -a "$TAG" -m "Release ${TAG}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "==> Pushing ${CURRENT_BRANCH} and ${TAG}"
git push origin "$CURRENT_BRANCH"
git push origin "$TAG"

cat <<EOF

Release ${TAG} pushed.

The GitHub Actions 'Release' workflow will:
  1. Create the GitHub Release with auto-generated notes.
  2. Compute the tarball SHA-256.
  3. Open a PR bumping Formula/kubernetes-tools.rb.
  4. (Optional) Bump the formula in the configured Homebrew tap.

Watch progress:
  gh run watch
EOF
