#!/usr/bin/env bash
file="$1"
status="$2" # "draft" or "nodraft"

if [[ ! -f "$file" ]]; then
  echo "Error: file not found: $file" >&2
  exit 1
fi

draft_value="false"
[[ "$status" == "draft" ]] && draft_value="true"

awk -v val="$draft_value" '
BEGIN { in_fm = 0; draft_line = 0 }
{
  if ($0 == "---") {
    if (!in_fm) { in_fm=1; print; next }
    else { in_fm=0; if (!draft_line) print "draft: " val; print; next }
  }
  if (in_fm && $1 == "draft:") { print "draft: " val; draft_line=1; next }
  print
}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
