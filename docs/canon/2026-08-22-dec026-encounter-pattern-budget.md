# DEC-026 — Four-School Encounter / Pattern Budget

```yaml
decision_id: DEC_026
project: NINJA_SURVIVAL
status: APPROVED_BY_USER_2026_08_22
owner: PRODUCT_CANON
supersedes: DEC_026_PENDING
runtime_status: NOT_IMPLEMENTED
human_qa: NOT_RUN
```

## 1. Decision

Each school owns a distinct encounter language, but the implementation reuses a small shared attack-primitive chassis rather than building four separate combat engines.

Per school authoring target:

- `Core Monster x3`
- `Elite x1`
- `Boss x1`
- one small school gimmick library
- one Stage 4 Boss capstone pattern

School identity and Stage difficulty remain separate axes. A school can appear at Stage 1, 2, 3 or 4 without requiring four duplicated enemy sets.

## 2. Selected architecture — shared primitives + school compositions

### Rejected A — fully unique logic per school

Strongest identity, but too expensive for a solo MVP and likely to create four independent combat subsystems, four tuning pipelines and duplicated telegraph/accessibility work.

### Rejected B — one generic enemy set with recolors/stat scaling

Cheapest, but fails the current product promise that the four schools teach different risk-processing languages.

### Selected C — shared primitive library + school-owned compositions

Reuse a bounded primitive vocabulary:

1. `CHASE_CONTACT` — readable pursuit/contact pressure.
2. `LINE_DASH` — telegraphed line/rush.
3. `FAN_OR_ARC_PROJECTILE` — ranged directional pressure.
4. `TELEGRAPHED_ZONE` — delayed area hazard with clear expiry.
5. `SUMMON_OR_PROXY` — temporary familiar/minion/proxy pressure.
6. `MARK_OR_LINK` — visible target/relationship state that drives a later attack.
7. `PULSE_OR_RING` — radial spacing test.
8. `BARRIER_OR_LANE` — short-lived movement-shaping obstacle/lane.

A school encounter combines these primitives with school-specific timing, visuals, status hooks and priorities. New primitives require evidence that the existing vocabulary cannot express the desired player test.

## 3. Stage timing budget

Authoring defaults for a normal school battlefield:

| Time | Purpose |
|---|---|
| `0:00–0:30` | school signature must become legible |
| `0:30–1:45` | Core language introduction / low-complexity mixing |
| `1:45–2:45` | pressure increase / interaction rehearsal |
| `~2:45` | Elite warning |
| `~3:00` | Elite enters |
| `~3:00–3:30` | Elite resolution target |
| Elite death | chest token + non-expiring trace |
| Trace AVAILABLE | stop new normal spawns; current hazards and clock continue |
| `~4:20` | earliest Boss warning if gate is satisfied or begin late-recovery warning flow |
| `~4:30` | earliest Boss appearance |
| `~5:00–5:30` | Boss clear target; soft overtime, never hard fail solely from time |

Exact numbers remain tuning values, not hidden difficulty multipliers that may silently invalidate telegraphs.

## 4. Stage pattern budget

The Stage index increases mechanic depth, not just HP/damage.

| Stage | Encounter budget | Advanced gimmicks | Boss capstone |
|---|---|---:|---|
| 1 | base school signature + simple Core combinations | max 1 active major hazard | disabled |
| 2 | add one interaction pattern that asks the player to combine two learned responses | max 1 advanced gimmick at once | disabled |
| 3 | add one synergy/field pattern; Core composition may deliberately create cross-pressure | max 2 advanced gimmicks at once | disabled |
| 4 | mastery mix of learned patterns + one school Boss capstone | max 2 advanced gimmicks at once | enabled |

Global safety rule: **never require the player to parse more than two advanced gimmicks concurrently**. Density and stats may rise through Stage profiles, but telegraph readability must not be traded away simply to make later stages harder.

## 5. Telegraph / fairness budget

Authoring floors before human tuning:

