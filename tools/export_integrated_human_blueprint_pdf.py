"""기존 28쪽 Human Blueprint에 현재 화면·와이어프레임 보강부를 결합한다.

이 exporter는 historical PDF의 page object를 변경하지 않는다. 새 guide/visual
companion만 ReportLab으로 만든 뒤 pypdf로 결합한다. 따라서 기존 reader snapshot의
레이아웃은 보존하면서도, 현재-main Blueprint와 user-locked asset을 한 다운로드
파일에서 이어서 볼 수 있다.
"""

from __future__ import annotations

import argparse
import hashlib
import re
from dataclasses import dataclass
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
PAGE_SIZE = landscape(A4)
PAGE_WIDTH, PAGE_HEIGHT = PAGE_SIZE
MARGIN = 16 * 2.834645669
FONT_REGULAR = Path(r"C:\Windows\Fonts\malgun.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\malgunbd.ttf")
HISTORICAL_PAGE_COUNT = 28
GUIDE_PAGE_COUNT = 3
VISUAL_COMPANION_PAGE_COUNT = 7
COMPANION_PAGE_COUNT = GUIDE_PAGE_COUNT + VISUAL_COMPANION_PAGE_COUNT

NAVY = colors.HexColor("#081426")
PANEL = colors.HexColor("#132741")
PANEL_ALT = colors.HexColor("#1A3554")
CREAM = colors.HexColor("#F7F0E3")
MIST = colors.HexColor("#D8E4EB")
MUTED = colors.HexColor("#9AB0C2")
GOLD = colors.HexColor("#D8AD59")
RED = colors.HexColor("#B24A4C")
BLUE = colors.HexColor("#69A8D6")
PURPLE = colors.HexColor("#8D6CC8")
GREEN = colors.HexColor("#71A889")

ASSETS = {
    "title_backdrop": REPOSITORY_ROOT / "assets/runtime/ui/title_screen_moonlit_ninja_v2.png",
    "title_wordmark": REPOSITORY_ROOT / "assets/runtime/ui/title_logo_ninja_god_v1.png",
    "title_medal": REPOSITORY_ROOT / "assets/runtime/ui/title_four_traditions_medal_v2.png",
    "school_select": REPOSITORY_ROOT / "docs/visual/screen-references/scrref-school-select-v2-sd.png",
    "battle": REPOSITORY_ROOT / "docs/visual/screen-references/scrref-battle-autocombat-continuous-floor-v3.png",
    "workbench": REPOSITORY_ROOT / "docs/visual/screen-references/scrref-workbench-v2-sd.png",
    "result": REPOSITORY_ROOT / "docs/visual/screen-references/scrref-result-v2-sd.png",
    "game_over": REPOSITORY_ROOT / "docs/visual/screen-references/scrref-game-over-v2-topdown-sd.png",
    "bongma_boss": REPOSITORY_ROOT / "assets/runtime/encounters/actors/hundred_demon_array_master.png",
    "bongma_familiar": REPOSITORY_ROOT / "assets/runtime/encounters/summons/bongma_hundred_demon_familiar.png",
}


@dataclass(frozen=True)
class ExportResult:
    """한 번의 atomic PDF export에서 나온 검증 가능한 요약 값."""

    page_count: int
    output_sha256: str
    historical_page_count: int
    companion_page_count: int


def sha256(path: Path) -> str:
    """Artifact/asset readback에 쓰는 SHA-256을 반환한다."""
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def register_fonts() -> tuple[str, str]:
    """Windows host의 approved Korean font를 embedded PDF family로 등록한다."""
    if not FONT_REGULAR.is_file() or not FONT_BOLD.is_file():
        raise RuntimeError("Malgun Gothic regular and bold are required for integrated PDF export")
    if "NinjaIntegrated" not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont("NinjaIntegrated", str(FONT_REGULAR)))
        pdfmetrics.registerFont(TTFont("NinjaIntegratedBold", str(FONT_BOLD)))
        pdfmetrics.registerFontFamily(
            "NinjaIntegrated",
            normal="NinjaIntegrated",
            bold="NinjaIntegratedBold",
            italic="NinjaIntegrated",
            boldItalic="NinjaIntegratedBold",
        )
    return "NinjaIntegrated", "NinjaIntegratedBold"


