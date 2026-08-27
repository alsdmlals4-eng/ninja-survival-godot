# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-27 KST
reactivation_reason: USER_APPROVED_PLANNING_CANON_AND_HUMAN_HOME_ALIGNMENT
completed_main_at_reactivation: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
current_completed_main: 03005e7dcc1a2e0b6ee57b4f6ebed9b481ee2fbc
current_completed_main_resolution: POST_MERGE_RUNTIME_BASELINE_PR_84_2026_08_27_KST
completed_main_label: IMG_02_RUNTIME_VISUAL_CORE
resume_state: IMG_02_MERGED_MACHINE_VERIFIED_HUMAN_QA_DEFERRED_BY_CURRENT_USER
next_product_gate: USER_VERTICAL_SLICE_VALIDATION
latest_docs_alignment_plan: docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md
current_visual_handoff: docs/CURRENT_VISUAL_HANDOFF.md
historical_closed_wip:
  - PR_43_T12_ATOMIC_WORKBENCH
  - PR_44_FRONT_DOOR_DOCS
other_workstream_read_only:
  - PR_49_T12_ATOMIC_WORKBENCH_FATE_ROUTE_COMMIT_SUPERSEDED_BY_PR_61
mvp0_to_mvp3_runtime: INTEGRATED_BASELINE
mvp4_t01_to_t11_domain_chain: INTEGRATED_ON_COMPLETED_MAIN
playable_new_four_school_run: NOT_PROVEN
persistent_workbench_route_ui_input: INTEGRATED_ON_MAIN_71152C7AA9DFF4CC05EEC76D4D2D70BE47755F6C
release_near_cheonsul_slice: MERGED_MAIN_51E39737F272DB0962A3DABADA51BAE10CD1FA97_AUTOMATED_EVIDENCE_ONLY
t15_school_function_help: MERGED_MAIN_E2CFE4452E1DE5A224F5CD7DEE8E47A104C868E0_MACHINE_VERIFIED_HUMAN_QA_DEFERRED_BY_CURRENT_USER
t16_in_combat_school_help: MERGED_MAIN_63FCF81FDF4B5D1BBFF14B5721A13F7C1AFE1497_MACHINE_VERIFIED_RUNTIME_INPUT_DELIVERED_HUD_MODAL_VISUAL_SEMANTICS_NOT_CONFIRMED
windows_internal_build: MERGED_MAIN_0F085FC4FEFF25353C049749BF34236A89C01BE4_CI_ARTIFACT_AND_LOCAL_EXPORT_RUNTIME_SMOKE_PASS
windows_internal_build_boundary: INTERNAL_VALIDATION_ONLY_NOT_PUBLIC_RELEASE_OR_DEVICE_EXPORT
human_usability: NOT_RUN
player_experience: NOT_RUN
device_export_android: NOT_RUN
current_visual_style: HYBRID_MASTER_PRESENTATION_INK_CODEx_GAMEPLAY_ANIME_SD_C_LEANING
runtime_character_visual_identity: ONE_FIXED_CHARACTER_PLUS_TRACE_LAYERS
trace_stage3_visual_rule: STARTING_MAIN_SCHOOL_ONLY
visual_keyvisual_notion_preview: SERVER_READBACK_PASS_LOW_RES
visual_supplementary_previews: SERVER_READBACK_PASS_LOW_RES_ONLY_ORIGINAL_AND_HUMAN_VISIBLE_NOT_PROVEN
img_02_runtime_visual_core: MERGED_MAIN_03005E7_SEVEN_APPROVED_PNGS_LOCAL_AND_NOTION_NATIVE_ORIGINALS
img_02_automated_evidence: GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_GUT_492_OF_492_5373_ASSERTIONS_PASS
img_02_live_render: NOT_RUN_HERA_CONNECTED_TO_DIFFERENT_PROJECT
img_03_runtime_battlefield_backdrop: MERGED_MAIN_5A52A30_LOCAL_AND_NOTION_NATIVE_ORIGINAL_SYNCED
img_03_automated_evidence: GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_GUT_493_OF_493_5380_ASSERTIONS_PASS
img_03_live_render: NOT_RUN_DESKTOP_VISUAL_TARGET_CHANGED
local_shared_godot_exact_pin: GODOT_4.7.1_STABLE_OFFICIAL_A13DA4FEB_FRESH_LOCAL_VERIFIED_2026_08_27_KST
local_editor_session: NOT_RUN_FOR_NINJA_SURVIVAL_VISUAL_PACKAGE
```

## Purpose

This is the mutable resume router. Product rules live in `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated canon files. Implementation facts live in actual code/scenes/data/tests and executed evidence. Human-facing game understanding lives in the exact Notion Human Home and its domain pages. Current visual continuation lives in `docs/CURRENT_VISUAL_HANDOFF.md` plus Notion `02 · 비주얼 바이블`.

