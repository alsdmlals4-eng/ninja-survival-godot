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
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas
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
    def code_span(match: re.Match[str]) -> str:
        content = match.group(1)
        font = mono if content.isascii() else "NinjaGdd"
        return f'<font name="{font}" color="#5B2C2C">{content}</font>'

    text = re.sub(r"\x60([^\x60]+)\x60", code_span, text)
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


BLUEPRINT_MARKER = re.compile(r"<!-- BLUEPRINT_PAGE: (\d{2}) / 28 -->")
BLUEPRINT_TOTAL_PAGES = 28
BLUEPRINT_NAVY = colors.HexColor("#091629")
BLUEPRINT_CARD = colors.HexColor("#152B47")
BLUEPRINT_CARD_ALT = colors.HexColor("#1D3A5A")
BLUEPRINT_CREAM = colors.HexColor("#F7F0E4")
BLUEPRINT_GOLD = colors.HexColor("#D6A94D")
BLUEPRINT_RED = colors.HexColor("#A84B52")
BLUEPRINT_MIST = colors.HexColor("#DCE7EE")


class BlueprintPage:
    """사람 검수용 한 페이지의 source-native 구성 요소."""

    def __init__(
        self,
        *,
        number: int,
        title: str,
        question: str,
        conclusion: str,
        sections: tuple[tuple[str, tuple[str, ...]], ...],
        image_path: Path | None = None,
        image_caption: str = "",
        flow_items: tuple[str, ...] = (),
        grid_rows: tuple[str, ...] = (),
    ) -> None:
        self.number = number
        self.title = title
        self.question = question
        self.conclusion = conclusion
        self.sections = sections
        self.image_path = image_path
        self.image_caption = image_caption
        self.flow_items = flow_items
        self.grid_rows = grid_rows


def strip_markdown(value: str) -> str:
    """작은 canvas 문구에 남는 Markdown 장식을 제거한다."""
    return re.sub(r"[`*_]", "", value).strip()


def parse_blueprint_pages(source: Path) -> list[BlueprintPage]:
    """명시적 페이지 marker를 사람용 visual-blueprint page 데이터로 읽는다."""
    source_text = source.read_text(encoding="utf-8")
    split = BLUEPRINT_MARKER.split(source_text)
    if len(split) != BLUEPRINT_TOTAL_PAGES * 2 + 1:
        raise ValueError("Blueprint source must contain exactly 28 explicit page markers")

    expected_numbers = [f"{index:02d}" for index in range(1, BLUEPRINT_TOTAL_PAGES + 1)]
    page_numbers = split[1::2]
    if page_numbers != expected_numbers:
        raise ValueError("Blueprint page markers must be ordered from 01 through 28")

    pages: list[BlueprintPage] = []
    for marker, raw_page in zip(page_numbers, split[2::2], strict=True):
        title = ""
        question = ""
        conclusion = ""
        image_path: Path | None = None
        image_caption = ""
        sections: list[tuple[str, tuple[str, ...]]] = []
        section_title = ""
        section_lines: list[str] = []
        flow_items: list[str] = []
        grid_rows: list[str] = []
        directive: str | None = None

        def flush_section() -> None:
            nonlocal section_title, section_lines
            if section_title and section_lines:
                sections.append((section_title, tuple(section_lines)))
            section_title = ""
            section_lines = []

        for raw_line in raw_page.splitlines():
            line = raw_line.strip()
            if not line:
                continue
            if line == ":::flow":
                directive = "flow"
                continue
            if line == ":::grid":
                directive = "grid"
                continue
            if line == ":::":
                directive = None
                continue
            if directive == "flow":
                flow_items.extend(strip_markdown(item) for item in line.split("|") if item.strip())
                continue
            if directive == "grid":
                grid_rows.append(line)
                continue

            image_match = re.match(r"!\[([^]]*)\]\(([^)]+)\)", line)
            if image_match:
                image_caption = image_match.group(1)
                image_path = (source.parent / image_match.group(2)).resolve()
                continue
            if line.startswith("# "):
                title = strip_markdown(line[2:])
                continue
            if line.startswith("## "):
                flush_section()
                section_title = strip_markdown(line[3:])
                continue
            if line.startswith(">"):
                quote = strip_markdown(line.lstrip(">").strip())
                if "검수 질문" in quote:
                    question = quote.split("·", 1)[-1].strip()
                elif "한 줄 결론" in quote:
                    conclusion = quote.split("·", 1)[-1].strip()
                continue

            content = strip_markdown(re.sub(r"^[-*]\s+", "", line))
            if not section_title:
                section_title = "핵심"
            section_lines.append(content)

        flush_section()
        if not title or not question or not conclusion:
            raise ValueError(f"Blueprint page {marker} requires title, review question, and conclusion")
        if image_path is not None and not image_path.is_file():
            raise FileNotFoundError(f"Blueprint image does not exist: {image_path}")
        pages.append(
            BlueprintPage(
                number=int(marker),
                title=title,
                question=question,
                conclusion=conclusion,
                sections=tuple(sections),
                image_path=image_path,
                image_caption=image_caption,
                flow_items=tuple(flow_items),
                grid_rows=tuple(grid_rows),
            )
        )
    return pages


