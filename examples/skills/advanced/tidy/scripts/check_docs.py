#!/usr/bin/env python3
"""
check_docs.py — mechanical doc-folder health check for the /tidy skill.

Reports two drift modes that need no judgment:
  1. Broken links  — relative markdown links in the folder that don't resolve.
  2. Orphan files  — .md files in the folder that NO other markdown file links to
                     (excluding README/index hubs).

Usage:  python3 check_docs.py <folder>      (default: current directory)
Exit:   0 = clean, 1 = issues found.

Orphan = a prompt to investigate, not an instruction to delete. A file may be
unlinked but load-bearing (a hub, or referenced from outside the repo). Read it.
"""
import os, re, sys, subprocess

LINK_RE = re.compile(r'\]\(([^)]+)\)')
HUB_NAMES = {"readme.md", "index.md"}            # never flagged as orphans
SKIP_PREFIX = ("http://", "https://", "mailto:", "#", "~")


def repo_root(folder):
    try:
        out = subprocess.run(["git", "-C", folder, "rev-parse", "--show-toplevel"],
                             capture_output=True, text=True)
        if out.returncode == 0:
            return out.stdout.strip()
    except Exception:
        pass
    return None


def tracked_md(root):
    """Git-tracked .md files (so gitignored breadcrumbs aren't treated as docs)."""
    out = subprocess.run(["git", "-C", root, "ls-files", "*.md"],
                         capture_output=True, text=True)
    return [os.path.join(root, p) for p in out.stdout.splitlines()]


def walk_md(root):
    found = []
    for d, dirs, files in os.walk(root):
        if os.sep + ".git" in d:
            continue
        for f in files:
            if f.endswith(".md"):
                found.append(os.path.join(d, f))
    return found


def links_in(path):
    try:
        text = open(path, encoding="utf-8").read()
    except Exception:
        return []
    return LINK_RE.findall(text)


def main():
    folder = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
    if not os.path.isdir(folder):
        print(f"not a folder: {folder}")
        return 2
    root = repo_root(folder)

    # Universe of docs: git-tracked .md when in a repo (skips gitignored
    # breadcrumbs); else everything on disk.
    if root:
        repo_md = tracked_md(root)
    else:
        root = folder
        repo_md = walk_md(folder)
    folder_md = [f for f in repo_md if os.path.abspath(f).startswith(folder + os.sep)
                 or os.path.dirname(os.path.abspath(f)) == folder]

    # 1. broken links (within the target folder's files)
    broken = []
    for f in folder_md:
        d = os.path.dirname(f)
        for link in links_in(f):
            if link.startswith(SKIP_PREFIX):
                continue
            target = link.split("#")[0]
            if not target:
                continue
            resolved = os.path.normpath(os.path.join(d, target))
            if not os.path.exists(resolved):
                broken.append((os.path.relpath(f, folder), link))

    # 2. orphans: target .md whose filename is mentioned NOWHERE else (link,
    # code-span, or prose all count as a reference). A true dangling file.
    texts = {f: open(f, encoding="utf-8", errors="ignore").read() for f in repo_md}
    orphans = []
    for f in folder_md:
        if os.path.basename(f).lower() in HUB_NAMES:
            continue
        bn = os.path.basename(f)
        if not any(bn in t for g, t in texts.items() if g != f):
            orphans.append(os.path.relpath(f, folder))

    # report
    print(f"Checked {len(folder_md)} markdown file(s) under {folder}")
    if broken:
        print(f"\nBROKEN LINKS ({len(broken)}):")
        for f, link in broken:
            print(f"  {f} -> {link}")
    if orphans:
        print(f"\nORPHANS — no inbound links, investigate before deleting ({len(orphans)}):")
        for f in orphans:
            print(f"  {f}")
    if not broken and not orphans:
        print("\nClean: all links resolve, no orphans.")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
