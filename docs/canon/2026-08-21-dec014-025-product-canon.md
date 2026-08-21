# DEC-014~025 Product Canon Rebaseline

```yaml
canon_id: NINJA_SURVIVAL_DEC014_025_REBASELINE_2026_08_21
source_of_product_direction: Notion project home + 03 UI 생존 Flow Map + 08 핵심 시스템 상세 + 09 세계관 핵심 스토리
source_snapshot_date: 2026-08-21 KST
repository_baseline_before_rebaseline: a84980661767b02391f85d87e8fc4e9fc5dc67e7
implementation_evidence_ceiling: MVP_0_TO_3_INTEGRATED_MVP4_NOT_STARTED
runtime_evidence_for_this_canon: NOT_RUN
human_evidence_for_this_canon: NOT_RUN
next_product_gate: DEC_026
```

## 1. Purpose and authority

This document mirrors the currently approved DEC-014~025 product direction into the GitHub implementation canon so future implementation does not resume from the older three-segment MVP-3 flow.

It does **not** claim that DEC-014~025 is implemented. Existing MVP-0~3 runtime/tests remain the rollback and regression baseline until later TDD packages replace specific behavior.

When this document conflicts with older active wording about `three segments`, `third Fate -> COMPLETE`, `20 minutes = full run end`, or the historical PR #17/T01 resume route, this document and the refreshed `CURRENT_CONFIRMED_DECISIONS.md` / `ACTIVE_CONTEXT.md` win for current planning.

The older MVP-4 spatial design remains protected unless a rule below explicitly changes its boundary.

## 2. Current one-line product promise

> Visit the four ninja-school battlefields, recover access to their traditions, complete a spatial/rotation/adjacency backpack build, then use that player-built power to suppress the final calamity core.

The player emotion target is:

`survive -> become stronger -> form my own ninja method -> reunite the four traditions -> suppress this front's calamity -> become a legend`

## 3. Current Run structure

```text
Collapsed joint frontier branch / starting school
-> Stage route preview
-> choose one unvisited school battlefield
-> school Core Monsters + current Stage gimmick
-> ~3 min school Elite
-> chest token + trace appears
-> trace recovery
-> BossApproachProfile / warning
-> school Boss around the five-minute boundary
-> RESULT + Boss Reward
-> return to joint branch
-> trace becomes STABILIZED / school access package opens
-> Persistent Workbench
-> choose/provisionally change the next unvisited school
-> Shop / Chest / Backpack / Combination
-> Fate atomically commits build + fate + next route
-> next Stage

Repeat until all four schools are cleared exactly once.

Fourth school Boss
-> RESULT / Boss Reward
-> four-trace binding
-> Final Binding Persistent Workbench
-> fourth Fate / final build commit
-> separate final battle: 난세 재앙핵
-> four liberated-school support callbacks
-> player backpack build delivers the actual victory
-> final result / Ninja Soul / legend callback
```

`~20 minutes` means the active-combat target for finishing the fourth school Boss. It is **not** the entire Run duration; final-rest and final-boss time are additional.

## 4. DEC-014 — Four-school circuit and separate final battle

- The old interpretation of four attacks around one branch is superseded.
- One Run visits 봉마 / 천술 / 귀인 / 흑영 battlefields exactly once each.
- Each battlefield owns its school encounter identity, trace, Elite and Boss.
- The joint branch is the departure/return/rest/Workbench/meta hub, not the only combat map.
- After the fourth school Boss, the player gets one final rest before a separate final Boss.

## 5. DEC-015 — Free next-school choice + Stage difficulty profile

- After each return/rest, choose freely among **unvisited** schools.
- School identity and Stage number are separate axes:
  - `school` = encounter language, monsters, Elite/Boss identity, gimmick library, access package.
  - `stage_index 1..4` = HP/damage/spawn/pattern-pressure and gimmick-depth adjustment.
- Do not hardcode 24 route permutations or 16 bespoke school-stage implementations.
- Runtime target composition is `SchoolEncounterDefinition + StageDifficultyProfile + SchoolGimmickLibrary`.

## 6. DEC-016 / DEC-019 — Trace current authority

DEC-019 supersedes the earlier DEC-016 interpretation that a stabilized trace automatically strengthens that school.