def make_blueprint_styles(regular: str, bold: str) -> dict[str, ParagraphStyle]:
    """Landscape A4 visual-blueprint canvas에 쓰는 최소 스타일 묶음."""
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "BlueprintTitle",
            parent=base["Title"],
            fontName=bold,
            fontSize=24,
            leading=29,
            textColor=BLUEPRINT_CREAM,
            spaceAfter=0,
        ),
        "question": ParagraphStyle(
            "BlueprintQuestion",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=8.5,
            leading=12,
            textColor=BLUEPRINT_CREAM,
        ),
        "conclusion": ParagraphStyle(
            "BlueprintConclusion",
            parent=base["BodyText"],
            fontName=bold,
            fontSize=10.5,
            leading=15,
            textColor=BLUEPRINT_NAVY,
        ),
        "section": ParagraphStyle(
            "BlueprintSection",
            parent=base["Heading2"],
            fontName=bold,
            fontSize=9.4,
            leading=12,
            textColor=BLUEPRINT_GOLD,
        ),
        "body": ParagraphStyle(
            "BlueprintBody",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=8.2,
            leading=11.4,
            textColor=BLUEPRINT_MIST,
        ),
        "flow": ParagraphStyle(
            "BlueprintFlow",
            parent=base["BodyText"],
            fontName=bold,
            fontSize=6.7,
            leading=8.5,
            alignment=TA_CENTER,
            textColor=BLUEPRINT_NAVY,
        ),
        "caption": ParagraphStyle(
            "BlueprintCaption",
            parent=base["BodyText"],
            fontName=regular,
            fontSize=6.6,
            leading=8,
            textColor=BLUEPRINT_GOLD,
        ),
    }


def draw_paragraph(
    canvas: Canvas,
    value: str,
    style: ParagraphStyle,
    x: float,
    y_top: float,
    width: float,
) -> float:
    """Paragraph를 top coordinate 기준으로 그리고 차지한 높이를 반환한다."""
    paragraph = Paragraph(value, style)
    _, height = paragraph.wrap(width, 1000)
    paragraph.drawOn(canvas, x, y_top - height)
    return height


def blueprint_card_height(lines: tuple[str, ...], style: ParagraphStyle, width: float) -> float:
    """내용을 자르지 않도록 카드의 필요한 최소 높이를 계산한다."""
    body = "<br/>".join(f"• {inline_markdown(line, 'Courier')}" for line in lines)
    paragraph = Paragraph(body, style)
    _, body_height = paragraph.wrap(width - 16, 1000)
    return max(48.0, body_height + 31.0)


def draw_blueprint_card(
    canvas: Canvas,
    heading: str,
    lines: tuple[str, ...],
    styles: dict[str, ParagraphStyle],
    x: float,
    y_top: float,
    width: float,
    height: float,
    accent: colors.Color,
) -> None:
    """보이는 것·하는 것·결정하는 것을 같은 리듬의 정보 카드로 그린다."""
    canvas.setFillColor(BLUEPRINT_CARD_ALT)
    canvas.roundRect(x, y_top - height, width, height, 7, fill=1, stroke=0)
    canvas.setFillColor(accent)
    canvas.roundRect(x, y_top - 4, width, 4, 2, fill=1, stroke=0)
    draw_paragraph(canvas, inline_markdown(heading, "Courier"), styles["section"], x + 8, y_top - 10, width - 16)
    body = "<br/>".join(f"• {inline_markdown(line, 'Courier')}" for line in lines)
    draw_paragraph(canvas, body, styles["body"], x + 8, y_top - 25, width - 16)