def require_inputs(historical_pdf: Path, source_commit: str) -> None:
    """잘못된 source/asset 상태에서는 이전 artifact를 바꾸지 않고 실패한다."""
    if not historical_pdf.is_file():
        raise FileNotFoundError(f"historical Human Blueprint is missing: {historical_pdf}")
    if not historical_pdf.read_bytes().startswith(b"%PDF-"):
        raise ValueError("historical Human Blueprint does not have a PDF header")
    if not re.fullmatch(r"[0-9a-f]{40}", source_commit):
        raise ValueError("source_commit must be a 40-character lowercase Git SHA")
    for label, path in ASSETS.items():
        if not path.is_file():
            raise FileNotFoundError(f"required locked asset is missing ({label}): {path}")


def write_text(
    canvas: Canvas,
    value: str,
    x: float,
    y_top: float,
    width: float,
    *,
    size: float,
    leading: float | None = None,
    color: colors.Color = MIST,
    font: str = "NinjaIntegrated",
) -> float:
    """Top-origin 좌표에서 단락을 줄바꿈해 그리고 실제 사용 높이를 반환한다."""
    if leading is None:
        leading = size * 1.48
    canvas.setFillColor(color)
    canvas.setFont(font, size)
    words = value.split()
    lines: list[str] = []
    current = ""
    for word in words:
        proposed = word if not current else f"{current} {word}"
        if current and canvas.stringWidth(proposed, font, size) > width:
            lines.append(current)
            current = word
        else:
            current = proposed
    if current:
        lines.append(current)
    for index, line in enumerate(lines):
        canvas.drawString(x, y_top - index * leading, line)
    return max(leading, len(lines) * leading)


def draw_panel(
    canvas: Canvas,
    x: float,
    y_top: float,
    width: float,
    height: float,
    *,
    accent: colors.Color = GOLD,
    fill: colors.Color = PANEL,
) -> None:
    """와이어프레임/설명 블록의 공통 대비와 여백을 유지한다."""
    canvas.setFillColor(fill)
    canvas.roundRect(x, y_top - height, width, height, 9, fill=1, stroke=0)
    canvas.setFillColor(accent)
    canvas.roundRect(x, y_top - 4, width, 4, 3, fill=1, stroke=0)


def draw_image_fit(
    canvas: Canvas,
    path: Path,
    x: float,
    y_bottom: float,
    width: float,
    height: float,
    *,
    fill: colors.Color = PANEL,
) -> None:
    """이미지를 비율 보존으로 page slot에 배치한다. source PNG는 수정하지 않는다."""
    canvas.setFillColor(fill)
    canvas.roundRect(x, y_bottom, width, height, 9, fill=1, stroke=0)
    image = ImageReader(str(path))
    image_width, image_height = image.getSize()
    scale = min((width - 12) / image_width, (height - 12) / image_height)
    rendered_width = image_width * scale
    rendered_height = image_height * scale
    canvas.drawImage(
        image,
        x + (width - rendered_width) / 2,
        y_bottom + (height - rendered_height) / 2,
        rendered_width,
        rendered_height,
        mask="auto",
        preserveAspectRatio=True,
    )


def draw_footer(canvas: Canvas, page_number: int, label: str) -> None:
    canvas.setStrokeColor(colors.HexColor("#39526B"))
    canvas.setLineWidth(0.5)
    canvas.line(MARGIN, 26, PAGE_WIDTH - MARGIN, 26)
    canvas.setFillColor(MUTED)
    canvas.setFont("NinjaIntegrated", 6.7)
    canvas.drawString(MARGIN, 15, label)
    canvas.drawRightString(PAGE_WIDTH - MARGIN, 15, f"통합본 보강부 {page_number:02d} / {COMPANION_PAGE_COUNT:02d}")


def start_page(canvas: Canvas, page_number: int, section: str, title: str, subtitle: str) -> None:
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, PAGE_WIDTH, PAGE_HEIGHT, fill=1, stroke=0)
    canvas.setFillColor(RED if page_number % 2 else GOLD)
    canvas.rect(0, PAGE_HEIGHT - 9, PAGE_WIDTH, 9, fill=1, stroke=0)
    canvas.setFillColor(GOLD)
    canvas.setFont("NinjaIntegratedBold", 7.5)
    canvas.drawString(MARGIN, PAGE_HEIGHT - 26, section)
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 23)
    canvas.drawString(MARGIN, PAGE_HEIGHT - 58, title)
    write_text(canvas, subtitle, MARGIN, PAGE_HEIGHT - 77, PAGE_WIDTH - MARGIN * 2, size=8.6, color=MUTED)


