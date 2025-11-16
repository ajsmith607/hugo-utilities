#!//bin/env bash

# move-with-rsync.sh — Move (not copy) the *contents* of CWD into DEST,
# merging into existing tree, creating dirs as needed, and logging destination paths.
# - Shows a preview, asks for confirmation.
# - Skips/does not touch files that already exist at DEST (keeps sources for those).
# - Removes sources only for files that were actually transferred.
# - Cleans up now-empty directories in the source.
# Requires: rsync ≥ 3.x

set -euo pipefail

# ====== CONFIG ======
DEST="${HOME}/Dropbox/business/code/hugo/memills/content/_assets/images"   # <-- set this

# Optional: exclude patterns (uncomment/edit as needed)
# List patterns/paths here (relative to CWD). Missing files are fine.
EXCLUDE_PATTERNS=(
  ".figifytmp/"
  "moved.log"
)

# Optional: exclude-from file (used only if it exists)
EXCLUDE_FILE=".rsyncignore"
# -------------------

# Begin by optimizing images 
opt-png.sh
opt-jpg.sh

# Build rsync exclude args safely (never treated as extra sources)
RSYNC_FILTER=()
for pat in "${EXCLUDE_PATTERNS[@]}"; do
  RSYNC_FILTER+=( --exclude "$pat" )
done
[[ -f "$EXCLUDE_FILE" ]] && RSYNC_FILTER+=( --exclude-from "$EXCLUDE_FILE" )
# ====================

# ----- Resolve absolute, sanity checks -----
SRC="$(pwd -P)"
LOG_FILE="${SRC%/}/moved.log"            # appended log of destination paths
DEST="$(realpath -m -- "$DEST")"

if ! command -v rsync >/dev/null 2>&1; then
  echo "ERROR: rsync not found." >&2
  exit 1
fi

if [[ "$SRC" == "$DEST" ]]; then
  echo "ERROR: DEST is the current directory; aborting." >&2
  exit 1
fi

# Prevent moving into a subdir of the source (would recurse forever)
case "$DEST" in
    "$SRC"/*) echo "ERROR: DEST ($DEST) is inside SRC ($SRC); aborting." >&2; exit 1;;
esac

# ----- Build common rsync args -----
# -a : archive (permissions, times, recursive)
# -v : verbose (we'll still format output)
# --ignore-existing : don't overwrite/touch existing files at DEST
# --remove-source-files : delete each source file *after* a successful transfer
# --partial : keep partial files if interrupted
# Trailing slashes: "./" -> copy *contents* of CWD, not the directory itself; "$DEST/" -> target dir
COMMON_ARGS=(-a -v --ignore-existing --partial "${RSYNC_FILTER[@]}")

# ----- PREVIEW -----
echo "Preview of NEW files/dirs that will be MOVED to: $DEST"
# Dry-run list of *new* items (that don't already exist at DEST)
rsync --dry-run "${COMMON_ARGS[@]}" ./ "$DEST/" \
  --out-format='%n' \
  | sed '/^$/d' | sed 's#^\./##' | sort | tee /tmp/rsync_move_preview.$$ || true

NEW_COUNT="$(wc -l </tmp/rsync_move_preview.$$ | tr -d ' ')"
if [[ "$NEW_COUNT" -eq 0 ]]; then
  echo "Nothing to move (no new files)."
  rm -f /tmp/rsync_move_preview.$$
  exit 0
fi

echo "----------"
echo "NOTE: Existing files at DEST are left untouched and will NOT be moved/overwritten."
echo "Proceed to MOVE $NEW_COUNT item(s)? [y/N]"
read -r reply
if [[ ! "$reply" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  rm -f /tmp/rsync_move_preview.$$
  exit 1
fi
rm -f /tmp/rsync_move_preview.$$

# ----- EXECUTE MOVE -----
# We want the log to contain DESTINATION paths actually written.
RSYNC_OUT_FMT="${DEST}/%n"

echo "Moving files..."
# shellcheck disable=SC2086
rsync "${COMMON_ARGS[@]}" --remove-source-files \
  --out-format="$RSYNC_OUT_FMT" \
  ./ "$DEST/" | tee -a "$LOG_FILE"

# ----- CLEANUP EMPTY DIRS IN SOURCE -----
# Remove empty directories left behind (but not the top-level ".")
find . -depth -mindepth 1 -type d -empty -print -delete

echo "Done."
echo "Appended destination paths to: $LOG_FILE"
