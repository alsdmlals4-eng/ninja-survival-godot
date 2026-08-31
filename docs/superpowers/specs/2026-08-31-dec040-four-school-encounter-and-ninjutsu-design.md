# DEC-040 — Four-School Encounter Roster and Ninjutsu Design

> **Status:** `USER_DESIGN_APPROVED_IMPLEMENTED_MACHINE_SCOPE_ROSTER_BOARD_USER_LOCKED_ONE_RUNTIME_ACTOR_ASSET_REGISTERED_MACHINE_VERIFIED_FAMILY_PARTIAL`
> **Product owner:** current user instruction, 2026-08-31 KST
> **Canon dependencies:** DEC-026 shared primitives and school encounter data; DEC-037 one directly moved Ninja; DEC-039 automatic katana/shuriken plus one selected-school starter ninjutsu.
> **Current branch baseline:** `codex/dec037-runtime-migration-135` at `3e9c46f` before this design-only commit; PR #135 remains open and unmerged.

## 1. Goal and acceptance outcome

Make the four traditions feel like four different battlefields rather than
four labels over the same generic enemy and one reused Boss. The deliverable
contains a complete, machine-testable roster for every school:

| Per school | Count | Total |
| --- | ---: | ---: |
| Core enemies | 3 | 12 |
| standalone Elite mini-Bosses | 1 | 4 |
| school Bosses | 1 | 4 |
| automatic ninjutsu | 3 | 12 |

Every school has exactly one ranged Core enemy. Every Elite and Boss uses
readable attack **patterns** and an explicit visual **telegraph** before the
harmful portion begins. Each Boss owns two or three school-specific techniques
that remix its Core language. An Elite is a dedicated character, definition,
visual and attack sequence; it must never be a scaled `EnemyBasic` instance.

The player still starts every combat with exactly three automatic patterns:
Japanese katana, shuriken, and the selected school's starter ninjutsu. The
other two spells of that school are acquired as scrolls and become additional
automatic patterns during the same Run; there are no manual skill buttons,
aiming reticles or player-body attack poses.

## 2. Confirmed product decisions

1. Existing `SchoolEncounterDefinition` names/IDs are the roster's identity
   owner. The new implementation gives those already-approved entries real
   actors, assets and attacks; it does not rename them or collapse them into
   generic variants.
2. A Core roster is `contact pressure + one ranged threat + one school-signature
   pressure`. The ranged slot is intentionally visible and responds to player
   movement; it does not turn the game into a manual aiming game.
3. Elite spawn, death, chest token and Trace authority remain in
   `StageEncounterState` / `SchoolCircuitController`. Elite death alone opens
   the existing Trace route.
4. Boss appearance still requires Elite clear, Trace recovery and the existing
   time/warning gate. Boss death still enters the Workbench flow.
5. Bosses pause normal spawning through the existing lifecycle permission.
   The uncapped normal-horde rule is not moved into an actor or Boss script.
6. Ninjutsu belongs to the moving Ninja's current Run loadout, not the
   battlefield currently selected. A spell acquired after clearing 봉마류 can
   therefore remain active when the player travels to the next Stage.
7. Scrolls do not occupy Backpack cells and do not alter the protected 19-item
   spatial catalog, geometry, CombinationResolver or Fate transaction. They
   are a separate automatic-combat loadout with its own explicit acquisition
   receipts.

## 3. Player-facing content contract

### 3.1 봉마류 — 이동 요새 / 봉인과 식신