def draw_wireframe_box(canvas: Canvas, x: float, y_top: float, width: float, height: float, title: str, rows: list[tuple[str, str]]) -> None:
    """텍스트만으로 수정 가능한 화면 골격을 그린다."""
    draw_panel(canvas, x, y_top, width, height, accent=BLUE, fill=colors.HexColor("#0D1E33"))
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 9.2)
    canvas.drawString(x + 10, y_top - 18, title)
    row_height = (height - 36) / max(1, len(rows))
    for index, (label, content) in enumerate(rows):
        row_y = y_top - 32 - index * row_height
        canvas.setStrokeColor(colors.HexColor("#294765"))
        canvas.line(x + 8, row_y, x + width - 8, row_y)
        canvas.setFillColor(GOLD if index % 2 == 0 else MIST)
        canvas.setFont("NinjaIntegratedBold", 6.8)
        canvas.drawString(x + 10, row_y - 13, label)
        write_text(canvas, content, x + 52, row_y - 7, width - 62, size=6.6, leading=8.3, color=MIST)


def draw_flow_node(canvas: Canvas, x: float, y: float, width: float, label: str, accent: colors.Color) -> None:
    canvas.setFillColor(CREAM)
    canvas.roundRect(x, y, width, 34, 7, fill=1, stroke=0)
    canvas.setFillColor(accent)
    canvas.roundRect(x, y + 29, width, 5, 4, fill=1, stroke=0)
    canvas.setFillColor(NAVY)
    canvas.setFont("NinjaIntegratedBold", 7.4)
    canvas.drawCentredString(x + width / 2, y + 13, label)


def guide_cover(canvas: Canvas) -> None:
    """표지: 기존 본문과 최신 visual companion의 관계를 한눈에 보여 준다."""
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, PAGE_WIDTH, PAGE_HEIGHT, fill=1, stroke=0)
    draw_image_fit(canvas, ASSETS["title_backdrop"], 0, 0, PAGE_WIDTH, PAGE_HEIGHT, fill=NAVY)
    canvas.saveState()
    canvas.setFillAlpha(0.72)
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, PAGE_WIDTH * 0.58, PAGE_HEIGHT, fill=1, stroke=0)
    canvas.restoreState()
    canvas.setFillColor(GOLD)
    canvas.setFont("NinjaIntegratedBold", 8)
    canvas.drawString(MARGIN, PAGE_HEIGHT - 38, "NINJA SURVIVAL · DOWNLOADABLE HUMAN EDITION")
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 25)
    canvas.drawString(MARGIN, PAGE_HEIGHT - 75, "Human Blueprint")
    canvas.setFillColor(GOLD)
    canvas.setFont("NinjaIntegratedBold", 16)
    canvas.drawString(MARGIN, PAGE_HEIGHT - 102, "Integrated Edition · 2026-09-02")
    write_text(
        canvas,
        "기존 28쪽 Human Blueprint를 그대로 보존하고, 최신 화면 와이어프레임·플로우·LOCK 이미지·현재-main 소비처를 한 파일에 결합한 사람 검수용 열람본입니다.",
        MARGIN,
        PAGE_HEIGHT - 130,
        PAGE_WIDTH * 0.47,
        size=10.3,
        leading=16,
        color=MIST,
    )
    draw_panel(canvas, MARGIN, 212, PAGE_WIDTH * 0.43, 76, accent=RED, fill=colors.HexColor("#0D2037"))
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 10.2)
    canvas.drawString(MARGIN + 12, 191, "읽는 순서")
    write_text(canvas, "읽기 지도 → 기존 28쪽 전체 → 현재-main 시각 보강부 → 증거 경계", MARGIN + 12, 174, PAGE_WIDTH * 0.39, size=8, leading=12, color=MIST)
    draw_image_fit(canvas, ASSETS["title_wordmark"], MARGIN, 80, PAGE_WIDTH * 0.32, 76, fill=colors.HexColor("#0D2037"))
    draw_image_fit(canvas, ASSETS["title_medal"], PAGE_WIDTH * 0.39, 87, 60, 60, fill=colors.HexColor("#0D2037"))
    draw_footer(canvas, 1, "기존 Blueprint + 현재 화면 Blueprint + user-locked visual assets")


