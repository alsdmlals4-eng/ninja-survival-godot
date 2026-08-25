# CURRENT_CONFIRMED_DECISIONS

```yaml
owner_role: CURRENT_APPROVED_PRODUCT_AND_PROTECTED_SCOPE_LEDGER
updated_at: 2026-08-25 KST
completed_main_at_reactivation: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
current_completed_main: 675073df3d47248666d5ad378c242480cb57c547
latest_product_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
latest_encounter_canon: docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
latest_migration_traceability: docs/traceability/2026-08-22-dec026-post-gate-traceability.md
latest_phase_b: docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md
current_migration_plan: docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md
current_docs_alignment_plan: docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md
current_visual_handoff: docs/CURRENT_VISUAL_HANDOFF.md
phase_b_verdict: PASS_FOR_APPROVED_DOMAIN_SEQUENCE
mvp0_to_mvp3_baseline: INTEGRATED
t01_to_t11_domain_chain: INTEGRATED_ON_COMPLETED_MAIN
t12_atomic_workbench_commit: IN_PROGRESS_DRAFT_PR_49_NOT_MERGED
pr_43_t12: CLOSED_UNMERGED_HISTORICAL_WIP
pr_44_front_door_docs: CLOSED_UNMERGED_HISTORICAL_WIP
pr_49_t12: OPEN_DRAFT_OTHER_WORKSTREAM_READ_ONLY_FOR_VISUAL_CLOSEOUT
playable_new_four_school_run: NOT_PROVEN
release_near_vertical_slice_human_qa: NOT_RUN
human_usability: NOT_RUN
player_experience: NOT_RUN
device_android_export: NOT_RUN
visual_master_style_reference: HYBRID_MASTER_STYLE_2026_08_25
visual_runtime_character_identity: ONE_FIXED_CHARACTER_PLUS_TRACE_LAYERS
visual_trace_stage3_rule: STARTING_MAIN_SCHOOL_ONLY
visual_binary_notion_attachment: HYBRID_KEYVISUAL_AND_SUPPLEMENTARY_LOW_RES_SERVER_READBACK_PASS_ORIGINAL_AND_HUMAN_VISIBLE_NOT_PROVEN
```

This is the current mutable decision router/ledger. Detailed rules live in the dated canon files; implementation reality lives in actual code/scenes/data/tests and executed evidence. Do not use an older status sentence or closed branch to override this file. Visual continuation detail lives in `docs/CURRENT_VISUAL_HANDOFF.md` and the Notion `02 · 비주얼 바이블`; if an older visual sentence elsewhere conflicts, this section and those current owners win.

## 1. Current product definition

`닌자의 신 / 닌자 서바이벌` is a 2D survival roguelike where the player chooses a starting ninja school, clears all four school battlefields in a player-chosen order, opens their tradition acquisition packages, and uses a spatial/rotation/adjacency backpack build to defeat a separate final calamity.

High-level Run:

`starting school -> choose unvisited school -> ~5m battlefield with Core/Elite/trace/school Boss -> branch Workbench/Fate -> repeat four schools -> Final Binding Workbench -> separate final calamity Boss -> result/Ninja Soul/legend`.

`~20 minutes` is the target active-combat time through the fourth school Boss, not the entire Run end.

Player emotion target:

`survive -> become stronger -> form my own ninja method -> reunite the four traditions -> suppress this front's calamity -> become a legend`.

Detailed DEC-014~025 rules: `docs/canon/2026-08-21-dec014-025-product-canon.md`.

Detailed DEC-026 encounter/pattern rules: `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`.

## 2. Protected integrated baseline

Keep and regression-protect until deliberately replaced by approved behavior changes:

- MVP-0 basic movement/combat/game-over foundation.
- MVP-1 combat DDD: kill combo, stylish score, reward absorption feedback.
- MVP-2 four-school shallow runtime as migration baseline.
- MVP-3 contribution/result, GOLD, Shop, Fate and existing three-segment rest-loop behavior as rollback/regression baseline where newer packages have not intentionally replaced it.
- T01 spatial data contracts/catalog.
- T02 committed `BackpackState` spatial facts.
- T03 deterministic `BackpackResolver` resolution/previews.
- T04 `RestBackpackSession` REST edit-session domain.
- T05 first-tier atomic `CombinationResolver` transaction.
- T06 committed `RunBuildState` item/spatial combat modifier authority.
- T07 Boss/Shop/Chest spatial acquisition transaction foundation.
- T08 `RunRouteState` four-school routing domain.
- T09 encounter definitions + Stage profiles.
- T10 Elite -> Trace -> Boss lifecycle/domain gate.
- T11 Run-level tradition access state + Boss/Shop/Chest lane-first reward selection.

