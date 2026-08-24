# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-25 KST
reactivation_reason: USER_APPROVED_PLANNING_CANON_AND_HUMAN_HOME_ALIGNMENT
completed_main_at_reactivation: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
completed_main_label: T11_TRADITION_ACCESS_REWARD_LANES
resume_state: T11_MERGED_T12_NOT_MERGED
next_product_gate: T12_FRESH_ATOMIC_WORKBENCH_FATE_ROUTE_PACKAGE
latest_docs_alignment_plan: docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md
historical_closed_wip:
  - PR_43_T12_ATOMIC_WORKBENCH
  - PR_44_FRONT_DOOR_DOCS
mvp0_to_mvp3_runtime: INTEGRATED_BASELINE
mvp4_t01_to_t11_domain_chain: INTEGRATED_ON_COMPLETED_MAIN
playable_new_four_school_run: NOT_PROVEN
persistent_workbench_route_ui_input: NOT_INTEGRATED
release_near_cheonsul_slice: NOT_RUN
human_usability: NOT_RUN
player_experience: NOT_RUN
device_export_android: NOT_RUN
current_visual_style: USER_APPROVED_FIRST_IMAGE_2026_08_25
visual_binary_notion_attachment: BLOCKED_TOOL_SURFACE_UNTIL_ACTUAL_UPLOAD_READBACK
local_shared_godot_exact_pin: UNKNOWN_UNVERIFIED_IN_DOCS_ALIGNMENT
local_editor_session: NOT_RUN_NOT_REQUIRED_FOR_DOCS_ALIGNMENT
```

## Purpose

This is the mutable resume router. Product rules live in `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated canon files. Implementation facts live in actual code/scenes/data/tests and executed evidence. Human-facing game understanding lives in the exact Notion Human Home and its domain pages.

Do not reconstruct current state from older handoff sentences or closed branches without first reading current completed `main` and this router.

## Current read order

1. `AGENTS.md`
2. latest user instruction / active task contract
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md`
5. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
6. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
7. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
8. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
9. actual `scripts/`, `scenes/`, `data/`, `tests/`, workflows
10. Notion `닌자 서바이벌 · Home`, `03 · UI · 생존 Flow Map`, `08 · 핵심 시스템 · 상세`, `06 · Production · Handoff`, Visual Bible
11. current Base owners when Base freshness materially affects the task

Closed PR #43/#44 may be inspected only as historical/WIP evidence. They are not resume baselines.

## Current product direction

`닌자의 신 / 닌자 서바이벌` is a 2D survival roguelike where the player:

```text
starts from one ninja school
-> freely chooses among unvisited school battlefields
-> learns that school's Core/Elite/Boss encounter language
-> recovers its trace and opens tradition acquisition access
-> returns to the shared frontier branch
-> rebuilds a 6x6 spatial backpack through reward/shop/chest/rotation/adjacency/combination
-> provisionally chooses the next school
-> commits build + Fate + route together
-> clears all four schools exactly once
-> enters Final Binding Workbench
-> defeats the separate calamity core with the player-built backpack power
-> receives final result / Ninja Soul / legend callback
```

`~20 minutes` targets active combat through the fourth school Boss, not the whole Run.

## Current four-school identity

- **봉마류:** mobile stronghold — prepare space, familiars/barriers fight for you.
- **천술류:** setup + ordered elemental/status reactions transform the field.
- **귀인류:** sustain dangerous close-range presence for power; not universally low-HP-only.
- **흑영류:** mark/priority/execution removes dangerous targets first through auto-combat-compatible indirect control.

## Current integrated implementation truth

### MVP-0~3

Integrated and retained as rollback/regression baselines where newer behavior has not deliberately replaced them.

### T01~T05

Integrated spatial foundation:

- definitions/catalog
- committed `BackpackState`
- deterministic `BackpackResolver`
- REST `RestBackpackSession`
- atomic first-tier `CombinationResolver`

### T06

Committed spatial modifier snapshot became the single item/spatial combat modifier authority without legacy double application.

### T07

Boss/Shop/Chest acquisition transactions route acquired items/bags through bounded spatial REST transaction ownership.

### T08

`RunRouteState` owns provisional/active/cleared schools, Stage 1..4 progression and clear order; revisits are rejected and fourth clear leads to Final Binding eligibility.

### T09

Four-school encounter definitions and shared Stage profiles are data/domain integrated, including bounded DEC-026 primitive vocabulary and Cheonsul first-slice data.

### T10

Elite warning/active -> chest token + non-expiring trace -> trace recovery -> Boss warning/dual gate -> Boss active/clear lifecycle is domain integrated.

### T11

Run-level tradition access and reward lanes are integrated over the existing canonical 19 base-acquisition item IDs:

- Universal 7 + school package 3 x 4 authoring model
- starting-school access
- stabilization opens package
- Boss continuity / newly liberated tradition / bridge-universal lanes
- Shop/Chest lane-first selection
- canonical item-ID dedupe

T11 exact merged evidence recorded in Production Handoff:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 447/447 -> 4985 assertions -> T11 core 9/9 + adversarial 8/8 + clean re-attack 5/5`.