| Role | ID / name | Player-visible behavior | Telegraph / recovery |
| --- | --- | --- | --- |
| Core A | `seal_chaser` / 봉인 추적자 | Close pursuit that briefly overcommits after contact pressure. | Red-gold seal on the ground beneath its next lunge; short open recovery after it misses. |
| Core B — ranged | `shikigami_handler` / 식신 사역자 | Fires a slow blue paper-shikigami bolt toward the Ninja from outside contact range. | Paper charm lifts and points at the firing line before launch. |
| Core C | `barrier_carrier` / 결계 운반자 | Places one temporary blocking seal lane that asks the player to route around it. | Thin square seal border fills from dim gold to bright gold before the lane becomes harmful. |
| Elite | `mobile_array_caster` / 이동진 술사 | Alternates a relocating seal anchor and a short-lived proxy summon; it is a moving mini-Boss, not a large pursuer. | Anchor glyph appears before relocation; proxy silhouettes remain visibly lighter than the Elite. |
| Boss | `hundred_demon_array_master` / 백귀진 주재자 | `유동봉진`: moves a circular seal field; `백귀분령`: creates two fragile proxies; `절단봉쇄`: announces and then closes one seal lane. Stage 4 adds `삼중 이동봉진` sequentially. | Every anchor, proxy source and lane has a bright gold/red glyph and a visible dissolve/recovery cue. |

Ninjutsu: `백귀 식신` (starter, existing familiar attack), `봉인쇄` (Elite chest scroll, nearest enemy seal latch plus short slow/impact), `수호결계` (Boss reward scroll, periodic player-centered ward pulse that damages and gives a visible safe-space edge).

### 3.2 천술류 — 원소 설정 / 순서 있는 반응

| Role | ID / name | Player-visible behavior | Telegraph / recovery |
| --- | --- | --- | --- |
| Core A — ranged | `fire_mark_caster` / 화인 술사 | Fires an amber fan of flame marks toward the Ninja. | Caster's fan and arc line light up before the bolts leave. |
| Core B | `water_vein_caster` / 수맥 술사 | Creates one temporary wet/slowing circle. | Blue boundary expands first and fades at expiry. |
| Core C | `lightning_chain_caster` / 뇌쇄 술사 | Links a prepared source to a marked target with a delayed lightning line. | Violet endpoints and an explicit line show the future discharge. |
| Elite | `five_element_tuner` / 오행 조율자 | Alternates two-element setup pairs and resolves only the displayed reaction. | Both setup colors are present before the reaction; the first field clears/transforms rather than stacking forever. |
| Boss | `heavenly_change_taoist` / 천변 도사 | `화인풍쇄`: fan flame arc; `수맥천환`: shifting wet zone; `뇌쇄연결`: delayed chain discharge. Stage 4 uses `연쇄 오행전환` as two sequential, announced reactions. | Distinct amber, blue and violet sources always precede their execution; no all-element burst without setup. |

Ninjutsu: `화염 인장` (starter, existing flame/status cycle), `수맥 결박` (Elite chest scroll, wet field that primes reactions), `뇌쇄 전이` (Boss reward scroll, chain discharge prioritizing wet/marked targets).

### 3.3 귀인류 — 위험한 근접 지속 / 돌파와 회복 창

| Role | ID / name | Player-visible behavior | Telegraph / recovery |
| --- | --- | --- | --- |
| Core A | `surge_fighter` / 쇄도 권객 | Commits to a straight rush past the Ninja, opening a crossing/reposition window after it ends. | Body leans, weapon trail draws a straight red path, then a clear stop/recovery. |
| Core B — ranged | `pressure_monk` / 압박 승병 | Fires a slower compressed-force orb that blooms into a small ring at its destination. | A red-black hand seal and expanding target ring show where it will land. |
| Core C | `ghost_blood_chaser` / 귀혈 추적자 | Escalates close pursuit only after sustained proximity, then loses pressure when the player disengages. | Crimson pulse meter and shoulder aura build visibly, then cool down while separated. |
| Elite | `melee_chaos_captain` / 난전 대장 | Cycles dash -> proximity ring -> explicit recovery window. The player wins by crossing or orbiting through its rhythm, not by infinite kiting. | Dash line and ring boundary are shown before impact; the captain visibly staggers after the sequence. |
| Boss | `ghost_general` / 귀신장 | `혈귀 돌진`: heavy charge; `귀혈진`: delayed slam ring; `추혼 압박`: short pursuit phase with a forced recovery. Stage 4 adds `연속 귀혈쇄도` as feint plus two separately telegraphed rushes. | Each phase has its own red/black tell; no permanent contact lock or opaque multi-rush. |

Ninjutsu: `귀혈파` (starter, existing close pulse), `잔영 쇄도` (Elite chest scroll, a spectral line attack that does not move the player), `수라진` (Boss reward scroll, periodic expanding melee ring with a readable outer edge).

