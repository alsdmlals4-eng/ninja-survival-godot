# 사람용 게임 경험 블루프린트 적대 검토

```yaml
review_id: HUMAN_GAME_BLUEPRINT_ADVERSARIAL_2026_08_30
mode: attack -> validate-critique -> refine-approved-findings -> regression-recheck -> decision-report
approved_scope:
  - 28-page Korean human game-experience blueprint
  - one controlled Ninja made explicit
  - exact 3x3 starting usable backpack with 6x6 technical ceiling
  - Stage/Phase public vocabulary
  - paired implementation boundary and PDF publication
out_of_scope:
  - Godot runtime/data/UI/save migration
  - Human Usability or Player Experience session
  - touch/gamepad/device/export verification
  - new generated art or asset lock
base_main: b0d310d1b7b8006524e7078fa1a9443430481e38
source_commit: 2d20d379bcf8019d66addb7af51fee6c87265a09
publication_commit: bb132107857143fa37bbca4dc2d0111b2bc75a4f
current_branch: codex/human-game-blueprint-revision-132
```

## 기준과 실패 가정

모든 회차는 같은 전체 범위를 다시 공격했다: 최신 사용자 요구, DEC-037과 실제 `PlayerController`/Backpack owner의 경계, Human source→PDF 파생 연결, 실제 screen-reference/approved player asset 재사용, 현재 문서 route, 동명의 열린 PR, 비용/권한/Notion 경계, 테스트·PDF 구조·렌더 가독성, 그리고 runtime evidence ceiling이다. 특정 한 렌즈만 검사한 것을 별도 회차로 세지 않았다.

실패 가정은 다음과 같다.

1. PDF가 길어졌지만 누가 조작되는지 여전히 보이지 않는다.
2. 3×3이 문구만 바뀌고 기존 6×6/4×3 시작 계약이 current owner에 남는다.
3. Stage와 기존 Stage 1–4가 충돌해 용어가 더 혼란스러워진다.
4. PDF가 소스보다 오래되거나, manifest가 다른 파일을 current라고 주장한다.
5. 렌더는 열리지만 한글/카드/흐름도/실제 화면이 잘리거나, runtime 검증처럼 과장된다.

## 실질 대안과 비교

| 대안 | 판정 | 이유 |
| --- | --- | --- |
| 기존 4쪽 GDD의 문장만 수정 | `REJECT` | 플레이어 조작·3×3 성장·Scene/Flow 검수 질문을 한눈에 보여 주지 못한다. |
| Markdown source의 명시적 28페이지를 custom ReportLab visual renderer로 파생 | `ADOPT` | 사람이 수정하는 원고를 정본으로 유지하고, 실제 화면/설계 도식/흐름카드를 같은 A4 landscape 문서에 검수 가능하게 묶는다. |
| 새 일러스트·유료 디자인 도구로 예시와 비슷한 외형을 제작 | `REJECT` | 현재 실제 소비처/승인 이미지가 충분하며, 새 후보는 user LOCK과 provenance gate를 늘리고 이번 문서 문제를 직접 해결하지 않는다. |

장기 적합성은 두 번째 안이 가장 높다. source marker가 28개라는 테스트, PDF 페이지 수 테스트, manifest hash, `.gitattributes` binary 처리로 재발행 비용과 false diff noise를 함께 낮춘다.

## 전체 개선 루프

