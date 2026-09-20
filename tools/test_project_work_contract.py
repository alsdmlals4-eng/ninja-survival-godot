"""Offline cold-start navigation checks; not proof of agent or game behavior."""

from pathlib import Path
import re
import unittest
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
OWNERS = (
    "AGENTS.md",
    "docs/DOCUMENTATION_MAP.md",
    "docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md",
    "docs/BASE_RULES_VERSION.md",
    "docs/ACTIVE_CONTEXT.md",
    "docs/CURRENT_CONFIRMED_DECISIONS.md",
)


def local_destinations(relative_path):
    source = ROOT / relative_path
    destinations = set()
    for target in re.findall(r"\[[^\]\n]+\]\(([^)\s]+)\)", source.read_text(encoding="utf-8")):
        url = urlsplit(target)
        if url.scheme or url.netloc or not url.path:
            continue
        destinations.add((source.parent / unquote(url.path)).resolve())
    return destinations


class ProjectWorkNavigationTests(unittest.TestCase):
    def test_cold_start_reaches_native_owners_without_external_adapter(self):
        """Break: a new session cannot reach decisions/state/contract from AGENTS."""
        reached = {ROOT / "AGENTS.md"}
        pending = ["AGENTS.md"]
        while pending:
            current = pending.pop()
            for target in local_destinations(current):
                if target in reached:
                    continue
                reached.add(target)
                relative = target.relative_to(ROOT).as_posix()
                if relative in OWNERS:
                    pending.append(relative)
        for required in OWNERS:
            with self.subTest(owner=required):
                self.assertIn(ROOT / required, reached)

    def test_selected_local_links_resolve_inside_repository(self):
        """Break: relocated rules leave dangling links or escape the checkout."""
        for owner in OWNERS:
            for target in local_destinations(owner):
                with self.subTest(owner=owner, target=target):
                    self.assertTrue(target.is_relative_to(ROOT))
                    self.assertTrue(target.is_file(), f"Missing owner: {target}")


if __name__ == "__main__":
    unittest.main()
