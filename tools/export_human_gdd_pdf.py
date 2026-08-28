"""사람용 Master GDD Markdown을 다운로드 가능한 한국어 PDF로 내보낸다."""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    PageTemplate,
    Paragraph,
    Preformatted,
    Spacer,
    Table,
    TableStyle,
)


PAGE_SIZE = landscape(A4)
LEFT_MARGIN = 16 * mm
RIGHT_MARGIN = 16 * mm
TOP_MARGIN = 18 * mm
BOTTOM_MARGIN = 16 * mm
FONT_REGULAR = Path(r"C:\Windows\Fonts\malgun.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\malgunbd.ttf")


def register_fonts() -> tuple[str, str]:
    """등록 가능한 한글 TrueType 글꼴과 Paragraph 가족을 반환한다."""
    if not FONT_REGULAR.exists() or not FONT_BOLD.exists():
        raise RuntimeError("Malgun Gothic fonts are required for Korean GDD PDF export")

    pdfmetrics.registerFont(TTFont("NinjaGdd", str(FONT_REGULAR)))
    pdfmetrics.registerFont(TTFont("NinjaGddBold", str(FONT_BOLD)))
    pdfmetrics.registerFontFamily(
        "NinjaGdd",
        normal="NinjaGdd",
        bold="NinjaGddBold",
        italic="NinjaGdd",
        boldItalic="NinjaGddBold",
    )
    return "NinjaGdd", "NinjaGddBold"


def inline_markdown(value: str, mono: str) -> str:
    """ReportLab Paragraph가 읽는 최소 Markdown 표현으로 변환한다."""
    text = html.escape(value.strip())
    text = re.sub(
        r"\[([^\]]+)\]\(([^)\s]+)\)",
        r'<link href="\2" color="#254E70">\1</link>',
        text,
    )
    text = re.sub(
        r"\x60([^\x60]+)\x60",
        lambda match: f'<font name="{mono}" color="#5B2C2C">{match.group(1)}</font>',
        text,
    )
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<i>\1</i>", text)
    return text


def make_styles(regular: str, bold: str) -> dict[str, ParagraphStyle]:
    """가독성 우선의 한글 GDD 문단 스타일을 구성한다."""
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "NinjaTitle",
            parent=base["Title"],
            fontName=bold,
            fontSize=23,
            leading=29,
            textColor=colors.HexColor("#16233A"),
            alignment=TA_CENTER,
            spaceAfter=7 * mm,
        ),
        "publication": ParagraphStyle(
            "NinjaPublication",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=7.2,
            leading=9.5,
            textColor=colors.HexColor("#526779"),
            alignment=TA_CENTER,
            spaceAfter=7 * mm,
        ),
        "h1": ParagraphStyle(
            "NinjaH1",
            parent=base["Heading1"],
            fontName=bold,
            fontSize=16,
            leading=21,
            textColor=colors.HexColor("#16233A"),
            spaceBefore=7 * mm,
            spaceAfter=3 * mm,
            keepWithNext=True,
        ),
        "h2": ParagraphStyle(
            "NinjaH2",
            parent=base["Heading2"],
            fontName=bold,
            fontSize=12,
            leading=16,
            textColor=colors.HexColor("#314E72"),
            spaceBefore=5 * mm,
            spaceAfter=2 * mm,
            keepWithNext=True,
        ),
        "h3": ParagraphStyle(
            "NinjaH3",
            parent=base["Heading3"],
            fontName=bold,
            fontSize=10,
            leading=13,
            textColor=colors.HexColor("#6A3A28"),
            spaceBefore=3 * mm,
            spaceAfter=1.5 * mm,
            keepWithNext=True,
        ),
        "body": ParagraphStyle(
            "NinjaBody",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=8.8,
            leading=13,
            textColor=colors.HexColor("#20252C"),
            alignment=TA_LEFT,
            spaceAfter=1.6 * mm,
        ),
        "small": ParagraphStyle(
            "NinjaSmall",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=7.1,
            leading=9.3,
            textColor=colors.HexColor("#20252C"),
        ),
        "table_header": ParagraphStyle(
            "NinjaTableHeader",
            parent=base["BodyText"],
            fontName=bold,
            fontSize=7.1,
            leading=9.3,
            textColor=colors.white,
        ),
        "quote": ParagraphStyle(
            "NinjaQuote",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=8.2,
            leading=12,
            textColor=colors.HexColor("#3B5066"),
            leftIndent=5 * mm,
            borderColor=colors.HexColor("#C8D5E5"),
            borderWidth=0.8,
            borderPadding=4,
            spaceAfter=2.5 * mm,
        ),
        "code": ParagraphStyle(
            "NinjaCode",
            parent=base["Code"],
            fontName="Courier",
            fontSize=6.8,
            leading=8.5,
            textColor=colors.HexColor("#2E353B"),
            backColor=colors.HexColor("#F2F4F6"),
            borderColor=colors.HexColor("#D5DCE3"),
            borderWidth=0.5,
            borderPadding=5,
            spaceAfter=2.5 * mm,
        ),
    }


