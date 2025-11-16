#!/usr/bin/env python3

# bin/gcommit.py — commit helper with --dry-run and Python 3.7/3.8 typing compatibility
# - Reads DONE items from TODO.TASKS
# - Opens $EDITOR with a prefilled message (you edit freely)
# - On real run: commits with that message and appends the final "# Completed" lines to DONE.TASKS
# - On --dry-run: shows what would happen, no commit, no file changes

import os
import re
import shlex
import sys
import tempfile
import argparse
import subprocess
from pathlib import Path
from typing import List

TODO_FILE = os.environ.get("TODO_FILE", "TODO.TASKS")
DONE_LOG  = os.environ.get("DONE_LOG",  "DONE.TASKS")

SECTION_TODO = re.compile(r'^\s*TODO:\s*$', re.I)
SECTION_DONE    = re.compile(r'^\s*DONE:\s*$', re.I)
SECTION_BACKLOG = re.compile(r'^\s*BACKLOG:\s*$', re.I)
BULLET = re.compile(r'^(\s*-\s+.*\S.*)$')
COMMENT_OR_BLANK = re.compile(r'^\s*(#|$)')

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--dry-run", action="store_true", help="build & edit message, but do not commit or write DONE.TASKS")
    p.add_argument("--no-stage-check", action="store_true", help="skip 'nothing staged' check (useful for formatting tests)")
    return p.parse_args()

def sh(args: List[str], **kw):
    return subprocess.run(args, check=True, text=True, **kw)

def sh_out(args: List[str], **kw) -> str:
    return subprocess.run(args, check=True, text=True, capture_output=True, **kw).stdout

def extract_done_lines_from_todo(path: Path) -> List[str]:
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8").splitlines()
    in_done = False
    out: List[str] = []
    for line in lines:
        if SECTION_DONE.match(line):
            in_done = True
            continue
        if SECTION_TODO.match(line) or SECTION_BACKLOG.match(line):
            in_done = False
        if not in_done:
            continue
        if COMMENT_OR_BLANK.match(line):
            continue
        # preserve leading spaces before "- "
        m = re.match(r'^(\s*-\s+.*\S.*)$', line)
        if m:
            out.append(m.group(1))
    return out

def pick_editor() -> List[str]:
    for var in ("GIT_EDITOR", "VISUAL", "EDITOR"):
        val = os.environ.get(var)
        if val:
            return shlex.split(val)
    return ["vi"]

def build_initial_message(done_items: List[str]) -> str:
    parts: List[str] = []
    parts.append("")  # subject line placeholder
    parts.append("")  # blank line
    parts.append("# Completed")
    if done_items:
        parts += [f"- {t}" for t in done_items]
    else:
        parts.append("- ")
    parts.append("")  # blank
    try:
        staged = sh_out(["git", "diff", "--cached", "--name-only"]).splitlines()
    except subprocess.CalledProcessError:
        staged = []
    if staged:
        parts.append("# Staged files:")
        parts += [f"# {p}" for p in staged]
        parts.append("")
    parts.append("# First line = subject. Edit '# Completed' freely; those bullets will be logged to DONE.TASKS.")
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

def extract_completed_from_message(msg: str) -> List[str]:
    """
    Pull bullets under a '# Completed' header (until blank line or next '# ' header).
    Returns plain bullet texts (without '- ').
    """
    lines = msg.splitlines()
    completed: List[str] = []
    i = 0
    while i < len(lines) and not re.match(r'^\s*#\s*Completed\s*$', lines[i]):
        i += 1
    if i == len(lines):
        return []
    i += 1
    while i < len(lines):
        line = lines[i]
        if line.strip() == "":
            break
        if re.match(r'^\s*#\s+\S', line):
            break
        m = BULLET.match(line)
        if m:
            completed.append(m.group(1))
        i += 1
    return completed

def append_done_log(items: List[str]):
    if not items:
        return
    try:
        date = sh_out(["git", "show", "-s", "--format=%ad", "--date=format:%F", "HEAD"]).strip()
    except subprocess.CalledProcessError:
        from datetime import date as _d
        date = _d.today().isoformat()
    log = Path(DONE_LOG)
    with log.open("a", encoding="utf-8") as f:
        f.write(f"# {date}\n")
        for t in items:
            f.write(f"{date}\t{t}\n".replace("\t", "    "))
        f.write("\n")

def clear_done_bullets_in_todo(path: Path):
    """Remove bullet lines (- ...) inside the DONE: section of TODO.TASKS."""
    if not path.exists():
        return
    lines = path.read_text(encoding="utf-8").splitlines(True)  # keep \n endings
    out = []
    in_done = False
    for line in lines:
        if SECTION_DONE.match(line):
            in_done = True
            out.append(line)
            continue
        if SECTION_CURRENT.match(line) or SECTION_BACKLOG.match(line):
            in_done = False
        if in_done:
            # skip bullet lines only (keep comments/blanks)
            if re.match(r'^\s*-\s+.*$', line):
                continue
        out.append(line)
    path.write_text("".join(out), encoding="utf-8")


def main():
    args = parse_args()

    if not args.no_stage_check:
        try:
            staged = sh_out(["git", "diff", "--cached", "--name-only"]).strip()
        except subprocess.CalledProcessError:
            staged = ""
        if not staged and not args.dry_run:
            print("Nothing staged. Use: git add -A   (or pass --no-stage-check / --dry-run)", file=sys.stderr)
            sys.exit(1)

    done_items = extract_done_lines_from_todo(Path(TODO_FILE))
    initial = build_initial_message(done_items)
    final_msg = open_in_editor(initial)
    if not final_msg.strip():
        print("Aborted: empty commit message.", file=sys.stderr)
        sys.exit(1)

    if args.dry_run:
        sys.stdout.write("----- DRY RUN: final commit message -----\n")
        sys.stdout.write(final_msg)
        sys.stdout.write("----- END MESSAGE -----\n")
    else:
        commit_with_message(final_msg)

    completed = extract_completed_from_message(final_msg)

    if args.dry_run:
        sys.stdout.write("----- DRY RUN: would append to DONE.TASKS -----\n")
        for t in completed:
            sys.stdout.write(f"{t}\n")
        sys.stdout.write("----- END DONE LIST -----\n")
    else:
        append_done_log(completed)
        # Clear DONE bullets from TODO.TASKS after successful commit
        clear_done_bullets_in_todo(Path(TODO_FILE))

if __name__ == "__main__":
    main()
