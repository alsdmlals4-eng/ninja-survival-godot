# Phase 2 — 네 유파 Circuit Definition of Ready

```yaml
package: NINJA_FOUR_SCHOOL_CIRCUIT_V1
status: READY_FOR_USER_IMPLEMENTATION_CONTRACT_APPROVAL
issue: 126
assessed_main: 50fbf203ec3f71af1633a5b6cc74e7167c0604c8
human_player_gate: DEFERRED_BY_DEC036_NOT_RUN
implementation_started: false
```

## Verdict

**기획/정본 측면에서는 구현계약 승인 대기 상태다.** 사용자 승인 전에는 Godot production code, production asset batch, Final Binding package를 시작하지 않는다.

이 verdict는 four-school run이 구현됐거나 사람이 재미있다고 검증됐다는 뜻이 아니다. 현재 main의 T12~T16은 보호할 machine baseline이며, 이 계약은 그 위의 다음 package를 정의한다.

## Ready checklist

| 항목 | 판정 | 근거 / 처리 |
| --- | --- | --- |
| player promise와 대표 행동 | `READY` | 이동/군집/근접/위협우선/공간배치/route-Fate 결정이 고정됐다. |
| four-school scope | `READY` | DEC-029와 contract §4가 shared chassis와 유파별 composition을 명시한다. |
| final package boundary | `READY` | DEC-030: fourth Boss `final_binding_eligible`까지. |
| Trace purpose | `READY` | in-world pickup, Elite gate, no combat/G reward로 명시했다. |
| Workbench ownership | `READY` | reward → buffer → spatial layout → Fate/route → atomic commit의 domain boundary가 고정됐다. |
| combat information grammar | `READY` | icon-first + recently-hit enemy one HP bar + Korean help path가 고정됐다. |
| economy/retry meaning | `READY` | DEC-033과 contract §7에 source, checkpoint, idempotency, true-end boundary가 있다. |
| tuned starting values | `READY_WITH_TUNE_RECOMMENDATION` | Cheonsul seal과 recent-hit HP duration은 data defaults이며 silent code tuning을 금지한다. |
| human/player evidence | `DEFERRED_NOT_RUN` | DEC-036: current implementation gate는 막지 않지만 PASS도 아니다. |
| Final Binding/final calamity | `OUT_OF_SCOPE` | 별도 review package가 필요하다. |
| production assets | `OUT_OF_SCOPE` | existing consumers와 Godot UI/procedural presentation을 우선 사용한다. |

## Feasibility and reuse check

- existing reuse: `StageEncounterState`, `RunRouteState`, `RestBackpackSession`, `CombinationResolver`, `RestCommitCoordinator`, `RunBuildState`, `EncounterCatalog`, `SchoolRuntimeHost`, `RestFlowUI`.
- necessary additions only: school-neutral circuit coordinator, Trace pickup presenter, status/HP presenters, economy policy, wallet/checkpoint/settlement ledger.
- prohibited duplication: four school-specific MainControllers, UI-owned rule mutation, second wave system, separate combat modifier authority, broad meta-power framework.
- zero-cost path: Godot/GDScript, existing GUT and existing CI/internal-build workflow; no paid service/API/SaaS is introduced.

## Machine QA plan

| class | required proof | ceiling |
| --- | --- | --- |
| unit/domain | invariants, data policy, atomic failures, idempotency | no on-screen readability |
| integration | ordered/all-order four-school lifecycle and Workbench input intents | no human comprehension |
| import/parse/smoke | project loads and main scene survives automated startup | no visual UX/fun |
| CI/internal build | exact PR-head repeatability and Windows internal artifact | no device/export certification |
| adversarial review | five whole-state loops, only validated findings corrected | no Player Experience PASS |

Godot's headless execution disables rendering/window functions, so it is deliberately not counted as a visual or player-input review. The implementation still needs non-headless evidence if it later claims those outcomes. [Godot DisplayServer](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)

## Dependency order

```text
shared lifecycle/data
-> Trace + telegraph + combat information
-> Boss reward / spatial Workbench
-> economy + checkpoint / retry
-> four-school circuit integration
-> machine regression + adversarial review
-> later: Human/player or release evaluation, then Final Binding package
```

## Risks and mitigations

| risk | early control | revisit condition |
| --- | --- | --- |
| four schools become four engines | one circuit controller and data composition tests | school code adds route/economy/Backpack ownership |
| Workbench UI bypasses atomic domain rules | UI intents plus coordinator-only commit tests | any direct UI state write |
| deferred human review is mistaken for pass | DEC-036 labels in all receipts | player-facing release claim |
| Ninja Soul duplicates/erases value during retry | wallet/ledger/checkpoint separation and idempotency tests | true settlement package begins |
| visual grammar is lost in VFX density | semantic presenters, palette ownership, no text badges | screen capture or visual review reveals ambiguity |

## Required authorization after this review

The user must approve `docs/implementation/2026-08-29-four-school-circuit-implementation-contract.md` before Godot production implementation begins. No additional product-meaning Grill Me question is currently required.
