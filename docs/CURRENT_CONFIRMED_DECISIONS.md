# CURRENT_CONFIRMED_DECISIONS

```yaml
owner_role: CURRENT_APPROVED_PRODUCT_AND_PROTECTED_SCOPE_LEDGER
updated_at: 2026-08-28 KST
completed_main_at_reactivation: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
current_completed_main: RESOLVE_FROM_REPOSITORY_DEFAULT_BRANCH
current_completed_main_resolution: FRESH_GITHUB_DEFAULT_BRANCH_READ_REQUIRED
last_completed_main_read: 508711f5572c37587088223469e337817076ce19
last_completed_main_read_receipt: PRE_DEC033_RUN_END_NINJA_SOUL_SETTLEMENT_2026_08_28_KST
last_product_implementation_merge: 63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497
github_main_read_before_router_reconciliation: 695d01f278b1468e3c61880e3c10033f44057f65
github_main_read_resolution: POST_PR_105_FRESH_GITHUB_DEFAULT_BRANCH_READBACK_2026_08_28_KST
latest_product_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
latest_encounter_canon: docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
latest_migration_traceability: docs/traceability/2026-08-22-dec026-post-gate-traceability.md
latest_phase_b: docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md
current_migration_plan: docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md
current_docs_alignment_plan: docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md
current_visual_handoff: docs/CURRENT_VISUAL_HANDOFF.md
phase_b_verdict: PASS_FOR_APPROVED_DOMAIN_SEQUENCE
mvp0_to_mvp3_baseline: INTEGRATED
t01_to_t16_machine_scope: INTEGRATED_ON_LAST_PRODUCT_IMPLEMENTATION_MERGE
t12_atomic_workbench_commit: MERGED_MAIN_41202283b75921efb7691e77c3de1502d77410d1
t13_persistent_workbench_route_ui_input: MERGED_MAIN_71152C7AA9DFF4CC05EEC76D4D2D70BE47755F6C
t14_cheonsul_release_near_vertical_slice: MERGED_MAIN_51E39737F272DB0962A3DABADA51BAE10CD1FA97_AUTOMATED_EVIDENCE_ONLY
t15_school_function_help_machine_slice: MERGED_MAIN_E2CFE4452E1DE5A224F5CD7DEE8E47A104C868E0_MACHINE_VERIFIED_HUMAN_QA_DEFERRED_BY_CURRENT_USER
t16_in_combat_current_school_help_machine_slice: MERGED_MAIN_63FCF81FDF4B5D1BBFF14B5721A13F7C1AFE1497_MACHINE_VERIFIED_HUMAN_QA_DEFERRED_BY_CURRENT_USER
windows_internal_build_artifact: MERGED_MAIN_0F085FC4FEFF25353C049749BF34236A89C01BE4_GITHUB_CI_ARTIFACT_AND_LOCAL_EXPORT_RUNTIME_SMOKE_PASS
windows_internal_build_boundary: INTERNAL_VALIDATION_ONLY_NOT_PUBLIC_RELEASE_OR_DEVICE_EXPORT
pr_43_t12: CLOSED_UNMERGED_HISTORICAL_WIP
pr_44_front_door_docs: CLOSED_UNMERGED_HISTORICAL_WIP
pr_49_t12: OPEN_DRAFT_READ_ONLY_SUPERSEDED_BY_FRESH_PR_61
playable_new_four_school_run: NOT_PROVEN
release_near_vertical_slice_human_qa: DEFERRED_BY_CURRENT_USER_NOT_RUN
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

Detailed DEC-027 Cheonsul spatial auto-reaction rules: `docs/canon/2026-08-28-dec027-cheonsul-spatial-auto-reaction.md`.

Detailed DEC-028 Cheonsul fixed setup-seal rules: `docs/canon/2026-08-28-dec028-cheonsul-fixed-setup-seal.md`.

Detailed DEC-029 four-school lifecycle-before-Human-validation scope: `docs/canon/2026-08-28-dec029-four-school-lifecycle-before-human-validation.md`.

Detailed DEC-030 four-school Human-validation endpoint-before-final-package scope: `docs/canon/2026-08-28-dec030-four-school-validation-endpoint-before-final-package.md`.

Detailed DEC-031 default Run-end plus one-time emergency school-retry base scope: `docs/canon/2026-08-28-dec031-gold-one-time-emergency-school-retry.md`.

Detailed DEC-032 optional expanded school-help scope: `docs/canon/2026-08-28-dec032-optional-expanded-school-help.md`.

Detailed DEC-033 Run-end Ninja Soul settlement, Boss-only soul eligibility, and Ninja Soul retry scope: `docs/canon/2026-08-28-dec033-run-end-ninja-soul-settlement.md`.

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

The first release-near slice is authored from **천술류**, but DEC-029 requires all four school lifecycles to be implemented before the first Human/Player vertical-slice validation begins.

DEC-026 does not claim full playable encounter integration or final-calamity exact full attack script completion.

## 7.1 DEC-027 Cheonsul spatial auto-reaction — APPROVED / implementation deferred

- Cheonsul retains automatic `WET → SHOCK` combat, but a high-value chained reaction must arise from a readable spatial condition made through player movement and enemy grouping.
- The player does not gain a separate manual reaction trigger, aim reticle, or cooldown sequence in this first Slice.
- Current automatic token-targeting implementation does not yet satisfy this product intent; concrete spatial-condition form and tuning remain the next Phase 1 decision.
- This is product/canon authority only. It does not claim a code, Scene, asset, Human Usability, or Player Experience change.

## 7.2 DEC-028 Cheonsul fixed setup seal — APPROVED / implementation deferred

- The player-created spatial condition is a short, fixed blue setup seal at the automatic `WET` cast location.
- The next automatic `SHOCK` prioritizes a prepared `WET` group inside that seal for a higher-value amber/orange chain reaction.
- Reuse existing zone/field presentation only as an implementation reference; the current flame field and automatic targeting do not satisfy DEC-028.
- Exact duration, radius, cluster threshold and numerical effects remain intentionally undecided until the complete implementation contract.

## 7.3 DEC-029 four-school completed lifecycle before Human validation — APPROVED / implementation deferred

- The first Human/Player vertical-slice validation waits until all four schools can traverse the shared school lifecycle and an actual unvisited-school route/Workbench commit.
- Reuse one shared encounter primitive chassis and existing route/Backpack/Workbench owners; school-specific data/compositions express identity.
- This package excludes Final Binding Workbench, final calamity Boss and final ending implementation under the DEC-030 later-package boundary.
- This supersedes the current-package Cheonsul-only Human-validation gate, not DEC-026's Cheonsul-first encounter authoring or any existing product rule.

## 7.4 DEC-030 four-school validation endpoint before final package — APPROVED / implementation deferred

- The first four-school Human/Player validation ends when the fourth school Boss Result/Reward makes existing `final_binding_eligible` legible; it does not enter a Final Binding Scene or launch final combat.
- Final Binding Workbench, final calamity Boss, four-school support callbacks and final result/Ninja Soul/legend remain one later, separately reviewed package under DEC-018/020/022.
- Do not manufacture a placeholder ending or special final reward that could make this evidence look like a full-Run completion.

## 7.5 DEC-031 default Run-end plus one-time emergency school retry — PARTIALLY SUPERSEDED / implementation deferred

- Default death ends the Run. One explicit retry per Run remains conditionally available only from a valid successful Workbench checkpoint and restarts the same active school.
- The retry currency, persistent Ninja Soul allowance, and Boss eligibility ledger are owned by DEC-033. Failed-school transient GOLD/rewards/Trace/progress are still lost; previously committed Backpack/Fate/route/clear order restore atomically.
- No automatic revive or retry recharge is allowed.

## 7.6 DEC-032 optional expanded school help — APPROVED / implementation deferred

- Do not add forced first-30-second prompts, tutorial cards or action markers. A player may instead open a clearer, expanded Korean explanation for the currently selected school through the existing combat help path.
- Each explanation must connect actual risk processing → relevant screen information → player positioning attempt → observable success/next goal, without claiming future mechanics or changing automatic-combat ownership.
- Help remains a post-baseline, optional explanation path. It cannot turn an unassisted first-30-second Human result into `PASS`; status presentation remains compact icon-first.

## 7.7 DEC-033 Run-end Ninja Soul settlement — APPROVED / implementation deferred

- `GOLD` remains transient Run economy: normal enemies have a recommended 20% chance for 1G, Elite gives fixed 5G, and a school Boss gives fixed 10G. The normal chance is a data-tunable initial recommendation, not verified balance.
- Ninja Soul is persistent. At Run end only, a distinct school Boss clear awards 2 Soul and progress rank awards C/B/A/S = 0/1/2/4 Soul for 0/1/2–3/4 distinct school Boss clears.
- Retry costs persistent Ninja Soul 1, requires a valid Workbench checkpoint, is limited to once per Run, and never grants immediate or duplicate Boss Soul. The Result must explain each settlement component separately.

## 8. Current implementation boundary — product implementation merged through T16 help

The last product implementation merge is:

`63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497` — `feat: reopen school help during combat`.

The GitHub default branch read immediately before PR #77 was a later documentation follow-up:

`f77a1c86660784c1a20c9f2a9abfee7b774ba911` — `docs: keep T16 GUT evidence count-safe (#76)`.

This repository document cannot name its own eventual merge SHA as a durable “current main” fact. Always fresh-read GitHub `main` before mutation; Production Handoff records post-merge main receipts.

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
-> T12 atomic committed backpack snapshot + Fate + route transaction
-> T13 Persistent Workbench route-preview UI/input presentation
-> T14 Cheonsul lifecycle adapter / Boss-clear Workbench entry
-> T15 starting-school Korean function help
-> T16 selected-school help reopen from combat HUD
```

T12 post-merge automated evidence in Production Handoff:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 471/471 -> 5168 assertions`.

Evidence ceiling: automated/domain implementation scope only.

## 9. Current product workstream — T12~T16 machine slices merged / Human QA deferred

T12 PR #61 (`T12: atomically commit Workbench snapshot, Fate, and route`) and T13 PR #63 (`T13: add persistent Workbench route-preview UI`) are merged in the completed-main baseline above. T13 remains limited to a reusable Workbench route-preview/input presentation contract.

Draft PR #49 (`T12: atomic Workbench Fate route commit`) is superseded and remains read-only WIP/reference only. Historical PR #43 (`T12: add atomic Workbench commit coordinator`) and PR #44 are also closed-unmerged WIP/reference only.

T12's protected product outcome remains:

- next route remains provisional through Workbench,
- final T04 backpack/session state + one pending Fate + one provisional unvisited school are validated before committed mutation,
- failure mutates none of committed backpack/Fate/route state,
- success commits exactly once,
- existing T02/T03/T04/T05/T06/T07/T08/T11 owners remain singular,
- T13 presentation may not move transaction ownership into UI.

T13 intentionally did not absorb MainController/T14 integration: it renders supplied snapshots, marks route/Fate choices as pending, sends intent signals, and presents coordinator/readiness failures in Korean. T14 is merged in `51e39737f272db0962a3dabada51bae10cd1fa97`: it adds the Cheonsul-only lifecycle adapter (first-route commit, Elite → Trace → Boss gates, Boss-clear Workbench entry), existing runtime combat composition, active combat reward-orbs, read-only Boss-reward candidates, and pending route/Fate intents. `EncounterCatalog` remains the source for Core/Elite/Boss role IDs and display names; its fan/zone/mark primitives are not newly verified runtime claims. T15 PR #69 is squash-merged in `e2cfe4452e1de5a224f5cd7dee8e47a104c868e0`: it adds a separate Korean `기능 도움말` entry for every starting school, one reusable modal, and input isolation so help cannot select a school. Exact PR-head GitHub GUT and isolated post-merge local import, editor parse, five-second main smoke, focused GUT `8/8` / `38`, and full GUT `488/488` / `5321` passed. Under the current user contract Human QA is `DEFERRED_BY_CURRENT_USER_NOT_RUN`; it is not Human, Player Experience, touch, device/export, or live-render PASS. The user then separately approved T16 in-combat current-school help: PR #73 is squash-merged in `63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497`, preserving the existing single help-dialog owner while a combat HUD intent opens only the selected school’s help. Exact PR-head GitHub GUT and isolated post-merge local import, editor parse, five-second main smoke, focused GUT `25/25` / `176`, and full GUT `491/491` passed. Assertion totals are omitted because earlier receipts disagree and the CI log proves the test count, not one canonical assertion total. Direct Debug input delivery is recorded separately; it is not live-render, Human, Player Experience, touch, device/export, or device PASS. Visual work must not modify, rebase, close, merge or absorb PR #49.

## 10. Remaining production sequence

```text
T12~T16 implemented machine scope
-> DEC-029/030/031/032/033 four-school lifecycle implementation contract and Phase 2 review
-> all-four-school shared-chassis/circuit implementation and machine evidence
-> User vertical-slice validation through fourth-Boss Final Binding eligibility (deferred / NOT_RUN)
-> separately reviewed Final Binding / final calamity package
-> full-Run verification only after that package
```

DEC-029/030/031/032/033 authorize four-school shared-chassis implementation before the first Human gate, delimit that first test before the final package, require optional help as a non-substitute for unassisted readability, and preserve default Run-end pressure with one Ninja-Soul-gated school retry. The later Human gate remains mandatory and `NOT_RUN`; no machine evidence may replace it.

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

## 13. Visual decision — 2026-08-25 Hybrid Master Style + 2026-08-28 combat readability lock

Current visual continuation authority:

- `docs/CURRENT_VISUAL_HANDOFF.md`
- Notion `02 · 비주얼 바이블`

### 2026-08-28 — approved combat information grammar

- **천술류**는 청색 + 호박/주황을 상태·반응의 주색으로 사용한다. 보라/검정은 **흑영류**의 소유 색이며 천술류의 주색 또는 기본 상태 표시에 사용하지 않는다.
- 전투 상태는 지속적인 단어 배지가 아니라 **색 + 고유 실루엣을 갖춘 작은 아이콘**으로 표현한다. 구현 단계에서는 포커스/도움말 등 접근 가능한 설명 경로를 별도로 검증한다.
- 적 HP 바는 기본적으로 숨긴다. **피격 직후의 적 하나만** HP 바를 표시한다. 지속 시간·전환은 Human Usability 검증에서 조정할 항목이며, 이 결정은 전투 규칙이나 HP 수치를 바꾸지 않는다.
- `PROJECT_CORE_SCENE_VISUAL_BOARD`는 현재 대화에서 만든 **GENERATED_EXPLORATION / planning visualization**이다. 런타임 texture, Godot UI 구현, 승인 Project Asset, Human/Player evidence가 아니며 사용자 검토 전에는 어느 것도 대체하지 않는다.

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

Do not use T01~T16 test receipts or Notion server readback to promote these states.

## 16. Documentation alignment history and current visual continuation

`Planning Canon & Human Home Alignment` remains completed history. Its older instruction to generate no further images applied to that alignment package only and was superseded by the user's later explicit visual-generation approvals on 2026-08-25.

Current visual continuation and next-chat quality gate are owned by `docs/CURRENT_VISUAL_HANDOFF.md`.

Product implementation currently includes T12 PR #61, T13 PR #63, T14 PR #66, T15 PR #69, and T16 PR #73; draft PR #49 remains read-only and does not authorize resuming that older implementation path.