def guide_reading_map(canvas: Canvas) -> None:
    start_page(canvas, 2, "읽기 지도", "무엇을 보존하고 무엇을 추가했는가", "문서 정본, historical reader snapshot, screen atlas, 잠금 asset의 책임을 섞지 않는다.")
    left = MARGIN
    top = PAGE_HEIGHT - 112
    width = (PAGE_WIDTH - MARGIN * 2 - 16) / 2
    draw_panel(canvas, left, top, width, 135, accent=GOLD)
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 13)
    canvas.drawString(left + 12, top - 22, "보존 — 기존 28쪽 Human Blueprint")
    write_text(canvas, "기존 Human GDD가 렌더된 28쪽을 그 page object 그대로 포함합니다. 핵심 재미·Stage 여정·가방 성장·조합·Fate·각성의 설명은 축약하거나 다시 해석하지 않습니다.", left + 12, top - 46, width - 24, size=8.6, leading=13, color=MIST)
    write_text(canvas, "역할: 전체 게임을 처음 이해하는 상세 독자용 원본", left + 12, top - 113, width - 24, size=7.5, leading=11, color=GOLD, font="NinjaIntegratedBold")
    right = left + width + 16
    draw_panel(canvas, right, top, width, 135, accent=BLUE)
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 13)
    canvas.drawString(right + 12, top - 22, "추가 — 현재-main 시각 보강부")
    write_text(canvas, "Title·Stage·Battle HUD·Trace/Boss·Result/Workbench·Game Over의 wireframe과 최신 LOCK 이미지를 화면 흐름에 맞춰 배치합니다.", right + 12, top - 46, width - 24, size=8.6, leading=13, color=MIST)
    write_text(canvas, "역할: 현재 화면의 우선순위, 자산 사용처, 검수 질문", right + 12, top - 113, width - 24, size=7.5, leading=11, color=BLUE, font="NinjaIntegratedBold")
    draw_panel(canvas, MARGIN, 218, PAGE_WIDTH - MARGIN * 2, 90, accent=GREEN, fill=colors.HexColor("#102B36"))
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 10.5)
    canvas.drawString(MARGIN + 12, 197, "증거의 선")
    write_text(canvas, "PDF에 포함된 화면 참고와 wireframe은 reader/plan asset입니다. Godot scene, runtime render, telegraph fairness, Human Usability, Player Experience, touch/gamepad, device/export는 실제 실행 전까지 별도 증거로 남습니다.", MARGIN + 12, 180, PAGE_WIDTH - MARGIN * 2 - 24, size=8.2, leading=12, color=MIST)
    canvas.setFillColor(MUTED)
    canvas.setFont("NinjaIntegrated", 7.3)
    canvas.drawString(MARGIN, 103, "Historical source: exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf")
    canvas.drawString(MARGIN, 87, "Current atlas: docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md")
    canvas.drawString(MARGIN, 71, "Asset approval/provenance: docs/CURRENT_VISUAL_HANDOFF.md + docs/visual/screen-references/README.md")
    draw_footer(canvas, 2, "기존 28쪽은 다음 페이지부터 그대로 이어진다")


