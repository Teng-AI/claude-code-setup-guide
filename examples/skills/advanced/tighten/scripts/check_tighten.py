#!/usr/bin/env python3
"""Structural check for a /tighten pass.

Compares a document before and after compression and reports what changed
structurally. Checks structure, never meaning: a fact can vanish from a
paragraph without any of these firing. The fact-index diff in SKILL.md step 5
is what catches that, and this does not replace it.

Usage:
    python3 check_tighten.py BEFORE.md AFTER.md
    git show HEAD~1:path/to/doc.md > /tmp/before.md && \
        python3 check_tighten.py /tmp/before.md path/to/doc.md

Exit code is 1 if anything needs a human decision, 0 if clean.
"""

import difflib
import os
import re
import sys

HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*$", re.M)
# "see section 7", "question 4", "Q12", "step 3b"
XREF = re.compile(r"\b(?:section|questions?|step|phase|decision)\s+(\d+[a-z]?)\b|\bQ(\d+)\b", re.I)
MD_LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
# numbered list items at the start of a line, the things renumbering breaks
NUM_ITEM = re.compile(r"^\s{0,4}(\d+)\.\s+\*?\*?(.{0,60})", re.M)


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def headings(text):
    return [(len(h), t) for h, t in HEADING.findall(text)]


def xrefs(text):
    out = set()
    for a, b in XREF.findall(text):
        out.add(a or b)
    return out


def numbered_targets(text):
    """Map every numbered-list number to the label that follows it."""
    found = {}
    for num, label in NUM_ITEM.findall(text):
        found.setdefault(num, []).append(label.strip().rstrip("*").strip())
    return found


def heading_numbers(text):
    """Numbers claimed by headings, e.g. '## 4. What discovery found', '### Phase 0.'"""
    nums = set()
    for _, title in HEADING.findall(text):
        for m in re.finditer(r"\b(\d+[a-z]?)\b", title):
            nums.add(m.group(1))
    return nums


def normalize(label):
    """Strip markdown and punctuation so a reword doesn't read as a renumber."""
    s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", label)   # links to their text
    # labels are truncated, so a link may be cut mid-URL and never close
    s = re.sub(r"\[([^\]]*)\]\([^)]*$", r"\1", s)
    s = re.sub(r"[`*_#]", "", s).lower()
    s = re.sub(r"[^a-z0-9 ]+", " ", s)
    return " ".join(s.split())


def same_topic(old, new):
    """True if two list labels are the same item reworded rather than a different item."""
    a, b = normalize(old), normalize(new)
    if not a or not b:
        return True
    if a.startswith(b[:15]) or b.startswith(a[:15]):
        return True
    # shared distinctive words beat raw string distance for short labels
    wa, wb = set(a.split()), set(b.split())
    if wa and wb and len(wa & wb) / min(len(wa), len(wb)) >= 0.5:
        return True
    return difflib.SequenceMatcher(None, a, b).ratio() >= 0.5


def links(text, base):
    broken = []
    for target in MD_LINK.findall(text):
        t = target.split("#")[0].strip()
        if not t or t.startswith(("http://", "https://", "mailto:")):
            continue
        if not os.path.exists(os.path.join(base, t)):
            broken.append(target)
    return broken


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 2

    before_path, after_path = sys.argv[1], sys.argv[2]
    before, after = read(before_path), read(after_path)
    base = os.path.dirname(os.path.abspath(after_path))

    problems = 0

    bl, al = before.count("\n") + 1, after.count("\n") + 1
    pct = (al - bl) / bl * 100 if bl else 0
    print(f"lines: {bl} -> {al}  ({pct:+.0f}%)")
    print(f"words: {len(before.split())} -> {len(after.split())}")
    print()

    # Headings dropped or added.
    hb, ha = headings(before), headings(after)
    dropped = [t for t in hb if t not in ha]
    added = [t for t in ha if t not in hb]
    if dropped:
        problems += 1
        print(f"HEADINGS REMOVED ({len(dropped)}) - confirm each was deliberate:")
        for lvl, t in dropped:
            print(f"  {'#' * lvl} {t}")
        print()
    if added:
        print(f"headings added ({len(added)}):")
        for lvl, t in added:
            print(f"  {'#' * lvl} {t}")
        print()

    # Cross-references pointing at a number nothing claims.
    targets = numbered_targets(after)
    claimed = set(targets) | heading_numbers(after)
    unresolved = sorted(r for r in xrefs(after) if r not in claimed)
    if unresolved:
        problems += 1
        print(f"CROSS-REFS POINTING AT NOTHING ({len(unresolved)}):")
        print(f"  {', '.join(unresolved)}")
        print()

    # Renumbering: position N now holds a different item than it did.
    before_targets = numbered_targets(before)
    shifted = []
    for num, labels in targets.items():
        old = before_targets.get(num)
        if old and labels and not same_topic(old[0], labels[0]):
            shifted.append((num, old[0][:50], labels[0][:50]))
    if shifted:
        problems += 1
        print(f"NUMBERED ITEMS THAT CHANGED MEANING ({len(shifted)}) - other files may cite these:")
        for num, o, n in shifted:
            print(f"  {num}. was {o!r}")
            print(f"  {' ' * len(num)}  now {n!r}")
        print("  -> grep siblings for 'question <n>' / 'section <n>' before shipping")
        print()

    broken = links(after, base)
    if broken:
        problems += 1
        print(f"BROKEN RELATIVE LINKS ({len(broken)}):")
        for b in broken:
            print(f"  {b}")
        print()

    # Cheap signal that content was cut wholesale rather than consolidated.
    for token, label in ((r"^\|", "table rows"), (r"^\s*[-*]\s", "bullets")):
        b = len(re.findall(token, before, re.M))
        a = len(re.findall(token, after, re.M))
        if b >= 10 and a < b * 0.6:
            print(f"note: {label} dropped {b} -> {a}, more than 40%. Consolidated or cut?")

    if problems:
        print(f"\n{problems} thing(s) need a human decision.")
        print("Structure only. Still diff the fact index by hand.")
    else:
        print("Structural check clean. Still diff the fact index by hand.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
