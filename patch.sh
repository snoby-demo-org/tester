#!/usr/bin/env bash
# Vendor upstream source into ./src + apply local patches.
set -euo pipefail
UPSTREAM="${1:-https://github.com/CivicLight/CivicNet.git}"
SRC_DIR="src"

if [ ! -d "$SRC_DIR/.git" ]; then
  echo "Cloning upstream $UPSTREAM into $SRC_DIR/ ..."
  git clone "$UPSTREAM" "$SRC_DIR"
else
  echo "Refreshing $SRC_DIR from upstream ..."
  git -C "$SRC_DIR" fetch origin
  git -C "$SRC_DIR" reset --hard origin/master
fi

echo "Applying patches from patches/ ..."
for p in patches/*.patch; do
  [ -e "$p" ] || continue
  echo "  $p"
  patch -p1 -d "$SRC_DIR" < "$p" || { echo "FAILED: $p"; exit 1; }
done
echo "Patches applied."
echo "Build with: ./build.sh"