Current rule:

- Trace is a Run-only progression/resource object separate from Ninja Soul.
- Elite kill produces the trace; trace recovery opens Boss approach, not combat power.
- Boss clear + branch return changes the trace to `STABILIZED`.
- `STABILIZED` opens that school's **tradition acquisition access package** in the existing Boss Reward / Shop / Chest economy.
- The trace itself grants no large automatic DPS/stat buff.
- Actual power remains `acquire -> backpack placement -> adjacency -> combination -> committed modifier snapshot`.
- Starting-school runtime stays selected for the Run; visiting another school does not swap the player's base runtime.

Required trace states:

`AVAILABLE -> RECOVERED -> STABILIZED`

## 7. DEC-017 — Encounter content structure and Stage gimmick budget

Each school owns:

- 3 Core Monster identities,
- 1 Elite,
- 1 Boss,
- a School Gimmick Library.

First Vertical Slice total content ceiling is therefore:

`12 Core Monsters + 4 Elites + 4 school Bosses`.

Internal chassis such as `Swarm / Priority Threat / Anchor` may be reused, but behavior meaning, visual language and gimmick combinations must remain school-distinct.

Stage gimmick depth:

- Stage 1: base signature only.
- Stage 2: +1 school interaction gimmick.
- Stage 3: school synergy/field gimmick.
- Stage 4: mastery gimmick + one Boss advanced pattern.
- Even at Stage 4, do not stack every previous advanced gimmick simultaneously; default concurrent advanced-gimmick cap is **2**.

Protected rules:

- no school hard-counter immunity,
- readable telegraphs,
- route order must not create runaway snowball,
- difficulty comes from Stage profile/content interaction, not permanent Meta stat compensation.

## 8. DEC-018 — Final calamity and Final Boss

The final calamity is an emergent disaster formed from:

`excess yokai energy + four-school conflict/forbidden techniques + distorted tradition echoes`.

It is not a single mastermind responsible for the whole world's war.

Final Boss learns from earlier encounters rather than introducing an unrelated ruleset:

1. Phase 1: one school echo/gimmick at a time.
2. Phase 2: combinations of two school gimmicks; the same concurrent advanced-gimmick cap principle applies.
3. Final resolution must still foreground the player's own backpack build.

Exact attack sets and final pattern budget remain downstream of DEC-026 and are **not approved by this rebaseline**.

## 9. DEC-020 — Liberated-school support in final battle

- School Bosses/representatives are framed as corrupted/divided traditions that are liberated, suppressed or cleansed rather than proving the whole school evil.
- Each of the four liberated schools intervenes once in the final fight.
- Support order defaults to the player's clear order.
- No four-companion management UI and no four manual summon buttons.
- Support should be short automatic/situational callbacks that create risk relief or a brief attack window.
- Support is not a mandatory puzzle solution and must not auto-win.
- The player's backpack build remains the owner of actual victory and finishing power.

School callback intent:

- 봉마: barrier/familiar battlefield stabilization.
- 천술: reaction-based purification of hazardous fields/energy.
- 귀인: frontal breakthrough that interrupts pressure and creates an opening.
- 흑영: mark a calamity-core weakness and create a vulnerability window.

## 10. DEC-021 / 021A — Tradition access packages and reward lanes

Trace stabilization controls **when content can appear**, not permanent item ownership or item identity.

First Vertical Slice access-authoring model:

- 19 existing base-acquisition items are retained.
- Access timing is authored as `Universal 7 + school signature package 3 x 4`.
- This is an **access package**, not an exclusive-affinity table.
- Existing item IDs, prices, footprints, tags, multi-school affinities, 3 combinations and 5 bags remain the 2026-08-11 MVP-4 content canon unless later explicitly changed.

Authoring-default access packages:

- **Universal 7:** 행운 부적, 인법단련, 재생의 두루마리, 오의 비전서, 유파 증표, 금기의 부적, 폭탄.
- **봉마 3:** 깨달음, 결계술, 대형 소환진.
- **천술 3:** 수둔, 뇌둔, 화둔.
- **귀인 3:** 체술단련, 호신 부적, 일본도.
- **흑영 3:** 수리검, 은신술, 독침술.