def guide_flow(canvas: Canvas) -> None:
    start_page(canvas, 3, "플로우 맵", "한 Run에서 플레이어가 실제로 건너는 화면", "Title부터 Fate까지 화면은 정보를 보여 주는 순서이며, 규칙·경제·경로의 권한은 기존 domain owner에 남긴다.")
    labels = ["Title", "Stage", "Core", "Elite", "Trace", "Boss", "Result", "Workbench", "Fate"]
    accents = [GOLD, BLUE, RED, PURPLE, GREEN, RED, GOLD, BLUE, PURPLE]
    node_width = 74
    start_x = MARGIN
    first_y = 306
    for index, (label, accent) in enumerate(zip(labels[:5], accents[:5], strict=True)):
        x = start_x + index * 112
        draw_flow_node(canvas, x, first_y, node_width, label, accent)
        if index < 4:
            canvas.setStrokeColor(GOLD)
            canvas.line(x + node_width, first_y + 17, x + 106, first_y + 17)
    second_y = 220
    for index, (label, accent) in enumerate(zip(labels[5:], accents[5:], strict=True)):
        x = start_x + 105 + index * 132
        draw_flow_node(canvas, x, second_y, node_width + 14, label, accent)
        if index < 3:
            canvas.setStrokeColor(GOLD)
            canvas.line(x + node_width + 14, second_y + 17, x + 124, second_y + 17)
    canvas.setStrokeColor(GOLD)
    canvas.line(start_x + 4 * 112 + 37, first_y, start_x + 4 * 112 + 37, second_y + 44)
    write_text(canvas, "Title → Stage → Core → Elite → Trace → Boss → Result → Workbench → Fate", MARGIN, 164, PAGE_WIDTH - MARGIN * 2, size=12, leading=16, color=CREAM, font="NinjaIntegratedBold")
    draw_panel(canvas, MARGIN, 126, PAGE_WIDTH - MARGIN * 2, 56, accent=GOLD)
    write_text(canvas, "자동 전투는 무관여가 아니다. 닌자는 이동·군집 유도·무적 Dash·Boss 전조 회피를 직접 결정한다. 일본도·수리검·시작 인법은 자동 발동하며, stage 선택과 Workbench/Fate는 다음 전투의 판단을 만든다.", MARGIN + 12, 105, PAGE_WIDTH - MARGIN * 2 - 24, size=8.3, leading=12, color=MIST)
    draw_footer(canvas, 3, "Flow purpose: player question → screen priority → existing domain owner")


def companion_title(canvas: Canvas) -> None:
    start_page(canvas, 4, "시각 보강부 · Title", "첫 화면은 로고가 아니라 시작의 약속", "한 명의 닌자, 워드마크와 작은 4조각 메달, 그리고 명확한 action row를 읽게 한다.")
    draw_image_fit(canvas, ASSETS["title_backdrop"], MARGIN, 80, 420, 260)
    draw_wireframe_box(
        canvas,
        470,
        336,
        325,
        256,
        "TITLE WIREFRAME",
        [
            ("상단", "워드마크 + 작은 4조각 메달. 메달은 두 번째 주인공이 아니다."),
            ("행동", "새 게임 → 이어하기 → 각성 → 도감"),
            ("보조", "조작 방법 · 설정 · 종료는 Title 위 local modal이다."),
            ("입력", "새 게임부터 순차 focus. modal 종료 뒤 origin으로 복귀."),
            ("권한", "Title은 intent만 전달. Run/save/route는 MainController."),
        ],
    )
    canvas.setFillColor(GOLD)
    canvas.setFont("NinjaIntegrated", 6.8)
    canvas.drawString(470, 65, "LOCK assets: title backdrop / transparent wordmark / four-fragment medal (cover에 원본 배치)")
    draw_footer(canvas, 4, "Actual consumer: scenes/ui/title_screen.tscn → TitleScreen")


def companion_stage(canvas: Canvas) -> None:
    start_page(canvas, 5, "시각 보강부 · Stage 선택", "다음 스테이지는 다른 코스튬이 아니라 다른 위험", "네 Stage는 같은 닌자가 위험을 다루는 방식을 고르는 화면이다. 선택은 Fate 전까지 임시다.")
    draw_image_fit(canvas, ASSETS["school_select"], MARGIN, 104, 488, 274)
    draw_wireframe_box(
        canvas,
        536,
        378,
        258,
        274,
        "STAGE SELECT WIREFRAME",
        [
            ("질문", "이번 Run에서 어떤 위험 처리 방식을 시험할까?"),
            ("카드", "봉마=결계/식신 · 천술=상태/반응 · 귀인=근접 · 흑영=위협 우선"),
            ("상태", "미방문/방문, 현재 focus, 도움말의 의미가 색보다 먼저 읽힌다."),
            ("확정", "선택 뒤 안내: Fate 전까지 경로는 임시입니다."),
            ("금지", "4명의 주인공 portrait·영구 직업처럼 보이는 표현"),
        ],
    )
    draw_footer(canvas, 5, "Planning reference: SCRREF-SCHOOL-SELECT-02; runtime texture가 아님")


