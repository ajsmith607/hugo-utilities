#!/usr/bin/env python3

"""
mirrorimage.py
---------------------------------
Interactive directory mirroring and move-script generator.

This script lets you interactively select or type a directory path
relative to a known "anchor" directory using fzf. It then mirrors that
directory structure inside the current working directory, generating
a move script (.mv.sh) that lists all visible files in the current
directory as mv commands to relocate them into the new structure.

FEATURES:
  • Interactive fzf interface with free typing and Tab navigation
  • Live colorized preview of both subdirectories and visible files
  • Hidden items excluded from display and script generation
  • Automatically creates any missing directories only upon confirmation
  • Opens .mv.sh in your $EDITOR (defaults to vi) for manual review
  • Optionally executes the move script immediately after editing

DEPENDENCIES:
  - Python 3.7+
  - fzf (tested with versions ≥ 0.27)
  - bash
  - a color-capable terminal for preview highlighting

USAGE:
  1. Edit the ANCHOR path near the top of this script to your desired base.
  2. From any directory containing files to move, run:
         mirrorimage.py
  3. Use fzf to navigate or type a relative path under the anchor.
  4. Edit and confirm the generated .mv.sh file.

EXAMPLE:
  Anchor: ~/Dropbox/business/code/hugo/memills/content/_assets/images
  Current directory: ~/Downloads/new_assets
  Result:
      .mv.sh created with commands like:
          mv photo1.png ./products/logos/newconcept/
      Optionally executes after confirmation.

---------------------------------
"""

import os, subprocess, sys

# ---- Configuration ----
ANCHOR = os.path.expanduser("~/Dropbox/business/code/hugo/memills/content/_assets/images")
EDITOR = os.getenv("EDITOR", "vi")
MV_SCRIPT = ".mv.sh"


def list_all_dirs(base):
    """Recursively list all directories (excluding hidden) under base."""
    result = []
    for root, dirs, _ in os.walk(base):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        rel = os.path.relpath(root, base)
        result.append(rel if rel != "." else "")
    return sorted(result)

"""
Use fzf to select or type a relative path from base.
- Tab / Shift+Tab cycle through results
- Live preview shows both subdirectories and visible files
- Hidden items are excluded
- Works when `echo '{}'` works in your shell
"""

def fzf_choose_path(base):
    dirs = list_all_dirs(base)
    prompt = f"{os.path.basename(base)}/ "

    preview_cmd = (
        f"full='{base}/{{}}'; "
        "if [ -d \"$full\" ]; then "
        "  ls --color=always -1p \"$full\" 2>/dev/null | grep -v '^\\.' || echo '(empty)'; "
        "else "
        "  echo '(not a directory)'; "
        "fi"
    )

    result = subprocess.run(
        [
            "fzf",
            "--prompt", prompt,
            "--height", "80%",
            "--reverse",
            "--ansi",
            "--preview-window", "right:45%",
            "--print-query",
            "--expect", "enter",
            "--bind", "tab:down,btab:up",
            "--preview", preview_cmd,
        ],
        input="\n".join(dirs).encode(),
        stdout=subprocess.PIPE,
    )

    lines = result.stdout.decode().splitlines()
    if not lines:
        return None

    typed_query = lines[0].strip()
    expect_key  = lines[1].strip() if len(lines) > 1 else None

    # Real selection is AFTER the expect-key, not the expect-key itself
    selected_item = lines[2].strip() if len(lines) > 2 else ""

    rel_path = selected_item or typed_query
    return rel_path.strip("/")








def make_mv_script(target_rel_path):
    files = [
        f for f in os.listdir(".")
        if os.path.isfile(f) and not f.startswith(".")
    ]
    files.sort()
    lines = [
        f"# Target path (will be created if confirmed): {target_rel_path}",
        "",
        "# Uncomment and adjust 'mv' commands as needed",
    ]
    lines += [f"mv {f} ./{target_rel_path}/" for f in files]
    return "\n".join(lines) + "\n"


def run_editor_and_confirm(script_path, target_path):
    subprocess.run([EDITOR, script_path])
    ans = input(f"\nCreate '{target_path}' and run {script_path}? [y/N]: ").strip().lower()
    if ans == "y":
        os.makedirs(target_path, exist_ok=True)
        subprocess.run(["bash", script_path])
    else:
        print("Aborted. Nothing created or moved.")


def main():
    if not os.path.isdir(ANCHOR):
        print(f"Error: Anchor directory '{ANCHOR}' does not exist.")
        sys.exit(1)

    print(f"📂 Anchor: {ANCHOR}")
    rel_path = fzf_choose_path(ANCHOR)
    if not rel_path:
        print("No path selected or typed.")
        sys.exit(0)

    target_path = os.path.join(os.getcwd(), rel_path)
    content = make_mv_script(rel_path)
    with open(MV_SCRIPT, "w") as f:
        f.write(content)
    os.chmod(MV_SCRIPT, 0o755)

    run_editor_and_confirm(MV_SCRIPT, target_path)


if __name__ == "__main__":
    main()


# Would you like it to auto-open the newly mirrored directory in a second pane (e.g., with ranger or vim) before editing the .mv.sh file — to visually verify structure before moving?
