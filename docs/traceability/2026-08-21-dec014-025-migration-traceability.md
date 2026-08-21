# DEC-014~025 Migration Traceability

```yaml
packet_id: NINJA_SURVIVAL_DEC014_025_MIGRATION_2026_08_21
source_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
runtime_baseline: MVP_0_TO_3_INTEGRATED
old_mvp4_plan: docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md
old_mvp4_traceability: docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md
coverage_status: GAP
blocking_product_gate: DEC_026
```

## 1. Purpose

This packet recalculates what remains reusable from the approved 2026-08-11 MVP-4 plan after DEC-014~025 changed the Run structure.

It is a traceability document, not an implementation-complete claim and not permission to invent unresolved DEC-026 attack/pattern content.

## 2. Reuse verdict for old MVP-4 tasks

| Old task | Capability | Verdict | Reason |
|---|---|---|---|
| T01 | spatial item/bag/catalog contracts | `REUSE` | DEC-014~025 does not replace 6x6/4x3/rotation/content identity |
| T02 | BackpackState | `REUSE` | still required as committed spatial source of truth |
| T03 | BackpackResolver | `REUSE` | adjacency/connectivity/special-bag rules unchanged |
| T04 | RestBackpackSession | `REUSE_WITH_ROUTE_COMMIT_EXTENSION_LATER` | session remains owner of Workbench edits; route is a separate provisional input |
| T05 | CombinationResolver | `REUSE` | first-tier atomic combinations unchanged |
| T06 | committed RunBuildState modifiers | `REUSE` | actual power still comes from committed backpack + Fate |
| T07 | Boss/Shop/Chest transactions | `REUSE_WITH_ACCESS_LANES` | acquisition sources remain but DEC-019/021 add access-package/lane eligibility |
| T08 | elite/cadence/stage flow | `SUPERSEDED_FOR_EXECUTION` | old immediate-boss/three-segment assumptions conflict with Elite->Trace->Boss + four-school circuit |
| T09 | Workbench UI | `RECALCULATE` | must include provisional route preview/selection and trace/access state |
| T10 | input/responsive parity | `RECALCULATE` | route preview/commit adds focus/touch requirements |
| T11 | full composition/Fate commit | `SUPERSEDED_FOR_EXECUTION` | Fate now atomically commits backpack + Fate + next school; four-school completion no longer means Run complete |
| T12 | verification/human evidence | `RECALCULATE` | release-near one-school Vertical Slice and later four-school/final-run evidence are distinct gates |

The old plan remains historical and authoritative for T01-T07 details unless a later approved decision explicitly changes those low-level contracts.

## 3. New migration requirements

### MIG-01 — School circuit state ownership

**Decision inputs:** DEC-014, DEC-015, DEC-025.

Required behavior:

- track four schools as `unvisited / provisional-next / cleared`,
- preserve clear order,
- expose Stage index 1..4 separately from school identity,
- reject revisiting a cleared school,
- allow provisional route changes during Workbench,
- commit next route only with Fate/build commit,
- after fourth school Boss/rest route to final-rest/final-battle state, not normal Stage 5.

**Architecture direction:** add one bounded Run-level circuit/route state owner instead of overloading school runtime classes or hardcoding route order in UI.

**Status:** `PLANNED / NOT_IMPLEMENTED`.

### MIG-02 — School encounter definitions and Stage profiles

**Decision inputs:** DEC-017 and DEC-026.

Required behavior already approved:

- school owns Core Monster x3 + Elite x1 + Boss x1 + gimmick library,
- Stage 1 base signature,
- Stage 2 interaction gimmick,
- Stage 3 synergy/field gimmick,
- Stage 4 mastery + one Boss advanced pattern,
- default concurrent advanced-gimmick cap 2,
- compose school encounter identity with Stage difficulty profile rather than hardcoding 16 variants.

**Blocked detail:** exact Core Monster/Elite/Boss attack sets and Stage pattern budget are DEC-026.

**Status:** `BLOCKED_DEC026`.

### MIG-03 — Elite -> Trace -> Boss gate

**Decision inputs:** DEC-016/019, DEC-024.

Required behavior:

- Elite warning around 2:40 and Elite opportunity around 3:00,
- Elite actual death grants chest token exactly once,
- separate non-expiring trace object/state,
- trace auto-approach/close-range absorption and no ORB/STYLE/GOLD side effects,
- pause new normal spawns while trace is AVAILABLE without pausing combat clock/current hazards,
- Boss requires Elite clear + trace recovered + earliest-time + warning complete,
- late trace recovery produces soft overtime rather than hard fail,
- access package opens only on Boss clear + branch return stabilization.

**Status:** `PLANNED / NOT_IMPLEMENTED`.

### MIG-04 — Access packages and reward lanes

**Decision inputs:** DEC-019, DEC-021, DEC-021A.

Required behavior:

