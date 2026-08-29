# 플레이어 조작·스테이지·3×3 가방 블루프린트 명세

```yaml
spec_id: NINJA_HUMAN_BLUEPRINT_PLAYER_STAGE_BAG_V1
status: SPECIFIED_FOR_HUMAN_BLUEPRINT
approved_by: user_chat_2026-08-30_KST
canon_owner: docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md
runtime_build_authority: NOT_GRANTED_UNTIL_USER_FINAL_PDF_REVIEW
paired_human_source: docs/design/NINJA_SURVIVAL_HUMAN_GDD.md
paired_reader_artifact: exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf
```

## 1. 결정과 해결할 문제

이번 사용자 결정은 세 가지다.

1. 사람이 보는 설명과 화면에서 **플레이어가 직접 조작하는 한 명의 닌자**가 즉시 보여야 한다.
2. 가방의 실제 시작 사용 가능 영역은 **정확히 3×3**이며, 가방 획득·배치로 확장된다.
3. 플레이어에게 보이는 목적지는 **스테이지**다. 기존 `Stage 1..4` 난이도/패턴 축은 **페이즈 1..4**로 부른다.

기존 사람용 GDD는 자동 공격의 이유는 설명하지만, 조작 대상·직접 행동·자동 행동의 경계가 화면 흐름으로 드러나지 않는다. 또한 `6×6 / 시작 4×3`와 school/stage 이중 용어가 새 사용자 결정을 거스른다.

## 2. 플레이어 공개 계약

### 2.1 내가 조작하는 것

- 플레이어는 Run 전체에서 **한 명의 고정 닌자**를 조작한다.
- 전투 직접 행동은 이동이다. 현재 실제 구현의 방향키/WASD 이동을 사람용 문서의 기준 행동으로 설명한다.
- 자동 공격·유파/전승 행동은 조작 대상이 아니라, 닌자의 위치·적 군집·확정 빌드가 만든 결과다.
- Workbench에서는 아이템/가방 선택, 90도 회전, 배치, 조합, Fate 및 다음 스테이지 확정이 플레이어의 직접 결정이다.
- 사람용 PDF는 전투 직접 행동과 Workbench 직접 결정을 같은 비중으로, 자동 결과와 분리해 시각화한다.

### 2.2 용어

| 공개 용어 | 의미 | 이전/내부 호환 표현 | 상태 |
| --- | --- | --- | --- |
| 스테이지 | 네 가지 위험 처리법과 전장을 가진 다음 목적지 | legacy `school`, `school_id` | 사람용 문서부터 채택 |
| 페이즈 1–4 | 한 스테이지 안에서 위험·패턴이 깊어지는 진행 축 | legacy `Stage 1..4` | 사람용 문서부터 채택 |
| 전승 | 봉마·천술·귀인·흑영이 주는 위험 처리 철학 | school tradition | 공개 보조 용어 |

이번 package는 코드의 legacy key 또는 클래스명을 대량 변경하지 않는다. 실제 런타임 이행 때 UI 문구, `RunRouteState`, stage profile, 저장 호환, 도움말, 테스트를 하나의 migration package로 검토한다.

### 2.3 가방 성장

| 구간 | 플레이어가 보는 상태 | 보호 규칙 |
| --- | --- | --- |
| Run 시작 | **3×3** 사용 가능 영역 | 시작 외곽을 열린 6×6 보드로 보이지 않게 한다. |
| 첫 확장 이후 | 획득한 가방이 붙어 실제 사용 공간이 넓어진다 | 가방/아이템 90도 회전, 직교 인접, special-bag overlap 규칙을 유지한다. |
| 상한 | 기술적으로 최대 6×6 외곽 안에서 조립한다 | UI가 geometry/economy/commit 권한을 갖지 않는다. |
| 전투 반영 | 확정된 레이아웃만 전투력에 반영한다 | preview는 combat power 0, atomic Fate/route commit을 유지한다. |

초기 3×3은 현 catalog의 2×3 아이템이 큰 결정을 만들 수 있다. 런타임 package의 Definition of Ready는 시작 보상 순서, item footprint, 첫 확장 시점, 막힘/undo 피드백을 별도로 검증해야 한다.

## 3. 사람용 블루프린트 범위

사람용 PDF는 28개의 명시적 검수 페이지로 구성한다. 각 페이지는 검수 질문, 한 줄 결론, 실제 화면 또는 텍스트 기반 흐름 도식, “보이는 것·하는 것·결정하는 것”을 가진다.

- 실제 전투/선택/Workbench/결과 화면은 repository의 screen reference를 재사용한다.
- 플레이어 Move/Attack/Hit 이미지는 실제 승인 source이며, 새 플레이어 이미지를 만들지 않는다.
- `3×3 → 가방으로 확장` 및 입력/흐름은 **설계 도식**으로 표시하고 실제 runtime screenshot으로 오인시키지 않는다.
- PDF는 사람 검수용 파생본이다. raw path, PR, CI, 엔진 버전, 테스트 명령은 PDF 본문에 넣지 않는다.

## 4. 구현 가능성 및 범위 경계

현재 `PlayerController`의 입력, `BackpackState`/`BackpackResolver`의 공간 규칙, `RestBackpackSession`/`RestCommitCoordinator`의 preview/atomic commit 분리는 새 설명과 충돌하지 않는다. 그러나 `3×3` 시작 가방과 Stage 공개 용어는 실제 구현 시 catalog, UI, route, save, GUT 회귀 테스트에 영향을 준다.

따라서 이 작업의 완료는 **문서와 PDF의 검수 가능한 재구성**이다. Godot runtime, Human Usability, Player Experience, touch/gamepad/device/export는 이 PDF의 생성·검수로 PASS가 되지 않으며, 사용자 최종 PDF 검수 전에는 runtime 구현을 시작하지 않는다.

## 5. 이후 런타임 package의 완료 조건

1. 시작 상태가 정확히 3×3 사용 가능 영역을 제공하고, 초기 아이템/보상 흐름이 배치 가능하다.
2. 플레이어 화면에서 한 명의 닌자와 이동 직접 행동이 자동 공격과 구별된다.
3. 공개 UI·도움말·결과 문구가 Stage/Phase를 일관되게 사용한다.
4. Workbench의 pointer, keyboard/gamepad, touch 핵심 경로와 3×3 확장 흐름을 실제로 검증한다.
5. 저장/rollback, committed-only combat authority, Fate/route atomicity를 회귀 검증한다.

## 6. 결정 로그

| 날짜 | 결정 | 근거 | 다음 검토 |
| --- | --- | --- | --- |
| 2026-08-30 | 사람이 보는 목적지를 스테이지, 난이도/패턴 축을 페이즈로 정한다 | 사용자 최신 지시와 기존 이중 Stage 의미 충돌 | 런타임 migration package |
| 2026-08-30 | 3×3 시작 + 최대 6×6 외곽을 채택한다 | 사용자 요구와 현재 spatial owner의 안전한 재사용 | 초기 보상/footprint usability |
| 2026-08-30 | 먼저 사람용 28쪽 블루프린트를 만들고, 최종 PDF 승인 후 런타임 이행한다 | 첨부 템플릿의 human-review gate | 사용자 final review |