A green automated test does not prove the current intended Run is playable or enjoyable. Human/Player/device evidence remains separate.

## 3. Protected MVP-4 spatial / Workbench decisions

Approved:

- fixed `6x6` board and centered `4x3` starting active area,
- purchasable bags expand usable area,
- item/bag 90-degree rotation,
- orthogonal adjacency,
- rectangular regular items with selected L/T bag shapes,
- special-bag activation by at least one-cell item overlap,
- six-slot REST work buffer,
- explicit atomic first-tier combination transaction,
- complete mouse, keyboard/gamepad-focus and touch completion targets,
- UI renders snapshots/emits intents; domain classes own legality/economy/combination/route rules,
- existing 19 base items, 3 first-tier combinations and 5 purchasable bags remain protected unless explicitly changed,
- preview/uncommitted items contribute zero combat power,
- one committed spatial modifier snapshot is the item/spatial combat authority.

Architecture:

`Item/Bag definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState -> combat runtime`.

## 4. Current four-school philosophy

- **봉마류:** prepare space and let familiars/barriers fight; mobile stronghold, not stationary tower defense.
- **천술류:** make statuses and transform the field through ordered elemental reactions.
- **귀인류:** become stronger by sustaining dangerous close-range presence; low HP alone is not the universal identity.
- **흑영류:** identify and remove dangerous targets first through marks/priority/execution; indirect targeting remains auto-combat compatible.

Backpack relationships should reinforce these different risk-processing identities without adding four separate spatial algorithms:

- 봉마: summon + installation/barrier
- 천술: different elements/statuses and reaction chains
- 귀인: close-range weapon + survival/recovery
- 흑영: ranged/throwing + mark/poison/execution

Current MVP-2 runtime is evidence/migration baseline, not a wholesale deletion target.

## 5. DEC-014~025 current authority summary

- **DEC-014:** one Run clears all four school battlefields and then a separate final battle.
- **DEC-015:** freely choose among unvisited schools; school identity and Stage difficulty are separate axes.
- **DEC-016/019:** trace is Run progression and tradition access, not automatic school power.
- **DEC-017:** each school owns Core Monster x3 + Elite x1 + Boss x1 + gimmick library; Stage gimmick depth grows 1→4 with default concurrent advanced-gimmick cap 2.
- **DEC-018:** final calamity recombines learned four-school encounter language rather than introducing unrelated combat grammar.
- **DEC-020:** liberated-school representatives provide short final-battle support callbacks; player build owns victory.
- **DEC-021/021A:** access packages and reward lanes control acquisition timing while preserving item identity/affinity/combinations.
- **DEC-022:** four-trace binding means Final Binding Workbench, not a new automatic upgrade tree.
- **DEC-023:** Heukyeong mark duration follows current 8-second refreshable runtime.
- **DEC-024:** Elite -> chest token + non-expiring trace -> trace recovery -> timed warning -> school Boss dual gate.
- **DEC-025:** route preview + provisional selection; Fate is the final build + Fate + next-school commit boundary after T12 migration.

## 6. Tradition access / reward decisions

Trace state:

`AVAILABLE -> RECOVERED -> STABILIZED`.

Rules:

- Elite death immediately grants chest token and creates the progression trace.
- Trace recovery opens Boss approach and does not grant ORB/STYLE/GOLD/direct combat power.
- Boss clear + branch return stabilizes the trace.
- `STABILIZED` opens that school's tradition acquisition package.
- Actual power still requires item acquisition and backpack placement/adjacency/combination.

First authoring access model preserves the existing canonical 19 base acquisition items:

- Universal 7
- 봉마 3
- 천술 3
- 귀인 3
- 흑영 3

This is an access-timing model, not exclusive item ownership. Multi-school affinity and cross-school combinations remain valid.

Reward selection principles:

- Boss Reward should preserve readable current-build continuity / newly liberated tradition / bridge-universal lanes when possible.
- Shop/Chest select lane/pool first, then item, with canonical item-ID dedupe.
- Chest stays more random than Shop and does not guarantee recipes.
- Do not add automatic `number of schools used -> +N%` multischool power.

