# Ninja Survival Screen Surface & Visual Coverage

> Issue: [#93](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/93)
> Scope date: 2026-08-27 KST
> Repository baseline read: `1841041055026c4f6b211447488a682b914a57b6`
> Status: `SCREEN_INVENTORY_HANDOFF_READY_FOR_DEFERRED_HUMAN_SLICE`
> This is the project-local canonical screen-first coverage owner. It is
> subordinate to product canon and links existing asset manifests rather than
> replacing their approval, provenance, or lifecycle authority.

## 0. 2026-08-28 amendment — P0 reference creation

The user explicitly requested that missing visual work be produced after a
screen-first audit. This amendment supersedes the earlier audit's
`NO_AUTOMATIC_IMAGE_GENERATION_FROM_GAPS` boundary **only for the five current
P0 whole-screen design references**. It does not authorize an orphan runtime
texture, a replacement of an approved runtime image, or a title/save/final
screen that has no current consumer.

The initial v1 reference set was rejected before merge because it used a
poster-like, adult-proportion composition rather than the actual top-down SD
survival-game language. `docs/visual/screen-references/README.md` is the
binary/provenance owner for the following replacement references. They bind to
the supplied SD style sheet: one small black-clad ninja identity, steep
top-down combat readability, and school differentiation through effects and
symbols rather than four protagonists.

| Reference | Covers | Consumer surface | Current evidence |
| --- | --- | --- | --- |
| `SCRREF-SCHOOL-SELECT-02` | school selection | `Main/SchoolSelectionUI` | local + Notion native v2 reference stored; live composition `NOT_RUN` |
| `SCRREF-BATTLE-CHEONSUL-02` | Cheonsul battle | `Main` + HUD + runtime actors | local + Notion native v2 SD/top-down reference stored; live composition `NOT_RUN` |
| `SCRREF-WORKBENCH-02` | Workbench/Fate/preview | `Main/RestFlowUI` | local + Notion native v2 reference stored; live composition `NOT_RUN` |
| `SCRREF-RESULT-02` | result/reward | `RestFlowUI/ResultView` | local + Notion native v2 reference stored; live composition `NOT_RUN` |
| `SCRREF-GAME-OVER-02` | failure/retry | `HUD/GameOverPanel` | local + Notion native v2 SD/top-down reference stored; live composition `NOT_RUN` |

The references are production guidance, not runtime imports. The existing
actual runtime image-consumer audit remains valid: its P0 assets are already
covered by the approved local sources in `docs/assets/approved/` and
`assets/runtime/visual-core/`. Notion attachment state is recorded separately
after destination readback; do not call any row dual-stored before then.

## 1. Scope and protected boundary

### Current target build

The current target is the **Cheonsul release-near machine vertical slice**:

`launch Main -> select a starting school -> Cheonsul battlefield -> Elite -> Trace -> Boss -> Result / Boss reward pending -> Persistent Workbench -> provisional next-route and Fate intent`.

The target is not the full four-school release, title/save shell, final binding,
final calamity, platform release, or a Human-validated player experience. The
last product implementation is T16's in-combat school-help slice; live render,
Human Usability, Player Experience, touch/gamepad completion, and device/export
evidence remain `NOT_RUN` or user-deferred.

### Hard boundaries

- The earlier `NO_AUTOMATIC_IMAGE_GENERATION_FROM_GAPS` boundary is superseded
  only for this completed, replacement v2 P0 reference set. It still forbids
  runtime promotion, replacement of an approved runtime image, and expansion
  to a screen with no current consumer.
- Runtime facts come from the Godot scenes/scripts named below. A screen
  requirement is not evidence of an implemented screen.
- `SCREEN_DESIGN_REFERENCE` and runtime component assets are separate outputs.
- `docs/assets/approved/*` remains the source of asset binary/provenance truth;
  this document stores only requirement and consumer links.
- PR #49 is `OPEN_DRAFT_READ_ONLY_SUPERSEDED`; this work neither reads it as a
  baseline nor changes it.

### P0 decision

For the current machine-slice target, all P0 runtime surfaces below have an
actual Godot consumer. Their screen-composition/readability confirmation is
**deferred with the already recorded Human slice decision**, not silently
treated as passed. Therefore current P0 image-production blockers are `0`; the
explicit deferred validation gate is retained in section 7.

## 2. Target Screen Inventory

`consumer_kind` distinguishes an actual game surface from a future planned
surface. `SCREEN_DESIGN_REFERENCE` means an entire-screen hierarchy reference,
not a bitmap to place in the game.

| screen_id | family | priority / stage | entry -> exit | player goal / question | consumer & evidence | coverage status / decision |
| --- | --- | --- | --- | --- | --- | --- |
| `SCR-BOOT-DIRECT-MAIN` | Boot / splash / loading | P0 / VERTICAL_SLICE | executable start -> `SCR-SCHOOL-SELECT` | “Can I enter the current test slice?” | `project.godot` -> `scenes/main/main_scene.tscn`; no dedicated boot/loading scene | `COVERED_EXISTING` for direct development entry; release splash/loading is P2 |
| `SCR-TITLE-MENU` | Main / title menu | P2 / RELEASE | N/A -> N/A | “Start, continue, settings, quit?” | no title/menu scene or consumer | `NOT_APPLICABLE` to the direct-launch current slice; future release-shell requirement |
| `SCR-SAVE-PROFILE` | New / continue / save load | P2 / RELEASE | N/A -> N/A | “Which saved run do I play?” | no save/profile owner or scene | `NOT_APPLICABLE` to the current no-save slice |
| `SCR-SCHOOL-SELECT` | Starting build selection | P0 / VERTICAL_SLICE | direct Main start -> school selected / help dismissed | “Which danger-handling school do I start with?” | `Main/SchoolSelectionUI`; `scenes/ui/school_selection_ui.tscn`; four school buttons + Korean help dialog; integration test covers selection/help | `COVERED_EXISTING`; `SCRREF-SCHOOL-SELECT` deferred pending Human-slice visual review |
| `SCR-ROUTE-WORKBENCH` | Hub / route / build preparation | P0 / VERTICAL_SLICE | Boss-clear Workbench -> commit preview or retain pending state | “Which unvisited school and Fate should I prepare for?” | dynamically instantiated `Main/RestFlowUI`, `WorkbenchView`; `scripts/ui/rest_flow_ui.gd`; T12~T14 machine contracts | `COVERED_EXISTING` for runtime contract; `SCRREF-WORKBENCH` deferred; backpack placement/Boss-reward interaction remains an implementation gap |
| `SCR-BATTLE-CHEONSUL` | Core gameplay / battle | P0 / VERTICAL_SLICE | school selected -> Elite/Trace/Boss/result/game over | “How do I survive and read Cheonsul's status/reaction field?” | `scenes/main/main_scene.tscn` + Player / Enemy / HUD / WaveSpawner / Cheonsul runtime; `BattlefieldBackdrop`; automated Main and slice tests | `COVERED_EXISTING` for actual scene; `SCRREF-BATTLE-CHEONSUL` deferred; live visual readability is `NOT_RUN` |
| `SCR-SCHOOL-HELP` | Guidance / help overlay | P1 / VERTICAL_SLICE | selection or combat HUD help -> close / return focus | “How does the selected school work?” | `SchoolSelectionUI/HelpDialog`; HUD `SchoolHelpButton`; T15/T16 machine tests | `COVERED_EXISTING`; existing Godot UI/text, no image file required; visible modal confirmation `NOT_RUN` |
| `SCR-RESULT` | Result / review | P0 / VERTICAL_SLICE | Boss/result transition -> shop or Workbench | “What did this combat yield and what should I do next?” | `RestFlowUI/ResultView`; `MainController` result snapshot wiring; integration UI tests | `COVERED_EXISTING` for runtime owner; `SCRREF-RESULT` deferred |
| `SCR-SHOP` | Shop / maintenance | P1 / VERTICAL_SLICE | result -> Fate / next | “Buy, sell, or reroll within current GOLD?” | `RestFlowUI/ShopView`; `ShopController`; machine UI and domain tests | `COVERED_EXISTING`; dynamic controls are `GODOT_UI`/`TEXT_LAYER`, not image requests |
| `SCR-FATE` | Fate choice | P0 / VERTICAL_SLICE | result/shop -> Workbench intent | “Which benefit/cost do I accept?” | `RestFlowUI/FateView`; `FateController`; dynamic candidate buttons | `COVERED_EXISTING`; `SCRREF-WORKBENCH` covers its shared full-screen composition |
| `SCR-NEXT-PREVIEW` | Route preview / transition | P1 / VERTICAL_SLICE | successful commit -> start next combat | “What is my next committed route?” | `RestFlowUI/PreviewView`; current T13 presentation contract | `COVERED_EXISTING` as machine/UI surface; next-school combat start outside Cheonsul slice is not a verified gameplay claim |
| `SCR-GAME-OVER` | Failure / retry | P0 / VERTICAL_SLICE | player death -> restart | “Why did the run stop and how do I retry?” | `HUD/GameOverPanel` + `RestartButton`; `MainController` game-over path; integration test | `COVERED_EXISTING`; failure copy is present but visual hierarchy review is deferred |
| `SCR-PAUSE-SETTINGS` | Pause / settings | P1 / PRODUCTION | N/A -> N/A | “Pause, adjust input/audio, return safely?” | no pause/settings scene, menu, or setting system | `GAP_NONBLOCKING`; not needed for direct current machine slice, required before a player-facing production build |
| `SCR-CODEX-TUTORIAL` | Archive / tutorial | P1 / PRODUCTION | N/A -> N/A | “Where do I re-read mechanics and controls?” | school help is implemented; no archive/search/tutorial surface | `GAP_NONBLOCKING`; help is not a full Codex/archive |
| `SCR-LOADING-ERROR` | Loading / error / recovery | P1 / PRODUCTION | N/A -> N/A | “What happened and how can I recover?” | one local main scene; no loading, save conflict, offline, or recovery consumer | `NOT_APPLICABLE` to the no-save direct slice; `GAP_NONBLOCKING` for production shell |
| `SCR-FINAL-BINDING-END` | Final binding / ending / credits | P2 / PLANNED_GAME_SURFACE | future four-school clear -> future final flow | “How does this run conclude?” | product canon only; no current scene/runtime consumer | `DEFERRED_BY_DECISION`; do not create a runtime image queue before its consumer exists |
| `SCR-DEBUG-ONLY` | Development diagnostics | P2 / DEBUG | developer input -> developer exit | “Can development state be inspected?” | Godot/editor and tests only | `NOT_APPLICABLE` to player-facing visual coverage |

## 3. Screen -> Asset Coverage Matrix

### `SCR-SCHOOL-SELECT`

- **Composition / identity:** full-screen selection panel, Korean title and four
  distinct school philosophy lines. Existing full-screen `PanelContainer` is
  the runtime composition source.
- **World / object:** no required portrait or school-character image; player
  identity must stay singular.
- **UI / text:** Buttons, help buttons, dialog, close action are `GODOT_UI` +
  `TEXT_LAYER`.
- **States:** selection normal/focus/pressed; help open/closed; locked state
  is not applicable because all four starting choices are available.
- **Feedback:** focus restoration after help close is implemented; actual
  visual focus readability remains deferred.
- **Technical:** full-viewport CanvasLayer; keyboard 1–4 and button path are
  implemented. Touch/gamepad visual evidence is `NOT_RUN`.

### `SCR-BATTLE-CHEONSUL`

- **Composition / identity:** `Main/BattlefieldBackdrop` keeps the combat
  center open. Player, enemy, projectile, reward orb and field ring form the
  runtime visual hierarchy.
- **World / character / object:** fixed player identity, generic-yokai enemy
  pool, Cheonsul Boss, talisman projectile, reward orb, and moonlit backdrop
  are existing approved runtime consumers.
- **UI / text:** HUD labels, restart, current-school help, game-over panel are
  `GODOT_UI` + `TEXT_LAYER`; no baked text image is required.
- **States:** player Move/Attack/Hit texture relay is implemented; enemy
  generic/Boss and orb/familiar have actual Sprite2D consumers. Player
  idle/death sprite and verified enemy wind-up/recovery visual states have no
  current asset consumer and are not falsely marked complete.
- **Feedback / VFX:** Cheonsul field `FlameFieldVisual` is an actual transparent
  Sprite2D. Status badges, mark count, ward polygon, projectile, school
  feedback text and game-over state are runtime-owned feedback.
- **Technical:** backdrop behind play at `z_index=-10`; generated source
  manifest records alpha and source metadata. Target-resolution/layer-overlap
  observation is deferred to live render.

### `SCR-RESULT`, `SCR-SHOP`, `SCR-FATE`, `SCR-ROUTE-WORKBENCH`, `SCR-NEXT-PREVIEW`

- **Composition / identity:** one full-screen `RestFlowUI/Panel` swaps views;
  this is a shared composition surface, not five independent bitmap screens.
- **World / object:** offers, owned items, route cards, Fate candidates and
  readiness reasons are generated from current domain snapshots.
- **UI / text:** every offer/card/button and Korean failure explanation is
  `GODOT_UI` + `TEXT_LAYER`. New button/card PNGs are not justified.
- **States:** normal, selected/provisional, disabled, pending Boss reward,
  readiness failure, complete and restart are actual dynamic states.
- **Feedback:** selection/focus intent and disabled commit reason are text and
  control states. No automatic reward icon/animation requirement is inferred.
- **Technical:** full viewport CanvasLayer, dynamic child buttons, pointer and
  focus tests. Actual touch/gamepad rendering/readability is `NOT_RUN`.

### `SCR-SCHOOL-HELP` and `SCR-GAME-OVER`

- Help uses the existing `HelpDialog` and localization-safe Korean text; no
  explanatory image sheet is a runtime requirement.
- Game over uses `HUD/GameOverPanel`, message label and restart affordance;
  death-cause presentation is a future UX requirement, not an invented art
  asset request.

## 4. Canonical Coverage Cross-check

| coverage_item_id | category / surface | applicable | state family | source / consumer | status |
| --- | --- | --- | --- | --- | --- |
| `COV-FOUNDATION-01` | Visual direction | yes | N/A | Notion Visual Bible + `CURRENT_VISUAL_HANDOFF.md` | `COVERED_EXISTING` |
| `COV-SCREEN-01` | P0 whole-screen composition | yes | select/battle/rest/result/failure | section 2; no target-resolution capture | `DEFERRED_BY_DECISION` — Human slice validation |
| `COV-PLAYER-01` | Fixed player gameplay representation | yes | Move -> Attack -> Hit; idle/death not consumed | `Player/Visual`, IMG-01 | `PARTIAL` / `COVERED_EXISTING` for actual states |
| `COV-ENEMY-01` | Generic enemy and Boss representation | yes | visible base/Boss; wind-up/recovery unverified | `EnemyBasic/Visual`, `StageBoss/Visual` | `PARTIAL` |
| `COV-ENV-01` | Combat environment | yes | static battlefield | `Main/BattlefieldBackdrop`, IMG-03 | `COVERED_EXISTING` |
| `COV-VFX-01` | Cheonsul cast/field feedback | yes | field lifetime; status badge | `Cheonsul/FlameFieldVisual`, `EnemyEffectBadge` | `COVERED_EXISTING` for actual consumer |
| `COV-VFX-02` | Other-school secondary VFX | no for Cheonsul current target | ward / melee / mark variants | `BongmaRuntime/WardVisual` polygon, Guiin has no visual node, Heukyeong badge | `DEFERRED_BY_DECISION` — remaining-school scope |
| `COV-UI-01` | HUD / selection / modal / Rest controls | yes | normal/focus/disabled/selected/pending as supported | HUD, SchoolSelectionUI, RestFlowUI | `COVERED_EXISTING`; visual QA deferred |
| `COV-INPUT-01` | keyboard/pointer/touch/gamepad cues | partial | focus implemented; device visual cue unverified | button focus contracts; no glyph asset consumer | `GAP_NONBLOCKING` |
| `COV-GUIDANCE-01` | school function help | yes | open/close/return focus | HelpDialog + HUD entry | `COVERED_EXISTING` |
| `COV-OUTCOME-01` | result/reward/failure feedback | yes | result/shop/fate/pending/game-over | RestFlowUI + HUD | `COVERED_EXISTING` for machine surfaces |
| `COV-MENU-01` | title/save/settings/loading | no for direct slice | N/A | no consumers | `NOT_APPLICABLE` with release-shell follow-up |
| `COV-MARKETING-01` | store/distribution art | no current distribution consumer | N/A | Visual Bible key art only | `DEFERRED_BY_DECISION` |

`PARTIAL` is a state-family assessment, not an approval or image-generation
command. The corresponding runtime components continue to use their existing
approved sources only.

## 5. Queues and completed P0 reference work

### Screen Design Reference Queue

| screen_id | consumer surface | player goal | reference needed | existing anchor | fidelity / validation | priority / status |
| --- | --- | --- | --- | --- | --- | --- |
| `SCRREF-SCHOOL-SELECT` | `Main/SchoolSelectionUI` | choose school confidently | whole screen hierarchy and focus | v2 SD symbols/cards; actual scene | target-resolution capture; mouse/keyboard/gamepad/touch readability | P0 / `REFERENCE_CREATED_V2`, live `NOT_RUN` |
| `SCRREF-BATTLE-CHEONSUL` | `Main` + HUD + runtime actors | read danger, field and rewards | whole gameplay composition | v2 top-down SD battle; approved runtime consumers | live capture at target aspect; overlap/telegraph/readability review | P0 / `REFERENCE_CREATED_V2`, live `NOT_RUN` |
| `SCRREF-WORKBENCH` | `Main/RestFlowUI` | choose route/Fate and understand disabled commit | whole rest/Workbench hierarchy | v2 SD Workbench; actual Control tree | target-resolution capture; focus, pending and failure states | P0 / `REFERENCE_CREATED_V2`, live `NOT_RUN` |
| `SCRREF-RESULT` | `RestFlowUI/ResultView` | read outcome and next action | result/reward hierarchy | v2 SD result; actual ResultView | capture normal and zero-contribution states | P0 / `REFERENCE_CREATED_V2`, live `NOT_RUN` |
| `SCRREF-GAME-OVER` | `HUD/GameOverPanel` | understand failure and retry | failure hierarchy | v2 top-down SD failure; actual GameOverPanel | target-resolution capture and focus/restart check | P0 / `REFERENCE_CREATED_V2`, live `NOT_RUN` |

All five P0 references now have one reviewed v2 local candidate under the
user's standing image authorization. They remain design references; no row
authorizes a runtime image import. The remaining gate is the explicit live
composition/readability validation, not another generation pass.

### Runtime Asset Family Queue

| asset_family_id | screen ids | runtime consumer | role / states | production mode | existing source | requirement / validation | status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `RAF-PLAYER-CORE` | battle, game over | `Player/Visual` | Move/Attack/Hit; fixed identity | `EXISTING_APPROVED`, `RASTER_TEXTURE` relay | IMG-01 approved local + Notion originals | current script/test consumer; live pose readability deferred | `COVERED_EXISTING` / state `PARTIAL` |
| `RAF-BATTLEFIELD` | battle | `Main/BattlefieldBackdrop` | static background, open center | `EXISTING_APPROVED`, `RASTER_IMAGE` | IMG-03 | scene reference + import test; live composition deferred | `COVERED_EXISTING` |
| `RAF-ENEMY-CORE` | battle | `EnemyBasic/Visual`, `StageBoss/Visual` | generic trio and Cheonsul Boss | `EXISTING_APPROVED`, `RASTER_IMAGE` | IMG-02 runtime visual core | actual Sprite2D consumers; attack-state visual audit deferred | `COVERED_EXISTING` / state `PARTIAL` |
| `RAF-COMBAT-FEEDBACK` | battle | `ProjectileBasic/Visual`, `RewardOrb/Visual`, `Cheonsul/FlameFieldVisual`, badge scenes | projectile/reward/field/status | `EXISTING_APPROVED`, `RASTER_IMAGE`, `GODOT_UI` | IMG-02 / IMG-04 | import + automated consumer tests; live telegraph review deferred | `COVERED_EXISTING` |
| `RAF-BONGMA-COMPANION` | future other-school battle | `BongmaFamiliar/Visual` | companion base visual | `EXISTING_APPROVED`, `RASTER_IMAGE` | IMG-02 | actual consumer exists; remaining-school validation out of scope | `DEFERRED_BY_DECISION` |
| `RAF-BONGMA-WARD` | future other-school battle | `BongmaRuntime/WardVisual` | 0.16-alpha circular ward | `PROCEDURAL_DRAW`, `DO_NOT_GENERATE` | existing Polygon2D | no image needed unless a later consumer/brief changes it | `COVERED_EXISTING` for current procedural implementation |
| `RAF-REST-UI` | result/shop/fate/workbench | `RestFlowUI` | cards/buttons/pending/disabled/failure | `GODOT_UI`, `TEXT_LAYER`, `NO_NEW_IMAGE_FILE_REQUIRED` | existing scene/script | dynamic render and focus contracts; composition capture deferred | `COVERED_EXISTING` |
| `RAF-SELECT-HELP-UI` | selection/help/game over | `SchoolSelectionUI`, HUD | buttons, dialog, focus, restart | `GODOT_UI`, `TEXT_LAYER`, `NO_NEW_IMAGE_FILE_REQUIRED` | existing scenes/scripts | selection/help/game-over tests; visual capture deferred | `COVERED_EXISTING` |

## 6. Correction Log and Codex Handoff

### Correction log

| Current state | Finding | Correction | Actual use | Expected effect / evidence |
| --- | --- | --- | --- | --- |
| Asset lists existed without a screen-first inventory | title, selection, battle, result and settings applicability were not one source-backed matrix | this owner records every Base screen family with a reason | future Work/Codex starts from screen and consumer, not category count | Base screen-first contract + scene/script readback |
| Runtime components and whole-screen references were mixed | a PNG consumer did not prove hierarchy/readability | screen-reference queue is separate from runtime asset queue | future capture/wireframe work does not become a bitmap import task | explicit `SCREEN_DESIGN_REFERENCE` rows |
| Dynamic Rest views are mostly Controls/text | a coverage audit could wrongly request UI PNGs | records `GODOT_UI` and `TEXT_LAYER` as sufficient modes | labels/cards/buttons remain editable/localizable | `rest_flow_ui.tscn` + script dynamic buttons |
| Current target is only Cheonsul slice | full-run/title/final scope could be implied by canon | marks release shell/final flow `NOT_APPLICABLE` or deferred with reasons | current work remains bounded | product router + no corresponding runtime consumer |
| Initial P0 references used poster composition | references could steer implementation away from top-down SD survival gameplay | reject v1 before merge; replace with v2 small-ninja/top-down/school-symbol references | no adult-poster or four-protagonist visual direction remains active | supplied SD style sheet + v2 reference inspection |

### Codex implementation handoff

- **Read first:** this file; `docs/ACTIVE_CONTEXT.md`; `docs/CURRENT_CONFIRMED_DECISIONS.md`; `docs/CURRENT_VISUAL_HANDOFF.md`; Notion Flow Map / Visual Bible; and the actual scene/script named by the selected queue row.
- **Do not implement from this audit alone:** title/save/settings/final binding, remaining-school art, or any new runtime raster asset. They require a separately approved product scope. The v2 files are references only, and must not be promoted as textures.
- **Current actual consumers:** `scenes/main/main_scene.tscn`, `scenes/ui/school_selection_ui.tscn`, `scenes/ui/hud.tscn`, dynamically instantiated `scenes/ui/rest_flow_ui.tscn`, plus the asset consumers listed in section 5.
- **Next permitted validation package:** target-aspect live capture of `SCR-SCHOOL-SELECT`, `SCR-BATTLE-CHEONSUL`, `SCR-RESULT/WORKBENCH`, and `SCR-GAME-OVER`; verify focus, disabled/pending states, Korean readability, overlap and safe exit. This is validation, not implementation completion.
- **Acceptance:** do not claim Human/Player/device PASS without separate evidence; preserve all current domain owners; keep PR #49 unchanged; update this owner and Production Handoff after a future approved capture or implementation.

## 7. Adversarial Review Record

The following five whole-scope loops were completed against the fresh baseline.
They are a documentation/coverage review, not a substitute for live or Human
validation.

| loop | attack | verified evidence | finding / correction | result |
| --- | --- | --- | --- | --- |
| 1 | Can a required Base screen family be silently omitted? | section 2 enumerates Boot, title, save, selection, Workbench, battle, help, result, shop, Fate, preview, failure, settings, tutorial, recovery, final, and debug | no omitted family; every non-current family has a concrete N/A, deferred, or gap reason | pass |
| 2 | Does a screen row claim a flow that no scene/controller owns? | `main_scene`, selector, HUD, RestFlowUI, MainController, and test references | retained actual consumer paths; next-school play beyond Cheonsul is explicitly not claimed | pass |
| 3 | Are state families or input claims inflated from machine tests? | player/Enemy assets, Help/HUD/Rest test contracts, no Ninja live HERA session | player/enemy state coverage remains `PARTIAL`; touch/gamepad and modal readability remain `NOT_RUN` | pass with deferred evidence |
| 4 | Could a visual gap accidentally become an image-production order? | user no-generation boundary; asset manifests; procedural ward and Control/text owners | separated whole-screen reference queue from runtime assets; records `DO_NOT_GENERATE` and approval gate | pass |
| 5 | Did the audit drift into T12/full-release/PR #49 scope? | current canon/router; open-PR inventory; direct-slice scene reality | title/save/final and remaining-school work stay noncurrent; PR #49 untouched | pass |

Validated correction made during loop 3: the player source is a per-state
`RASTER_TEXTURE` relay, not a sprite sheet. No code or asset was changed.

## 8. Remaining Work

### Blocking gaps

- `0` for the current **machine-slice coverage audit**. This is not a claim that
  the player-facing vertical slice is ready.

### Explicit deferred P0 validation gate

- `HUMAN_SLICE_SCREEN_COMPOSITION_VALIDATION`: target-resolution live/capture
  review for selection, Cheonsul battle, result/Workbench and game-over;
  Korean readability, focus, overlap, telegraph fairness, and input clarity.
  Status: `DEFERRED_BY_CURRENT_USER / NOT_RUN`.

### Nonblocking gaps

- Pause/settings, title/save/load, archive/tutorial, loading/error/recovery,
  final binding/ending and distribution screens have no current consumer.
- Player idle/death, enemy wind-up/recovery, live accessibility cue and
  device-specific input prompt completeness require future scope and evidence.
- Boss-reward selection and backpack placement are intentionally unavailable
  in the current Cheonsul Workbench machine path; no visual asset can close
  that domain/UI integration boundary by itself.

### User decisions / approvals needed later

- Reopen Human vertical-slice validation for target-resolution capture against
  the completed v2 references.
- Approve any future title/save/settings/full-run/remaining-school scope before
  implementation. Future image work follows the latest user authorization and
  its required local/Notion storage rule.