def companion_battle(canvas: Canvas) -> None:
    start_page(canvas, 6, "시각 보강부 · 자동전투", "군중·내 위치·Dash가 먼저 읽히는 전장", "공격 버튼이나 하단 skill bar 없이, 탑다운 군중과 접지된 닌자의 이동 판단을 전면에 둔다.")
    draw_image_fit(canvas, ASSETS["battle"], MARGIN, 108, 492, 275)
    draw_wireframe_box(
        canvas,
        534,
        383,
        260,
        275,
        "BATTLE HUD WIREFRAME",
        [
            ("상단", "생명 · Dash 충전 · PLAY 시간 · 일시정지/설정"),
            ("중심", "접지 그림자가 있는 고정 닌자와 일정 거리 밖에서 밀려오는 군중"),
            ("자동", "일본도 근접 호 / 수리검 투사체 / 시작 인법 effect — player body attack motion 없음"),
            ("바닥", "끝없이 이어지는 달빛 돌바닥; 등잔/고목/돌은 sparse 독립 prop"),
            ("위험", "Core는 contact pressure 중심. 장판/부적은 Elite·Boss pattern 전조에 한정"),
        ],
    )
    draw_footer(canvas, 6, "Locked planning reference: SCRREF-BATTLE-AUTOCOMBAT-03; live combat render는 NOT_RUN")


def companion_trace_boss(canvas: Canvas) -> None:
    start_page(canvas, 7, "시각 보강부 · Elite → Trace → Boss", "전조는 공략의 시작이고, Trace는 Boss 입장의 이유", "Core crowd의 압박과 다르게 Elite/Boss는 읽을 수 있는 전조형 pattern과 뚜렷한 실루엣으로 구분한다.")
    draw_image_fit(canvas, ASSETS["bongma_boss"], MARGIN + 16, 77, 265, 292, fill=colors.HexColor("#0D1E33"))
    draw_image_fit(canvas, ASSETS["bongma_familiar"], 291, 140, 120, 120, fill=colors.HexColor("#0D1E33"))
    draw_wireframe_box(
        canvas,
        438,
        377,
        356,
        280,
        "ENCOUNTER WIREFRAME",
        [
            ("Elite", "명확한 등장 cue와 별도 silhouette. 처치 시 chest token + Trace AVAILABLE."),
            ("Trace", "일반 ORB/Gold와 다른 위치·방향 신호. 직접 회수해야 Boss gate가 진행된다."),
            ("Warning", "Boss는 갑자기 전장을 덮지 않는다. 짧은 warning 뒤 dual gate가 열린다."),
            ("Boss", "활성 전조 구역과 Boss life만 우선 노출. 봉마 보스는 이동진·식신·결계의 특색을 쓴다."),
            ("경계", "이 그림은 LOCK runtime asset이며, pattern fairness/Human 난이도 PASS가 아니다."),
        ],
    )
    canvas.setFillColor(GOLD)
    canvas.setFont("NinjaIntegrated", 6.7)
    canvas.drawString(MARGIN + 16, 60, "LOCK runtime assets: Hundred Demon Array Master + Bongma Hundred Demon Familiar")
    draw_footer(canvas, 7, "Actual encounter visual consumers exist; live Boss pattern/render evidence remains separate")


def companion_result_workbench(canvas: Canvas) -> None:
    start_page(canvas, 8, "시각 보강부 · Result → Workbench", "보상은 아직 빌드가 아니다", "Result에서 받은 보상은 가방 배치·인접·조합·다음 Stage 임시 선택을 거쳐 Fate에서만 확정된다.")
    draw_image_fit(canvas, ASSETS["result"], MARGIN, 186, 370, 205)
    draw_image_fit(canvas, ASSETS["workbench"], 398, 186, 396, 205)
    draw_wireframe_box(
        canvas,
        MARGIN,
        170,
        PAGE_WIDTH - MARGIN * 2,
        130,
        "RESULT / WORKBENCH WIREFRAME",
        [
            ("Result", "Boss/reward source → 선택/획득 보상 → Workbench"),
            ("Bag", "6×6 천장 안의 실제 시작 사용 영역은 정확히 3×3. 구매/특수 가방으로 확장."),
            ("Commit", "배치·회전·인접·조합 preview는 전투력 0. Fate가 backpack + route를 원자 확정."),
        ],
    )
    draw_footer(canvas, 8, "Planning references: SCRREF-RESULT-02 + SCRREF-WORKBENCH-02; interaction UX is NOT_RUN")