- distinguish access package, affinity/tag, reward lane and actual backpack power,
- Run starts with Universal + starting-school package,
- stabilized trace unlocks that school package,
- Boss/Shop/Chest choose lane/pool before item,
- canonical item-ID deduplication across overlapping lanes,
- combo-result IDs remain outside base acquisition unless a later decision says otherwise,
- preserve existing 19 item identities, 3 combinations and 5 bags.

**Status:** `PLANNED / old T07 requires bounded amendment`.

### MIG-05 — Route preview + atomic Fate commit

**Decision inputs:** DEC-015, DEC-025.

Required behavior:

- show only unvisited schools,
- expose readable risk/gimmick/reward/current-build links without exact hidden tuning values,
- selection remains provisional through Workbench edits,
- Fate commit is atomic for `backpack + fate + next_school`,
- failed commit leaves all three unchanged,
- route history remains visible and later feeds final support order.

**Status:** `PLANNED / NOT_IMPLEMENTED`.

### MIG-06 — Final binding and final-battle routing

**Decision inputs:** DEC-018, DEC-020, DEC-022.

Required behavior:

- fourth school clear opens Final Binding Workbench rather than normal Run completion,
- all four access packages remain open,
- no new final automatic stat tree,
- final Boss reuses previously learned school languages,
- each liberated school supplies one short automatic/situational support callback in clear order,
- callbacks cannot auto-win or replace player damage/build ownership,
- final actual victory remains player-backpack-owned.

**Blocked detail:** exact final Boss attack set/pattern timing remains downstream of DEC-026 and later final-boss implementation planning.

**Status:** `PARTIAL_SPEC / NOT_IMPLEMENTED`.

### MIG-07 — Four-school identity migration

**Decision inputs:** DEC-010/011 protected by current canon.

Keep current MVP-2 runtime as regression evidence while later playtesting evaluates:

- 봉마 fixed ward -> mobile stronghold expression,
- 귀인 low-HP-only emphasis -> dangerous close-range presence,
- 흑영 nearest-target rule -> threat-priority execution compatible with auto-combat,
- 천술 current reaction loop as the closest existing product-fit baseline.

Do not change all four simultaneously before one-school Vertical Slice evidence.

**Status:** `DEFER_TO_VERTICAL_SLICE_TUNING`.

### MIG-08 — Release-near Vertical Slice evidence

The first human player-experience gate should be one school end-to-end rather than waiting for all four schools.

Minimum representative slice:

```text
starting school signature within ~30 sec
-> Core Monster pressure
-> ~3 min Elite
-> trace recovery
-> ~5 min Boss
-> result / guaranteed-readable reward
-> branch return
-> Persistent Workbench with real backpack placement/combination decision
-> provisional next-route preview
```

Human evidence must evaluate:

- first-30-second school readability,
- combat tension progression,
- Elite/Boss telegraph fairness,
- trace clarity,
- Workbench comprehension and fatigue,
- whether placement materially changes next-combat expectation,
- Korean UI readability with production-candidate visual/audio/VFX feedback.

Placeholder/card-only UI can remain technical evidence but cannot close this human gate.

**Status:** `NOT_RUN`.

## 4. Verification matrix

| Requirement | Automated evidence required | Human/runtime evidence | Current |
|---|---|---|---|
| MIG-01 | route-state unit tests + four-stage integration | route comprehension | NOT_RUN |
| MIG-02 | encounter/profile deterministic tests | school/Stage distinction | BLOCKED_DEC026 |
| MIG-03 | Elite/trace/Boss gate unit+integration tests | pacing/telegraph | NOT_RUN |
| MIG-04 | seeded access-lane/reward tests | reward readability | NOT_RUN |
| MIG-05 | atomic commit tests + input parity | Workbench route-choice clarity | NOT_RUN |
| MIG-06 | fourth-clear/final-routing tests | final support/build ownership | BLOCKED_PARTIAL_SPEC |
| MIG-07 | current school regression + focused tuning tests | school feel | NOT_RUN |
| MIG-08 | technical slice smoke/regression | release-near human QA | NOT_RUN |

## 5. Current protected regression baseline

Before any gameplay migration package:

- preserve Godot 4.7.1 import,
- preserve main-scene headless smoke,
- preserve source-faithful GUT preparation and duplicate-UID failure guard,
- preserve the current MVP-0~3 regression suite until a test is deliberately replaced by an approved behavior change,
- do not interpret old three-segment PASS as evidence that this migration is implemented.

Last observed pre-rebaseline PR-head evidence: 34 scripts / 250 tests / 1624 assertions PASS.

## 6. Executable-plan gate

A detailed T08+ code implementation plan must not be marked ready while DEC-026 is unresolved because exact encounter attack sets/pattern budgets are a material product/content input.

Allowed work before DEC-026:

- canon/document sync,
- current-state router correction,
- T01-T07 low-level plan preservation,
- traceability/dependency rebaseline,
- benchmark/evidence preparation for DEC-026.

Not allowed as a completion claim before DEC-026:

- `T08 implementation ready`,
- `four-school circuit production ready`,
- `final Boss implementation ready`,
- runtime/human PASS for the new product direction.