## 7. DEC-026 encounter / pattern budget — APPROVED

Selected architecture: **shared attack primitives + school-owned encounter compositions**.

Per school:

- Core Monster x3
- Elite x1
- Boss x1
- bounded gimmick/pattern library
- Stage 4 Boss capstone

Stage budget:

- Stage 1: base signature, max 1 major hazard.
- Stage 2: one interaction pattern, max 1 advanced gimmick at once.
- Stage 3: one synergy/field layer, max 2 advanced gimmicks at once.
- Stage 4: mastery mix + one Boss capstone, still max 2 advanced gimmicks at once.

School encounter language:

- 봉마: moving seals/proxies/barrier lanes -> mobile-space adaptation.
- 천술: visible setup -> elemental reaction sequence.
- 귀인: committed rush/proximity pressure -> readable recovery windows.
- 흑영: visible threat/mark -> delayed execution and positioning priority.

First release-near Vertical Slice target remains **천술류**.

DEC-026 does not claim full playable encounter integration or final-calamity exact full attack script completion.

## 8. Current implementation boundary — merged through T11

Latest completed-main observation for this closeout is `c0440e7043bcf3bb678f5cb7d1653883f93c07a2`. The latest merged product implementation baseline remains T11:

`265bab32da087c070ea2ea0d98a3bdace1e10f7f` — `T11: add tradition access reward lanes`.

Current merged domain chain:

```text
T01 definitions/catalog
-> T02 committed backpack state
-> T03 spatial resolver
-> T04 REST session
-> T05 combination transaction
-> T06 committed combat modifier authority
-> T07 Boss/Shop/Chest acquisition transaction
-> T08 route state
-> T09 encounter definitions/stage profiles
-> T10 Elite/Trace/Boss lifecycle
-> T11 tradition access/reward lanes
```