def draw_blueprint_flow(
    canvas: Canvas,
    flow_items: tuple[str, ...],
    styles: dict[str, ParagraphStyle],
    x: float,
    y_top: float,
    width: float,
) -> float:
    """한 페이지 안에서 Run/스테이지 흐름을 짧은 순서 카드로 보여 준다."""
    if not flow_items:
        return 0.0
    gap = 5.0
    item_width = (width - gap * (len(flow_items) - 1)) / len(flow_items)
    height = 43.0 if len(flow_items) <= 6 else 50.0
    for index, item in enumerate(flow_items):
        item_x = x + index * (item_width + gap)
        canvas.setFillColor(BLUEPRINT_CREAM if index % 2 == 0 else colors.HexColor("#E3C77F"))
        canvas.roundRect(item_x, y_top - height, item_width, height, 6, fill=1, stroke=0)
        draw_paragraph(canvas, inline_markdown(item, "Courier"), styles["flow"], item_x + 5, y_top - 8, item_width - 10)
        if index < len(flow_items) - 1:
            canvas.setStrokeColor(BLUEPRINT_GOLD)
            canvas.setLineWidth(1.2)
            start_x = item_x + item_width
            canvas.line(start_x + 1, y_top - height / 2, start_x + gap - 1, y_top - height / 2)
    return height + 11.0


def draw_blueprint_grid(canvas: Canvas, x: float, y_top: float) -> float:
    """3×3 시작 가방을 텍스트가 아닌 조작 가능한 공간의 도식으로 표현한다."""
    cell = 30.0
    canvas.setFillColor(BLUEPRINT_GOLD)
    canvas.setFont("NinjaGddBold", 8)
    canvas.drawString(x, y_top, "설계 도식 · 시작 사용 가능 공간")
    grid_top = y_top - 10
    for row in range(3):
        for column in range(3):
            cell_x = x + column * (cell + 4)
            cell_y = grid_top - (row + 1) * (cell + 4)
            canvas.setFillColor(BLUEPRINT_CREAM if (row + column) % 2 == 0 else colors.HexColor("#E2C879"))
            canvas.roundRect(cell_x, cell_y, cell, cell, 4, fill=1, stroke=0)
    canvas.setFillColor(BLUEPRINT_MIST)
    canvas.setFont("NinjaGdd", 7)
    canvas.drawString(x + 112, grid_top - 31, "처음부터 열린 6×6이 아니라")
    canvas.drawString(x + 112, grid_top - 44, "정확히 3×3에서 시작한다.")
    return 128.0


def draw_blueprint_image(
    canvas: Canvas,
    page: BlueprintPage,
    styles: dict[str, ParagraphStyle],
    x: float,
    y_bottom: float,
    width: float,
    height: float,
) -> None:
    """승인 자산/현재 화면 참고를 비율 보존으로 배치한다."""
    if page.image_path is None:
        return
    canvas.setFillColor(colors.HexColor("#0E223B"))
    canvas.roundRect(x, y_bottom, width, height, 9, fill=1, stroke=0)
    image = ImageReader(str(page.image_path))
    image_width, image_height = image.getSize()
    scale = min((width - 18) / image_width, (height - 34) / image_height)
    rendered_width = image_width * scale
    rendered_height = image_height * scale
    image_x = x + (width - rendered_width) / 2
    image_y = y_bottom + 16 + (height - 34 - rendered_height) / 2
    canvas.drawImage(image, image_x, image_y, rendered_width, rendered_height, mask="auto", preserveAspectRatio=True)
    draw_paragraph(canvas, inline_markdown(page.image_caption, "Courier"), styles["caption"], x + 8, y_bottom + height - 7, width - 16)


