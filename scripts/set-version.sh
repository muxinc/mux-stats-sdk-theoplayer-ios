#!/usr/bin/env bash
#
# set-version.sh — Set a new release version across the codebase.
#
# Usage:
#   scripts/set-version.sh X.Y.Z
#
set -euo pipefail
IFS=$'\n\t'

# --- Locate the repository root relative to this script -----------------------
# Resolve regardless of the caller's current working directory.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

readonly PODSPEC="${REPO_ROOT}/Mux-Stats-THEOplayer.podspec"
readonly CONSTANTS="${REPO_ROOT}/Sources/MuxStatsTHEOplayer/Constants.swift"
readonly README="${REPO_ROOT}/README.md"

# Temp file used by update_file; cleaned up on exit if a run is interrupted.
TMP_FILE=""
cleanup() {
  if [[ -n "$TMP_FILE" ]]; then
    rm -f "$TMP_FILE"
  fi
}
trap cleanup EXIT

usage() {
  cat >&2 <<EOF
Usage: ${0##*/} <version>

Set a new release version (X.Y.Z) across the podspec, Constants.swift and README.

Arguments:
  version   New semantic version, e.g. 0.15.0 (a leading "v" is accepted).

Example:
  ${0##*/} 0.15.0
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

# update_file <file> <locator-regex> <sed-substitution> <description>
update_file() {
  local file="$1" locator="$2" substitution="$3" description="$4"

  [[ -f "$file" ]] || die "file not found: ${file}"
  grep -Eq "$locator" "$file" \
    || die "could not find ${description} in ${file} (pattern: ${locator})"

  TMP_FILE="$(mktemp)"
  sed -E "$substitution" "$file" >"$TMP_FILE"
  cat "$TMP_FILE" >"$file"
  rm -f "$TMP_FILE"
  TMP_FILE=""

  echo "  ✓ ${description}"
}

main() {
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
  esac

  [[ $# -eq 1 ]] || { usage; die "exactly one argument (the new version) is required"; }

  # Accept an optional leading "v", then validate strict semver X.Y.Z as the
  # README specifies ("X, Y, Z are the major, minor, and patch versions").
  local version="${1#v}"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
    || die "invalid version '${1}'; expected X.Y.Z (e.g. 0.15.0)"

  # major.minor, used for the CocoaPods '~> X.Y' constraint in the README.
  local major_minor="${version%.*}"

  echo "Setting version to ${version} (CocoaPods constraint '~> ${major_minor}')"

  # podspec: s.version          = 'X.Y.Z'
  update_file "$PODSPEC" \
    "^[[:space:]]*s\.version[[:space:]]*=" \
    "s/^([[:space:]]*s\.version[[:space:]]*=[[:space:]]*')[^']*'/\1${version}'/" \
    "podspec s.version"

  # Constants.swift: static let pluginVersion = "X.Y.Z"
  update_file "$CONSTANTS" \
    "static let pluginVersion[[:space:]]*=" \
    "s/(static let pluginVersion[[:space:]]*=[[:space:]]*\")[^\"]*\"/\1${version}\"/" \
    "Constants.swift pluginVersion"

  # README Swift Package Manager snippet: .upToNextMajor(from: "X.Y.Z")
  update_file "$README" \
    "\.upToNextMajor\(from:[[:space:]]*\"" \
    "s/(\.upToNextMajor\(from:[[:space:]]*\")[^\"]*\"/\1${version}\"/" \
    "README Swift Package Manager version"

  # README CocoaPods snippet: pod 'Mux-Stats-THEOplayer', '~> X.Y'
  update_file "$README" \
    "pod 'Mux-Stats-THEOplayer',[[:space:]]*'~>" \
    "s/(pod 'Mux-Stats-THEOplayer',[[:space:]]*'~>[[:space:]]*)[^']*'/\1${major_minor}'/" \
    "README CocoaPods version"

  echo
  echo "Done. Review the changes with 'git diff' before committing."
}

main "$@"