| Loop | input / evidence delta | full-scope attack·검증 결과 | validated finding / 최소 조치 | regression·대안·장기 적합성 | clean exit candidate |
| --- | --- | --- | --- | --- | --- |
| 1 | 이전 4쪽 Human GDD, 실제 `PlayerController`, `BackpackState`, current docs | 기존 문서가 한 명의 조작 닌자를 시각적으로 앞에 두지 않고, 시작 4×3/6×6 및 school/Stage 이중어를 유지함을 확인 | `MUST_FIX / CONFLICT`: 사용자 결정과 사람용 설명이 충돌. `DEC-037`, paired spec, 28-page source를 추가하고 active router/Master/README를 갱신 | 기존 코드 key를 즉시 대량 rename하는 안은 runtime/save 위험이 커 `DEFER`; 사람용 용어와 migration boundary를 먼저 분리 | false |
| 2 | source commit `2d20d37`; exporter test red→green | 28 marker, 첫 페이지의 조작 닌자, 3×3/Stage/Phase 텍스트, 기존 generic exporter 경로를 함께 공격 | `MUST_FIX`: 기존 exporter는 20쪽 흐름형 출력으로 marker/page 계약을 지키지 못함. marker parser + 28-page canvas route와 2개 회귀 테스트를 추가 | generic Markdown PDF 회귀 테스트 5개를 보존하고 blueprint test 2개를 더함. source-native layout이 code-only text duplication보다 유지보수에 유리 | false |
| 3 | generated PDF, `pdfinfo`, pypdf, 144dpi PNG 28장, 전 페이지 시각 readback | blank page, glyph loss, header/footer overlap, clipped cards, flow direction, actual-screen misuse, 3×3 도식, final evidence statement를 전 페이지 공격 | `NO_MATERIAL_FOLLOWUP`: 28/28 페이지·0 blank·0 zero-byte render, 01/28–28/28, 한글/카드/그림/번호가 읽힘. 실제 화면 참고와 설계 도식도 문서 안에서 구분됨 | 예시 PDF의 게임 콘텐츠/레이아웃을 그대로 복사하는 안은 `REJECTED_CRITIQUE`; 어두운 navy/cream/gold 카드 문법만 채택 | false — publication pointer/manifest를 아직 branch state에 맞게 고정해야 함 |
| 4 | publication commit `bb13210`, active-owner rescan, open PR readback | current pointer, old 20260828 link, 6×6/4×3 active statement, manifest SHA, binary diff, open PR 중복을 공격 | `COMPLEMENT_GAP`: 새 PDF가 text diff로 해석되어 `git diff --check origin/main...HEAD`에 이진 압축 내용을 whitespace finding으로 오인. `.gitattributes`에 `*.pdf binary`를 추가. DEC-037 note로 active `SYSTEM_MAP`과 historical T129 contract의 역할을 분리 | `git check-attr`이 PDF `binary: set`, `diff: unset`; text-only diff check와 active-reference rescan이 clean. 열린 PR은 무관한 historical draft #49 하나뿐이며 변경하지 않음 | false — final exact-head verification 필요 |
| 5 | final candidate with `.gitattributes`, manifest hash recheck, full exporter tests, full-page render review, active-doc rescan | 사용자 요구, canon/spec/source/PDF/manifest/test/README/router, image reuse, legacy/runtimes, cost, Notion exclusion, PR duplication, failure/rollback/evidence ceiling을 다시 전체 공격 | `NO_MATERIAL_FOLLOWUP`: 현재 scope의 새 `MUST_FIX`, approved `SHOULD_FIX`, user-decision blocker, stale active route, derivative drift, duplicate work 없음 | custom renderer + source test + binary attribute가 현 범위의 최소 복잡도. 새 이미지/런타임 변경은 consumer/approval boundary를 넘으므로 하지 않음 | true |

## Finding disposition

| ID | 분류 / 심각도 | 판정 | 처리 |
| --- | --- | --- | --- |
| AR-01 | `CONFLICT / MUST_FIX` | validated | DEC-037과 source, Master, current router, README, PDF route를 연결했다. |
| AR-02 | `COMPLEMENT_GAP / MUST_FIX` | validated | visual blueprint parser/export와 explicit-page regression test를 추가했다. |
| AR-03 | `COMPLEMENT_GAP / SHOULD_FIX` | validated | PDF binary attribute를 추가해 meaningful whitespace check가 가능해졌다. |
| AR-04 | `USER_DECISION_REQUIRED` 가능성 | rejected for current scope | Stage/Phase 공개 계약은 user가 승인했고, runtime key/save migration은 final PDF review 이후 별도 package다. |
| AR-05 | `BLOCKED_UNVERIFIED` | recorded, not a publication blocker | Human usability, Player Experience, touch/gamepad/device/export 및 3×3 runtime은 실행하지 않았다. PDF가 이를 PASS로 바꾸지 않는다. |
| AR-06 | `ALLOWED_LEGACY` | retained | historical plan/traceability/T129 machine record의 school/4×3 문구는 historical implementation fact로 보존한다. active owner에는 DEC-037 overlay를 명시했다. |

## 열린·최근 작업 / Repository-only 경계

- 2026-08-30 readback의 유일한 열린 PR은 #49이며, superseded historical T12 draft다. 이 작업과 중복되지 않고 read-only로 유지했다.
- current `main`은 `b0d310d…`; 이 branch는 그 위에서 두 commits를 가진 분리 작업 공간이다. direct main push, force push, PR mutation은 하지 않았다.
- DEC-035에 따라 Notion/Google Sheets에는 읽기·쓰기·sync를 하지 않았다. repository source, PDF, manifest가 이 publication의 단일 active record다.

## remaining-work 재계산과 종료 판정

### 현재 승인 범위

- 사람용 28쪽 Blueprint source: 완료 후보
- paired implementation spec + DEC-037: 완료 후보
- PDF/manifest/source hash/전 페이지 render: 완료 후보
- active route/readme/document map propagation: 완료 후보

### 다음 권한이 필요한 범위

- `human_visual_review`: `NOT_RUN` — 사용자가 PDF를 검수해야 한다.
- Godot 3×3, 공개 Stage/Phase UI, legacy migration, save/test/runtime/입력 경로: user final PDF review 뒤의 별도 build package
- Human Usability, Player Experience, touch/gamepad/device/export: `NOT_RUN`

`REMAINING_WORK_COMPLETION_GATE` 재계산 결과, 현재 **문서·PDF publication scope**에서 자동으로 실행 가능한 남은 교정은 0이다. `CLEAN_REVIEW_EXIT`는 publication scope에만 적용한다. runtime 이행은 이 결과로 승인되지 않는다.
