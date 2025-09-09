#!/usr/bin/env python3
# minimal Python commit helper (no hooks)
# - Reads DONE items from TODO.TASKS (your vi-edited file)
# - Opens $EDITOR with a prefilled commit message that includes a "# Completed" section
# - You edit freely; on save+quit it commits with that message
# - Then it appends the *final edited* "# Completed" lines to DONE.TASKS, dated
#
# Usage:
#   git add -A
#   ./bin/gcommit.py
#
# Config (optional env):
#   TODO_FILE (default: TODO.TASKS)
#   DONE_LOG  (default: DONE.TASKS)
#   GIT_EDITOR / VISUAL / EDITOR (default: vi aliased to nvim)

import os, re, subprocess, sys, tempfile
from pathlib import Path

TODO_FILE = os.environ.get("TODO_FILE", "TODO.TASKS")
DONE_LOG  = os.environ.get("DONE_LOG",  "DONE.TASKS")

SECTION_CURRENT = re.compile(r'^\s*CURRENT:\s*$', re.I)
SECTION_DONE    = re.compile(r'^\s*DONE:\s*$', re.I)
SECTION_BACKLOG = re.compile(r'^\s*BACKLOG:\s*$', re.I)

BULLET = re.compile(r'^\s*-\s+(.+?)\s*$')  # capture text after "- "
COMMENT_OR_BLANK = re.compile(r'^\s*(#|$)')

def sh(args, **kw):
    return subprocess.run(args, check=True, text=True, **kw)

def sh_out(args, **kw) -> str:
    return subprocess.run(args, check=True, text=True, capture_output=True, **kw).stdout

def extract_done_lines_from_todo(path: Path):
    """Return list of DONE bullet texts (strings) from TODO.TASKS (current working tree)."""
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    in_done = False
    out = []
    for line in lines:
        if SECTION_DONE.match(line):
            in_done = True
            continue
        if SECTION_CURRENT.match(line) or SECTION_BACKLOG.match(line):
            in_done = False
        if not in_done:
            continue
        if COMMENT_OR_BLANK.match(line):
            continue
        m = BULLET.match(line)
        if m:
            out.append(m.group(1))
    return out

def pick_editor() -> list[str]:
    for var in ("GIT_EDITOR", "VISUAL", "EDITOR"):
        val = os.environ.get(var)
        if val:
            return val.split()
    return ["vi"]

def build_initial_message(done_items: list[str]) -> str:
    parts = []
    parts.append("")  # subject line left blank; user will write it
    parts.append("")  # blank line
    parts.append("# Completed")
    if done_items:
        parts += [f"- {t}" for t in done_items]
    else:
        parts.append("- ")  # leave an empty bullet as a hint; user can delete it
    parts.append("")  # blank
    # Staged files list (commented)
    try:
        staged = sh_out(["git", "diff", "--cached", "--name-only"]).splitlines()
    except subprocess.CalledProcessError:
        staged = []
    if staged:
        parts.append("# Staged files:")
        parts += [f"# {p}" for p in staged]
        parts.append("")
    # Helpful footer
    parts.append("# Write subject on the first line. Body below.")
    parts.append("# Edit the '# Completed' list as desired; those lines will be logged to DONE.TASKS.")
    return "\n".join(parts) + "\n"

def open_in_editor(initial_text: str) -> str:
    with tempfile.NamedTemporaryFile("w+", delete=False, prefix="gcommit_", suffix=".tmp") as f:
        path = f.name
        f.write(initial_text)
        f.flush()
    try:
        sh(pick_editor() + [path])
        final = Path(path).read_text(encoding="utf-8")
        return final
    finally:
        try: os.unlink(path)
        except OSError: pass

def commit_with_message(msg: str):
    with tempfile.NamedTemporaryFile("w+", delete=False, prefix="gcommit_msg_", suffix=".txt") as f:
        p = f.name
        f.write(msg)
        f.flush()
    try:
        sh(["git", "commit", "-F", p])
    finally:
        try: os.unlink(p)
        except OSError: pass

def extract_completed_from_message(msg: str) -> list[str]:
    """
    From the final edited commit message, pull lines under a '# Completed' header
    until a blank line or another header line beginning with '# '.
    Return the bullet texts (without '- ').
    """
    lines = msg.splitlines()
    completed = []
    i = 0
    # find header
    while i < len(lines) and not re.match(r'^\s*#\s*Completed\s*$', lines[i]):
        i += 1
    if i == len(lines):
        return []
    i += 1
    while i < len(lines):
        line = lines[i]
        if line.strip() == "":
            break
        if re.match(r'^\s*#\s+\S', line):  # another header in body
            break
        m = BULLET.match(line)
        if m:
            completed.append(m.group(1))
        i += 1
    return completed

def append_done_log(items: list[str]):
    if not items:
        return
    # Use the actual commit date of HEAD for consistency
    try:
        date = sh_out(["git", "show", "-s", "--format=%ad", "--date=format:%F", "HEAD"]).strip()
    except subprocess.CalledProcessError:
        from datetime import date as _d
        date = _d.today().isoformat()
    log = Path(DONE_LOG)
    with log.open("a", encoding="utf-8") as f:
        f.write(f"# {date}\n")
        for t in items:
            f.write(f"{date}\t{t}\n")
        f.write("\n")

def main():
    # Ensure there is something staged; otherwise git commit will fail later
    try:
        staged = sh_out(["git", "diff", "--cached", "--name-only"]).strip()
    except subprocess.CalledProcessError:
        staged = ""
    if not staged:
        print("Nothing staged. Use: git add -A   (or stage specific files)", file=sys.stderr)
        sys.exit(1)

    done_items = extract_done_lines_from_todo(Path(TODO_FILE))
    initial = build_initial_message(done_items)
    final_msg = open_in_editor(initial)
    # Empty/whitespace-only message? Let git enforce policy, but avoid accidental empty
    if not final_msg.strip():
        print("Aborted: empty commit message.", file=sys.stderr)
        sys.exit(1)

    commit_with_message(final_msg)
    completed = extract_completed_from_message(final_msg)
    append_done_log(completed)

if __name__ == "__main__":
    main()
