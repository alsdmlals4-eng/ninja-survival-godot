# MVP-4 Backpack / Combination Basics — Game Feature Design Spec

## 0. Identity & authority

```yaml
feature_id: MVP-4-BACKPACK-COMBINATION
feature_name: Backpack / Combination Basics
work_level: L2
status: APPROVED
owner: ninja-survival-godot game design
canonical_path: docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
related_decision_ids:
  - DEC-2026-08-11-001
related_specialized_sources:
  - path: docs/CURRENT_CONFIRMED_DECISIONS.md
    authority: current approved product decisions
  - path: AGENTS.md
    authority: project execution and MVP constraints
  - path: MVP_ROADMAP.md
    authority: staged MVP boundary
  - path: docs/ACTIVE_CONTEXT.md
    authority: implementation/verification state only
created_at: 2026-08-11
updated_at: 2026-08-11
approval_reference: user written-spec approval in project chat on 2026-08-11; PR #7 design checkpoint merged as 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
```

### Authority boundary

이 Spec은 MVP-4가 플레이어에게 어떤 공간 퍼즐·획득·조합·휴식 경험을 제공해야 하는지, 그 규칙·상태·입력·피드백·오류·검증 계약을 책임진다.

이 Spec은 실제 Task 진행률, PR 상태, 코드 완료율, 실행된 테스트 결과를 소유하지 않는다. 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md` 및 후속 Traceability/검증 기록이 책임진다.

MVP-3의 실제 구현은 현행 baseline이며, MVP-4는 이를 파괴적으로 번역하지 않고 spatial backpack ownership과 REST transaction을 추가하는 방향으로 확장한다.

---

## 1. Player Problem

```yaml
player_problem: 전투에서 얻은 보상과 빌드 성과가 휴식 구간에서 실제 다음 전투 전략으로 변환되는 체감이 아직 부족하다.
current_behavior: MVP-3는 비공간 owned item 목록과 선형 RESULT→SHOP→FATE→PREVIEW 흐름을 사용한다.
undesired_outcome: 구매·보유가 곧바로 전투 modifier가 되어 배치 판단이 없고, 휴식이 단순 상점 메뉴처럼 느껴질 수 있다.
desired_change: 플레이어가 제한된 가방 공간에서 무엇을 넣고, 어디에 놓고, 무엇을 조합할지 판단하며 다음 전투의 성능과 정체성을 설계한다.
evidence_state: DESIGN_HYPOTHESIS_WITH_BENCHMARK_SUPPORT / HUMAN_MVP4_EVIDENCE_NOT_RUN
```

---

## 2. Experience Intent & Core Alignment

### Experience intent

- 행동: 아이템/가방을 획득하고, 옮기고, 회전하고, 배치하고, 조합한다.
- 판단: 지금 강한 아이템과 앞으로 필요한 조합 재료, 공간 효율, 인접 시너지, 가방 확장 중 무엇을 우선할지 결정한다.
- 즉시 피드백: 놓기 전에 유효성·시너지·특수 가방 영향·조합 가능성을 이해한다.
- 변화 체감: REST 전후 build preview가 달라지고 다음 전투에서 실제 성능 차이를 확인한다.
- 반복 숙련: 같은 아이템 풀에서도 공간/가방/인접 관계 때문에 다른 배치 해법을 만든다.

### Core alignment

| 연결 대상 | 이 기능의 기여 | 위반 위험 |
|---|---|---|
| 인법 조합 빌드 | 실제 배치와 인접을 조합의 전제 비용으로 만든다 | 조합표 클릭 메뉴로 축소하면 핵심 약화 |
| 전투 쾌감 | REST 선택의 결과를 다음 전투에서 폭발력으로 검증한다 | 휴식이 너무 길면 전투 리듬 붕괴 |
| 백팩 배치 시너지 | 공간 자체가 성능과 선택의 일부가 된다 | 정답 자동배치/과도한 힌트는 설계감 약화 |
| 유파 실험 | 유파 관련 보상 가중치와 인법/장비 조합으로 빌드 방향을 지지한다 | 유파별 고정 정답 가방이 되면 다양성 약화 |

### Planned evidence

```yaml
TECH_EVIDENCE: resolver deterministic tests, transaction tests, seeded reward tests
UI_EVIDENCE: Windows and Android layout/input captures, focus-path evidence
HUMAN_USABILITY_EVIDENCE: first-time REST workbench task observation
PLAYER_EXPERIENCE_EVIDENCE: whether placement feels like next-fight design rather than inventory chores
human_status: HUMAN_NOT_RUN
```

---

## 3. Scope / Non-goals

### In scope

- 고정 `6x6` 보드와 시작 `4x3` 사용 가능 영역.
- 가방 배치로 활성 셀 확장.
- 가방/아이템 90도 회전.
- 일반 아이템 직사각형 footprint.
- 일부 L/T형 가방.
- 아이템 직교 인접 시너지.
- 1-cell overlap부터 적용되는 특수 가방 효과.
- 6-slot REST work buffer.
- boss reward / shop / chest 획득 축.
- 약 3분 엘리트 → chest token, 약 5분 세그먼트 boss.
- 명시적 1차 조합 3종과 progressive hint.
- 통합 Persistent Workbench UI.
- Undo/Redo, preview, error recovery, deterministic testability.

### Out of scope

- 2차/3차 조합.
- arbitrary polyomino item system.
- 깊은 set/curse system.
- full rarity layer.
- 완전한 상점 경제와 최종 밸런스.
- polished final art / full animation production.
- MVP-5 최종 보스·최종 결과·Ninja Soul loop.

### Minimum viable behavior

한 번의 REST에서 플레이어가 보상 하나 이상을 work buffer로 받고, 현재 가방과 새 보상을 보면서 합법적 배치/회전/인접을 만들고, 가능하면 대표 조합을 명시적으로 수행한 뒤, 모든 pending 상태를 정리하고 Fate를 선택해 다음 전투에 들어갈 수 있어야 한다.

---

## 4. Player Verbs & Decisions

| Verb | 입력/행동 | 핵심 판단 | 기대 피드백 |
|---|---|---|---|
| inspect | 아이템/가방 선택 | 이 물건이 현재 빌드에 왜 필요한가 | 크기, 효과, 시너지, 조합 힌트 |
| move | drag 또는 pick/move/place | 이 위치가 더 좋은가 | footprint preview, valid/invalid |
| rotate | 90도 회전 | 공간을 더 잘 쓰거나 인접을 만들 수 있는가 | 회전 footprint와 결과 preview |
| translate layout | `전체 이동 모드` → 방향 입력 | 전체 상대 배치를 보존한 채 보드 위치를 바꿀 필요가 있는가 | mode indicator + full-layout preview |
| expand | 가방 구매/배치 | GOLD를 공간에 투자할 가치가 있는가 | 활성 셀 증가와 연결성 |
| store | backpack↔buffer 이동 | 당장 비활성화하고 공간을 재구성할 것인가 | buffer 상태와 effect disabled 표시 |
| combine | 명시적 조합 액션 | 재료를 소비해 결과물로 바꿀 것인가 | result preview, 배치 성공 후 atomic commit |
| undo/redo | 배치 편집 복원 | 이전 배치가 더 나았는가 | history state |
| commit | Fate 선택 진입 | REST 정리가 완료됐는가 | commit checklist |

---

## 5. Entry / Exit / Cancel / Re-entry

| 구분 | 조건 | 처리 | 피드백 |
|---|---|---|---|
| Entry | 세그먼트 boss 처치 후 RESULT와 강제 boss reward 완료 | Persistent Workbench 진입 | 현재 backpack, buffer, chest, shop 상태 표시 |
| Exit | Fate commit checklist 전체 통과 + Fate 선택 | next preview/complete로 이동 | 확정 build preview와 Fate 요약 |
| Cancel move/rotate | preview 중 취소 | canonical placement 미변경 | 원위치 복귀 |
| Cancel layout mode | `전체 이동 모드` 중 취소/완료 | 일반 focus 탐색으로 복귀 | mode indicator 제거, focus 유지/복원 |
| Cancel combination | result placement 전 취소 | 재료 보존 | 조합 취소 표시 |
| Re-entry within REST | chest/shop/backpack/combination surface 왕복 | 같은 `RestBackpackSession` 유지 | 선택/포커스 문맥 복원 |

MVP-4는 새로운 save/load persistence 시스템을 만들지 않는다. 앱 종료/재실행 mid-REST 복구는 후속 범위다.

---

## 6. Player Flow

```text
COMBAT
→ ~3 min ELITE
   └─ kill → chest token