def companion_game_over(canvas: Canvas) -> None:
    start_page(canvas, 9, "시각 보강부 · Game Over", "실패는 숨겨진 벌이 아니라 다음 판단의 경계", "재시도 여부, 각성의 의미, 그리고 안전하게 확정된 Workbench checkpoint가 명확하게 분리돼야 한다.")
    draw_image_fit(canvas, ASSETS["game_over"], MARGIN, 101, 480, 275)
    draw_wireframe_box(
        canvas,
        526,
        376,
        268,
        275,
        "GAME OVER WIREFRAME",
        [
            ("원인", "왜 멈췄는지: life reaches zero와 현재 Stage 상태"),
            ("재도전", "검증된 Workbench checkpoint + 각성 1회 조건일 때만 same Stage fresh Core pressure"),
            ("귀환", "조건이 없으면 Run 종료 뒤 Title로 돌아간다."),
            ("경계", "mid-combat enemy/projectile/hazard/timestamp는 저장하지 않는다."),
            ("검수", "retry wording, checkpoint comprehension, touch/gamepad route는 Human/device gate"),
        ],
    )
    draw_footer(canvas, 9, "Planning reference: SCRREF-GAME-OVER-02; target-resolution readability is NOT_RUN")


def companion_assets_and_evidence(canvas: Canvas, source_commit: str, generated_at: str) -> None:
    start_page(canvas, 10, "시각 보강부 · 자산·다운로드·증거", "이 파일은 최신 이미지를 붙인 포스터가 아니라 추적 가능한 Blueprint", "사용한 모든 이미지의 상태와 실제 사용처를 읽고, PDF가 무엇을 증명하지 않는지도 함께 확인한다.")
    entries = [
        ("Title backdrop", "NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02", "USER_LOCKED · TitleScreen backdrop"),
        ("Wordmark", "NINJA_RUNTIME_TITLE_LOGO_NINJA_GOD_01", "USER_LOCKED · TitleScreen logo"),
        ("4-fragment medal", "NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02", "USER_LOCKED · TitleScreen medal"),
        ("Screen references", "SCRREF-SCHOOL / BATTLE / WORKBENCH / RESULT / GAME OVER", "locked/dual stored · planning reference only"),
        ("Bongma encounter", "HUNDRED_DEMON_ARRAY_MASTER + HUNDRED_DEMON_FAMILIAR", "USER_LOCKED · actual encounter visual consumers"),
    ]
    top = 365
    for index, (role, asset_id, state) in enumerate(entries):
        y = top - index * 45
        draw_panel(canvas, MARGIN, y, PAGE_WIDTH - MARGIN * 2, 37, accent=GOLD if index % 2 == 0 else BLUE, fill=PANEL_ALT)
        canvas.setFillColor(CREAM)
        canvas.setFont("NinjaIntegratedBold", 8.1)
        canvas.drawString(MARGIN + 10, y - 17, role)
        canvas.setFillColor(MIST)
        canvas.setFont("NinjaIntegrated", 7.3)
        canvas.drawString(MARGIN + 140, y - 17, asset_id)
        canvas.setFillColor(GOLD)
        canvas.setFont("NinjaIntegrated", 6.8)
        canvas.drawRightString(PAGE_WIDTH - MARGIN - 10, y - 17, state)
    draw_panel(canvas, MARGIN, 126, PAGE_WIDTH - MARGIN * 2, 72, accent=RED, fill=colors.HexColor("#2A1A25"))
    canvas.setFillColor(CREAM)
    canvas.setFont("NinjaIntegratedBold", 9.4)
    canvas.drawString(MARGIN + 12, 105, "Evidence ceiling")
    write_text(canvas, "PDF source/hash/render checks prove only this downloadable reader artifact. They do not prove Godot runtime render, crowd performance, telegraph fairness, Human Usability, Player Experience, controller/touch, device/export, or release readiness.", MARGIN + 12, 88, PAGE_WIDTH - MARGIN * 2 - 24, size=7.8, leading=11, color=MIST)
    canvas.setFillColor(MUTED)
    canvas.setFont("NinjaIntegrated", 6.6)
    canvas.drawString(MARGIN, 43, f"Integrated source commit: {source_commit}")
    canvas.drawString(MARGIN, 31, f"Generated: {generated_at}")
    draw_footer(canvas, 10, "Artifact route: exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf")


