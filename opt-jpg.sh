#!/usr/bin/env bash
# opt-jpg.sh — strip non-essential metadata, optimize Huffman tables,
# convert to progressive (lossless re-encode). Keeps ICC profile for color.
# Only replaces files if the result is smaller. Preserves mtimes.

# Dependencies (Ubuntu/Debian)
# sudo apt update
# sudo apt install -y libjpeg-turbo-progs jpegoptim
# (optional, for logging EXIF removals) sudo apt install -y exiftool

set -euo pipefail

shopt -s nullglob
tmpdir="$(mktemp -d)"; trap 'rm -rf "$tmpdir"' EXIT

# Find targets (current dir recursively, .jpg/.jpeg)
mapfile -d '' files < <(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0)

total_before=0 total_after=0

for f in "${files[@]}"; do
  # absolute-safe paths
  abs="$(readlink -f -- "$f")"
  base="${abs##*/}"
  tmp="$tmpdir/$base"

  # 1) Lossless re-encode: strip everything except ICC, optimize, progressive
  #    (mirrors what many viewers do when “saving”)
  jpegtran -copy all -optimize -progressive -outfile "$tmp" "$abs"

  # 2) Further lossless squeeze (rarely helps but cheap): optimize again in-place
  #    and strip EXIF/IPTC/XMP (ICC already retained by step 1)
  jpegoptim --quiet --strip-exif --strip-iptc --strip-xmp --all-progressive --stdout "$tmp" > "$tmp".opt
  mv -f -- "$tmp".opt "$tmp"

  before=$(stat -c %s -- "$abs")
  after=$(stat -c %s -- "$tmp")
  total_before=$((total_before + before))
  total_after=$((total_after + after))

  if (( after < before )); then
    touch -r "$abs" "$tmp"               # keep mtime
    mv -f -- "$tmp" "$abs"
    printf "✓ %s  %s → %s (−%s%%)\n" "$abs" "$before" "$after" \
      "$(( (before-after)*100 / (before == 0 ? 1 : before) ))"
  else
    printf "• %s  no gain (%s → %s)\n" "$abs" "$before" "$after"
  fi
done

printf "\nTOTAL: %s → %s (−%s%%)\n" "$total_before" "$total_after" \
  "$(( (total_before-total_after)*100 / (total_before == 0 ? 1 : total_before) ))"
