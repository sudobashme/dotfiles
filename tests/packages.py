#!/usr/bin/env python3

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LAMINA = ROOT / "bin" / "lamina"
PACKAGES = ROOT / "lamina" / "lib" / "packages.py"


class PackageResolverTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        bindir = Path(self.temp.name)
        scripts = {
            "brew": "#!/bin/sh\nprintf 'ripgrep\\nripgrep-all\\n'\n",
            "cargo": "#!/bin/sh\nprintf 'ripgrep = \"14.1.1\" # Fast search\\nripgrep-extra = \"1.0\" # Extra\\n'\n",
            "npm": "#!/bin/sh\nprintf '[{\"name\":\"ripgrep\",\"version\":\"1.0.0\",\"description\":\"wrapper\"}]'\n",
        }
        for name, body in scripts.items():
            path = bindir / name
            path.write_text(body)
            path.chmod(0o755)
        self.env = os.environ | {"PATH": f"{bindir}:{os.environ['PATH']}"}

    def tearDown(self):
        self.temp.cleanup()

    def run_lamina(self, *args):
        return subprocess.run(
            ["python3", str(PACKAGES), *args],
            env=self.env,
            capture_output=True,
            text=True,
        )

    def test_search_ranks_exact_results_by_provider_preference(self):
        result = self.run_lamina("search", "ripgrep")
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = result.stdout.splitlines()
        self.assertIn("brew:ripgrep", lines[0])
        self.assertIn("cargo:ripgrep", lines[1])
        self.assertIn("npm:ripgrep", lines[2])

    def test_qualified_search_uses_one_provider(self):
        result = self.run_lamina("search", "cargo:ripgrep")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("cargo:ripgrep", result.stdout)
        self.assertNotIn("brew:ripgrep", result.stdout)

    def test_install_dry_run_chooses_preferred_exact_match(self):
        result = self.run_lamina("install", "ripgrep", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Resolved ripgrep -> brew:ripgrep", result.stdout)
        self.assertIn("$ brew install ripgrep", result.stdout)

    def test_install_refuses_inexact_guess(self):
        result = self.run_lamina("install", "rip")
        self.assertEqual(result.returncode, 2)
        self.assertIn("refusing to guess", result.stderr)


if __name__ == "__main__":
    unittest.main()