def parse_table(
    lines: list[str],
    start: int,
    styles: dict[str, ParagraphStyle],
    bold: str,
) -> tuple[Table, int]:
    """연속된 GitHub Markdown 표를 페이지 내에서 행 단위로 분할 가능한 표로 바꾼다."""
    rows: list[list[str]] = []
    index = start
    while index < len(lines) and lines[index].strip().startswith("|"):
        raw = [cell.strip() for cell in lines[index].strip().strip("|").split("|")]
        if not all(re.fullmatch(r":?-{3,}:?", cell) for cell in raw):
            rows.append(raw)
        index += 1

    column_count = max(len(row) for row in rows)
    normalized = [row + [""] * (column_count - len(row)) for row in rows]
    data = [
        [
            Paragraph(
                inline_markdown(cell, "Courier"),
                styles["table_header"] if row_index == 0 else styles["small"],
            )
            for cell in row
        ]
        for row_index, row in enumerate(normalized)
    ]
    available_width = PAGE_SIZE[0] - LEFT_MARGIN - RIGHT_MARGIN
    table = Table(
        data,
        colWidths=[available_width / column_count] * column_count,
        repeatRows=1,
        hAlign="LEFT",
    )
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#233A57")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), bold),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#B7C3CE")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F8FAFC")),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return table, index


def markdown_story(
    source: Path,
    styles: dict[str, ParagraphStyle],
    bold: str,
    source_branch: str,
    source_commit: str,
    generated_at: str,
) -> list:
    """사람용 Markdown 정본을 ReportLab flowable 목록으로 변환한다."""
    lines = source.read_text(encoding="utf-8").splitlines()
    story: list = []
    index = 0
    in_code = False
    code_lines: list[str] = []
    title_written = False

    while index < len(lines):
        line = lines[index]
        stripped = line.strip()

        if stripped.startswith("```"):
            if in_code:
                story.append(Preformatted("\n".join(code_lines), styles["code"]))
                code_lines = []
            in_code = not in_code
            index += 1
            continue
        if in_code:
            code_lines.append(line)
            index += 1
            continue
        if stripped.startswith("|"):
            table, index = parse_table(lines, index, styles, bold)
            story.extend([table, Spacer(1, 3 * mm)])
            continue
        if not stripped or stripped in {"---", "***"}:
            story.append(Spacer(1, 1.5 * mm))
            index += 1
            continue

        heading = re.match(r"^(#{1,3})\s+(.+)$", stripped)
        if heading:
            level = len(heading.group(1))
            if level == 1 and not title_written:
                story.append(Paragraph(inline_markdown(heading.group(2), "Courier"), styles["title"]))
                story.append(
                    Paragraph(
                        inline_markdown(
                            f"발행 기준 · branch `{source_branch}` · source commit `{source_commit}` · 생성 `{generated_at}`",
                            "Courier",
                        ),
                        styles["publication"],
                    )
                )
                title_written = True
            else:
                story.append(Paragraph(inline_markdown(heading.group(2), "Courier"), styles[f"h{level}"]))
            index += 1
            continue
        if stripped.startswith(">"):
            story.append(Paragraph(inline_markdown(stripped.lstrip(">").strip(), "Courier"), styles["quote"]))
            index += 1
            continue

        bullet = re.match(r"^[-*]\s+(.+)$", stripped)
        numbered = re.match(r"^(\d+)\.\s+(.+)$", stripped)
        if bullet:
            story.append(Paragraph("• " + inline_markdown(bullet.group(1), "Courier"), styles["body"]))
        elif numbered:
            story.append(
                Paragraph(
                    f"{numbered.group(1)}. " + inline_markdown(numbered.group(2), "Courier"),
                    styles["body"],
                )
            )
        else:
            story.append(Paragraph(inline_markdown(stripped, "Courier"), styles["body"]))
        index += 1

    if code_lines:
        story.append(Preformatted("\n".join(code_lines), styles["code"]))
    return story