T11 recorded exact-head evidence in Production Handoff:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 447/447 -> 4985 assertions -> T11 core 9/9 + adversarial 8/8 + clean re-attack 5/5`.

Evidence ceiling: automated/domain implementation scope only.

## 9. Current product workstream — T12 PR #49

T12 is **IN_PROGRESS / NOT_MERGED / NOT_COMPLETED** in draft PR #49 (`T12: atomic Workbench Fate route commit`). PR #49 is a separate implementation workstream and remains read-only for this visual closeout.

Historical PR #43 (`T12: add atomic Workbench commit coordinator`) remains closed-unmerged WIP/reference only. PR #44 is also closed-unmerged historical WIP.

Still-approved product outcome:

- next route remains provisional through Workbench,
- final T04 backpack/session state + one pending Fate + one provisional unvisited school are validated before committed mutation,
- failure mutates none of committed backpack/Fate/route state,
- success commits exactly once,
- existing T02/T03/T04/T05/T06/T07/T08/T11 owners remain singular,
- T13 UI/MainController migration is not silently absorbed unless fresh evidence proves a smaller integration necessity.

Visual work must not modify, rebase, close, merge or absorb PR #49 unless a later user instruction explicitly authorizes that PR workstream.

## 10. Remaining production sequence

```text
T12 atomic Workbench + Fate + route commit (currently draft PR #49)
-> T13 Persistent Workbench route-preview UI/input
-> T14 Cheonsul one-school release-near Vertical Slice
-> T15 Human QA gate
-> T16 expand 봉마/귀인/흑영
-> T17 four-school circuit integration
-> T18 final calamity package
-> T19 full-run verification
```

Do not multiply full school production before T15 human evidence closes the shared-chassis risks.

## 11. World / `닌자의 신` product meaning

Approved world/story core:

- human war + abuse of forbidden arts breaks spiritual seals/boundaries,
- yokai/spirits/corruption and human conflict amplify each other,
- the player starts as an unfinished ninja in the damaged joint frontier branch,
- the legend says a `닌자의 신` appears in an age of chaos, but the player is not preselected by bloodline or prophecy,
- the player earns that meaning by surviving, creating a personal method, reconnecting the four traditions and suppressing the calamity.

Do not reduce every conflict to one mastermind or define one school as the default evil faction.

## 12. Meta / Ninja Soul direction

**Run power is built inside the Run.**

Ninja Soul/meta progression prioritizes horizontal possibility rather than permanent stats that erase backpack/route/Fate decisions:

- technique/equipment/bag/start-option unlocks,
- combination hints/codex,
- convenience,
- challenge conditions,
- other bounded horizontal options.

Base-building/economy is not the project core.

## 13. Visual decision — 2026-08-25 APPROVED HYBRID MASTER STYLE

Current visual continuation authority:

- `docs/CURRENT_VISUAL_HANDOFF.md`
- Notion `02 · 비주얼 바이블`

The user approved a two-surface visual system that must still read as one IP:

- **Presentation / key art / lore:** hand-drawn ink codex + mature dark painterly anime ninja fantasy.
- **In-game:** animation-forward **2–3 head SD anime** with C-leaning dark painterly DNA and restrained ink/rough-edge cues.

### Runtime character identity — protected visual rule

The player is **one fixed ninja identity**, not four school-specific protagonists. Keep the same face, hair, body proportion and core outfit identity. Collecting school traces adds bounded visual layers around the same character.

All four traces must combine naturally as `one ninja accumulating four traditions`, not as four unrelated costumes combined.

The strongest **Trace Stage 3** visual expression applies only to the **starting/main school**. Other school traces remain supporting layers so the full four-school state stays readable.

Approved school visual motifs:

- **봉마류:** 부적 + 식신
- **천술류:** 차크라 기운
- **귀인류:** 오니가면 + 귀기
- **흑영류:** 그림자 + 어둠

Shared visual DNA:

- dark moonlit ninja fantasy,
- black / deep navy / charcoal + red / warm gold base,
- ink / brush framing and Korean brush-calligraphy in presentation surfaces,
- readable silhouettes and controlled effects,
- same character/motif/palette hierarchy across presentation and gameplay even when rendering detail differs.

### Image authority levels

- Hybrid Key Visual: **APPROVED MASTER BRIDGE**.
- Four-school full-body sheet: **APPROVED SUPPORTING REFERENCE** for Presentation/Lore silhouette/motif comparison; not four runtime protagonists.
- SD/action/icon three-panel sheet: **WORKING_REFERENCE**; SD/action/icon structure is reusable, but details must be revised to the fixed-character + main-school Stage-3 + all-four-coherent rules before runtime-art approval.

No new image should be generated automatically on chat start. Resume via current visual handoff → text brief → user approval → requested generation → result review → durable Notion placement.

### Notion delivery evidence

The approved Hybrid Key Visual has a **Notion-native low-resolution preview** with server readback resolving to Notion-owned `prod-files-secure`: PASS.

High-resolution pixel-equivalent Notion delivery is not proven. Browser/Android/iOS human-visible rendering of the latest preview set remains NOT_RUN until directly observed.

## 14. Notion Human Home decision — APPROVED

The Human Home is a **self-contained player-facing whole-game flow map + visual/text learning surface**, not an AI task dashboard.

Home directly exposes enough to understand the project without opening raw technical pages:

- project promise and player fantasy,
- full Run Flow,
- 4-school philosophies,
- backpack/rotation/adjacency/combination/Fate core data,
- world/final-goal meaning,
- approved visual direction / actual approved visual anchor when durably attached,
- AI interpretation for user correction,
- human edit guide,
- compact implementation/evidence ceiling and next product gate.

Raw SHA, full PR/CI history, local Godot path/ports, internal routing and detailed Txx receipts stay in Project Registry/System and Production Handoff.

## 15. Evidence / completion protection

The following remain `NOT_RUN` or explicitly limited until direct evidence exists:

- release-near new-Run Human Usability,
- intended Player Experience,
- production-candidate Workbench/end-to-end input flow,
- device/Android/export readiness,
- current local shared Godot/editor/session identity for future Godot authoring,
- high-resolution pixel-equivalent Notion delivery of the approved generated images,
- browser/Android/iOS human-visible render of the latest Notion image previews,
- actual Godot runtime implementation of the new SD character direction,
- final four-school accumulated-character composite under the newest trace rules.

Do not use T01~T11 test receipts or Notion server readback to promote these states.

## 16. Documentation alignment history and current visual continuation

`Planning Canon & Human Home Alignment` remains completed history. Its older instruction to generate no further images applied to that alignment package only and was superseded by the user's later explicit visual-generation approvals on 2026-08-25.

Current visual continuation and next-chat quality gate are owned by `docs/CURRENT_VISUAL_HANDOFF.md`.

Product implementation continues independently through draft T12 PR #49; the visual closeout does not claim or mutate that implementation workstream.
