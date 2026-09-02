"""통합 Human Blueprint PDF의 보존·보강 출력 계약을 검증한다."""

from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from pathlib import Path

from pypdf import PdfReader


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
EXPORTER_PATH = REPOSITORY_ROOT / "tools" / "export_integrated_human_blueprint_pdf.py"
HISTORICAL_PDF = REPOSITORY_ROOT / "exports" / "NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf"


def load_exporter_module():
    if not EXPORTER_PATH.is_file():
        raise AssertionError("integrated Human Blueprint PDF composer is missing")
    spec = importlib.util.spec_from_file_location("integrated_human_blueprint_pdf", EXPORTER_PATH)
    if spec is None or spec.loader is None:
        raise AssertionError("integrated Human Blueprint PDF composer cannot be loaded")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class IntegratedHumanBlueprintPdfTests(unittest.TestCase):
    def test_integrated_export_preserves_historical_blueprint_and_adds_current_visual_companion(self) -> None:
        module = load_exporter_module()

        with tempfile.TemporaryDirectory() as temporary_directory:
            output = Path(temporary_directory) / "integrated.pdf"
            result = module.export_integrated_pdf(
                historical_pdf=HISTORICAL_PDF,
                output=output,
                source_commit="0" * 40,
                generated_at="2026-09-02T00:00:00+09:00",
            )

            historical_reader = PdfReader(HISTORICAL_PDF)
            integrated_reader = PdfReader(output)
            extracted_text = "\n".join(page.extract_text() or "" for page in integrated_reader.pages)

            self.assertTrue(output.read_bytes().startswith(b"%PDF-"))
            self.assertLess(
                output.stat().st_size,
                50 * 1024 * 1024,
                "the downloadable PDF should stay below GitHub's 50 MiB guidance threshold",
            )
            self.assertEqual(len(historical_reader.pages), 28)
            self.assertEqual(result.historical_page_count, 28)
            self.assertEqual(result.companion_page_count, module.COMPANION_PAGE_COUNT)
            self.assertGreaterEqual(result.page_count, 38)
            self.assertEqual(len(integrated_reader.pages), result.page_count)
            self.assertIn("기존 28쪽 Human Blueprint", extracted_text)
            self.assertIn("Title → Stage → Core → Elite → Trace → Boss", extracted_text)
            self.assertIn("현재-main 시각 보강부", extracted_text)
            self.assertIn("HUMAN_GDD_20260830.pdf", extracted_text)


if __name__ == "__main__":
    unittest.main()
