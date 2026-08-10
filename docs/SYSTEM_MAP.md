# SYSTEM_MAP

## 목적

이 문서는 `닌자 서바이벌` Godot 버전의 **현재 실제 시스템 책임과 다음 MVP-4 확장 경계**를 연결한다.

현재 제품 결정은 `docs/CURRENT_CONFIRMED_DECISIONS.md`, 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`가 우선한다. 이 문서는 상태/책임을 찾는 지도이며 동일 규칙을 별도 정본으로 복제하지 않는다.

## 현재 baseline

Project main baseline observed for this map: `9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1`.

- MVP-0~MVP-3 runtime is integrated.
- MVP-4 design is complete pending written-spec review.
- MVP-4 production implementation has not started.

## 현재 구현 책임

| 영역 | 현재 파일/씬 | 현재 책임 | 상태 |
|---|---|---|---|
| Main orchestration | `scripts/core/main_controller.gd` | 전투/학교/스테이지/휴식 controller wiring | MVP-3 integrated |
| Game state | `scripts/core/game_state.gd` | score/kill 등 기본 run state | integrated |
| Stage flow | `scripts/core/stage_flow_controller.gd` | `SCHOOL_SELECT → COMBAT → BOSS → RESULT → SHOP → FATE → PREVIEW/COMPLETE` | MVP-3 integrated, MVP-4 target differs |
| Build state | `scripts/core/run_build_state.gd` | GOLD, non-spatial `owned_items`, Fate, derived modifiers | MVP-3 integrated; spatial ownership 예정 |
| Shop | `scripts/core/shop_controller.gd` | 3 item offer, buy/sell/reroll, injectable RNG | MVP-3 integrated; MVP-4 intake semantics 변경 예정 |
| Fate | `scripts/core/fate_controller.gd` | Fate candidate/selection | integrated |
| Contribution | `scripts/combat/combat_contribution_tracker.gd` | damage/healing/defense/status/kill-combo segment snapshot | integrated |
| Combat modifier resolution | `scripts/combat/combat_resolver.gd` | run modifier를 전투 damage path에 적용 | integrated |
| Rest UI | `scripts/ui/rest_flow_ui.gd` + `scenes/ui/rest_flow_ui.tscn` | RESULT/SHOP/FATE/PREVIEW view, intent signal | MVP-3 integrated; Persistent Workbench 예정 |
| Item definition | `scripts/data/item_definition.gd` | MVP-3 item id/price/tag/effect | integrated; footprint/rotation data 없음 |
| Catalog | `scripts/data/mvp3_catalog.gd` | 현재 item/fate catalog | integrated; MVP-4 pool 확장 예정 |
| Stage boss | `scripts/enemies/stage_boss.gd` + `scenes/enemies/stage_boss.tscn` | 5분 경계 boss runtime | MVP-3 integrated |
| Tests | `tests/unit/`, `tests/integration/`, `.github/workflows/gut.yml` | GUT unit/integration/CI | active |

## MVP-4 target responsibility map

MVP-4는 UI에 공간 규칙을 넣지 않고 다음 책임을 분리한다.

```text
ItemDefinition / BagDefinition
        ↓
ItemInstance / BagInstance
        ↓
BackpackState
        ↓
BackpackResolver
        ↓
BuildPreviewSnapshot
        ↓
RunBuildState + Fate
        ↓
RunModifierSet / combat runtime

REST editing side:
RestBackpackSession
  ├─ 6-slot work buffer
  ├─ placement/rotation preview
  ├─ whole-layout translation
  ├─ Undo/Redo
  ├─ pending bag
  └─ combination preview/transaction

UI side:
Persistent Workbench UI
  └─ snapshot 표시 + intent signal/event만 반환
