# 화면 블루프린트 퇴행 복구 설계 — 2026-09-02

## 문제와 목표

`NS-BLUEPRINT-001`은 PR #137 시점의 사전제작 문서 상태를 그대로 유지해,
그 뒤 PR #139로 합쳐진 `TitleScreen`, 새 게임/이어하기/각성/도감/조작 방법/설정/종료,
Stage/Phase 공개 표기와 정확한 3×3 시작 가방을 다시 “예정”처럼 서술하고 있다.
반면 사람이 보던 28쪽 `NINJA_SURVIVAL_HUMAN_GDD`와 PDF는 남아 있지만, 현재
화면 블루프린트에서 그 열람 경로와 잠금된 화면 참조들이 충분히 전면에 보이지 않는다.

목표는 이전 사람용 블루프린트를 축소·교체하지 않고 다음 둘을 함께 복구하는 것이다.

1. 28쪽 Human Blueprint/PDF를 상세한 사람용 열람 원본으로 보존한다.
2. `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`를 현재 `main` 소비처와 기존 잠금 화면
   참조를 연결한 현재 화면 아틀라스로 정합화한다.

## 대안 비교

| 대안 | 판정 | 이유 |
| --- | --- | --- |
| A. 예정 문장만 최소 치환 | `REJECT` | 현재 구현 사실은 맞춰도, 이전보다 얇아진 열람 경로·화면 이미지를 복구하지 못한다. |
| B. 새 단일 포스터/보드 이미지를 제작 | `REJECT` | 이미 잠금된 5개 화면 참조와 실제 runtime 소비처가 있으며, 새 이미지가 문서의 증거·소비처 공백을 해결하지 않는다. |
| C. 28쪽 원본 + 잠금 참조 화면 아틀라스 + current-main 소비처 표를 함께 갱신 | `ADOPT` | 사용자에게 읽을 자료를 되돌리고, 코드/Scene와 문서의 시간축을 맞추며 새 raster binary 없이 provenance를 보존한다. |

## 범위와 비범위

### 포함

- 현재 `origin/main` `477ac7343bd655278d4f045d3152f6b7e4214062` 기준으로
  블루프린트의 baseline, Title/3×3/Stage/Phase/전투/Workbench 증거 문구를 정합화한다.
- 기존 `SCRREF-*` 5개 PNG를 Markdown 화면 아틀라스에서 문서 소비처로 재사용한다.
- 화면 커버리지 owner, 화면참조 README, Documentation Map, Active Context의
  파생 상태를 같은 의미로 정합화한다.
- 문서 정적 경로 검증, Godot import/editor/main smoke, PR exact-head CI와
  다섯 전체범위 적대적 검토를 실행한다.

### 제외

- 게임 규칙, 저장 구조, scene/script, runtime asset, 이미지 binary, UI 레이아웃 변경.
- 28쪽 PDF의 재생성/교체. PDF는 당시 사람용 검수 snapshot으로 보존하며,
  이 작업은 현재 화면 atlas가 그 snapshot과 현 구현을 연결하도록 한다.
- Human usability, player experience, device/export, 새로운 live-render 판정.

## 현재 사실과 소비처

| 사실 | current-main 읽기 근거 | 이 작업의 표기 |
| --- | --- | --- |
| 타이틀 진입 | `scenes/main/main_scene.tscn`이 `scenes/ui/title_screen.tscn`을 `TitleScreen`으로 instance | 현재 소비처 / machine scope, live visual은 `NOT_RUN` |
| Title 행동 | `scripts/core/main_controller.gd`, `scripts/ui/title_screen.gd`, `tests/integration/test_title_actions.gd`, `test_main_title_resume_flow.gd` | 새 게임·이어하기·각성·도감·조작 방법·설정·종료의 runtime owner를 정확히 표기 |
| 시작 가방 | `scripts/backpack/backpack_state.gd`, `tests/unit/test_backpack_state.gd` | 중앙 3×3은 구현된 공개 계약, Workbench UX/human은 별도 `NOT_RUN` |
| Stage/Phase | DEC-037 및 current main runtime reconciliation receipt | 공개 언어는 구현된 machine scope, visual/human은 별도 |
| 화면 참조 | `docs/visual/screen-references/*.png` 및 README hash/status | 문서 소비처이며 Godot texture로 승격하지 않음 |

## 실현성·롤백

- **플레이어/문서 가치:** 이전의 충분한 설명과 시각 앵커를 잃지 않으면서 현재
  구현 범위를 사실대로 읽을 수 있다.
- **기술:** Markdown relative-image 경로는 repository viewer에서 렌더되고, Godot
  소비처는 기존 Scene/script다. 이 작업은 engine/version, save, input ownership을
  건드리지 않는다.
- **자산:** user-locked/dual-stored reference만 연결한다. 새 후보·import·hash 변경은 없다.
- **검증:** Markdown 경로/readback와 Godot parse/smoke는 문서가 가리키는 현재
  repository 사실만 검증한다. live editor 연결이 없으면 visual/human은 `NOT_RUN`으로 남긴다.
- **롤백:** 문서만 되돌리면 되며 runtime/save/asset binary에는 영향이 없다.

## 수용 기준

1. 블루프린트에서 28쪽 Human Blueprint/PDF가 첫 열람 경로로 보이고, 다섯 기존
   화면 참조가 실제 Markdown으로 보인다.
2. Title과 3×3/Stage/Phase를 current main에서 “planned” 또는 “future migration”으로
   잘못 표시하지 않는다.
3. 실제 machine/source, live render, Human/device 증거가 분리되어 있다.
4. 모든 image link와 코드/문서 링크가 repository 안에서 해석되고, 새 raster binary가 없다.
5. current scope를 다섯 번 전체적으로 재공격한 적대적 검토와 exact-head CI/readback를 남긴다.
