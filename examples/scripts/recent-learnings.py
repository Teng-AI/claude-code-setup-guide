#!/usr/bin/env python3
"""Print learnings.md entries from the last N days instead of the whole file.

`/session-start` used to read the file entire. A long-running project's learnings.md runs to
several hundred lines and grows every session, so the read cost rises forever while the useful
part (what happened recently) stays about the same size.

Entries are `## [YYYY-MM-DD] Title`, which makes a date bound deterministic rather than a
guess. Bounded by DATE, not by count: a burst of eight learnings in one session should not
push out last week's, which a "last N entries" rule would do.

The bound is a default, not the whole picture. The full file is one grep away and the skill
says so.

Usage:
    recent-learnings.py <path-to-learnings.md> [--days N] [--list-only]
"""
import argparse
import re
import sys
from datetime import date, timedelta
from pathlib import Path

HEADING = re.compile(r"^##\s*\[(\d{4})-(\d{2})-(\d{2})\]\s*(.*)$")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path")
    ap.add_argument("--days", type=int, default=30)
    ap.add_argument("--list-only", action="store_true",
                    help="print just the dated titles, no bodies")
    args = ap.parse_args()

    p = Path(args.path).expanduser()
    if not p.exists():
        print(f"(no learnings.md at {p})")
        return 0

    cutoff = date.today() - timedelta(days=args.days)
    lines = p.read_text(errors="ignore").split("\n")

    # Walk entries, keeping each heading with its body.
    entries, cur, cur_date = [], None, None
    for line in lines:
        m = HEADING.match(line)
        if m:
            if cur is not None:
                entries.append((cur_date, cur))
            y, mo, d, _ = m.groups()
            try:
                cur_date = date(int(y), int(mo), int(d))
            except ValueError:
                cur_date = None
            cur = [line]
        elif cur is not None:
            cur.append(line)
    if cur is not None:
        entries.append((cur_date, cur))

    recent = [(d, body) for d, body in entries if d and d >= cutoff]
    total = len([1 for d, _ in entries if d])

    if not recent:
        newest = max((d for d, _ in entries if d), default=None)
        print(f"(no entries in the last {args.days} days; {total} total, "
              f"newest {newest}. Full file: {p})")
        return 0

    print(f"# {len(recent)} of {total} entries, last {args.days} days — {p}")
    print(f"# Older entries are NOT shown. Full file: grep it at {p}\n")
    for d, body in recent:
        if args.list_only:
            print(body[0])
        else:
            print("\n".join(body).rstrip())
            print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
