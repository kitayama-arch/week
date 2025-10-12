#!/usr/bin/env bash
set -euo pipefail

SRC_PATH="${SRCROOT}/Config/GoogleService-Info.plist"
DEST_PATH="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ ! -f "${SRC_PATH}" ]; then
  echo "⚠️  Missing Config/GoogleService-Info.plist. Please place the file before building." >&2
  exit 1
fi

mkdir -p "$(dirname "${DEST_PATH}")"
cp "${SRC_PATH}" "${DEST_PATH}"

echo "Copied GoogleService-Info.plist into app bundle."
