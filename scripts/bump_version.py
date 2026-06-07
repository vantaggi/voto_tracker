#!/usr/bin/env python3
"""Bump della versione di Voto Tracker + rigenerazione del CHANGELOG.

Adattato a un progetto Flutter: la versione canonica vive in `pubspec.yaml`
nella forma `version: X.Y.Z+build`. Lo script:

  1. imposta la nuova versione semver passata come argomento;
  2. incrementa il build number (`+N`);
  3. raccoglie i commit dall'ultimo tag, li raggruppa per prefisso conventional
     e scrive una nuova sezione in `CHANGELOG.md`.

Uso:
    python scripts/bump_version.py 1.2.0
"""
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBSPEC = ROOT / "pubspec.yaml"
CHANGELOG = ROOT / "CHANGELOG.md"

# prefisso conventional -> (titolo sezione, nascosto?)
CATEGORIES = [
    ("feat", "🚀 Nuove Funzionalità", False),
    ("fix", "🐞 Bug Fix", False),
    ("ui", "🎨 Interfaccia & Design", False),
    ("perf", "⚡ Prestazioni", False),
    ("refactor", "🛠️ Refactoring", False),
    ("test", "🧪 Test", False),
    ("docs", "📝 Documentazione", False),
    ("chore", "⚙️ Manutenzione", True),  # nascosto dal changelog
]
VISIBLE = [(p, t) for (p, t, hidden) in CATEGORIES if not hidden]
KNOWN_PREFIXES = {p for (p, _, _) in CATEGORIES}


def run(cmd):
    return subprocess.run(
        cmd, cwd=ROOT, capture_output=True, text=True, check=False
    ).stdout.strip()


def read_pubspec_version():
    text = PUBSPEC.read_text(encoding="utf-8")
    m = re.search(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)", text, re.MULTILINE)
    if not m:
        sys.exit("Impossibile leggere 'version: X.Y.Z+build' da pubspec.yaml")
    major, minor, patch, build = (int(g) for g in m.groups())
    return (major, minor, patch), build


def write_pubspec_version(new_semver, new_build):
    text = PUBSPEC.read_text(encoding="utf-8")
    new_line = f"version: {new_semver}+{new_build}"
    text = re.sub(r"^version:\s*\S+", new_line, text, count=1, flags=re.MULTILINE)
    PUBSPEC.write_text(text, encoding="utf-8")
    print(f"pubspec.yaml -> {new_line}")


def last_tag():
    tag = run(["git", "describe", "--tags", "--abbrev=0"])
    return tag or None


def commits_since(tag):
    rng = f"{tag}..HEAD" if tag else "HEAD"
    raw = run(["git", "log", rng, "--pretty=format:%s"])
    return [line for line in raw.splitlines() if line.strip()]


def group_commits(commits):
    groups = {p: [] for (p, _) in VISIBLE}
    pattern = re.compile(r"^(\w+)(?:\([^)]*\))?:\s*(.+)$")
    for subject in commits:
        m = pattern.match(subject)
        if not m:
            continue
        prefix, desc = m.group(1).lower(), m.group(2).strip()
        if prefix in groups:  # solo prefissi visibili
            groups[prefix].append(desc)
    return groups


def build_section(new_semver, groups):
    lines = [f"## [{new_semver}] - {date.today().isoformat()}", ""]
    has_content = False
    for prefix, title in VISIBLE:
        items = groups.get(prefix, [])
        if not items:
            continue
        has_content = True
        lines.append(f"### {title}")
        lines.extend(f"- {desc}" for desc in items)
        lines.append("")
    if not has_content:
        lines.append("_Nessuna modifica rilevante per l'utente in questa release._")
        lines.append("")
    return "\n".join(lines)


def update_changelog(new_semver, section):
    if not CHANGELOG.exists():
        sys.exit("CHANGELOG.md non trovato")
    text = CHANGELOG.read_text(encoding="utf-8")
    marker = "## [Unreleased]"
    idx = text.find(marker)
    if idx == -1:
        # nessun marker: inserisci dopo l'intestazione
        text = text.rstrip() + "\n\n" + section + "\n"
    else:
        end = text.find("\n## ", idx + len(marker))
        insert_at = end if end != -1 else len(text)
        text = text[:insert_at].rstrip() + "\n\n" + section + "\n" + text[insert_at:].lstrip("\n")
    CHANGELOG.write_text(text, encoding="utf-8")
    print(f"CHANGELOG.md -> aggiunta sezione [{new_semver}]")


def main():
    if len(sys.argv) != 2 or not re.fullmatch(r"\d+\.\d+\.\d+", sys.argv[1]):
        sys.exit("Uso: python scripts/bump_version.py X.Y.Z")
    new_semver = sys.argv[1]

    _, build = read_pubspec_version()
    new_build = build + 1

    tag = last_tag()
    groups = group_commits(commits_since(tag))

    write_pubspec_version(new_semver, new_build)
    update_changelog(new_semver, build_section(new_semver, groups))
    print(f"Versione bumpata a {new_semver}+{new_build} (tag base: {tag or 'nessuno'})")


if __name__ == "__main__":
    main()