- Core dangerous committed attack: visible anticipation whenever the hit is not safely readable from motion alone.
- Elite major attack: clear pre-attack tell + stable hazard language reused in the Boss when possible.
- Boss major attack: visually unique tell, readable origin/direction and explicit safe-response opportunity.
- persistent zones/barriers: visible boundary and expiry/fade cue.
- mark/link attacks: visible ownership and release cue; no invisible target selection.
- Stage scaling must not reduce warning time below the verified human-readable floor; difficulty should prefer composition, density, positioning and pattern overlap within the concurrency cap.

These are authoring rules. Final warning durations require release-near Vertical Slice evidence.

## 6. School encounter sets

### 6.1 봉마류 — mobile stronghold / prepared space

Player test: **keep moving while reading and breaking prepared hostile space**.

Core Monsters:

1. `봉인 추적자` — `CHASE_CONTACT` + short `TELEGRAPHED_ZONE`; leaves a brief seal where it commits, encouraging route planning rather than stationary camping.
2. `식신 사역자` — `SUMMON_OR_PROXY`; periodically releases a small proxy that pressures the player's current path.
3. `결계 운반자` — `BARRIER_OR_LANE`; creates a short-lived barrier segment that redirects movement but never fully cages the player.

Elite — `이동진 술사`:

- repositions before establishing two temporary seal anchors,
- alternates proxy pressure with barrier lanes,
- killing the Elite immediately stops future anchor creation; existing short-lived hazards resolve normally.

Boss — `백귀진 주재자`:

- cycles relocate -> seal field -> proxy wave -> lane break,
- teaches that the safe answer is continuous route adaptation, not standing inside a permanent bunker,
- Stage 4 capstone: `삼중 이동봉진` — three sequentially telegraphed anchors reshape the route, but only two advanced hazards may overlap.

### 6.2 천술류 — status setup / elemental reaction

Player test: **read setup first, then react to the transformation that follows**.

Core Monsters:

1. `화인 술사` — `FAN_OR_ARC_PROJECTILE`; applies a visible hot-zone setup.
2. `수맥 술사` — `TELEGRAPHED_ZONE`; creates a slowing/wet field with clear boundary.
3. `뇌쇄 술사` — `MARK_OR_LINK`; telegraphs a short lightning link that becomes dangerous when it intersects an existing setup zone.

Elite — `오행 조율자`:

- alternates two-element setup pairs,
- always presents setup before reaction,
- reaction clears or transforms the prior setup instead of indefinitely stacking hazards.

Boss — `천변 도사`:

- uses ordered setup -> reaction sequences with recognizable elemental tells,
- Stage 4 capstone: `연쇄 오행전환` — two previously learned setup types resolve in sequence, never as an unreadable all-element burst.

### 6.3 귀인류 — sustained close-range danger

Player test: **manage proximity and escape windows while the enemy tries to keep the fight close**.

Core Monsters:

1. `쇄도 권객` — `LINE_DASH`; commits through the player and creates a reposition window after the dash.
2. `압박 승병` — `PULSE_OR_RING`; slow approach with periodic close-range ring pressure.
3. `귀혈 추적자` — `CHASE_CONTACT` + visible enrage after sustained proximity; disengaging resets the pressure rather than requiring low HP play.

Elite — `난전 대장`:

- chains dash -> proximity pulse -> recovery window,
- rewards crossing through/around the attack rhythm instead of merely kiting forever.

Boss — `귀신장`:

- heavy charge, slam ring and brief pursuit phases,
- cannot permanently stick to the player; every committed sequence has a readable recovery window,
- Stage 4 capstone: `연속 귀혈쇄도` — feint + two committed rushes with distinct tells; no unavoidable contact-lock chain.

### 6.4 흑영류 — threat priority / mark / execution

Player test: **recognize which hostile source is about to become lethal and reposition so the automatic build removes or avoids it first**.

Core Monsters:

1. `표창 척후` — `FAN_OR_ARC_PROJECTILE`; repositions to flank before throwing a readable spread.
2. `독영 살수` — `TELEGRAPHED_ZONE`; leaves a small temporary poison lane rather than permanent arena denial.
3. `암표 추격자` — `MARK_OR_LINK`; marks the player, then performs a delayed line execution with a visible release cue.

Elite — `그림자 두령`:

- creates one marked execution threat while a second low-complexity attacker pressures positioning,
- target-priority readability comes from threat presentation and proximity, not manual mouse targeting.

Boss — `야행 처형자`:

- alternates mark -> reposition -> execution and clone/proxy feints,
- false clones use lower visual weight than the real execution source,
- Stage 4 capstone: `삼영 처형선` — three announced execution lines resolve sequentially; no simultaneous opaque one-shot lattice.

## 7. Boss and Elite ownership rules

- Elite and school Boss may not be active at the same time.
- Elite death is the only source of that encounter's chest token + trace event.
- Boss spawn still requires the DEC-024 dual gate: Elite clear + trace recovered + earliest-time/warning gate.
- A school Boss should remix the school's Core language; it should not introduce an unrelated mini-game.
- Final calamity later recombines learned school languages. DEC-026 does not finalize the final calamity's exact full attack script.

## 8. Implementation data boundary

Do not hardcode `school x stage x enemy` as sixteen hand-built controllers.

Preferred data shape:

`SchoolEncounterDefinition`

- school id
- Core Monster definition refs x3
- Elite ref
- Boss ref
- school gimmick/pattern refs

`StageEncounterProfile`

- Stage index 1..4
- density/stat multipliers
- allowed pattern-depth tier
- concurrent advanced-gimmick cap
- Boss capstone enabled flag

`EncounterPatternDefinition`

- primitive id
- telegraph parameters
- execution parameters
- tags / school presentation hooks

Current runtime controllers remain reusable where their responsibility matches; new data/domain owners must not duplicate combat authority inside UI.

## 9. Vertical Slice first

Do not author all four schools to production completeness before testing one school end-to-end.

First implementation/human gate:

`school signature <=30s -> Core pressure -> ~3m Elite -> trace -> ~5m Boss -> reward -> branch -> Persistent Workbench -> next-route preview`.

Recommended first representative slice: **천술류**, because its current MVP-2 status/reaction runtime is the closest product-fit baseline and therefore isolates new Stage/Elite/trace/Boss/Workbench migration risk instead of simultaneously rewriting school identity.

After that slice passes technical and human gates, port the shared encounter chassis to 봉마 -> 귀인 -> 흑영, tuning their product-identity deltas independently.

## 10. Benchmark evidence used

- Brotato official Steam page: auto-firing combat, short waves, between-wave shop and sub-30-minute runs support keeping combat readability and rest/build decisions distinct.
  - https://store.steampowered.com/app/1942280/Brotato/
- Halls of Torment official Steam page explicitly emphasizes diverse bosses with unique mechanics and attack patterns, supporting school-specific Boss language rather than pure stat scaling.
  - https://store.steampowered.com/app/2218750/Halls_of_Torment/

These are pattern references, not feature-copy requirements.

## 11. Five-round adversarial review

### Loop 1 — school identity

Attack: shared primitives could make all four schools feel reskinned.

Correction: school identity is defined by the **question posed to movement/build** (prepared space / setup-reaction / sustained proximity / threat execution), not by primitive ownership. Bosses remix that language.

### Loop 2 — fairness and readability

Attack: later Stages could become difficulty-by-overlap and erase readable telegraphs.

Correction: concurrent advanced gimmick cap is 2; Stage scaling cannot silently shrink telegraph time below human-verified floors.

### Loop 3 — auto-combat compatibility

Attack: Heukyeong threat priority might require direct targeting, while Guiin might require deliberate damage-taking.

Correction: Heukyeong remains indirect through position/threat presentation; Guiin rewards proximity duration and recovery windows rather than low HP as the universal rule.

### Loop 4 — solo production cost

Attack: 12 Core + 4 Elite + 4 Bosses could still multiply authoring before the fun is proven.

Correction: implement one school Vertical Slice first, reuse the shared chassis, then expand only after evidence.

### Loop 5 — run pacing

Attack: four ~5-minute fields plus rests/final battle risks run fatigue.

Correction: DEC-026 keeps each school combat budget near the existing ~5-minute target, avoids extra mid-field draft interruptions, and requires Human QA to measure Workbench/rest fatigue before four-school multiplication.

## 12. Result

`DEC-026 = APPROVED`.

This closes the missing encounter/pattern input required to recalculate T08+ and run a fresh Phase-B Definition of Ready. It does **not** claim any new runtime implementation or player-experience PASS.