Do not reconstruct current state from older handoff sentences or closed branches without first reading current completed `main`, current open-PR inventory and this router.

## Current read order

1. `AGENTS.md`
2. latest user instruction / active task contract
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/CURRENT_VISUAL_HANDOFF.md` when the task touches art / visual / asset / presentation
5. `docs/canon/2026-08-21-dec014-025-product-canon.md`
6. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
7. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
8. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
9. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
10. actual `scripts/`, `scenes/`, `data/`, `tests/`, workflows
11. Notion `닌자 서바이벌 · Home`, `03 · UI · 생존 Flow Map`, `08 · 핵심 시스템 · 상세`, `06 · Production · Handoff`, `02 · 비주얼 바이블`
12. current Base owners when Base freshness materially affects the task

Closed PR #43/#44 may be inspected only as historical/WIP evidence. They are not resume baselines. Draft PR #49 is a read-only, superseded T12 reference. PR #61 is merged T12 history; current production work begins from its completed `main`.

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

## T12 merged status

**MERGED TO `main` AT `41202283b75921efb7691e77c3de1502d77410d1`.**

PR #61 `T12: atomically commit Workbench snapshot, Fate, and route` is merged production history. Its post-merge automated evidence is `Godot 4.7.1 import PASS -> main-scene smoke PASS -> GUT 471/471 -> 5168 assertions`; this is not Human, Player Experience, device, or end-to-end Run evidence.

PR #49 `T12: atomic Workbench Fate route commit` and historical PR #43 remain read-only WIP/reference only. Do not reopen, rebase, merge or absorb either branch.

Current approved T12 outcome remains:

- Workbench route stays provisional until commit.
- finalized backpack snapshot + one pending Fate + one provisional unvisited school commit all-or-none.
- validation failure mutates none of committed backpack/Fate/route state.
- success commits once; duplicate commit is rejected.
- UI/MainController migration remains T13 unless a current test proves a smaller integration necessity.

## 2026-08-25 planning/documentation alignment

User approved `Planning Canon & Human Home Alignment`.

This alignment package established the durable project front door after T11. It is completed history. Its scope-local instruction to avoid additional image generation was later superseded by explicit user approvals for the Hybrid Visual work.

Implementation/decision locator:

`docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md`.

## Notion authority / Human Home

Human Home purpose:

`30-second promise -> full Run Flow -> four schools -> backpack/combination/Fate core data -> world/final goal -> approved visual direction -> AI interpretation -> edit guide -> compact evidence ceiling -> drilldown`.

Raw SHA, full PR/CI history, local path/ports/tool routing and detailed Txx receipts stay in Project Registry/System and `06 · Production · Handoff`.

## Visual decision — 2026-08-25 · current

Current visual authority is `docs/CURRENT_VISUAL_HANDOFF.md` + Notion `02 · 비주얼 바이블`.

### Hybrid surface split

- Presentation / key art / lore: hand-drawn ink codex + dark painterly anime ninja fantasy.
- In-game: animation-forward **2–3 head SD anime** with C-leaning dark painterly DNA and restrained ink/rough-edge cues.

### Runtime character identity

The player remains **one fixed ninja identity**. School traces add items / aura / companion / shadow effects instead of replacing the character body/face/costume identity.

All four traces must combine naturally. The strongest Trace Stage 3 expression is reserved for the **starting/main school**; other school traces remain supporting layers.

Approved school motifs:

- 봉마류: 부적 + 식신
- 천술류: 차크라 기운
- 귀인류: 오니가면 + 귀기
- 흑영류: 그림자 + 어둠

### Current image authority

- Hybrid Key Visual: APPROVED MASTER BRIDGE; Notion low-res native preview server readback PASS.
- Four-school full-body silhouette sheet: APPROVED SUPPORTING REFERENCE; not four runtime protagonists.
- SD/action/icon three-panel sheet: WORKING_REFERENCE; structure reusable but exact trace details superseded by current fixed-character/main-school-Stage-3 rules.
- IMG-02 runtime visual core: merged at `03005e7dcc1a2e0b6ee57b4f6ebed9b481ee2fbc` with seven approved PNG originals stored locally and as native Notion Asset Library attachments. Actual consumers are three generic EnemyBasic variants, Cheonsul StageBoss, ProjectileBasic, RewardOrb and BongmaFamiliar.
- IMG-03 moonlit battlefield backdrop: merged at `5a52a30aa6c38cfed17e46d550eef27ab06e53f7` with its opaque PNG stored locally and as a native Notion Asset Library original. Its sole consumer is `Main/BattlefieldBackdrop` behind gameplay; it changes no game-rule authority.
- IMG-04 Cheonsul flame field: merged at `6d538fcf933e2fbcca50f8e6d369d165efac620c` with its transparent PNG stored locally and as a native Notion Asset Library original. Its sole consumer is the existing `Cheonsul/FlameFieldVisual`; it changes no combat, route, reward, or school-rule authority.

No corrected trace-layer/action/icon sheet is a pending implementation task by itself. The next visual task begins only after a fresh consumer contract identifies the smallest missing runtime asset; dynamic trace VFX remain intentionally uncreated until then.

## Local/toolchain evidence ceiling

The IMG-02 package used a fresh local Godot 4.7.1 readback. Import, editor
parse, five-second headless main-scene smoke and full GUT `492/492` with
`5373` assertions passed after merge. Exact PR-head GitHub CI also passed GUT
and the Windows internal-build artifact.

Hera's only discovered live editor belonged to another project, so no Ninja
Survival live-render/input claim is made. Historical Project Registry values
for dedicated executable/ports are not current execution authority.

```text
LOCAL_SYNC: POST_MERGE_READBACK_PASS
GODOT_RUN: HEADLESS_MAIN_SMOKE_PASS
GODOT_EDITOR_SESSION: NOT_RUN_FOR_NINJA_SURVIVAL
HUMAN_PLAY: NOT_RUN
DEVICE_EXPORT: NOT_RUN
NOTION_NATIVE_ORIGINAL_ATTACHMENT: SEVEN_OF_SEVEN_SERVER_READBACK_PASS
NOTION_HUMAN_VISIBLE_LATEST_PREVIEWS: NOT_RUN
```

## T13 merged status

T13 Issue #62 / PR #63 is merged to `main` at `71152c7aa9dff4cc05eec76d4d2d70be47755f6c`; its documentation readback PR #64 advances the completed-main reference to `33242876d1b930906416323076e0b55e79896ef7`. T13 adds only the reusable `RestFlowUI` Workbench route-preview and intent contract: legal unvisited-school cards, pending Fate presentation, human-readable readiness state, and standard pointer/touch/focus input. It does not wire the protected MVP-3 loop to the T12 transaction; T14 owns that real session/encounter integration.

## T14 merged status

Issue #65 / PR #66 is squash-merged to GitHub `main` at `51e39737f272db0962a3dabada51bae10cd1fa97`. T14 connects the Cheonsul selection path to the protected route/encounter/Workbench owners: first-school route commit, Elite → chest token + Trace, explicit Trace recovery, Boss warning/spawn gate, Boss-clear route stabilization, mandatory Boss-reward-pending Workbench entry, and provisional route/Fate intent refresh. `EncounterCatalog` is the runtime source for the Core/Elite/Boss role IDs and Elite/Boss HUD display names bound to existing enemy representations; its fan/zone/mark pattern definitions are not newly implemented or claimed as live behavior. Cheonsul combat RewardOrbs stay active despite the legacy MVP-3 stage-flow phase remaining idle. Boss-reward candidates are readable but selection/board placement remain unavailable, so commit stays disabled; no build power, Fate, or next route is auto-committed. Exact PR head local evidence and fresh isolated post-merge evidence each passed Godot 4.7.1 import, editor parse, five-second main-scene smoke, and full GUT `485/485` with `5301` assertions. GitHub Actions run `32983817646` remained queued and was cancelled; a follow-up PR synchronization run was not created, so this router does not claim remote-CI success. These are automated-only evidence; new image generation, raster asset work, human usability, player experience, device/export, and visual live validation remain `NOT_RUN`.

The active package also closes a relevant T12 safety gap: a successful `RestCommitCoordinator` cannot be reconfigured to begin another commit. Existing session-reinitialization protection was already enforced by the generation check.

## Remaining product sequence

```text
T14 Cheonsul release-near Vertical Slice
-> T15 school-function help machine slice (merged)
-> User vertical-slice validation (Human/Player feedback remains deferred, not passed)
-> T16 remaining schools only after a separate current-scope decision
-> T17 four-school circuit integration
-> T18 final calamity package
-> T19 full-run verification
```

Do not skip T15 and multiply four-school content before representative Human evidence closes the shared-chassis risks.
