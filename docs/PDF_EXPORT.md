# 플레이어용 GDD PDF 발행 계약

## 역할과 정본 경계

- **기술 정본:** `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`
- **사람용 편집 원고:** `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md`
- **사람용 다운로드 snapshot:** `exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`
- **발행 상태/해시:** `docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json`
- **생성기:** `tools/export_human_gdd_pdf.py`
- **통합 다운로드 열람본:** `exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf`
- **통합본 manifest:** `docs/publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_PDF_MANIFEST.json`
- **통합본 composer:** `tools/export_integrated_human_blueprint_pdf.py`

PDF는 사람이 한 파일로 읽고 내려받는 파생본이다. Human GDD는 28개의 명시적 검수 페이지로 핵심 재미·플레이 흐름·선택·구현 경계를 쉬운 말로 설명한다. 각 페이지는 검수 질문과 한 줄 결론을 가지며, 실제 화면 참고와 수정 가능한 설계 도식을 구분한다. 기술 정본의 SHA/PR/CI receipt/경로 세부는 PDF 본문에 반복하지 않는다. PDF 안의 설명, 표, 링크 또는 생성 성공은 Godot runtime, Human Usability, Player Experience, device/export, release evidence를 승격하지 않는다.

`NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf`는 기존 28쪽을 다시
렌더하거나 교체하지 않는다. 3쪽의 읽기 지도 뒤에 기존 PDF page object 28쪽을
그대로 보존하고, 7쪽의 current-main 화면 wireframe·flow·잠금 이미지 보강부를 한
파일로 결합한다. 이 통합본이 사람용 기본 다운로드 경로이며, 기존 PDF는 재현성과
historical reader snapshot을 위해 유지한다.

## 조사·실현성 판정

- **ADOPT — [ReportLab TrueType font guidance](https://docs.reportlab.com/reportlab/userguide/ch3_fonts/):** Korean UTF-8 text에는 embedded TrueType font와 `registerFontFamily`를 사용한다. 이 project는 현재 Windows host의 Malgun Gothic regular/bold를 실제로 읽어 PDF에 포함한다.
- **ADOPT — [ReportLab table guidance](https://docs.reportlab.com/reportlab/userguide/ch7_tables/):** 표는 고정 column width와 `repeatRows=1`로 행 단위 분할을 허용한다. ReportLab은 column split을 제공하지 않으므로 landscape A4와 representative-page inspection으로 문서의 표 밀도를 검증한다.
- **REJECT — 별도 SaaS/유료 PDF 변환 서비스:** 현재 bundled Python·ReportLab·Poppler만으로 생성/구조검사/PNG render가 가능하며, 이 선택은 추가 비용·credential·network dependency가 없다.

현재 실현성은 **Windows local export toolchain에서만 VERIFIED**다. 다른 OS/CI에서 Malgun Gothic 경로가 없으면 exporter는 글자 누락 PDF를 만들지 않고 명시적으로 실패한다. 그 환경을 지원해야 할 때에는 승인된 Korean font package와 라이선스/배포 경계를 별도 검토한다.

## 발행 정책

`ALWAYS_SYNC_ON_HUMAN_GDD_OR_EXPORTER_CHANGE`

Human GDD Markdown 또는 exporter가 바뀌는 같은 **publication package**에서 PDF와 manifest를 반드시 재발행한다. 기술 정본의 변경이 사람용 설명의 의미를 바꾸면 Human GDD 원고를 먼저 갱신한 뒤 재발행한다. PDF가 검수에 실패하면 이전 정상 PDF/manifest를 보존하고 실패한 output을 current로 기록하지 않는다.

manifest가 completed `main` source commit을 기록해야 할 때에는 source merge와 PDF publication merge를 분리할 수 있다. 이 경우 source merge는 manifest를 `STALE_PENDING_MAIN_SOURCE_PUBLICATION`으로 명시하고, unrelated work 없이 fresh completed `main`에서 PDF/manifest publication PR을 즉시 열어 `CURRENT`로 되돌린다. 두 PR은 하나의 publication package이며, source PR만으로 current PDF를 주장하거나 package를 닫을 수 없다.

## 재생성 절차

PowerShell에서 source 변경을 별도 commit으로 확정한 뒤 다음처럼 실행한다.

```powershell
$sourceBranch = 'main'
$sourceCommit = '<completed-main SHA containing the Human GDD source>'
$generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
& 'C:\Users\user\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\export_human_gdd_pdf.py `
  --source docs\design\NINJA_SURVIVAL_HUMAN_GDD.md `
  --output exports\NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf `
  --source-branch $sourceBranch `
  --source-commit $sourceCommit `
  --generated-at $generatedAt `
  --document-title '닌자의 신 - 플레이어용 게임 기획서' `
  --header-label '닌자의 신 | 플레이어용 게임 기획서' `
  --right-header-label '읽기용 게임 기획서'
```

출력 파일은 generator가 임시 `.tmp` 파일에 먼저 작성하고 PDF header를 확인한 뒤에만 대상 경로로 교체한다.

### 통합 Human Blueprint 재생성

통합본의 source는 historical 28쪽 PDF + current screen Blueprint + approved visual
handoff + integration design이다. 새 visual companion이 필요할 때에는 먼저 기존
잠금/승인 asset으로 gap이 채워지는지 확인한다. 새 image binary가 필요한 경우에는
DEC-034의 single-candidate `LOCK / REVISE / REJECT` gate를 별도로 따른다.

다운로드본은 GitHub의 50 MiB 권고선 아래를 유지한다. 따라서 opaque visual
reference만 composer 메모리 안에서 최대 1600px·JPEG quality 94로 넣고, source PNG
bytes·SHA·provenance·runtime consumer는 수정하지 않는다. 투명도가 있는 title/encounter
asset은 silhouette 보존을 위해 source PNG 그대로 넣는다.

```powershell
$sourceCommit = '<commit containing the integration design and test contract>'
$generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
& 'C:\Users\user\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' tools\export_integrated_human_blueprint_pdf.py `
  --historical-pdf exports\NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf `
  --output exports\NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf `
  --source-commit $sourceCommit `
  --generated-at $generatedAt
```

그 뒤 `NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_PDF_MANIFEST.json`의 source,
composer, artifact, 모든 reused locked asset SHA, page count, render 결과를 함께
갱신한다. 통합본은 3 front-matter + 28 preserved historical + 7 visual companion,
총 38쪽을 유지한다.

## 필수 검수

1. `python -m unittest tools\test_export_human_gdd_pdf.py -v`로 Korean content와 publication metadata 보존을 확인한다.
2. `pdfinfo`와 pypdf로 file header, 페이지 수, metadata, Korean title, source SHA를 확인한다.
3. `pdftoppm -png`로 **전 페이지**를 렌더하고 빈 페이지, 한글·특수문자 대체, 카드/흐름도/3×3 도식/실제 화면 참고의 잘림, footer/header 겹침을 시각 검수한다.
4. source SHA-256, generator SHA-256, PDF SHA-256, branch/commit, 생성 시각, render 상태를 manifest에 기록한다.
5. `sync_status: CURRENT`와 `human_visual_review: NOT_RUN`을 혼동하지 않는다. 사람이 실제로 읽어 승인한 경우에만 후자를 변경한다.
6. 통합본은 `python -m unittest tools\test_export_integrated_human_blueprint_pdf.py -v`, `pdfinfo`, pypdf, 전 페이지 `pdftoppm` render와 새 보강부 전체의 시각 검수를 추가로 통과해야 한다.
