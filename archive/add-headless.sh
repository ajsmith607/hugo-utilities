#!/bin/bash

TARGET_DIR="images"  # Adjust as needed

find "$TARGET_DIR" -name '*.md' | while read -r file; do
  echo "Checking $file"

  # Check if file starts with front matter
  if head -n 1 "$file" | grep -q '^---'; then
    # YAML front matter
    if grep -q '^headless:' "$file"; then
      echo "  → Already has headless, skipping"
    else
      echo "  → Adding headless: true to YAML"
      # Insert after the first '---'
      awk 'NR==1{print; print "headless: true"; next}1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi

  elif head -n 1 "$file" | grep -q '^\+\+\+'; then
    # TOML front matter
    if grep -q '^headless =' "$file"; then
      echo "  → Already has headless, skipping"
    else
      echo "  → Adding headless = true to TOML"
      awk 'NR==1{print; print "headless = true"; next}1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi

  else
    echo "  → No front matter found, skipping"
  fi
done

echo "✅ Done adding headless"