These are access-timing packages only. They do not erase existing multi-school affinity or cross-school combination meaning.

At Run start:

- Universal lane is open.
- Starting-school representative package is open.

After stabilizing another school's trace:

- that school package becomes eligible for later Boss Reward / Shop / Chest draws.

Boss Reward meaning should preserve three readable lanes when possible:

1. current-build continuity,
2. newly liberated school tradition,
3. bridge/universal/mixed-build option.

Shop/Chest must not select from one flat global list that lets the largest category dominate probability. Choose lane/pool first, then item; deduplicate by canonical item ID.

Additional protected reward behavior:

- the first Shop after a newly liberated school may temporarily weight that school, but ignoring it and deepening the current build remains valid,
- Chest preserves more randomness than Shop and does not guarantee recipe completion,
- do not add an automatic `number of schools used -> +N%` multischool bonus,
- pure/mixed power differences should emerge from footprint, adjacency, combination and effect budgets.

Protected existing cross-school combinations include the current representative combinations such as `water_style + stealth_art` and `katana + lightning_style`.

## 11. DEC-022 — Final Binding Workbench

Four-trace binding is **not** a new upgrade tree or large automatic buff.

It means:

- all four tradition access packages are open,
- the player enters the last Persistent Workbench,
- existing items, placement, adjacency and combinations are used to finish the final build,
- the final build commit and final Fate lead into the calamity-core battle.

If final-rest duration becomes repeatedly excessive, improve lane/combination hints before adding new power shortcuts or relocking traditions.

## 12. DEC-023 — Heukyeong mark duration reconciliation

Current canon is the already merged/tested MVP-3 runtime rule:

- mark duration: base `8.0 seconds`, refreshable per target,
- reapplying at 1-2 stacks refreshes remaining time to the effective full duration,
- 3+ stacks triggers `MARK BURST` and removes that target's marks.

Older unlimited-duration MVP-2 wording is historical only.

## 13. DEC-024 — Elite -> Trace -> Boss Gate

Current Core System authoring timeline:

```text
0:00~0:30  Swarm / school signature first proof
0:30~2:45  Priority + Anchor gradual mix
2:45       Elite warning authoring default
~3:00      school Elite appears
3:00~3:30  Elite resolution target
3:30~4:20  pressure rise / ultimate preparation
4:20       earliest Boss warning target
~4:30      earliest Boss appearance target
5:00~5:30  Boss clear target; soft overtime if still alive
Boss death -> RESULT -> Reward -> Workbench -> Fate
```

The UI Flow visual uses approximately `2:40` for the Elite warning while the later Core System timeline uses `2:45`; use `2:45` as the current authoring default and treat the Flow value as approximate presentation timing. Reconfirm exact warning/pattern budget in DEC-026 rather than hiding the discrepancy.

Elite reward split:

- **Chest token:** actual Elite death immediately grants `+1`; it is not a physical drop and feeds the existing next-Workbench chest rule (`token 1 -> item 2`).
- **School trace:** required progression object at the Elite death position; it opens Boss approach after recovery but gives no immediate combat modifier/access package.

Trace pickup authoring defaults:

```yaml
settle_seconds: 0.40
homing_delay_seconds: 0.75
homing_speed_px_per_second: 260
pickup_radius_px: 48
lifetime: INFINITE_UNTIL_COLLECTED_OR_RUN_END
fast_homing_after_seconds: 6.0
```

Approved milestone sequence:

```text
Elite warning
-> ~3:00 school Elite
-> Elite kill
   -> chest token +1 immediately
   -> non-expiring school trace appears
-> trace settle / homing / close-range auto pickup
-> TRACE RECOVERED
-> current Stage BossApproachProfile
-> earliest-time + warning gate
-> school Boss
-> ~5:00 resolution target with soft overtime when necessary
```

Protected behavior:

- Chest token and trace are separate rewards.
- Trace is non-expiring and cannot be collected twice.
- While `TRACE_AVAILABLE`, new normal spawns stop but the combat clock and existing hazards/enemies continue.
- Time alone cannot spawn the Boss; trace recovery alone cannot spawn the Boss.
- Boss requires: Elite clear + trace recovered + earliest-time reached + warning completed + Boss not already spawned.
- Earliest Boss warning target is about `4:20`; earliest Boss appearance target is about `4:30`.
- If trace is recovered after `4:20`, immediately start an approximately `10s` Boss warning.
- `5:00` is not a hard failure; HUD should show the actual overtime milestone such as TRACE / BOSS WARNING / BOSS.
- Elite and school Boss are not active simultaneously.
- `RECOVERED` alone does not open the tradition access package; stabilization requires Boss clear + branch return.
- Trace collection must not increment ORB / STYLE / GOLD and must remain separate from the MVP-1 RewardOrb lifetime behavior.

## 14. DEC-025 — Next-school risk/reward preview and atomic route commit

Route choice is a player decision surface, not hidden RNG.

First battlefield:

- starting-school choice is followed by a separate explicit battlefield/route confirmation.

Stages 2-4:

- Workbench displays all unvisited-school candidate cards,
- route selection is provisional and may be changed while editing the build,
- Fate commits `backpack + fate + next_school` atomically.

Candidate card must communicate:

- school name/symbol and one-line combat philosophy,
- Stage gimmick depth (`base / interaction / synergy / mastery`),
- one-line Elite/Boss main risk,
- the school tradition option guaranteed/readable from Boss Reward,
- representative tradition access that will open after stabilization,
- real links to the player's current backpack tags/combination ingredients,
- the support-order consequence for the final Boss.

Do **not** expose exact HP/damage multipliers, exact spawn schedule, cooldown tables, predicted DPS/win-rate, or an AI recommendation score.

Route history must remain visible, e.g. `1 흑영 ✓ -> 2 봉마 ✓ -> 3 [선택 중] -> 4 ?`.

## 15. Existing MVP-4 spatial canon protected

This rebaseline does not change:

- fixed 6x6 board,
- starting 4x3 active area,
- purchasable bag expansion,
- item + bag 90-degree rotation,
- rectangular regular items with selected L/T bag shapes,
- orthogonal adjacency,
- one-cell special-bag overlap activation,
- six-slot REST work buffer,
- explicit atomic first-tier combinations,
- Boss / Shop / Chest acquisition pillars,
- deterministic domain rules separated from UI,
- `BackpackState + BackpackResolver + RestBackpackSession + CombinationResolver + committed RunBuildState snapshot` architecture direction,
- no permanent Meta power that overwhelms Run choices.

## 16. Current four-school philosophy protected

- 봉마: prepare space and let summons/barriers fight; mobile stronghold, not stationary tower defense.
- 천술: create statuses and transform the field through ordered reactions.
- 귀인: become stronger by sustaining dangerous close-range presence; low HP alone is not the universal core rule.
- 흑영: remove the most dangerous targets first through marks/priority/execution; targeting remains compatible with auto-combat and is influenced indirectly through position/build.

Current MVP-2 runtime is retained as evidence and migration baseline; it is not deleted just because long-term identity is sharper.

## 17. Migration boundary

### Reuse without redesign

Keep the previously approved MVP-4 T01-T07 domain direction:

`data -> BackpackState -> BackpackResolver -> RestBackpackSession -> Combination -> committed modifiers -> reward/shop/chest transactions`.

### Recalculate before implementation

The older T08-T12 assumed the obsolete linear three-segment/instant-boss composition. They are superseded for execution and must be replaced after DEC-026.

### Do not resume historical execution packages

- PR #17 is closed and unmerged; it is historical evidence, not a prerequisite to revive.
- `impl/mvp4-t01-spatial-data-contracts` is a historical prepared baseline, not the active implementation branch.
- Future production packages must branch from fresh merged `main` after current canon/plan readback.

## 18. Verification ceiling and next Gate

Current evidence after this document is merged will still be:

```yaml
mvp0_to_mvp3_runtime: INTEGRATED
current_regression_baseline: 250_TESTS_1624_ASSERTS_PASS_ON_PR20_HEAD
mvp4_spatial_production: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
final_calamity_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
```

Next unresolved product decision is **DEC-026: four-school Core Monster/Elite/Boss concrete attack sets and Stage pattern budget**.

Do not invent or implement DEC-026 content as part of this rebaseline.