### 3.4 흑영류 — 위협 우선 / 표식과 처형

| Role | ID / name | Player-visible behavior | Telegraph / recovery |
| --- | --- | --- | --- |
| Core A — ranged | `shuriken_scout` / 표창 척후 | Repositions to a flank and throws a readable three-shuriken spread. | Throws from a dark-purple wind-up with three thin projected paths. |
| Core B | `poison_shadow_assassin` / 독영 살수 | Leaves one small temporary poison lane behind its relocation. | Purple stain outline arrives before the damaging center; it dissipates visibly. |
| Core C | `dark_mark_pursuer` / 암표 추격자 | Marks the Ninja, then releases a delayed line execution. | Eye-mark on the player and an obvious release line identify the source and timing. |
| Elite | `shadow_chief` / 그림자 두령 | Creates one marked execution threat while one lower-weight shadow proxy adds positional pressure. | The real chief has a sharp purple outline; proxy opacity and VFX weight are intentionally lower. |
| Boss | `night_executioner` / 야행 처형자 | `흑영 낙인`: target mark; `야행 분신`: repositioning feint with one weak proxy; `처형선`: announced execution line. Stage 4 adds `삼영 처형선` as three sequential lines. | Never uses simultaneous opaque one-shot lattice; true source, target and release cue remain legible. |

Ninjutsu: `암영침` (starter, existing mark needle), `독무 장막` (Elite chest scroll, small poison zone at the highest-priority nearby enemy), `사슬 처형` (Boss reward scroll, executes or heavily damages the most-marked valid target through the current resolver).

## 4. Acquisition and combat flow

```text
select a Stage
-> katana + shuriken + selected-school starter ninjutsu activate
-> Elite defeat grants the existing chest token and Trace
-> chest resolution at the ensuing Workbench grants that cleared school's Elite-scroll ninjutsu
-> Boss reward lane grants that cleared school's Boss-scroll ninjutsu
-> loadout commits atomically with the existing Workbench/Fate/next-route transaction
-> acquired ninjutsu remain automatic patterns in the later Stages of this Run
```

The chest and Boss reward each carry exactly one school-scroll receipt for the
cleared school. A scroll does not compete with a Backpack item choice in a
flat pool: it is a separately labeled tradition lane, shown alongside existing
Workbench facts and committed only at the existing atomic boundary. The
starter is free and immediate; the two scroll spells cannot become active by
manual input or by a generic UI toggle.

## 5. Runtime architecture

### 5.1 Encounter actors

Create a reusable `SchoolEncounterActor` that extends `EnemyChaser` and is
configured by a new immutable `EncounterActorDefinition` resource. The
definition contains identity, school ID, role (`core`, `elite`, `boss`), base
stats, texture path, contact shape/scale, attack pattern definitions, and
telegraph/visual resource references. `MainController` remains responsible
only for spawning an already chosen definition and attaching existing
role/encounter metadata; it does not decide attacks, visuals or school stats.

Core actors are selected from the existing `next_core_encounter()` stream.
Elites and Bosses are selected by the `elite_id` / `boss_id` already supplied
by `SchoolEncounterDefinition`. Generic `EnemyBasic` remains a normal-horde
fallback only until every authored Core definition is bound; it is never used
for a school Elite or Boss.

Create a reusable `EncounterPatternController` child for actors. It owns a
data-defined cadence and state sequence:

```text
idle/chase -> telegraph -> execute -> recovery -> idle/chase
```

The controller supports only the DEC-026 primitive vocabulary: contact,
line dash, fan/arc projectile, telegraphed zone, summon/proxy, mark/link,
pulse/ring and barrier/lane. It does not create a second WaveSpawner, own
route/Trace/Boss gates, or modify Backpack/Fate authority. Harm uses the
existing Player damage path so dash invulnerability stays authoritative.

### 5.2 Ninjutsu loadout

Create a Run-scoped `NinjutsuLoadoutState` node configured by a static
`NinjutsuCatalog`. It owns only:

