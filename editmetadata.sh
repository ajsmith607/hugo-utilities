#!/usr/bin/env bash

set -eEuo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO"; exit 1' ERR

source common.sh

# editmetadata.sh
#
# PURPOSE:
#   Batch workflow for editing image metadata side-by-side:
#     • Opens each image in a viewer (default: fim).
#     • Opens the corresponding .md metadata file in $EDITOR (default: nvim).
#     • Ensures the viewer does not steal focus (swaymsg restores terminal focus).
#     • After quitting $EDITOR, kills the viewer (per-file lifecycle).
#     • Tracks progress in ".edit-state" so the process can be stopped/resumed.
#
# BEHAVIOR:
#   • Files already in .edit-state are normally skipped.
#   • EXCEPTION: The *last* file in .edit-state is re-opened, in case you exited
#     $EDITOR before finishing. This lets you double-check your most recent edit.
#   • Skipped files are echoed at the start; you get ONE pause before the first
#     real edit (so you can review skip output).
#   • After every edit (including a re-open), you are prompted before continuing,
#     unless it was the final file overall.
#   • At the end, a completion message is shown.
#
# REQUIREMENTS:
#   • sway (Wayland WM) with swaymsg and jq available.
#   • $VIEWER installed (default: fim).
#   • $EDITOR installed (default: nvim).
#
# OVERRIDES:
#   Run with environment vars to change defaults:
#       EDITOR=vim VIEWER=vimiv ./editmetadata.sh
#

TRACKFILE=".edit-state"
touch "$TRACKFILE"

# Editor & viewer
EDITOR_CMD=${EDITOR:-nvim}
VIEWER=${VIEWER:-fim}

# Sway: container ID of the terminal running this script (for refocus)
TERMINAL_CON="$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .id' 2>/dev/null || true)"

refocus_terminal() {
  if [[ -n "${TERMINAL_CON:-}" ]]; then
    sleep 0.2
    swaymsg "[con_id=$TERMINAL_CON]" focus >/dev/null 2>&1 || true
  fi
}

prompt_continue() {
  echo
  echo "Press ENTER to continue, or Ctrl+C to cancel..."
  read -r _
}

edit_one() {
  local imgfile="$1"
  local mdfile="${imgfile%.*}.md"
  local idx="$2"
  local total="$3"

  REOPENED=0

  # Check if already processed
  if grep -qxF "$mdfile" "$TRACKFILE"; then
    last_tracked=$(tail -n 1 "$TRACKFILE")
    if [[ "$mdfile" == "$last_tracked" ]]; then
      echo "[$idx/$total] Re-opening last edited file: $imgfile <-> $mdfile"
      REOPENED=1
      # fall through → treat as an edit
    else
      echo "[$idx/$total] Skipping: $imgfile <-> $mdfile"
      return 1   # skipped
    fi
  fi

  echo "[$idx/$total] Editing: $imgfile <-> $mdfile"

  "$VIEWER" "$imgfile" >/dev/null 2>&1 &
  local ivid=$!
  trap 'kill '"$ivid"' 2>/dev/null || true' EXIT

  refocus_terminal
  "$EDITOR_CMD" "$mdfile" +2

  kill "$ivid" 2>/dev/null || true
  trap - EXIT
  echo "$mdfile" >> "$TRACKFILE"
  return 0   # edited
}

# Collect images (sorted, limited to current dir)
mapfile -d '' files < <(
  find . -type f \( -iname '*.jpg' -o -iname '*.png' \) -print0 | sort -z
)

total=${#files[@]}
idx=0

first_edit_seen=0
need_start_pause=0

for path in "${files[@]}"; do
  file="${path#./}"
  idx=$((idx+1))

  # If we haven't edited yet, and skips were seen → pause once before first edit
  if [[ $first_edit_seen -eq 0 && $need_start_pause -eq 1 ]]; then
    mdfile_candidate="${file%.*}.md"
    last_tracked=$(tail -n 1 "$TRACKFILE")

    if [[ "$mdfile_candidate" == "$last_tracked" ]]; then
      prompt_continue
      need_start_pause=0
    elif ! grep -qxF "$mdfile_candidate" "$TRACKFILE"; then
      prompt_continue
      need_start_pause=0
    fi

  fi

  if edit_one "$file" "$idx" "$total"; then
    if [[ $first_edit_seen -eq 0 ]]; then
      # First edit (new or reopened)
      first_edit_seen=1
      if [[ $need_start_pause -eq 0 && $REOPENED -eq 0 && $idx -lt $total ]]; then
        # Case: no skips, first edit → pause AFTER first edit
        prompt_continue
      elif [[ $REOPENED -eq 1 && $idx -lt $total ]]; then
        # Case: reopened last file → pause AFTER editing
        prompt_continue
      fi
    else
      # Subsequent edits → pause unless this was the last file
      if [[ $idx -lt $total ]]; then
        prompt_continue
      fi
    fi
  else
    # Skipped
    if [[ $first_edit_seen -eq 0 ]]; then
      need_start_pause=1
    fi
  fi
done

echo "✅ All $total files processed."
