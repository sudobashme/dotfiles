#!/usr/bin/env python3
"""Sync zsh plugins declared in lamina/plugins.toml."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:
    print("lamina: python 3.11+ required (tomllib)", file=sys.stderr)
    raise SystemExit(1)


def expand(path: str, home: Path) -> Path:
    if path.startswith("~/"):
        return home / path[2:]
    return Path(path).expanduser()


def run(cmd: list[str], *, cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=cwd, check=check, text=True)


def clone_args(entry: dict) -> list[str]:
    args = ["git", "clone"]
    depth = entry.get("depth")
    if depth:
        args.extend(["--depth", str(depth)])
    branch = entry.get("branch")
    if branch:
        args.extend(["--single-branch", "--branch", branch])
    if entry.get("recurse_submodules"):
        args.append("--recurse-submodules")
    return args


def sync_repo(entry: dict, root: Path, *, dry_run: bool) -> int:
    name = entry["name"]
    dest = root / entry["dir"]
    url = entry["url"]
    issues = 0

    if dest.exists() and (dest / ".git").is_dir():
        print(f"  ↑ {name} — updating {dest}")
        if dry_run:
            return 0
        try:
            run(["git", "-C", str(dest), "fetch", "--depth", "1", "origin"], check=True)
            branch = entry.get("branch")
            ref = f"origin/{branch}" if branch else "FETCH_HEAD"
            run(["git", "-C", str(dest), "reset", "--hard", ref], check=True)
            if entry.get("recurse_submodules"):
                run(
                    ["git", "-C", str(dest), "submodule", "update", "--init", "--recursive", "--depth", "1"],
                    check=True,
                )
        except subprocess.CalledProcessError as exc:
            print(f"  ✗ {name} — update failed ({exc})", file=sys.stderr)
            issues += 1
        return issues

    print(f"  + {name} — cloning into {dest}")
    if dry_run:
        return 0

    dest.parent.mkdir(parents=True, exist_ok=True)
    cmd = clone_args(entry) + [url, str(dest)]
    try:
        run(cmd, check=True)
    except subprocess.CalledProcessError as exc:
        print(f"  ✗ {name} — clone failed ({exc})", file=sys.stderr)
        issues += 1
    return issues


def sync_files(files: list[dict], home: Path, *, dry_run: bool) -> int:
    issues = 0
    for entry in files:
        path = expand(entry["path"], home)
        mode = entry.get("mode", "touch")
        if path.exists():
            print(f"  ✓ {path.name} — present")
            continue
        print(f"  + {path} — creating ({mode})")
        if dry_run:
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        if mode == "touch":
            path.touch()
        else:
            print(f"  ✗ unsupported file mode: {mode}", file=sys.stderr)
            issues += 1
    return issues


def zrecompile_plugins(root: Path, *, dry_run: bool) -> None:
    if dry_run:
        print("  (skip zrecompile in dry-run)")
        return
    zsh_files = sorted(root.rglob("*.zsh")) + sorted(root.rglob("*.zsh-theme"))
    if not zsh_files:
        return
    print(f"  ⚙ zrecompile — {len(zsh_files)} plugin zsh file(s)")
    for zsh_file in zsh_files:
        run(["zsh", "-fc", f"autoload -Uz zrecompile; zrecompile -pq {zsh_file}"], check=False)


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync zsh plugins for lamina")
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-zrecompile", action="store_true")
    args = parser.parse_args()

    home = Path.home()
    plugin_section = tomllib.loads(args.manifest.read_text()).get("plugins", {})
    root = expand(plugin_section.get("root", "~/.zsh/plugins"), home)
    repos = plugin_section.get("repo", [])
    files = plugin_section.get("files", [])

    print(f"lamina sync-plugins — {root}")
    issues = 0
    issues += sync_files(files, home, dry_run=args.dry_run)
    for entry in repos:
        issues += sync_repo(entry, root, dry_run=args.dry_run)

    if not args.no_zrecompile:
        zrecompile_plugins(root, dry_run=args.dry_run)

    if issues:
        print(f"lamina sync-plugins — {issues} issue(s)", file=sys.stderr)
        return 1
    print("lamina sync-plugins — done")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())