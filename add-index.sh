#!/bin/bash

# Path to the parent directory containing your image subfolders
ASSET_ROOT="images"  # adjust as needed

# Loop over all subdirectories (excluding ones that already have index.md)
find "$ASSET_ROOT" -type d | while read -r dir; do
  index="$dir/_index.md"

  if [ -f "$index" ]; then
    echo "-  _index.md already exists in: $dir"
  else
    echo "- Adding _index.md to: $dir"
    cat > "$index" <<EOF
---
headless: true
---

EOF
  fi
done

echo "- Done creating _index.md files."
