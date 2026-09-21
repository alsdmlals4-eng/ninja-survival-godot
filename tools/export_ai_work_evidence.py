"""Retrospective evidence supplement; never fabricates screenshots or certified dates."""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import io
import subprocess
from datetime import datetime, timezone, timedelta
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from pypdf import PdfReader, PdfWriter
from export_human_gdd_pdf import register_fonts

ROOT = Path(__file__).resolve().parents[1]
KST = timezone(timedelta(hours=9))
REPO = "https://github.com/alsdmlals4-eng/ninja-survival-godot"
RECORDS = [
    ("a23361e", "남은 구현 작업·설계 명세", "기존 구현과 남은 연결 업무가 여러 기록에 나뉘어 있었다.",
     "기존 코드·정본을 대조해 R01~R10 순서, 책임 파일, 실패·복구 및 인수 기준을 정리했다.",
     "문서 작성·저장소 반영. 기획 문서 작성은 게임 기능 구현이나 사용자 승인과 다르다."),
    ("b7f5760", "단일 프로필 저장의 기초", "지갑과 이어하기가 별도 파일이며 새 프로필 거래 경계가 없었다.",
     "프로필 버전·숫자·거래 기록 검사와 임시 파일/이전 파일을 이용한 저장 거래를 구현했다.",
     "빈 런 프로필을 대상으로 자동 검증. 준비 상태·기본 게임 진입 연결은 미완료."),
    ("587a0dc", "새 출전 상태 저장·재읽기", "장비·선택 인법이 있는 진행 중 런과 보관함 교차 검사가 부족했다.",
     "경로·장비·가방·보관함·인법·오의 충전을 교차 검사하고 JSON 숫자 표현에 따른 거래 재시도 충돌을 수정했다.",
     "네 유파 및 24개 전장 완료 순서의 도메인 검사. 24회 실제 플레이를 뜻하지 않는다."),
    ("8e2558c", "복구 실패 시 원본·후보 보존", "파일 교체와 원상복구가 모두 실패하면 새 후보를 제거하는 경로가 있었다.",
     "연속 실패에서는 이전 저장과 새 후보를 모두 보존하고 복구 필요 상태를 반환하도록 교정했다.",
     "102개 스크립트 / 805개 테스트 / 11,529개 단언 통과 기록. 실제 전원 차단·실기기·Human 검증은 아님."),
]