→ ~5 min SEGMENT BOSS
→ RESULT
→ BOSS_REWARD: 3 choose 1 (forced)
→ REST WORKBENCH
   ├─ inspect contribution summary
   ├─ open chest if any
   ├─ shop / reroll / buy bag or items
   ├─ move rewards through 6-slot buffer
   ├─ place / rotate bags and items
   ├─ optional `전체 이동 모드` → translate whole layout
   ├─ inspect adjacency / special-bag effects
   ├─ optional explicit combination
   └─ resolve pending states
→ FATE COMMIT CHECK
→ choose Fate
→ PREVIEW / COMPLETE
```

REST 안에서는 chest/shop/backpack/combination의 순서를 강제하지 않는다. 보스 보상만 REST 진입 전에 강제한다.

---

## 7. State & Rules

### Primary states

| State | 의미 | authority |
|---|---|---|
| `BackpackState` | bag/item instance, coordinate, rotation, board occupancy source | runtime domain |
| `RestBackpackSession` | buffer, preview, edit history, pending combination/bag, input edit mode | REST edit domain |
| `BuildPreviewSnapshot` | 현재 REST 편집 결과의 예상 modifier | derived, non-authoritative |
| `RunBuildState` | GOLD, school, Fate, committed combat modifier composition | run domain |

### Core rules

1. Board는 `6x6` 고정이다.
2. 시작 활성 셀은 기본 bag의 `4x3` 영역이다.
3. 새 bag은 기존 활성 영역과 직교 연결되어야 하며 전체 활성 셀은 하나의 4-neighbor component를 유지한다.
4. bag끼리는 겹치지 않는다.
5. item은 활성 셀 위에만 존재할 수 있다.
6. bag/item은 90도 회전한다.
7. 일반 item은 MVP-4에서 직사각형 중심이며 bag 일부만 L/T 형태를 허용한다.
8. item adjacency는 직교 edge 공유만 인정한다.
9. 같은 pair/same synergy는 접촉 edge 수와 무관하게 1회다.
10. special bag은 item이 1칸만 overlap해도 효과 1회; 서로 다른 bag instance는 각각 적용 가능하다.
11. buffer item은 모든 전투/인접/special-bag/combination 효과가 비활성이다.
12. combat 진입 전 buffer는 0이어야 한다.
13. whole-layout translation은 상대 배치를 유지한 채 1칸 이동하며 하나라도 불법이면 전체 취소한다.
14. keyboard/gamepad에서는 `전체 이동 모드`가 활성화된 동안에만 방향키/D-pad가 Rule 13을 수행한다. 그 외 방향 입력은 focus/선택 셀 탐색용이다. 두 의미는 동시에 활성화되지 않는다.
15. touch에서는 명시적 `전체 이동` 액션 뒤 화면 방향 컨트롤로 Rule 13을 수행한다.
16. combination은 실제 backpack에 유효 배치된 두 재료의 직교 인접 + explicit action을 요구한다.
17. combination 재료는 result placement 성공 시에만 atomic consume한다.

---

## 8. Input → Processing → Output

| Input | validation | processing | Output | failure behavior |
|---|---|---|---|---|
| move item/bag | target footprint legal | resolver preview → session commit | new placement + preview snapshot | canonical state unchanged + reason |
| rotate | rotated footprint legal | resolver preview | rotated placement | unchanged + invalid cells |
| enter layout mode | no incompatible modal/transaction | session input-mode switch | visible `전체 이동 모드` | stay in normal focus mode |
| whole translate | layout mode active + all bags/items legal after offset | one atomic translation | translated layout | all-or-nothing cancel; mode remains visible |
| exit layout mode | layout mode active | session input-mode switch | normal focus/navigation restored | no domain mutation |
| open chest | token exists + buffer free slots ≥2 | seeded reward roll | 2 items to buffer | no token consume |
| buy item | offer valid + GOLD + limits + buffer capacity | transaction | GOLD spend + item to buffer | no partial spend |
| buy bag | bag offer valid + GOLD + rest bag cap | pending bag acquisition | bag available for placement | no partial spend |
| combine | eligible pair + result preview placement valid | atomic consume/create | result instance placed | originals preserved |
| Fate enter | commit checklist all pass | session finalize | Fate selection surface | failed checklist item linked |

UI는 이 규칙을 재계산하지 않고 resolver/session의 결과를 표시한다.

---

## 9. Feedback — UI / VFX / Animation / Audio / Haptics

### Persistent Workbench layout

- Windows: central board + surrounding rail/panel.
- Android: central board + bottom sheet / short tabs for secondary surfaces.
- backpack board는 REST의 시각 중심에서 사라지지 않는다.

### Information layers

1. Always: board, active/inactive cells, buffer count, GOLD, chest count, Fate commit readiness.
2. Selected: name, footprint, rotation, effect, current synergies, special-bag effects, hint stage.
3. Preview: target footprint, valid/invalid, adjacency changes, special-bag overlap, combination possibility, modifier delta.
4. Input mode: `전체 이동 모드`가 활성화되면 방향 입력의 의미가 바뀌었다는 label/icon/border와 종료 방법을 보인다.
5. Irreversible action: explicit result/cost and cancel boundary.

### State channels

- valid/invalid를 색 하나에 의존하지 않는다.
- outline + icon + short text를 병행한다.
- invalid reason은 `out of board / inactive cell / collision / bag disconnect` 중 실제 원인을 표시한다.
- adjacency는 관련 두 item과 접촉 edge를 강조한다.
- special-bag effect는 bag region과 affected item을 함께 표시한다.
- combination 가능 상태는 pair를 강조하고 action을 노출하되 자동 실행하지 않는다.
- `전체 이동 모드`는 일반 focus 탐색과 다른 시각 상태를 반드시 가진다.

Animation/audio/haptic은 정보 전달을 보조하며 transaction authority가 아니다. 중단되거나 mute/reduced-motion이어도 결과가 바뀌지 않는다.

---

## 10. Success / Failure / Recovery

| Outcome | 조건 | 결과 | Recovery |
|---|---|---|---|
| placement success | footprint/legal connection pass | canonical placement commit | Undo 가능 |
| placement failure | rule 위반 | 상태 미변경 | 문제 셀/원인 수정 후 재시도 |
| layout translation success | mode active + all shifted placements valid | whole layout commits atomically | Undo 가능 |
| layout translation failure | any shifted placement invalid | entire layout unchanged | 다른 방향/배치 후 재시도 |
| combination success | result placement valid | originals consumed + result placed atomically | 완료 조합은 Undo 대상 아님 |
| combination cancel/failure | preview 취소 또는 invalid | originals remain | 위치 변경/공간 확보 후 재시도 |
| chest blocked | buffer free <2 | token 유지 | buffer 비우기 |
| Fate blocked | checklist fail | REST 유지 | 실패 항목 바로가기 |

---

## 11. Edge Cases

| Edge | 기대 규칙 |
|---|---|
| GOLD 부족 | 구매/리롤 전 차단, GOLD 미변경 |
| 빠른 연타/중복 click | transaction 1회만 처리 |
| 방향 입력 의미 충돌 | normal state는 focus/셀 탐색, `전체 이동 모드`는 layout translation; 동시 처리 금지 |
| layout mode 중 modal/panel 진입 | mode를 명시 종료하거나 해당 이동 입력을 잠금; hidden mode 지속 금지 |
| drag 중 panel 전환 | preview 취소 또는 안정적으로 같은 session으로 복귀; half-commit 금지 |
| bag 이동이 overlap item을 포함 | 해당 bag과 overlap한 item만 이동 candidate, 다른 bag 연쇄 이동 금지 |
| item이 여러 special bag overlap | 각 bag instance 효과 1회씩 |
| square item rotation | footprint 동일해도 orientation command는 안전하게 처리, 중복 state pollution 금지 |
| disconnected bag result | preview invalid, canonical state 유지 |
| combination result 공간 없음 | originals 보존 |
| chest 1 token / buffer 1 slot | open 불가, token 유지 |
| UI snapshot stale | action 실행 시 domain state 재검증; stale UI만 믿지 않음 |
| REST 종료 직전 pending transaction | Fate blocked |
| save/load | MVP-4 새 persistence 범위 아님; 미지원 상태를 성공으로 주장하지 않음 |

---

## 12. Data & Balance

### Geometry constants

| 값 | 상태 |
|---|---|
| board | `6x6` CONFIRMED |
| start active area | `4x3` CONFIRMED |
| work buffer | `6 slots` CONFIRMED |
| rotations | 90° CONFIRMED |

### Base effect budget — RECOMMENDED_DEFAULT

| occupied cells | budget |
|---:|---:|
| 1 | 1.0 |
| 2 | 2.1 |
| 3 | 3.3 |
| 4 | 4.6 |
| 6 | 7.2 |

- combination result premium: approximately `+12%` over source total as initial recommended value.
- special-bag auxiliary effect: approximately `0.4~0.6` budget.
- these are tuning defaults, not immutable core rules; player-feel/balance evidence may retune them without changing geometry semantics.

### Acquisition defaults

- Boss reward: 3 options → choose 1; at least one current-school-related candidate.
- Shop: 3 normal item offers + 1 bag offer.
- Reroll: 5G → 10G → 15G.
- Recommended bag purchase cap: 1 per REST.
- Chest: 1 token → 2 random items, both to buffer.

---

## 13. UX/UI & Accessibility

### Input contract

- Mouse: drag/drop + click select.
- Keyboard/gamepad normal mode: predictable focus/selected-cell navigation → pick/select → cell movement → place; rotate/cancel actions.
- Keyboard/gamepad layout mode: a visible `전체 이동` action enters a mutually exclusive mode; while active, arrows/D-pad translate the entire layout. Exit/cancel restores normal focus navigation immediately.
- Touch: tap-select → tap-place is a complete path; drag is optional convenience. Whole-layout translation uses an explicit `전체 이동` action plus visible directional controls.
- long-press, hover, precision drag alone cannot gate a required action.
- rotate/whole-layout move/Undo/Redo/combine/cancel have visible controls; keyboard shortcuts are additive.

### Focus

Godot `Control` focus neighbors should be explicit for workbench-critical paths rather than relying only on nearest-control heuristics. Modal/bottom-sheet close returns to the previous meaningful focus target. A hidden `전체 이동 모드` may not survive modal/sheet transitions.

### Touch

Interactive controls should target at least approximately `48dp x 48dp` on Android; the visual icon may be smaller if the hit area is larger.

### Accessibility fallbacks

| 정보 | primary | fallback |
|---|---|---|
| valid/invalid | color | outline + icon + text |
| focus | highlight | border/shape + stable focus order |
| layout input mode | mode label/border | explicit text + exit control |
| success/error | animation/audio | persistent text/state |
| recipe relation | line/highlight | pair labels + hint text |
| drag | pointer/touch drag | select→move/place actions |

---

## 14. Art / Audio / Narrative Dependencies

MVP-4 기능 검증은 placeholder/card/text UI로 가능하다. 최종 icon art, VFX, audio polish는 blocker가 아니다.

Required minimum visual assets:

- distinguishable item/bag cards or placeholders,
- active/inactive/invalid cell states,
- selection/focus/preview/input-mode states,
- combination/hint icon or textual fallback.

---

## 15. Technical / Platform / Save Constraints

- Engine: Godot 4.x / GDScript.
- Domain rules must not live inside `RestFlowUI`.
- `BackpackResolver` is deterministic and UI-independent.
- reward candidate RNG must be seedable/injectable for tests.
- actual combat modifiers are not continuously mutated during REST; use preview snapshot until commit.
- MVP-4 does not add a new save system.
- Windows and Android UX share domain semantics but may use different layout adapters.
- The provided Godot `gui_multiple_resolutions` reference demonstrates Full Rect controls, aspect-ratio constraints, `canvas_items` stretching and `expand` behavior across resolutions. Treat it as a **TEST/REFERENCE**, not a mandate for one base resolution or stretch configuration.
- Workbench QA must exercise narrow/wide desktop windows and the declared Android orientation/layout; exact project base resolution and stretch settings remain implementation-plan decisions constrained by existing project settings and actual device evidence.

---

## 16. Content Production Pipeline

```text
ItemDefinition / BagDefinition / combination data
→ schema/rule validation
→ deterministic resolver test
→ catalog registration
→ Workbench preview
→ runtime commit
→ QA sample
```

Invalid footprint, missing id, impossible bag shape, unresolved combination reference, or missing effect payload must fail closed in authoring/test validation rather than entering runtime silently.

---

## 17. Benchmark Decision

Access date: 2026-08-11.

| Evidence | 관찰 | 한계 | Decision | Ninja Survival 적용 |
|---|---|---|---|---|
| Backpack Battles Steam official page | 구매뿐 아니라 배치와 shape/size, combination을 핵심 build decision으로 설명 | marketing description, usability study 아님 | ADAPT | board를 REST의 지속 중심으로 유지 |
| Backpack Hero Steam official page | item placement가 성능에 큰 영향을 주는 inventory-management identity | turn-based 구조라 전투 리듬이 다름 | ADAPT | 공간을 단순 수납이 아니라 전투 성능 판단으로 연결 |
| God of Weapons Steam official page | 제한 inventory에서 무기/장신구 정리가 생존 전략의 핵심 | 3D action pacing, system details differ | ADAPT | 제한 공간 tradeoff를 유지하되 REST로 전투와 관리 분리 |
| Godot 4.7 Control docs | focus neighbor, drag/drop, accessibility drag 경로를 제공 | engine primitive이지 UX 답 자체는 아님 | ADOPT | pointer + keyboard/gamepad/touch 동등 경로 설계, directional input mode 충돌 회피 |
| Microsoft XAG 112/113 | UI navigation consistency와 predictable/visible focus 권장 | Xbox guideline, Android 전용 규칙 아님 | ADAPT | focus 순서와 현재 focus, 입력 mode를 명확히 표시 |
| Android general app accessibility guidance | interactive touch target을 최소 48dp x 48dp로 권장 | 실제 게임 device/layout QA를 대신하지 않음 | ADOPT | touch control hit area 최소 기준으로 사용 |
| provided Godot multiple-resolutions demo | Full Rect, aspect constraints, stretch mode/aspect를 조합해 다양한 화면을 테스트 | demo 설정을 프로젝트에 그대로 복사하면 안 됨 | TEST | central board와 주변 panels의 aspect-ratio 회귀 QA에 사용 |

Reference URLs:

- https://store.steampowered.com/app/2427700/Backpack_Battles/
- https://store.steampowered.com/app/1970580/Backpack_Hero/
- https://store.steampowered.com/app/2342950/God_Of_Weapons/
- https://docs.godotengine.org/en/4.7/classes/class_control.html
- https://docs.godotengine.org/en/4.7/tutorials/inputs/controllers_gamepads_joysticks.html
- https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/112
- https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/113
- https://developer.android.com/guide/topics/ui/accessibility/apps.html

No benchmark UI, icon, brand expression, recipe, balance table, or content is copied directly.

---

## 18. Risk & Prototype

### Highest-risk hypothesis

```yaml
hypothesis_id: MVP4-RISK-01
claim: Persistent Workbench spatial editing is deep enough to feel strategic but fast enough not to break the combat-rest rhythm.
why_it_can_kill_the_feature: if editing is tedious or unreadable, the project's core differentiator becomes inventory chores.
cheapest_test: implemented MVP-4 rest slice with one boss reward, one chest, one shop cycle, representative bags/items/combinations; observe first-time players.
success_signal: player can explain why a placement changed the build and complete one REST without repeated confusion.
stop_signal: repeated inability to identify legal placement/commit blockers, or management time dominates desire to re-enter combat.
result: BLOCKED_UNVERIFIED_UNTIL_MVP4_BUILD
```

### Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| visual noise from many overlays | high | contextual layers, not all highlights at once |
| directional input ambiguity | high | explicit mutually exclusive `전체 이동 모드` |
| drag-only input barrier | high | complete select/place + focus path |
| recipe hints spoil discovery | medium | progressive hint states |
| state desync / partial transactions | high | resolver authority + atomic commits |
| REST fatigue | high | persistent board, limited offers, summary-first, human timing observation |
| mobile density | high | bottom-sheet adapter, touch targets, real-device QA |
| old documentation resurrects excluded rules | medium | canonical freshness pass before implementation handoff |

---

## 19. Acceptance Criteria

- **AC-01 Placement:** Given an item is selected, when the player previews a legal target, then the exact footprint and resulting relationships are shown before commit; illegal targets do not mutate canonical state.
- **AC-02 Rotation:** Given a non-square item/bag, when rotated 90°, then footprint, legality and relationship preview update consistently; invalid rotation cancels without partial state.
- **AC-03 Connectivity:** Given multiple bags, when an operation would split active cells into disconnected components, then it is rejected with a visible connectivity reason.
- **AC-04 Adjacency:** Given two valid items share an orthogonal edge, then the pair synergy applies once; diagonal-only contact does not apply it.
- **AC-05 Special bag:** Given one item overlaps one cell of a special bag, then that bag effect applies once; multiple distinct special bags may each apply once.
- **AC-06 Buffer:** Given an item is in the work buffer, then it contributes no combat/synergy/combination effect; Fate cannot be entered while buffer count >0.
- **AC-07 Chest:** Given a chest token and fewer than 2 free buffer slots, opening is blocked and the token remains.
- **AC-08 Shop:** Given a valid purchase, then purchased content enters the workbench flow rather than immediately changing combat runtime modifiers.
- **AC-09 Combination:** Given eligible adjacent ingredients, when combine is chosen, then result placement is previewed and originals are consumed only after a legal result placement succeeds.
- **AC-10 Undo boundary:** Placement edits can Undo/Redo; irreversible economy/reward/combination/Fate actions do not enter placement history.
- **AC-11 Commit:** Fate entry is enabled only when the complete REST checklist is satisfied and failed items give a usable recovery path.
- **AC-12 Input parity:** Core REST completion is possible by Windows mouse+keyboard, Windows gamepad, and Android touch without requiring hover/precision-drag-only behavior.
- **AC-13 Determinism:** With the same seed and state, resolver and reward candidate tests produce the same result.
- **AC-14 Duplicate guard:** Rapid duplicate activation of purchase/open/combine/commit produces at most one domain transaction.
- **AC-15 Layout mode:** Given normal keyboard/gamepad focus navigation, when `전체 이동 모드` is explicitly entered, then the mode is visibly indicated and directional input translates the whole layout only; when the mode exits, the same directional input returns to focus/navigation behavior without an accidental layout move.

---

## 20. Telemetry / Playtest Observation Plan

| Question | Observation | Success signal | Rethink signal |
|---|---|---|---|
| 공간 규칙을 이해하는가 | invalid placement 후 다음 행동 | reason을 이해하고 스스로 복구 | 같은 오류 반복 |
| 방향 입력 의미를 이해하는가 | focus 탐색 ↔ 전체 이동 mode 전환 | mode를 말로 설명하고 오조작 없이 복귀 | 의도치 않은 layout 이동 반복 |
| 배치가 전략으로 느껴지는가 | item 선택 전/후 설명 | 위치/인접/공간 tradeoff를 말함 | 단순 최고수치 선택만 함 |
| 조합 힌트가 적절한가 | first recipe discovery | 힌트로 시도하되 결과를 미리 다 알지 않음 | 전혀 못 찾거나 즉시 스포일러 |
| REST가 피곤한가 | REST 체류·망설임·다음 전투 기대 | 정리 후 바로 전투 검증 욕구 | 관리 포기/자동정리 요구 |
| 입력 경로가 완결되는가 | mouse/gamepad/touch task | 각 경로로 같은 핵심 목표 달성 | 특정 기능이 drag/hover에 묶임 |

실제 수치 목표는 first implementation playtest 전에 임의로 성공값을 고정하지 않는다.

---

## 21. Cut-down / Rollback

Cut-down 우선순위:

1. 장식성 motion/audio/haptic을 줄인다 — 핵심 spatial decision 보존.
2. 보조 상세 패널의 정보량을 줄인다 — board + legality + synergy + commit state 보존.
3. MVP-4 대표 content 수를 줄인다 — geometry/transaction/combination contract 보존.
4. L/T bag 종류 수를 줄인다 — 최소 1개 대표 non-rectangular bag은 유지.

다음은 cut-down 대상이 아니다: 6x6 board, 4x3 start, 90° rotation, orthogonal adjacency, work buffer gate, explicit atomic combination, Persistent Workbench decision, unambiguous whole-layout translation.

Rollback은 MVP-3 `RESULT → SHOP → FATE → PREVIEW` runtime baseline을 안전 기준으로 삼되, MVP-4 branch가 통합되기 전까지는 MVP-3 main 동작을 변경하지 않는다.

---

## 22. Open Decisions

| Decision | 상태 | 처리 |
|---|---|---|
| Persistent Workbench layout | CONFIRMED — DEC-2026-08-11-001 | A안 적용 |
| whole-layout directional input conflict | RECOMMENDED_DEFAULT_RESOLVED | explicit mutually exclusive `전체 이동 모드` |
| exact UI spacing/theme/art | RECOMMENDED_DEFAULT / later polish | 기능 검증 후 조정 |
| effect-budget numeric tuning | RECOMMENDED_DEFAULT | playtest 후 retune 가능 |
| exact REST time target | HYPOTHESIS / HUMAN_NOT_RUN | 첫 MVP-4 human QA에서 측정 |
| Google Sheet stale rows | BLOCKED_USER_ACTION | write permission 확보 후 GitHub canon 기준 동기화 |
| new core/economy/acquisition/combo tier | USER_DECISION_REQUIRED if proposed | 현재 범위에 없음 |

No unresolved user-only design decision remains inside the approved MVP-4 design. Production BUILD is still gated by the project instruction's explicit `기획 완료` transition, not by another written-spec decision.

---

## 23. Handoff to Traceability

Written-spec review was approved by the user on 2026-08-11. The next planning layer is therefore authorized and uses:

- `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`
- `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`

Implementation handoff must track:

- rule/acceptance IDs above,
- `BackpackState`, `BackpackResolver`, `RestBackpackSession`, `BuildPreviewSnapshot` responsibilities,
- existing `RunBuildState`, `ShopController`, `StageFlowController`, `RestFlowUI`, `MainController` integration hotspots,
- deterministic GUT tests,
- Windows/Android human QA gaps.

This approval does not itself start production code. The project remains in planning until the user explicitly declares `기획 완료`.

---

## Final adversarial self-review

- Placeholder/TBD/TODO: none.
- Product authority vs implementation state: separated.
- UI does not own domain rules: preserved.
- MVP-3 current runtime vs MVP-4 target behavior: explicitly separated.
- Board/rotation/connectivity/adjacency/special-bag rules: internally consistent.
- Buffer and combination atomicity: failure paths preserve canonical state.
- Mouse/keyboard/gamepad/touch: complete core paths declared.
- Directional-input collision: resolved through explicit mutually exclusive `전체 이동 모드` with visible state and regression criteria.
- Color/audio/motion-only information: prohibited.
- Save/load: explicitly out of MVP-4 rather than silently assumed.
- Android touch-target evidence: upgraded from Wear-only material to general Android app accessibility guidance.
- Provided multiple-resolutions demo: used only as layout QA/reference; no base-resolution/stretch setting copied into canon.
- Benchmark evidence: adapted, not copied; limitations recorded.
- Human evidence: remains `HUMAN_NOT_RUN` / `BLOCKED_UNVERIFIED` until a build exists.
- No new core system, economy axis, acquisition source, or deeper combination tier introduced during continuous-work defaults.

Result: `SPEC_APPROVED / IMPLEMENTATION_NOT_STARTED / PENDING_EXPLICIT_기획_완료`.