Evidence ceiling: domain/automated scope only.

## T12 current status

**NOT_MERGED / NOT_COMPLETED.**

PR #43 was intentionally closed-unmerged during the 2026-08-25 pause. Its branch contains potentially reusable implementation/test findings but is historical WIP only.

Current approved T12 outcome remains:

- Workbench route stays provisional until commit.
- finalized backpack snapshot + one pending Fate + one provisional unvisited school commit all-or-none.
- validation failure mutates none of committed backpack/Fate/route state.
- success commits once; duplicate commit is rejected.
- UI/MainController migration remains T13 unless a current test proves a smaller integration necessity.

When T12 resumes, create a fresh current-task branch from then-current completed main and re-evaluate #43 rather than reviving it.

## 2026-08-25 planning/documentation alignment

User approved `Planning Canon & Human Home Alignment`.

This alignment package defines the durable project front door after T11:

- active repository routers state T11 merged / T12 fresh next,
- T05/T06 stale resume routing is removed,
- #43/#44 remain closed historical WIP,
- Human Home is a self-contained game-flow/system/learning projection,
- raw implementation receipts remain in System/Production surfaces,
- current approved visual style is recorded without further image generation.

Implementation/decision locator:

`docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md`.

After this alignment is merged, it should be treated as completed front-door history; `next_product_gate` remains the current router for future work.

## Notion authority / Human Home

Human Home purpose:

`30-second promise -> full Run Flow -> four schools -> backpack/combination/Fate core data -> world/final goal -> approved visual direction -> AI interpretation -> edit guide -> compact evidence ceiling -> drilldown`.

Raw SHA, full PR/CI history, local path/ports/tool routing and detailed Txx receipts stay in Project Registry/System and `06 · Production · Handoff`.

## Visual decision — 2026-08-25

User approved the **first image in the approval turn** as the current master art-style reference.

Traits:

- dark moonlit ninja fantasy
- premium painterly anime illustration
- ink / brush / Korean calligraphy framing
- black / deep navy / red / warm gold core palette
- strong readable silhouette
- restrained readable VFX
- school accents: 봉마 gold, 천술 blue/orange elemental, 귀인 red, 흑영 purple/black

Dense parchment infographic layouts are supporting explanation surfaces, not the master gameplay art style.

No further image generation unless explicitly requested.

The approved chat image is **not yet a durable Notion attachment** because the current connector surface does not expose a verified local-binary upload path. Do not claim upload/attachment completion until actual attach + readback succeeds.

## Local/toolchain evidence ceiling

This planning/documentation alignment does not require Godot authoring/runtime, so local Editor/session startup is not forced.

Historical Project Registry values for dedicated executable/ports are not current execution authority. The current shared-host Base policy must be applied only after a fresh local readback in a future Godot task.

For this alignment:

```text
LOCAL_SYNC: NOT_RUN
GODOT_RUN: NOT_RUN_NOT_REQUIRED
GODOT_EDITOR_SESSION: NOT_RUN_NOT_REQUIRED
HUMAN_PLAY: NOT_RUN
DEVICE_EXPORT: NOT_RUN
```

## Remaining product sequence

```text
T12 fresh atomic Workbench/Fate/route package
-> T13 Persistent Workbench route-preview UI/input
-> T14 Cheonsul release-near Vertical Slice
-> T15 Human QA gate
-> T16 remaining schools
-> T17 four-school circuit integration
-> T18 final calamity package
-> T19 full-run verification
```

Do not skip T15 and multiply four-school content before representative Human evidence closes the shared-chassis risks.