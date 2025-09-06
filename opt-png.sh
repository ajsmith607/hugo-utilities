#!/usr/bin/env bash
# - Removes metadata that doesn’t affect appearance (--strip safe).
# - Disables Adam7 interlace (saves bytes).
# - Tries stronger deflate (zopfli) and advpng recompress.
# - Replaces only if smaller. Preserves mtime.
# Fallback script that DOESN’T require oxipng (uses what’s available)
# Saves only if smaller, keeps mtimes. Lossless. Optional lossy palette via PNGQUANT=1

# Dependencies (Debian/Ubuntu)
# sudo apt update
# sudo apt install -y oxipng optipng advancecomp zopfli pngcrush pngquant
set -euo pipefail
shopt -s nullglob

PNGQUANT="${PNGQUANT:-0}"

has(){ command -v "$1" >/dev/null 2>&1; }

mapfile -d '' files < <(find . -type f \( -iname '*.png' \) -print0)

for f in "${files[@]}"; do
  orig=$(stat -c %s -- "$f")
  tmp="$(mktemp --suffix=.png)"; trap 'rm -f "$tmp" "$tmp".z "$tmp".q 2>/dev/null || true' RETURN

  if has oxipng; then
    oxipng -q -o4 -i 0 --strip safe --out "$tmp" -- "$f"
  else
    cp -- "$f" "$tmp"
    has optipng  && optipng -quiet -o3 -strip all "$tmp"
    has pngcrush && pngcrush -q -rem alla -brute -reduce -ow "$tmp" >/dev/null 2>&1 || true
    if has zopflipng; then
      zopflipng -y --filters=0me --iterations=15 -- "$tmp" "$tmp".z >/dev/null 2>&1 || true
      [[ -s "$tmp".z && $(stat -c %s "$tmp".z) -lt $(stat -c %s "$tmp") ]] && mv -f -- "$tmp".z "$tmp"
    fi
    has advpng    && advpng -z4 -q -- "$tmp" || true
  fi

  # Optional (lossy) palette quantization for flat/UI art
  if [[ "$PNGQUANT" == "1" ]] && has pngquant; then
    pngquant --force --skip-if-larger --strip --quality=80-100 --output "$tmp".q -- "$f" 2>/dev/null || true
    [[ -s "$tmp".q && $(stat -c %s "$tmp".q) -lt $(stat -c %s "$tmp") ]] && mv -f -- "$tmp".q "$tmp"
  fi

  [[ -s "$tmp" ]] || { echo "• $f  (no output)"; continue; }
  new=$(stat -c %s -- "$tmp")
  if (( new < orig )); then
    touch -r "$f" "$tmp"
    mv -f -- "$tmp" "$f"
    printf "✓ %s  %d→%d (-%d%%)\n" "$f" "$orig" "$new" $(( (orig-new)*100 / orig ))
  else
    rm -f -- "$tmp"
    printf "• %s  no gain\n" "$f"
  fi
done
