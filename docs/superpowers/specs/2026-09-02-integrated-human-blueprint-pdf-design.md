# 통합 Human Blueprint PDF 설계 — 2026-09-02

## 목적

기존 28쪽 `NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`를 폐기하거나 축약하지 않고,
현재-main의 화면 Blueprint·와이어프레임·플로우와 이미 사용자 `LOCK`된 최신 이미지를
한 개의 내려받을 수 있는 사람용 PDF로 묶는다.

## 사용자에게 보이는 결과

`exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf`는 아래 순서로
읽힌다.

1. 새 표지와 읽기 지도 — 기존 본문과 새 시각 보강부의 역할을 먼저 분리한다.
2. 보존 본문 — 기존 28쪽 Human Blueprint를 원래 PDF page object로 그대로 포함한다.
3. 현재-main 시각 보강부 — 화면 플로우, Title, Stage 선택, 자동전투 HUD,
   Elite→Trace→Boss, Result→Workbench, Game Over의 와이어프레임과 자산 보드를
   순서대로 제공한다.
4. 증거/다운로드 경계 — 참조 이미지, Godot runtime, 사람 검수, device/export의
   증거를 혼동하지 않게 표시한다.

## 채택 구조

| 선택 | 이유 | 대안과 판정 |
| --- | --- | --- |
| 기존 PDF page object를 보존한 뒤 새 보강 페이지를 결합 | 기존 28쪽의 인간 검수 결과와 레이아웃을 손상시키지 않으면서 사용자가 요청한 추가물을 한 파일에 담는다. | 기존 원고를 재렌더: **REJECT** — 이미 검수된 본문 레이아웃 변형 위험. 별도 PDF 링크: **REJECT** — 한 파일로 보는 요구를 충족하지 못한다. |
| ReportLab + pypdf + bundled Poppler | 현재 프로젝트의 PDF 발행 계약, 한국어 글꼴, 로컬 검수 흐름을 재사용한다. | 별도 SaaS/유료 변환: **REJECT** — 비용과 계정 의존성이 불필요하다. |
| 사용자 `LOCK` 이미지 8종만 재사용 | Title, 5개 화면 참조, 봉마 보스/식신은 이미 SHA·승인·소비처가 있다. | 새 이미지 생성: **REJECT** — 이번 문서 소비처에는 승인된 자산이 충분하며 새 candidate gate가 필요 없다. |
| GitHub blob + raw 파일 경로를 문서와 최종 안내에 명시 | 저장소 내 binary가 누구나 같은 경로에서 열고 내려받을 수 있다. | 외부 파일 보관: **REJECT** — repository-primary/cost-free 원칙에 어긋난다. |

## 포함할 잠금 자산

| 역할 | Asset ID / 파일 | 상태 |
| --- | --- | --- |
| Title backdrop | `NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02` / `assets/runtime/ui/title_screen_moonlit_ninja_v2.png` | `USER_LOCKED`, current Title consumer |
| Wordmark | `NINJA_RUNTIME_TITLE_LOGO_NINJA_GOD_01` / `assets/runtime/ui/title_logo_ninja_god_v1.png` | `USER_LOCKED`, current Title consumer |
| Four-fragment medal | `NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02` / `assets/runtime/ui/title_four_traditions_medal_v2.png` | `USER_LOCKED`, current Title consumer |
| Screen references | `SCRREF-SCHOOL-SELECT-02`, `SCRREF-BATTLE-AUTOCOMBAT-03`, `SCRREF-WORKBENCH-02`, `SCRREF-RESULT-02`, `SCRREF-GAME-OVER-02` | user-locked / dual-stored planning references, not runtime textures |
| Bongma Boss + shikigami | `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01`, `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_FAMILIAR_01` | `USER_LOCKED`, actual encounter visual consumers |

## 보호 경계

- 새 PDF는 사람용 파생본이다. Scene/Script/test/asset manifest/runtime behavior의 정본을 대체하지 않는다.
- 기존 28쪽 PDF와 그 manifest는 historical snapshot으로 보존한다. 이 통합본은 새 파일과 새 manifest로만 발행한다.
- 화면 참고 PNG는 이번 PDF의 소비처가 되지만, planning reference가 Godot runtime texture로 승격되지는 않는다.
- 표지/와이어프레임은 PDF layout이다. 별도의 새 image binary가 아니다.
- `runtime render`, `Human Usability`, `Player Experience`, `touch/gamepad`, `device/export`는 실제로 실행하지 않으면 `NOT_RUN`을 유지한다.

## Definition of Ready

- `origin/main` at `16cf7a6bb2a8676ad979985605d66f1ca3edd28c` was read before branch creation.
- existing PDF, `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`, visual handoff, screen-reference README,
  `CURRENT_CONFIRMED_DECISIONS.md`, and Base fresh policy were read.
- target assets exist locally and their title hashes match the handoff.
- bundled Python has `reportlab`, `pypdf`, and `Pillow`; bundled Poppler exposes `pdfinfo` and `pdftoppm`.
- no image-generation gap is present.

## Acceptance criteria

1. One generated PDF is present at the new `exports/` path, starts with `%PDF-`, and is landscape A4.
2. The 28 original pages are copied unchanged after the new front matter.
3. The PDF contains at least 38 pages: 3 guide pages + 28 preserved pages + 7 visual companion pages.
4. Every required locked image is embedded by the companion pages and its source/role is listed in the new manifest.
5. The companion pages provide title, stage, battle, trace/boss, result/workbench, and game-over wireframes.
6. `pdfinfo`, pypdf text/metadata checks, full-page Poppler render, and visual review show no blank, clipped, or replacement-glyph pages.
7. Documentation Map, PDF contract, screen Blueprint, and ACTIVE_CONTEXT route a reader to the new file without claiming it proves runtime/Human/device evidence.
8. A GitHub blob link and raw-download URL are deterministic from the merged `main` path.

## Non-goals

- no new runtime feature, UI scene, visual asset binary, gameplay balance, Godot render claim, release, or device test;
- no rewrite of the historical 28-page GDD source or existing PDF;
- no external file host, paid tool, or Notion operation.