- the selected school's starter spell;
- acquired Elite/Boss scroll spell IDs;
- defensive snapshots and atomic pending-to-committed transition;
- duplicate/unknown/foreign-school rejection receipts.

`SchoolRuntimeHost` continues to own exactly one selected school runtime.
It receives the committed ninjutsu set and activates its school-specific
automatic spell controllers. Base weapons remain in `BasicWeaponController`;
school modifiers remain in `CombatResolver`; no spell logic goes into the HUD.

### 5.3 Workbench integration

`SchoolCircuitController` adds pending scroll state to the same snapshot that
already owns pending Boss reward, Chest and Fate facts. Its existing atomic
commit coordinator gains the scroll-set validation before it publishes the
new `RunBuildState` / route tuple. If any normal Workbench commit prerequisite
fails, no new spell is activated. Existing spatial item placement, bag
purchase, combination and route selection retain their current owners.

### 5.4 Implemented machine scope and remaining asset boundary

The data roster, reusable encounter actor, telegraph/recovery execution,
automatic scroll-loadout and four-Stage Core -> Elite -> Trace -> Boss ->
Workbench contract are implemented on the current unmerged branch. The Elite
receipt is staged at Elite defeat beside the existing chest-token event, and
the Boss receipt is staged only after the chosen Boss reward; both remain
inactive until the existing Workbench transaction atomically commits Backpack,
Fate, next Stage and valid pending scrolls.

The implementation deliberately uses the already locked generic
`basic_weapon_effects_v1.png` only as a temporary machine-test fallback for
unlocked scroll effects. The former external Cheonsul Elite style exploration
remains historical `GENERATED_CANDIDATE` only: it has no repository source or
runtime consumer and is not promoted.

The required art-direction prerequisite is met by the user-locked planning reference
`DEC040_FOUR_SCHOOL_CORRUPTED_YOKAI_ROSTER_01` at
`docs/visual/enemy-references/four-school-corrupted-yokai-roster-v1.png`
(SHA-256 `a49717d3783dd47593f26f9d9f5ed04c49de57aa5aa8c506b811f27b280ed9da`).
It locks the enemy direction to corrupted ninjas and hostile yokai with a
small-Core versus broader-Elite/Boss hierarchy. It is not itself a runtime
texture or a license to bind a board figure to an actor.

The first individual runtime promotion is now complete for the user-locked
봉마류 Elite `mobile_array_caster` / 이동진 술사. Its exact RGBA source is
`assets/runtime/encounters/actors/mobile_array_caster.png` (SHA-256
`1e145d6e00a0322c894cc3b1384a65c9d225b16a700093dd76eb205efd62fbfd`), and
`SchoolEncounterActor/Visual` loads that catalog path directly. Godot import
and a focused source/manifest/consumer test pass. This is one of twenty actor
cutouts only; the remaining 19 actor, 12 ninjutsu and shared telegraph sources
remain separate unapproved candidates. No family-level asset-completeness or
runtime-render claim is made from this individual promotion.

## 6. Image asset plan and gate

The required visual family has 20 transparent character cutouts and 12
transparent spell-effect cutouts. Each asset must follow the approved runtime
style: top-down/three-quarter readable silhouette, dark moonlit anime ink
finish, black/deep-navy base, school accent colors, transparent RGBA corners,
no text/UI/watermark, and a strong contact-shadow-compatible lower silhouette.

| Family | Asset count | Runtime consumer | State at this design stage |
| --- | ---: | --- | --- |
| Core/Elite/Boss character cutouts | 20 | `SchoolEncounterActor/Visual` | `1 USER_LOCKED + repository-registered + import/focused-machine-verified (mobile_array_caster); 19 NEEDED — each candidate still needs its own lock` |
| Ninjutsu visual cutouts/fields | 12 | school spell controllers | `NEEDED — roster-board prerequisite is USER_LOCKED; each runtime candidate still needs its own lock` |
| Boss/Elite telegraph effects | bounded per shared primitive, reused by school color hook | `NEEDED — roster-board prerequisite is USER_LOCKED; each runtime candidate still needs its own lock` |
| Four-school roster art-direction board | 1 | planning/review only; not runtime | `USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME` |