def draw_blueprint_page(canvas: Canvas, page: BlueprintPage, styles: dict[str, ParagraphStyle]) -> None:
    """한 페이지에 질문→결론→도식/화면→행동 카드를 같은 순서로 고정한다."""
    width, height = PAGE_SIZE
    margin = 14 * mm
    canvas.setFillColor(BLUEPRINT_NAVY)
    canvas.rect(0, 0, width, height, fill=1, stroke=0)
    canvas.setFillColor(BLUEPRINT_RED if page.number % 2 else BLUEPRINT_GOLD)
    canvas.rect(0, height - 10, width, 10, fill=1, stroke=0)

    canvas.setFillColor(BLUEPRINT_GOLD)
    canvas.setFont("NinjaGddBold", 7.5)
    canvas.drawString(margin, height - 24, "닌자의 신 | 사람용 게임 경험 블루프린트")
    canvas.setFillColor(BLUEPRINT_MIST)
    canvas.setFont("NinjaGdd", 7.5)
    canvas.drawRightString(width - margin, height - 24, f"{page.number:02d} / {BLUEPRINT_TOTAL_PAGES}")

    y = height - 42
    title_height = draw_paragraph(canvas, inline_markdown(page.title, "Courier"), styles["title"], margin, y, width - 2 * margin)
    y -= title_height + 7

    question_height = 26
    canvas.setFillColor(BLUEPRINT_CARD)
    canvas.roundRect(margin, y - question_height, width - 2 * margin, question_height, 6, fill=1, stroke=0)
    canvas.setFillColor(BLUEPRINT_GOLD)
    canvas.setFont("NinjaGddBold", 7.3)
    canvas.drawString(margin + 8, y - 10, "검수 질문")
    draw_paragraph(canvas, inline_markdown(page.question, "Courier"), styles["question"], margin + 53, y - 7, width - 2 * margin - 61)
    y -= question_height + 8

    conclusion_style = styles["conclusion"]
    conclusion = Paragraph(inline_markdown(page.conclusion, "Courier"), conclusion_style)
    conclusion_width = width - 2 * margin - 16
    _, conclusion_height = conclusion.wrap(conclusion_width, 1000)
    conclusion_card_height = max(35.0, conclusion_height + 14)
    canvas.setFillColor(BLUEPRINT_CREAM)
    canvas.roundRect(margin, y - conclusion_card_height, width - 2 * margin, conclusion_card_height, 7, fill=1, stroke=0)
    conclusion.drawOn(canvas, margin + 8, y - conclusion_card_height + 7)
    y -= conclusion_card_height + 12

    bottom = 18 * mm
    if page.flow_items:
        y -= draw_blueprint_flow(canvas, page.flow_items, styles, margin, y, width - 2 * margin)
    if page.grid_rows:
        y -= draw_blueprint_grid(canvas, margin, y)

    image_width = 0.0
    if page.image_path is not None:
        image_width = 108 * mm
        draw_blueprint_image(canvas, page, styles, width - margin - image_width, bottom, image_width, max(120.0, y - bottom))

    section_width = width - 2 * margin - image_width - (10 * mm if image_width else 0)
    section_x = margin
    columns = 1 if page.image_path is not None or len(page.sections) <= 2 else 2
    gap = 8.0
    card_width = (section_width - gap * (columns - 1)) / columns
    section_y = y
    for row_start in range(0, len(page.sections), columns):
        row = page.sections[row_start : row_start + columns]
        row_heights = [blueprint_card_height(lines, styles["body"], card_width) for _, lines in row]
        row_height = max(row_heights)
        for column, ((heading, lines), card_height) in enumerate(zip(row, row_heights, strict=True)):
            draw_blueprint_card(
                canvas,
                heading,
                lines,
                styles,
                section_x + column * (card_width + gap),
                section_y,
                card_width,
                row_height,
                BLUEPRINT_GOLD if (row_start + column) % 2 == 0 else BLUEPRINT_RED,
            )
        section_y -= row_height + 8

    canvas.setStrokeColor(colors.HexColor("#35506D"))
    canvas.setLineWidth(0.5)
    canvas.line(margin, 12 * mm, width - margin, 12 * mm)
    canvas.setFont("NinjaGdd", 6.8)
    canvas.setFillColor(BLUEPRINT_MIST)
    canvas.drawString(margin, 8.5 * mm, "사람 검수용 · 실제 화면 참고와 설계 도식을 구분해 표시")
    canvas.drawRightString(width - margin, 8.5 * mm, f"{page.number:02d} / {BLUEPRINT_TOTAL_PAGES}")


