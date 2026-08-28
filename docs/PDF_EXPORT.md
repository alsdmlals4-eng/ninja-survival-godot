# 플레이어용 GDD PDF 발행 계약

## 역할과 정본 경계

- **기술 정본:** `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`
- **사람용 편집 원고:** `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md`
- **사람용 다운로드 snapshot:** `exports/NINJA_SURVIVAL_HUMAN_GDD_20260828.pdf`
- **발행 상태/해시:** `docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json`
- **생성기:** `tools/export_human_gdd_pdf.py`

PDF는 사람이 한 파일로 읽고 내려받는 파생본이다. Human GDD는 핵심 재미·플레이 흐름·선택·구현 구조를 쉬운 말로 설명하고, 기술 정본의 SHA/PR/CI receipt/경로 세부를 반복하지 않는다. PDF 안의 설명, 표, 링크 또는 생성 성공은 Godot runtime, Human Usability, Player Experience, device/export, release evidence를 승격하지 않는다.

## 조사·실현성 판정

- **ADOPT — [ReportLab TrueType font guidance](https://docs.reportlab.com/reportlab/userguide/ch3_fonts/):** Korean UTF-8 text에는 embedded TrueType font와 `registerFontFamily`를 사용한다. 이 project는 현재 Windows host의 Malgun Gothic regular/bold를 실제로 읽어 PDF에 포함한다.
- **ADOPT — [ReportLab table guidance](https://docs.reportlab.com/reportlab/userguide/ch7_tables/):** 표는 고정 column width와 `repeatRows=1`로 행 단위 분할을 허용한다. ReportLab은 column split을 제공하지 않으므로 landscape A4와 representative-page inspection으로 문서의 표 밀도를 검증한다.
- **REJECT — 별도 SaaS/유료 PDF 변환 서비스:** 현재 bundled Python·ReportLab·Poppler만으로 생성/구조검사/PNG render가 가능하며, 이 선택은 추가 비용·credential·network dependency가 없다.

현재 실현성은 **Windows local export toolchain에서만 VERIFIED**다. 다른 OS/CI에서 Malgun Gothic 경로가 없으면 exporter는 글자 누락 PDF를 만들지 않고 명시적으로 실패한다. 그 환경을 지원해야 할 때에는 승인된 Korean font package와 라이선스/배포 경계를 별도 검토한다.

## 발행 정책

`ALWAYS_SYNC_ON_HUMAN_GDD_OR_EXPORTER_CHANGE`

Human GDD Markdown 또는 exporter가 바뀌는 같은 변경 단위에서 PDF와 manifest를 반드시 재발행한다. 기술 정본의 변경이 사람용 설명의 의미를 바꾸면 Human GDD 원고를 먼저 갱신한 뒤 재발행한다. PDF가 검수에 실패하면 이전 정상 PDF/manifest를 보존하고 실패한 output을 current로 기록하지 않는다.

## 재생성 절차

PowerShell에서 source 변경을 별도 commit으로 확정한 뒤 다음처럼 실행한다.

```powershell
$sourceBranch = 'main'
$sourceCommit = '<completed-main SHA containing the Human GDD source>'
$generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
& 'C:\Users\user\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\export_human_gdd_pdf.py `
  --source docs\design\NINJA_SURVIVAL_HUMAN_GDD.md `
  --output exports\NINJA_SURVIVAL_HUMAN_GDD_20260828.pdf `
  --source-branch $sourceBranch `
  --source-commit $sourceCommit `
  --generated-at $generatedAt `
  --document-title '닌자의 신 - 플레이어용 게임 기획서' `
  --header-label '닌자의 신 | 플레이어용 게임 기획서' `
  --right-header-label '읽기용 게임 기획서'
```

출력 파일은 generator가 임시 `.tmp` 파일에 먼저 작성하고 PDF header를 확인한 뒤에만 대상 경로로 교체한다.

## 필수 검수

1. `python -m unittest tools\test_export_human_gdd_pdf.py -v`로 Korean content와 publication metadata 보존을 확인한다.
2. `pdfinfo`와 pypdf로 file header, 페이지 수, metadata, Korean title, source SHA를 확인한다.
3. `pdftoppm -png`로 **전 페이지**를 렌더하고 빈 페이지, 한글·특수문자 대체, 표/코드/링크 잘림, footer/header 겹침을 시각 검수한다.
4. source SHA-256, generator SHA-256, PDF SHA-256, branch/commit, 생성 시각, render 상태를 manifest에 기록한다.
5. `sync_status: CURRENT`와 `human_visual_review: NOT_RUN`을 혼동하지 않는다. 사람이 실제로 읽어 승인한 경우에만 후자를 변경한다.
