"""사람용 GDD PDF 내보내기의 실제 산출물 계약을 검증한다."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

from pypdf import PdfReader


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
EXPORTER_PATH = REPOSITORY_ROOT / "tools" / "export_human_gdd_pdf.py"


def load_exporter_module():
    spec = importlib.util.spec_from_file_location("human_gdd_pdf_exporter", EXPORTER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("human GDD PDF exporter module is unavailable")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class HumanGddPdfExporterTests(unittest.TestCase):
    def test_export_preserves_korean_content_and_publication_metadata(self) -> None:
        """Break caught: a PDF opens but loses Korean text or publication identity."""
        source = """# 닌자의 신\n\n> 사람용 제작 기획서\n\n## 핵심 시스템\n\n- 상태는 아이콘으로 보여 준다.\n\n| ID | 규칙 |\n| --- | --- |\n| `UI-01` | 피격된 적만 HP 바를 표시한다. |\n"""

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            source_path = temp_root / "source.md"
            output_path = temp_root / "human-gdd.pdf"
            source_path.write_text(source, encoding="utf-8")

            exporter = load_exporter_module()
            exporter.export_pdf(
                source_path,
                output_path,
                source_branch="codex/test-publication",
                source_commit="0123456789abcdef0123456789abcdef01234567",
                generated_at="2026-08-28T00:00:00+09:00",
            )

            self.assertTrue(output_path.read_bytes().startswith(b"%PDF-"))
            reader = PdfReader(str(output_path))
            self.assertGreater(len(reader.pages), 0)
            rendered_text = "\n".join(page.extract_text() or "" for page in reader.pages)
            self.assertIn("닌자의 신", rendered_text)
            self.assertIn("피격된 적만 HP 바를 표시한다", rendered_text)
            self.assertIn("0123456789abcdef0123456789abcdef01234567", rendered_text)


if __name__ == "__main__":
    unittest.main()