def page_decor(canvas, document) -> None:
    """모든 페이지에 문서 정체성과 페이지 번호를 표시한다."""
    canvas.saveState()
    width, height = PAGE_SIZE
    canvas.setStrokeColor(colors.HexColor("#B7C3CE"))
    canvas.setLineWidth(0.5)
    canvas.line(LEFT_MARGIN, height - 11 * mm, width - RIGHT_MARGIN, height - 11 * mm)
    canvas.setFont(document.ninja_regular_font, 7)
    canvas.setFillColor(colors.HexColor("#526779"))
    canvas.drawString(LEFT_MARGIN, height - 8 * mm, "닌자의 신 | Master GDD")
    canvas.drawRightString(width - RIGHT_MARGIN, height - 8 * mm, "Repository human edition")
    canvas.line(LEFT_MARGIN, 10 * mm, width - RIGHT_MARGIN, 10 * mm)
    canvas.drawString(LEFT_MARGIN, 6.7 * mm, "Source: docs/design/NINJA_SURVIVAL_MASTER_GDD.md")
    canvas.drawRightString(width - RIGHT_MARGIN, 6.7 * mm, f"{document.page}")
    canvas.restoreState()


def export_pdf(
    source: Path,
    output: Path,
    *,
    source_branch: str,
    source_commit: str,
    generated_at: str,
) -> None:
    """PDF를 임시 파일로 검증 가능하게 만들고 성공 시에만 대상 파일을 교체한다."""
    if not source.is_file():
        raise FileNotFoundError(f"GDD source does not exist: {source}")
    if not re.fullmatch(r"[0-9a-f]{40}", source_commit):
        raise ValueError("source_commit must be a 40-character lowercase Git SHA")

    regular, bold = register_fonts()
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary_output = output.with_suffix(output.suffix + ".tmp")
    if temporary_output.exists():
        temporary_output.unlink()

    frame = Frame(
        LEFT_MARGIN,
        BOTTOM_MARGIN,
        PAGE_SIZE[0] - LEFT_MARGIN - RIGHT_MARGIN,
        PAGE_SIZE[1] - TOP_MARGIN - BOTTOM_MARGIN,
        id="main",
    )
    document = BaseDocTemplate(
        str(temporary_output),
        pagesize=PAGE_SIZE,
        leftMargin=LEFT_MARGIN,
        rightMargin=RIGHT_MARGIN,
        topMargin=TOP_MARGIN,
        bottomMargin=BOTTOM_MARGIN,
        title="닌자의 신 - Master GDD",
        author="Ninja Survival Project",
    )
    document.ninja_regular_font = regular
    document.addPageTemplates([PageTemplate(id="gdd", frames=[frame], onPage=page_decor)])
    try:
        document.build(markdown_story(source, make_styles(regular, bold), bold, source_branch, source_commit, generated_at))
        if not temporary_output.is_file() or not temporary_output.read_bytes().startswith(b"%PDF-"):
            raise RuntimeError("PDF export did not create a valid PDF header")
        temporary_output.replace(output)
    finally:
        if temporary_output.exists():
            temporary_output.unlink()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-branch", required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--generated-at", required=True)
    args = parser.parse_args()
    export_pdf(
        args.source,
        args.output,
        source_branch=args.source_branch,
        source_commit=args.source_commit,
        generated_at=args.generated_at,
    )


if __name__ == "__main__":
    main()