def export_blueprint_pdf(
    source: Path,
    output: Path,
    *,
    source_branch: str,
    source_commit: str,
    generated_at: str,
    document_title: str,
) -> None:
    """명시적 28페이지 source를 visual blueprint PDF로 파생한다."""
    if not re.fullmatch(r"[0-9a-f]{40}", source_commit):
        raise ValueError("source_commit must be a 40-character lowercase Git SHA")
    pages = parse_blueprint_pages(source)
    regular, bold = register_fonts()
    styles = make_blueprint_styles(regular, bold)
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary_output = output.with_suffix(output.suffix + ".tmp")
    if temporary_output.exists():
        temporary_output.unlink()
    try:
        canvas = Canvas(str(temporary_output), pagesize=PAGE_SIZE, title=document_title, author="Ninja Survival Project")
        canvas.setTitle(document_title)
        canvas.setAuthor("Ninja Survival Project")
        canvas.setSubject(f"Source {source.as_posix()} · {source_branch} · {source_commit} · {generated_at}")
        for page in pages:
            draw_blueprint_page(canvas, page, styles)
            canvas.showPage()
        canvas.save()
        if not temporary_output.is_file() or not temporary_output.read_bytes().startswith(b"%PDF-"):
            raise RuntimeError("Blueprint export did not create a valid PDF header")
        temporary_output.replace(output)
    finally:
        if temporary_output.exists():
            temporary_output.unlink()


def page_decor(canvas, document) -> None:
    """모든 페이지에 문서 정체성과 페이지 번호를 표시한다."""
    canvas.saveState()
    width, height = PAGE_SIZE
    canvas.setStrokeColor(colors.HexColor("#B7C3CE"))
    canvas.setLineWidth(0.5)
    canvas.line(LEFT_MARGIN, height - 11 * mm, width - RIGHT_MARGIN, height - 11 * mm)
    canvas.setFont(document.ninja_regular_font, 7)
    canvas.setFillColor(colors.HexColor("#526779"))
    canvas.drawString(LEFT_MARGIN, height - 8 * mm, document.ninja_header_label)
    canvas.drawRightString(width - RIGHT_MARGIN, height - 8 * mm, document.ninja_right_header_label)
    canvas.line(LEFT_MARGIN, 10 * mm, width - RIGHT_MARGIN, 10 * mm)
    canvas.drawString(LEFT_MARGIN, 6.7 * mm, document.ninja_footer_label)
    canvas.drawRightString(width - RIGHT_MARGIN, 6.7 * mm, f"{document.page}")
    canvas.restoreState()


def export_pdf(
    source: Path,
    output: Path,
    *,
    source_branch: str,
    source_commit: str,
    generated_at: str,
    document_title: str = "닌자의 신 - Master GDD",
    header_label: str = "닌자의 신 | Master GDD",
    right_header_label: str = "Repository human edition",
) -> None:
    """PDF를 임시 파일로 검증 가능하게 만들고 성공 시에만 대상 파일을 교체한다."""
    if not source.is_file():
        raise FileNotFoundError(f"GDD source does not exist: {source}")
    if BLUEPRINT_MARKER.search(source.read_text(encoding="utf-8")):
        export_blueprint_pdf(
            source,
            output,
            source_branch=source_branch,
            source_commit=source_commit,
            generated_at=generated_at,
            document_title=document_title,
        )
        return
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
        title=document_title,
        author="Ninja Survival Project",
    )
    document.ninja_regular_font = regular
    document.ninja_header_label = header_label
    document.ninja_right_header_label = right_header_label
    document.ninja_footer_label = f"Source: {source.as_posix()}"
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
    parser.add_argument("--document-title", default="닌자의 신 - Master GDD")
    parser.add_argument("--header-label", default="닌자의 신 | Master GDD")
    parser.add_argument("--right-header-label", default="Repository human edition")
    args = parser.parse_args()
    export_pdf(
        args.source,
        args.output,
        source_branch=args.source_branch,
        source_commit=args.source_commit,
        generated_at=args.generated_at,
        document_title=args.document_title,
        header_label=args.header_label,
        right_header_label=args.right_header_label,
    )


if __name__ == "__main__":
    main()
