"""사람용 GDD PDF 내보내기의 실제 산출물 계약을 검증한다."""

from __future__ import annotations

import importlib.util
import re
import tempfile
import unittest
from pathlib import Path

from pypdf import PdfReader
from reportlab.lib import colors


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
EXPORTER_PATH = REPOSITORY_ROOT / "tools" / "export_human_gdd_pdf.py"
BLUEPRINT_SOURCE_PATH = REPOSITORY_ROOT / "docs" / "design" / "NINJA_SURVIVAL_HUMAN_GDD.md"
SCREEN_REFERENCE_README_PATH = REPOSITORY_ROOT / "docs" / "visual" / "screen-references" / "README.md"
LOCKED_BATTLE_REFERENCE_PATH = (
    REPOSITORY_ROOT
    / "docs"
    / "visual"
    / "screen-references"
    / "scrref-battle-autocombat-continuous-floor-v3.png"
)
CURRENT_DECISIONS_PATH = REPOSITORY_ROOT / "docs" / "CURRENT_CONFIRMED_DECISIONS.md"
ACTIVE_CONTEXT_PATH = REPOSITORY_ROOT / "docs" / "ACTIVE_CONTEXT.md"
MASTER_GDD_PATH = REPOSITORY_ROOT / "docs" / "design" / "NINJA_SURVIVAL_MASTER_GDD.md"
VISUAL_COVERAGE_PATH = REPOSITORY_ROOT / "docs" / "visual" / "SCREEN_SURFACE_AND_VISUAL_COVERAGE.md"
DOCUMENTATION_MAP_PATH = REPOSITORY_ROOT / "docs" / "DOCUMENTATION_MAP.md"


def load_exporter_module():
    spec = importlib.util.spec_from_file_location("human_gdd_pdf_exporter", EXPORTER_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("human GDD PDF exporter module is unavailable")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class HumanGddPdfExporterTests(unittest.TestCase):
    def test_current_visual_and_backpack_authority_do_not_restore_superseded_state(self) -> None:
        """Break caught: current reader surfaces call an archived backdrop or 4x3 baseline the active product state."""
        human_source = BLUEPRINT_SOURCE_PATH.read_text(encoding="utf-8")
        current_decisions = CURRENT_DECISIONS_PATH.read_text(encoding="utf-8")
        active_context = ACTIVE_CONTEXT_PATH.read_text(encoding="utf-8")
        master_gdd = MASTER_GDD_PATH.read_text(encoding="utf-8")
        visual_coverage = VISUAL_COVERAGE_PATH.read_text(encoding="utf-8")
        documentation_map = DOCUMENTATION_MAP_PATH.read_text(encoding="utf-8")

        self.assertIn("역사적", human_source)
        self.assertNotIn("현재 게임에 연결된 기존 화면 자산", human_source)
        self.assertNotIn("기존 배경을 자동으로 교체하지 않으며", human_source)
        self.assertIn("현재 isolated 브랜치", current_decisions)
        self.assertNotIn("The existing `Main/BattlefieldBackdrop` runtime texture is not replaced.", current_decisions)
        self.assertIn("historical/provenance/rollback source", active_context)
        self.assertNotIn("Its sole consumer is `Main/BattlefieldBackdrop` behind gameplay.", active_context)
        self.assertIn("moonlit battlefield floor tile", master_gdd)
        self.assertIn("Main/BattlefieldBackdrop/FloorTile", visual_coverage)
        self.assertIn("정확히 3×3 시작", documentation_map)
        self.assertNotIn("6x6 / 4x3 / 회전", documentation_map)

    def test_locked_continuous_floor_reference_is_bound_to_the_human_blueprint(self) -> None:
        """Break caught: a user-locked combat reference is stored but omitted from its declared reader surface."""
        source = BLUEPRINT_SOURCE_PATH.read_text(encoding="utf-8")
        reference_manifest = SCREEN_REFERENCE_README_PATH.read_text(encoding="utf-8")

        self.assertTrue(LOCKED_BATTLE_REFERENCE_PATH.is_file())
        self.assertIn("scrref-battle-autocombat-continuous-floor-v3.png", source)
        self.assertIn("연속 바닥", source)
        self.assertIn("SCRREF-BATTLE-AUTOCOMBAT-03", reference_manifest)
        self.assertIn("68727c87b5f81dee18f06bb0955d37314a3e0ec03f04fe9dd33f842df0dd6eac", reference_manifest)
        self.assertIn("USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME", reference_manifest)

    def test_human_blueprint_source_has_28_explicit_review_pages(self) -> None:
        """Break caught: the reader PDF quietly collapses back into a short prose GDD."""
        source = BLUEPRINT_SOURCE_PATH.read_text(encoding="utf-8")
        page_markers = re.findall(r"<!-- BLUEPRINT_PAGE: (\d{2}) / 28 -->", source)

        self.assertEqual(page_markers, [f"{index:02d}" for index in range(1, 29)])
        self.assertIn("당신은 한 명의 닌자를 움직인다", source)
        self.assertIn("정확히 3×3", source)
        self.assertIn("스테이지", source)
        self.assertIn("페이즈", source)
        self.assertIn("닌자소울", source)
        self.assertIn("진짜 Run 종료", source)
        self.assertIn("제한된 한 번의 같은 스테이지 재도전", source)

    def test_current_blueprint_export_has_28_numbered_pages(self) -> None:
        """Break caught: source sections exist but the generated PDF loses the review-page contract."""
        with tempfile.TemporaryDirectory() as temp_dir:
            output_path = Path(temp_dir) / "ninja-blueprint.pdf"
            exporter = load_exporter_module()
            exporter.export_pdf(
                BLUEPRINT_SOURCE_PATH,
                output_path,
                source_branch="codex/test-blueprint",
                source_commit="0123456789abcdef0123456789abcdef01234567",
                generated_at="2026-08-30T00:00:00+09:00",
                document_title="닌자의 신 - 사람용 게임 경험 블루프린트",
                header_label="닌자의 신 | 게임 경험 블루프린트",
                right_header_label="사람 검수용",
            )

            reader = PdfReader(str(output_path))
            rendered_text = "\n".join(page.extract_text() or "" for page in reader.pages)
            self.assertEqual(len(reader.pages), 28)
            self.assertIn("01 / 28", rendered_text)
            self.assertIn("28 / 28", rendered_text)
            self.assertIn("한 명의 닌자", rendered_text)
            self.assertIn("3×3", rendered_text)
            self.assertIn("닌자소울", rendered_text)
            self.assertIn("진짜 Run 종료", rendered_text)

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
