#!/usr/bin/env bash
set -Eeuo pipefail

# ──────────────────────────────────────────────
# Paths
SITE_DIR="${1:-$(pwd)}"
BLOCK_DIR="$SITE_DIR/content/_assets/blocks"
ASSET_DIR="$SITE_DIR/content/_assets/images"
PYTHON_SCRIPT="compile-assets.sh"

# ──────────────────────────────────────────────
# Pre-run checks and initial steps
echo "🏗️  Starting development environment in: $SITE_DIR"

if command -v "$PYTHON_SCRIPT" >/dev/null 2>&1; then
  echo "⚙️  Running $PYTHON_SCRIPT (initial)..."
  "$PYTHON_SCRIPT" || echo "⚠️  $PYTHON_SCRIPT exited non-zero, continuing"
else
  echo "⚠️  $PYTHON_SCRIPT not found in PATH or not executable."
fi

# Show largest images (for awareness)
echo "📸 Top 10 largest images:"
find "$ASSET_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) -size +6M \
  -exec du -h '{}' + 2>/dev/null | sort -hr | head -10 || true

# ──────────────────────────────────────────────
# Utility: find parent pages that reference a given block or image
find_parents() {
  local changed="$1"
  local base
  base="$(basename "$changed" | sed 's/\..*$//')"
  grep -rl "{{< *\(block\|figure\)[^>]*$base" "$SITE_DIR/content" || true
}


bump_mtime() {
  # usage: bump_mtime FILE seconds
  local f="$1"; local seconds="${2:-2}"
  # portable mtime bump (GNU coreutils or busybox may differ)
  # Try GNU touch -d; if not, fall back to perl utime.
  if touch -m -d "@$(( $(date +%s) + seconds ))" "$f" 2>/dev/null; then
    return
  else
    perl -e 'my ($s,$f)=@ARGV; utime time+$s, time+$s, $f' "$seconds" "$f"
  fi
}


# ──────────────────────────────────────────────
# Unified watcher for both blocks and images
watch_blocks_and_assets() {
  echo "👁️  Watching:"
  echo "   - $BLOCK_DIR"
  echo "   - $ASSET_DIR"

  inotifywait -mq -e close_write --format '%w%f' -r \
    "$BLOCK_DIR" "$ASSET_DIR" |
  while read -r changed_file; do
    echo "🔄 Detected change: $changed_file"

    # For image sidecar markdowns (*.md), recompile metadata
    if [[ "$changed_file" == *"_assets/images/"* && "$changed_file" == *.md ]]; then
      echo "⚙️  Running compile-assets.sh for $changed_file"
      "$PYTHON_SCRIPT" --changed "$changed_file" || true
    fi

    # Touch parent pages that include this block/image
    for parent in $(find_parents "$changed_file"); do
      echo "👉 Touching parent page: $parent"
      #sleep 0.35     # let Hugo finish its first (irrelevant) rebuild
      bump_mtime "$parent" 2
    done
  done
}

# ──────────────────────────────────────────────
# Start Hugo server in background
HUGO_CMD=(
  hugo server
  --environment development
  --ignoreCache 
  --noHTTPCache
  --renderToMemory
  --navigateToChanged
)
echo "🚀 Launching Hugo: ${HUGO_CMD[*]}"
"${HUGO_CMD[@]}" &

# Get Hugo PID for cleanup
HUGO_PID=$!

# ──────────────────────────────────────────────
# Start watcher in background
watch_blocks_and_assets &
WATCH_PID=$!

# ──────────────────────────────────────────────
# Graceful shutdown
trap 'echo "🛑 Stopping..."; kill $HUGO_PID $WATCH_PID 2>/dev/null || true; wait' SIGINT SIGTERM

# Wait for both background jobs
wait


