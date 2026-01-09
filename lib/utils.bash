#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="git-crypt"
TOOL_REPO="AGWA/git-crypt"
BINARY_NAME="git-crypt"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  local curl_opts=(-sL)
  [[ -n "${GITHUB_TOKEN:-}" ]] && curl_opts+=(-H "Authorization: token $GITHUB_TOKEN")
  curl "${curl_opts[@]}" "https://api.github.com/repos/$TOOL_REPO/tags" 2>/dev/null | \
    grep -o '"name": "[^"]*"' | sed 's/"name": "//' | sed 's/"$//' | sort -V
}

download_release() {
  local version="$1" download_path="$2"
  local url="https://github.com/$TOOL_REPO/archive/refs/tags/${version}.tar.gz"
  local archive="$download_path/git-crypt.tar.gz"

  echo "Downloading git-crypt $version source..."
  curl -fsSL "$url" -o "$archive" || fail "Download failed"
  tar -xzf "$archive" -C "$download_path" --strip-components=1

  echo "Compiling git-crypt..."
  cd "$download_path"
  make || fail "Compilation failed. Install dependencies: openssl-devel"
  rm -f "$archive"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"
  mkdir -p "$install_path/bin"
  cp "$ASDF_DOWNLOAD_PATH/git-crypt" "$install_path/bin/"
  chmod +x "$install_path/bin/git-crypt"
}
