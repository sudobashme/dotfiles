#!/usr/bin/env python3
"""Federated package search and installation for Lamina."""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import re
import shutil
import subprocess
import sys
import tomllib
from dataclasses import asdict, dataclass
from pathlib import Path


MANIFEST = Path(__file__).resolve().parents[1] / "manifest.toml"


def package_config() -> dict:
    try:
        return tomllib.loads(MANIFEST.read_text()).get("packages", {})
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise RuntimeError(f"cannot read package policy from {MANIFEST}: {exc}") from exc


CONFIG = package_config()
PROVIDER_ORDER = tuple(CONFIG.get("providers", ("brew", "cargo", "npm", "uv", "pip", "gem", "git")))
SEARCH_PROVIDERS = tuple(CONFIG.get("search_providers", ("brew", "cargo", "npm")))


@dataclass(frozen=True)
class Result:
    provider: str
    name: str
    version: str = ""
    description: str = ""

    def score(self, query: str) -> tuple[int, int, int, str]:
        wanted = query.casefold()
        name = self.name.casefold()
        exact = name == wanted
        prefix = name.startswith(wanted)
        return (
            0 if exact else 1,
            0 if prefix else 1,
            PROVIDER_ORDER.index(self.provider),
            name,
        )


class ProviderError(RuntimeError):
    pass


def run(command: list[str]) -> str:
    try:
        completed = subprocess.run(
            command, check=True, capture_output=True, text=True, timeout=30
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        detail = getattr(exc, "stderr", "") or str(exc)
        raise ProviderError(detail.strip()) from exc
    return completed.stdout


def search_brew(query: str) -> list[Result]:
    output = run(["brew", "search", query])
    results: list[Result] = []
    for line in output.splitlines():
        line = line.strip()
        if not line or line.startswith("==>"):
            continue
        for name in line.split():
            results.append(Result("brew", name))
    return results


def search_cargo(query: str) -> list[Result]:
    output = run(["cargo", "search", query, "--limit", "20"])
    results: list[Result] = []
    pattern = re.compile(r'^([^ ]+) = "([^"]+)"(?:\s+#\s?(.*))?$')
    for line in output.splitlines():
        match = pattern.match(line.strip())
        if match:
            results.append(Result("cargo", match[1], match[2], match[3] or ""))
    return results


def search_npm(query: str) -> list[Result]:
    output = run(["npm", "search", query, "--json"])
    try:
        payload = json.loads(output)
    except json.JSONDecodeError as exc:
        raise ProviderError("npm returned invalid JSON") from exc
    return [
        Result(
            "npm",
            item.get("name", ""),
            item.get("version", ""),
            item.get("description", "") or "",
        )
        for item in payload
        if item.get("name")
    ]


SEARCHERS = {"brew": search_brew, "cargo": search_cargo, "npm": search_npm}


def search(query: str, providers: tuple[str, ...] = SEARCH_PROVIDERS) -> tuple[list[Result], dict[str, str]]:
    available = [provider for provider in providers if shutil.which(provider)]
    errors: dict[str, str] = {}
    results: list[Result] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(available) or 1) as pool:
        jobs = {pool.submit(SEARCHERS[p], query): p for p in available}
        for job in concurrent.futures.as_completed(jobs):
            provider = jobs[job]
            try:
                results.extend(job.result())
            except ProviderError as exc:
                errors[provider] = str(exc)
    unique = {(result.provider, result.name): result for result in results}
    return sorted(unique.values(), key=lambda result: result.score(query)), errors


def split_spec(spec: str) -> tuple[str | None, str]:
    if ":" not in spec:
        return None, spec
    provider, name = spec.split(":", 1)
    if provider not in PROVIDER_ORDER:
        raise ValueError(f"unknown provider: {provider}")
    if not name:
        raise ValueError("package name cannot be empty")
    return provider, name


def install_command(result: Result) -> list[str]:
    commands = {
        "brew": ["brew", "install", result.name],
        "cargo": ["cargo", "install", result.name],
        "npm": ["npm", "install", "--global", result.name],
    }
    try:
        return commands[result.provider]
    except KeyError as exc:
        raise ValueError(f"install is not implemented for {result.provider}") from exc


def print_results(results: list[Result], query: str, errors: dict[str, str]) -> None:
    if not results:
        print(f"No packages found for {query!r}.")
    for index, result in enumerate(results, 1):
        version = f" {result.version}" if result.version else ""
        description = f" — {result.description}" if result.description else ""
        exact = " [exact]" if result.name.casefold() == query.casefold() else ""
        print(f"{index:>2}. {result.provider}:{result.name}{version}{exact}{description}")
    for provider, message in sorted(errors.items()):
        print(f"lamina: {provider} search failed: {message}", file=sys.stderr)


def cmd_search(args: argparse.Namespace) -> int:
    _, query = split_spec(args.query)
    provider, _ = split_spec(args.query)
    providers = (provider,) if provider else SEARCH_PROVIDERS
    results, errors = search(query, providers)
    if args.json:
        print(json.dumps({"query": query, "results": [asdict(r) for r in results], "errors": errors}, indent=2))
    else:
        print_results(results, query, errors)
    return 0 if results else 1


def cmd_install(args: argparse.Namespace) -> int:
    provider, query = split_spec(args.package)
    if provider and provider not in SEARCHERS:
        print(f"lamina: {provider} search/install support is not implemented yet", file=sys.stderr)
        return 2
    results, errors = search(query, (provider,) if provider else SEARCH_PROVIDERS)
    exact = [result for result in results if result.name.casefold() == query.casefold()]
    if not exact:
        print_results(results[:10], query, errors)
        print("lamina: refusing to guess; use provider:package with an exact package name", file=sys.stderr)
        return 2
    selected = exact[0]
    command = install_command(selected)
    print(f"Resolved {args.package} -> {selected.provider}:{selected.name}")
    print("$ " + " ".join(command))
    if args.dry_run:
        return 0
    return subprocess.run(command).returncode


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(prog="lamina")
    commands = root.add_subparsers(dest="command", required=True)
    search_parser = commands.add_parser("search", help="search package providers")
    search_parser.add_argument("query")
    search_parser.add_argument("--json", action="store_true")
    search_parser.set_defaults(handler=cmd_search)
    install_parser = commands.add_parser("install", help="resolve and install a package")
    install_parser.add_argument("package")
    install_parser.add_argument("--dry-run", action="store_true")
    install_parser.set_defaults(handler=cmd_install)
    return root


def main() -> int:
    try:
        args = parser().parse_args()
        return args.handler(args)
    except (ValueError, ProviderError) as exc:
        print(f"lamina: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