```

### `BackpackState`

Target responsibility:

- fixed `6x6` board,
- bag/item instances,
- coordinates and rotation,
- canonical committed spatial state.

### `BackpackResolver`

Target responsibility:

- occupied cells,
- board bounds,
- active cells,
- bag connectivity,
- collision,
- orthogonal adjacency graph,
- special-bag overlap,
- combination eligibility,
- active placement effects.

Resolver는 UI/Scene과 분리된 deterministic rule layer여야 한다.

### `RestBackpackSession`

Target responsibility:

- 6-slot REST-only work buffer,
- move/rotate/drop preview,
- whole-layout translation,
- placement Undo/Redo,
- pending bag placement,
- combination preview and atomic commit,
- Fate commit readiness.

### Persistent Workbench UI

Target responsibility:

- central backpack board를 REST 동안 지속 표시,
- chest/shop/buffer/combination을 같은 session 안에서 왕복,
- Windows rail/panel과 Android bottom-sheet/tab adapter,
- mouse/keyboard/gamepad/touch intent 전달,
- valid/invalid/synergy/hint/commit feedback.

UI는 BackpackState, 경제, reward roll, combination legality를 재계산하지 않는다.

## MVP-4 stage/reward target

```text
COMBAT
→ ~3 min ELITE
   └─ kill: chest token
→ ~5 min SEGMENT BOSS
→ RESULT
→ BOSS_REWARD 3 choose 1
→ PERSISTENT REST WORKBENCH
→ FATE commit
→ PREVIEW / COMPLETE
```

MVP-3의 현재 StageFlow 구현은 실제 baseline으로 남아 있고, 위 흐름은 MVP-4 implementation target이다. 문서가 target을 현재 구현 완료로 표현하지 않는다.

## MVP-4 데이터 경계

### Confirmed

- 6x6 board / 4x3 start area.
- item+bag 90° rotation.
- rectangular regular items; selected L/T bags.
- 6-slot work buffer.
- orthogonal adjacency.
- one-cell special-bag overlap activation.
- representative combinations: 물안개 / 뇌명도 / 폭렬탄.
- boss/shop/chest acquisition pillars.

### Planned authoring additions

Implementation plan에서 기존 `ItemDefinition` 확장과 별도 `BagDefinition`, instance model, combination data의 정확한 파일 split을 결정한다. 새 파일 경로를 이 System Map이 선행 확정하지 않는다.

## 검증 구조

MVP-4 implementation은 최소 다음 계층으로 검증한다.

```text
unit
- geometry / rotation
- collision / connectivity
- adjacency / special-bag overlap
- buffer / Undo-Redo boundaries
- combination atomicity
- seeded reward generation

integration
- stage reward → buffer → placement → Fate commit
- shop/chest/boss-reward transaction
- RunBuildState modifier commit boundary
- Rest UI intent ↔ session snapshot

human
- Windows mouse+keyboard
- Windows gamepad focus
- Android real-device touch
- long Korean text / smallest supported layout
- REST fatigue and comprehension
```

실행되지 않은 MVP-4 test/runtime/human evidence는 `NOT_RUN`이다.

## 설계 원칙

- 상태 소유자를 중복시키지 않는다.
- UI는 domain 규칙의 authority가 아니다.
- REST preview와 actual combat modifier commit을 분리한다.
- transaction failure는 partial mutation 없이 fail closed한다.
- random reward path는 seeded/injectable test가 가능해야 한다.
- 첫 구현 Goal 하나에 MVP-4 전체를 무리하게 넣지 않고 implementation plan에서 독립 testable package로 나눈다.
- save system, 2차/3차 조합, arbitrary item polyomino, 깊은 set/curse, final economy는 MVP-4에서 새로 만들지 않는다.

## 다음 책임 원본

- 제품 결정: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- MVP-4 detailed design: `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
- 단계 범위: `MVP_ROADMAP.md`
- 현재 상태: `docs/ACTIVE_CONTEXT.md`
- 구현 전 최종 작업 분해: written-spec review 뒤 생성할 Superpowers implementation plan