"""사람용 GDD PDF 내보내기의 실제 산출물 계약을 검증한다."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

from pypdf import PdfReader
from reportlab.lib import colors


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
    def test_export_uses_reader_facing_document_identity(self) -> None:
        """Break caught: a player guide is published with the technical Master-GDD identity."""
        source = "# 닌자의 신 — 플레이어용 게임 기획서\n\n게임의 핵심 재미를 설명한다.\n"

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            source_path = temp_root / "source.md"
            output_path = temp_root / "player-gdd.pdf"
            source_path.write_text(source, encoding="utf-8")

            exporter = load_exporter_module()
            exporter.export_pdf(
                source_path,
                output_path,
                source_branch="main",
                source_commit="0123456789abcdef0123456789abcdef01234567",
                generated_at="2026-08-28T00:00:00+09:00",
                document_title="닌자의 신 - 플레이어용 게임 기획서",
                header_label="닌자의 신 | 플레이어용 게임 기획서",
                right_header_label="읽기용 게임 기획서",
            )

            reader = PdfReader(str(output_path))
            rendered_text = "\n".join(page.extract_text() or "" for page in reader.pages)
            self.assertEqual(reader.metadata.title, "닌자의 신 - 플레이어용 게임 기획서")
            self.assertIn("닌자의 신 | 플레이어용 게임 기획서", rendered_text)
            self.assertIn("읽기용 게임 기획서", rendered_text)

    def test_export_preserves_korean_inside_inline_code(self) -> None:
        """Break caught: Korean inline-code labels are rendered as missing glyphs by Courier."""
        source = "# 닌자의 신\n\n`닌자소울`은 영구 재화다.\n"

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir)
            source_path = temp_root / "source.md"
            output_path = temp_root / "human-gdd.pdf"
            source_path.write_text(source, encoding="utf-8")

            exporter = load_exporter_module()
            exporter.export_pdf(
                source_path,
                output_path,
                source_branch="main",
                source_commit="0123456789abcdef0123456789abcdef01234567",
                generated_at="2026-08-28T00:00:00+09:00",
            )

            reader = PdfReader(str(output_path))
            rendered_text = "\n".join(page.extract_text() or "" for page in reader.pages)
            self.assertIn("닌자소울은 영구 재화다", rendered_text)

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

    def test_exporter_renders_relative_markdown_link_as_its_label(self) -> None:
        """Break caught: repository PDF links leak raw Markdown syntax into human copy."""
        source = "# 닌자의 신\n\n[PDF 내려받기](../../exports/ninja.pdf)\n"

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

            reader = PdfReader(str(output_path))
            rendered_text = "\n".join(page.extract_text() or "" for page in reader.pages)
            self.assertIn("PDF 내려받기", rendered_text)
            self.assertNotIn("[PDF 내려받기](../../exports/ninja.pdf)", rendered_text)

    def test_table_headers_use_light_text_on_the_dark_header_band(self) -> None:
        """Break caught: table headers inherit body ink and become unreadable on navy."""
        exporter = load_exporter_module()
        regular, bold = exporter.register_fonts()
        table, _ = exporter.parse_table(
            ["| ID | 규칙 |", "| --- | --- |", "| UI-01 | 상태 아이콘 |"],
            0,
            exporter.make_styles(regular, bold),
            bold,
        )

        self.assertEqual(table._cellvalues[0][0].style.textColor, colors.white)


if __name__ == "__main__":
    unittest.main()