def build_companion_pdf(destination: Path, source_commit: str, generated_at: str) -> None:
    """새 guide 3쪽과 visual companion 7쪽만 별도 PDF로 먼저 만든다."""
    regular, bold = register_fonts()
    del regular, bold
    canvas = Canvas(str(destination), pagesize=PAGE_SIZE, title="닌자의 신 - Human Blueprint Integrated Edition", author="Ninja Survival Project")
    canvas.setTitle("닌자의 신 - Human Blueprint Integrated Edition")
    canvas.setAuthor("Ninja Survival Project")
    canvas.setSubject(f"Historical 28-page reader preserved; source commit {source_commit}; generated {generated_at}")
    for draw_page in (guide_cover, guide_reading_map, guide_flow, companion_title, companion_stage, companion_battle, companion_trace_boss, companion_result_workbench, companion_game_over):
        draw_page(canvas)
        canvas.showPage()
    companion_assets_and_evidence(canvas, source_commit, generated_at)
    canvas.showPage()
    canvas.save()
    if not destination.is_file() or not destination.read_bytes().startswith(b"%PDF-"):
        raise RuntimeError("companion composer did not create a valid PDF header")


def export_integrated_pdf(
    *,
    historical_pdf: Path,
    output: Path,
    source_commit: str,
    generated_at: str,
) -> ExportResult:
    """새 guide + 보존 본문 + visual companion을 atomic final artifact로 결합한다."""
    require_inputs(historical_pdf, source_commit)
    historical_reader = PdfReader(historical_pdf)
    if len(historical_reader.pages) != HISTORICAL_PAGE_COUNT:
        raise ValueError(f"historical Human Blueprint must retain {HISTORICAL_PAGE_COUNT} pages")
    output.parent.mkdir(parents=True, exist_ok=True)
    companion_path = output.with_name(output.stem + ".companion.tmp.pdf")
    temporary_output = output.with_suffix(output.suffix + ".tmp")
    for transient in (companion_path, temporary_output):
        if transient.exists():
            transient.unlink()
    try:
        build_companion_pdf(companion_path, source_commit, generated_at)
        companion_reader = PdfReader(companion_path)
        if len(companion_reader.pages) != COMPANION_PAGE_COUNT:
            raise RuntimeError("unexpected companion page count")
        writer = PdfWriter()
        for page in companion_reader.pages[:GUIDE_PAGE_COUNT]:
            writer.add_page(page)
        for page in historical_reader.pages:
            writer.add_page(page)
        for page in companion_reader.pages[GUIDE_PAGE_COUNT:]:
            writer.add_page(page)
        writer.add_metadata(
            {
                "/Title": "닌자의 신 - Human Blueprint Integrated Edition",
                "/Author": "Ninja Survival Project",
                "/Subject": "Preserved 28-page Human Blueprint + current-main wireframes and locked visual companion",
                "/Keywords": "Ninja Survival, Human Blueprint, wireframe, visual atlas, downloadable PDF",
            }
        )
        writer.add_outline_item("통합본 읽기 지도", 0)
        writer.add_outline_item("기존 28쪽 Human Blueprint (보존)", GUIDE_PAGE_COUNT)
        writer.add_outline_item("현재-main 시각 보강부", GUIDE_PAGE_COUNT + HISTORICAL_PAGE_COUNT)
        with temporary_output.open("wb") as stream:
            writer.write(stream)
        if not temporary_output.read_bytes().startswith(b"%PDF-"):
            raise RuntimeError("integrated export did not create a valid PDF header")
        final_reader = PdfReader(temporary_output)
        expected_page_count = COMPANION_PAGE_COUNT + HISTORICAL_PAGE_COUNT
        if len(final_reader.pages) != expected_page_count:
            raise RuntimeError("integrated export page count mismatch")
        temporary_output.replace(output)
        return ExportResult(
            page_count=expected_page_count,
            output_sha256=sha256(output),
            historical_page_count=HISTORICAL_PAGE_COUNT,
            companion_page_count=COMPANION_PAGE_COUNT,
        )
    finally:
        for transient in (companion_path, temporary_output):
            if transient.exists():
                transient.unlink()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--historical-pdf", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--generated-at", required=True)
    args = parser.parse_args()
    result = export_integrated_pdf(
        historical_pdf=args.historical_pdf,
        output=args.output,
        source_commit=args.source_commit,
        generated_at=args.generated_at,
    )
    print(f"page_count={result.page_count}")
    print(f"historical_page_count={result.historical_page_count}")
    print(f"companion_page_count={result.companion_page_count}")
    print(f"sha256={result.output_sha256}")


if __name__ == "__main__":
    main()