The user locked the conforming roster art-direction board after its review.
Its four palettes, corrupted-ninja/yokai enemy rule and Elite/Boss silhouette
separation are now the brief for the first bounded runtime state-family
candidate. The board itself has no runtime consumer. Every later runtime PNG
still requires its own user lock, repository source, SHA-256, manifest entry,
explicit state/consumer mapping and import evidence before it is promoted.

## 7. Data and validation rules

1. There are exactly 20 encounter actor definitions: 12 Core, four Elite and
   four Boss definitions. Each has a unique ID matching the current encounter
   catalog.
2. Each school has exactly three Core definitions, exactly one of which has
   the `ranged` tag and a non-empty ranged pattern.
3. Every Elite has at least two pattern definitions; every Boss has two or
   three school-specific pattern definitions. Every damaging pattern has a
   non-empty telegraph definition and a recovery state.
4. Every Boss references only its school accent/presentation hook and remixes
   that school's Core primitives; a Boss cannot silently use another school's
   visual/attack definition.
5. There are exactly 12 ninjutsu definitions: one `starter`, one
   `elite_scroll`, and one `boss_scroll` per school. A foreign-school scroll
   cannot be offered by a cleared school's reward lane.
6. Starter spells are active at selected Stage start; scroll spells are absent
   before their respective atomic Workbench acquisition and remain available
   after a later Stage selection within that Run.
7. Every named character/VFX PNG must be distinct from the approved generic
   yokai pool and from the existing Cheonsul-only Boss art. Scaling a generic
   actor cannot satisfy an Elite/Boss binding test.

## 8. Verification and evidence ceiling

Machine tests must cover actor/catalog cardinality, unique IDs, one ranged
Core per school, Elite/Boss pattern/telegraph requirements, wrong-school
binding rejection, generic-actor rejection for Elite/Boss spawns, player dash
damage immunity during an actor's damaging phase, and Ninjutsu acquisition
atomicity/retention. Integration tests must run all four selected schools
through Core -> Elite -> Trace -> Boss -> Workbench and verify the exact actor
and spell-reward identities.

Godot import/parser, headless main-scene smoke and full GUT are required on
the exact branch head. Render observation must separately establish that an
Elite looks unlike its Core units, a Boss technique telegraph is visible before
harm, and a ranged Core is readable amid the uncapped horde. Human Usability,
Player Experience, balance, frame-performance at uncapped density,
touch/gamepad and device/export remain `NOT_RUN` until actually observed.

## 9. Alternatives considered

| Approach | Result | Reason |
| --- | --- | --- |
| Scale/recolor the three generic yokai for every school role | `REJECT` | Violates the user's Elite/Boss identity requirement and provides no school-specific telegraph language. |
| Write 20 unrelated actor controllers | `REJECT` | Duplicates timing/damage/telegraph logic and makes the Stage 1–4 safety budget difficult to validate. |
| Reusable encounter chassis + immutable school actor/pattern data + distinct assets | `ADOPT` | Keeps actual identity and Boss tactics while preserving singular movement, route, reward and damage owners. |
| All three school spells active at Stage start | `REJECT` | Breaks the already-approved three-pattern starting contract and makes early horde readability worse. |
| Starter + Elite-scroll + Boss-scroll progression | `ADOPT` | Satisfies the user's scroll rule while fitting the existing Elite/Trace/Boss/Workbench rhythm and later-Stage build growth. |

The horde-survival benchmark supports the broad choice of overlapping automatic
patterns and distinct boss pressure, but it does not prescribe the roster,
names, tuning, assets or UI. This game keeps its current dark Korean ninja
fantasy, automatic combat and player-controlled movement identity.

## 10. Explicit exclusions

- No manual spell button, ultimate button, aim reticle or player attack pose.
- No new global autoload, save/meta progression, paid tool or second normal
  wave system.
- No generic flat reward pool that bypasses Chest/Boss/Workbench lanes.
- No visual asset is treated as approved, implemented or runtime-verified
  before the candidate `LOCK` and its subsequent repository evidence gates.
- No Human/balance/performance claim from catalog tests or a generated image.