def command(*args: str) -> str:
    return subprocess.check_output(args, cwd=ROOT, encoding="utf-8").strip()


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def update_daily(output: Path) -> None:
    """Update the one unsubmitted working copy; preserve original pages verbatim."""
    source = ROOT / "docs/operations/AI_WORK_EVIDENCE.md"
    daily = source.read_text(encoding="utf-8").split("## Cumulative dated summaries\n", 1)[1]
    daily_hash = hashlib.sha256(daily.encode()).hexdigest()
    evidence = output.parent / (output.stem + "_원본근거")
    manifest_path = evidence / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    original = output.read_bytes()
    original_hash = hashlib.sha256(original).hexdigest()
    if original_hash != manifest["pdf_sha256"]:
        raise ValueError("Working PDF changed outside its evidence manifest; refusing replacement")
    if manifest.get("daily_source_sha256") == daily_hash:
        print("DAILY_ALREADY_CURRENT " + original_hash)
        return
    reader = PdfReader(io.BytesIO(original))
    base_count = int((reader.metadata or {}).get("/NinjaDailyBasePages", 9))
    if base_count != 9 or len(reader.pages) < base_count:
        raise ValueError("Unexpected original evidence book")
    regular, bold = register_fonts()
    body = ParagraphStyle("daily", fontName=regular, fontSize=10, leading=16,
                          spaceAfter=12, wordWrap="CJK")
    heading = ParagraphStyle("daily-heading", parent=body, fontName=bold, fontSize=19, leading=27)
    story = []
    dates = []
    for section in daily.split("### "):
        if not section.strip():
            continue
        date, text = section.split("\n", 1)
        datetime.strptime(date.strip(), "%Y-%m-%d")
        dates.append(date.strip())
        if story:
            story.append(PageBreak())
        story.append(Paragraph("날짜별 누적 작업 요약 | " + date.strip(), heading))
        for paragraph in text.strip().split("\n\n"):
            story.append(Paragraph(html.escape(paragraph).replace("\n", "<br/>"), body))
    if not dates or dates != sorted(set(dates)):
        raise ValueError("Daily entries must have unique ascending dates")
    buffer = io.BytesIO()
    def footer(canvas, doc):
        canvas.setFont(regular, 8)
        canvas.drawString(45, 24, "닌자의 신 | 기존 월간 작업일지 누적 보강 | 외부 미제출")
        canvas.drawRightString(A4[0]-45, 24, str(base_count + doc.page))
    SimpleDocTemplate(buffer, pagesize=A4, leftMargin=45, rightMargin=45,
                      topMargin=42, bottomMargin=43).build(story, onFirstPage=footer, onLaterPages=footer)
    writer = PdfWriter()
    for page in reader.pages[:base_count]:
        writer.add_page(page)
    for page in PdfReader(buffer).pages:
        writer.add_page(page)
    writer.add_metadata({"/Title": "닌자의 신 - AI 활용 작업일지·증빙집", "/NinjaDailyBasePages": str(base_count)})
    staged = output.with_suffix(".updating.pdf")
    if staged.exists():
        raise FileExistsError(staged)
    with staged.open("xb") as stream:
        writer.write(stream)
    verified = PdfReader(staged)
    assert all(verified.pages[i].extract_text() == reader.pages[i].extract_text() for i in range(base_count))
    assert all(date in "".join(p.extract_text() for p in verified.pages[base_count:]) for date in dates)
    manifest.setdefault("update_history", []).append({"previous_pdf_sha256": original_hash,
        "updated_at": datetime.now(KST).isoformat(), "daily_dates": dates})
    manifest.update(pdf_sha256=digest(staged), pages=len(verified.pages), daily_source_sha256=daily_hash,
                    daily_source="docs/operations/AI_WORK_EVIDENCE.md", mode="cumulative-unsubmitted-working-copy")
    staged.replace(output)
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"pages": len(verified.pages), "sha256": manifest["pdf_sha256"], "dates": dates}))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", required=True, type=Path)
    ap.add_argument("--session", type=Path)
    ap.add_argument("--version", default="v0.2")
    ap.add_argument("--update-daily", action="store_true")
    args = ap.parse_args()
    output = args.output.resolve()
    if args.update_daily:
        update_daily(output)
        return
    if output.exists():
        raise FileExistsError("Published issue cannot be overwritten: " + str(output))
    evidence = output.parent / (output.stem + "_원본근거")
    if evidence.exists():
        raise FileExistsError("Existing evidence issue: " + str(evidence))
    output.parent.mkdir(parents=True, exist_ok=True)
    evidence.mkdir()
    captured = datetime.now(KST).isoformat(timespec="seconds")
    regular, bold = register_fonts()
    styles = {
        "title": ParagraphStyle("e-title", fontName=bold, fontSize=25, leading=35, spaceAfter=18),
        "h": ParagraphStyle("e-h", fontName=bold, fontSize=16, leading=23, spaceAfter=12, textColor=colors.HexColor("#17324d")),
        "body": ParagraphStyle("e-body", fontName=regular, fontSize=10, leading=16, spaceAfter=10, wordWrap="CJK"),
        "small": ParagraphStyle("e-small", fontName=regular, fontSize=8, leading=12, spaceAfter=7, wordWrap="CJK"),
    }
    story = []
    def p(text: str, style="body"):
        story.append(Paragraph(html.escape(text).replace("\n", "<br/>"), styles[style]))
    def link(label: str, url: str):
        story.append(Paragraph(f'<link href="{html.escape(url, quote=True)}" color="#225f91">{html.escape(label)}</link>', styles["body"]))
    def page(title: str):
        if story:
            story.append(PageBreak())
        p(title, "h")
    commits = []
    for short, title, before, change, state in RECORDS:
        sha = command("git", "rev-parse", short)
        metadata = command("git", "show", "-s", "--format=%H%n%aI%n%cI%n%s", sha).splitlines()
        patch = command("git", "show", "--format=fuller", "--stat", sha)
        path = evidence / f"commit-{short}.txt"
        path.write_text(patch, encoding="utf-8")
        commits.append(dict(sha=sha, authored=metadata[1], committed=metadata[2], title=title,
                            before=before, change=change, state=state,
                            files=command("git", "diff-tree", "--no-commit-id", "--name-only", "-r", sha).splitlines()))
    ci = json.loads(command("gh", "run", "view", "34786019166", "--json", "headSha,createdAt,updatedAt,conclusion,jobs,url"))
    if ci["headSha"] != commits[-1]["sha"] or ci["conclusion"] != "success":
        raise ValueError("Exact-head completed CI evidence required")
    (evidence / "github-ci.json").write_text(json.dumps(ci, ensure_ascii=False, indent=2), encoding="utf-8")
    log = command("gh", "run", "view", "34786019166", "--log")
    (evidence / "github-ci.log").write_text(log, encoding="utf-8")
    prompt = None
    if args.session and args.session.exists():
        with args.session.open(encoding="utf-8") as stream:
            for number, line in enumerate(stream, 1):
                if '남은 작업과 해당 작업들의 구현,설계 명세를 준비해줘' not in line:
                    continue
                record = json.loads(line)
                payload = record.get("payload", {})
                if record.get("type") == "event_msg" and payload.get("type") == "user_message":
                    prompt = {"timestamp": record.get("timestamp"), "line": number,
                              "text": payload.get("message", ""), "record_sha256": hashlib.sha256(line.encode()).hexdigest()}
        if prompt:
            (evidence / "input-record-extract.json").write_text(json.dumps(prompt, ensure_ascii=False, indent=2), encoding="utf-8")
    page("닌자의 신\nAI 활용 작업일지·증빙집")
    p("2026년 9월 | 중간본 " + args.version, "title")
    p("수록 범위: 2026-09-14의 확인 가능한 작업 4건. 9월 전체 작업·비용을 모두 수록한 월말 정산본이 아닙니다.")
    p("분류: 사후 정리 / 자체 검수용 초안 / 외부 미제출")
    p("프로젝트: 닌자의 신 (ninja-survival-godot)\nAI 서비스: OpenAI Codex - 현재 작업 대화에 따른 분류\n지원사업 등록 계정·결제 상품·모델별 청구 정보: 미확인")
    p("기록 작성·원본 수집·PDF 발행: " + captured)
    p("이 PDF는 날짜 인증서가 아닙니다. 커밋·원본 작업 기록·서버 검사 기록을 찾아 대조하기 위한 보조 보고서입니다. 협약서 원본·메일·영수증을 직접 확인하지 않았으며, 협회 지정 양식이나 비용 인정 판단을 대체하지 않습니다.")
    link("프로젝트 작업 PR #147 (Draft)", REPO + "/pull/147")
    page("01. 날짜별 작업 목록과 증거 구분")
    rows = [[Paragraph(x, styles["small"]) for x in ["ID / 기록일(KST)", "작업", "증거 수준 / 상세"]]]
    for i, item in enumerate(commits, 1):
        stamp = datetime.fromisoformat(item['committed']).astimezone(KST).strftime('%Y-%m-%d\n%H:%M:%S KST')
        rows.append([Paragraph(html.escape(x).replace('\n', '<br/>'), styles["small"]) for x in [f"NS-0914-{i:02}\n{stamp}", item["title"], f"커밋·결과 기록\n상세 {i+2}쪽"]])
    table = Table(rows, colWidths=[150, 160, 195])
    table.setStyle(TableStyle([("BACKGROUND",(0,0),(-1,0),colors.HexColor("#e7edf3")),("VALIGN",(0,0),(-1,-1),"TOP"),("GRID",(0,0),(-1,-1),0.3,colors.HexColor("#cad4df")),("LEFTPADDING",(0,0),(-1,-1),8),("RIGHTPADDING",(0,0),(-1,-1),8)]))
    story.append(table); story.append(Spacer(1,18))
    p("실제 작업 시간의 범위는 별도 확정하지 않았습니다. 표의 시간은 Git 커밋 메타데이터이며 작성자가 설정할 수 있습니다. 모든 작업은 이번 발행 시점에 사후 정리했습니다.")
    p("원본 수집일: " + captured + "\n프롬프트 화면 캡처일: 미확인 / 미첨부\n게임 결과 화면 캡처일: 이번 수록 작업에는 없음")
    p("구분: 문서 작성 ≠ 코드 반영 ≠ 자동검사 ≠ 실제 화면·조작 검수 ≠ 사용자 승인 ≠ 출시. 현재 저장 변경은 기본 Main 전환이나 전체 런 완성을 뜻하지 않습니다.")
    for i, item in enumerate(commits, 1):
        page(f"NS-0914-{i:02} | {item['title']}")
        p("원본 기록 시각\n작성자 시각: " + item["authored"] + "\n커밋 시각: " + item["committed"], "small")
        p("작업 전 상태", "h"); p(item["before"])
        p("이번 작업과 결과", "h"); p(item["change"])
        p("검수 결과와 한계", "h"); p(item["state"])
        input_status = "7쪽의 공통 요청 기록" if prompt else "미연결. 7쪽의 미확인 안내 참조"
        p("입력 증빙: " + input_status + ". 각 코드 수정별 프롬프트 화면은 미첨부.\nAI·계정: Codex / 등록 계정 미확인.\n수록 형태: 사후 정리. 기록·수집·발행 시각은 표지 참조.", "small")
        p("실제 반영 파일", "h")
        for name in item["files"]:
            p(name, "small")
        link("정확한 변경 원본 " + item["sha"][:12], REPO + "/commit/" + item["sha"])
    page("02. 입력 기록과 AI·계정별 찾아보기")
    if prompt:
        p("원본 작업 로그에서 추출한 사용자 요청입니다. 화면 캡처가 아니며 원래 대화 UI를 재현하지 않았습니다.")
        p("원본 기록 시각(UTC): " + str(prompt["timestamp"]) + "\n원본 JSONL 행: " + str(prompt["line"]), "small")
        p(prompt["text"][:1800])
        p("원본 레코드 SHA-256: " + prompt["record_sha256"], "small")
    else:
        p("관련 원본 프롬프트 기록을 자동 연결하지 못했습니다. 현재 대화의 요청은 확인되지만 과거 작업 시각을 소급하여 확정하지 않습니다.")
    p("AI 서비스·계정 찾아보기", "h")
    p("Codex: NS-0914-01~04. 서비스 사용은 현재 작업 대화와 변경 내역의 연결 기준이며 Git만으로 AI 사용 계정이나 유료 상품을 입증할 수 없습니다. 지원사업 등록 계정 식별자는 미확인입니다.")
    p("개별 입력·결과 스크린샷: 미첨부. 실제 화면 확보 후 정정·보강본에 추가해야 합니다. 이 PDF를 제출 요건 충족본으로 표시하지 않습니다.")
    page("03. 자동검사 결과와 원본 대조")
    p("검사 대상 커밋: " + ci["headSha"], "small")
    p("GitHub 실행 생성(UTC): " + ci["createdAt"] + "\nKST: " + datetime.fromisoformat(ci["createdAt"].replace("Z","+00:00")).astimezone(KST).isoformat(), "small")
    for job in ci["jobs"]:
        p(job["name"] + ": " + job["conclusion"] + " / " + job["completedAt"] + " (UTC)")
    selected = [line.split("\t")[-1] for line in log.splitlines() if any(s in line for s in ["Passing Tests", "Asserts", "All tests passed", "Scripts             ", "Tests               "])]
    p("실제 CI 로그 발췌 (화면 캡처 아님)", "h")
    p("색상 제어문자만 제거한 발췌이며 전체 원본 로그는 별도 보관합니다.", "small")
    p(re.sub(r'(?:\x1b|\^\[)\[[0-?]*[ -/]*[@-~]', '', "\n".join(selected[-8:])) or "원본 전체 로그 파일 참조", "small")
    link("서버 검사 실행 원본", ci["url"])
    p("임포트·메인 장면 자동 실행·자동검사 및 Windows 내부 빌드의 결과입니다. 사람이 게임을 플레이한 검수나 실기기 확인으로 확대 해석하지 않습니다.")
    p("자체 검수 주체: Codex 자동 검사 및 결과 대조. 사용자 최종 검수: 미확인.\n기본 Main 전환, 준비 상태 저장, 전체 런, 실기기, 전체 5회 검토: 미완료.")
    page("04. 제출 전 보완 항목·원본 목록")
    for text in [
        "미확인: 협약 체결 여부·지원 시작일·비용 인정 범위·협회 지정 정산 양식. 사용자 제공 설명만으로 확정하지 않음.",
        "필요: 지원사업 등록 AI 서비스·계정 식별정보. 개인정보·이메일·결제 식별자는 제출 필요 최소 범위로 관리.",
        "필요: 실제 프롬프트 및 결과 화면. 텍스트 발췌나 커밋은 화면 캡처를 대체했다고 표시하지 않음.",
        "결제 부록: 영수증·결제내역 미첨부. 비용 합계는 계산하지 않음. 추후 결제 증빙 하나에 여러 작업을 연결하고 중복 합산하지 않음.",
        "새 이미지 정책: 크로마키 원본 → 배경 제거 → 투명도/테두리/번짐 검수. 이번 호에서 새 이미지가 생성됐다고 주장하지 않음.",
        "9월 전체 기록은 아직 미수록. 추가 확인분은 새 버전으로 누적하고 제출본은 덮어쓰지 않음.",
    ]: p(text)
    p("원본근거 폴더에는 커밋별 기록, GitHub CI JSON·전체 로그와 SHA-256 목록(manifest.json)을 보관합니다. 입력 레코드는 확보된 경우에만 포함합니다. " + ("이번 호에는 입력 레코드 발췌를 포함했습니다." if prompt else "이번 호에는 입력 레코드가 미포함되어 있습니다.") + " 원본 대화 전체와 계정·결제 원본은 복사하지 않았습니다.")
    p("블루프린트 연결: docs/design/NINJA_SURVIVAL_HUMAN_BLUEPRINT.md\n구현 명세 연결: docs/design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md (R01~R10)", "small")
    link("확인 방법: GitHub 공식 실행 이력 가이드", "https://docs.github.com/en/actions/how-tos/monitor-workflows/view-workflow-run-history")
    def footer(canvas, doc):
        canvas.setFont(regular, 8); canvas.setFillColor(colors.HexColor("#52657a"))
        canvas.drawString(45, 25, "닌자의 신 | AI 활용 작업일지·증빙집 | 사후 정리·중간본 " + args.version)
        canvas.drawRightString(A4[0]-45, 25, str(doc.page))
    SimpleDocTemplate(str(output), pagesize=A4, leftMargin=45, rightMargin=45,
                      topMargin=42, bottomMargin=43, title="닌자의 신 - AI 활용 작업일지·증빙집",
                      author="프로젝트 작업 기록 정리").build(story, onFirstPage=footer, onLaterPages=footer)
    reader = PdfReader(output)
    if len(reader.pages) != 9:
        raise ValueError(f"Unexpected pagination: {len(reader.pages)}; inspect layout")
    manifest = {"published_at": captured, "scope": "2026-09-14 four verified commits; September partial retrospective",
                "pdf": output.name, "pdf_sha256": digest(output), "pages": len(reader.pages),
                "source_head": commits[-1]["sha"], "ci_url": ci["url"],
                "capture_type": "text records; no screenshot", "files": {p.name:digest(p) for p in evidence.iterdir()}}
    (evidence / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(manifest, ensure_ascii=False))


if __name__ == "__main__":
    main()
