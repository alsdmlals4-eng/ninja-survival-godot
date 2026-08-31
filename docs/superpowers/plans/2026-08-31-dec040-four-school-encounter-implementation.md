# DEC-040 Four-School Encounter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Implement distinct three-Core / Elite / Boss rosters and automatic scroll ninjutsu for all four schools, then prove the resulting Core -> Elite -> Trace -> Boss -> Workbench contract with machine checks.

**Architecture:** Catalog resources own identities, stats, school tags, effects, techniques, telegraph and recovery facts. SchoolEncounterActor plus EncounterPatternController execute that data; MainController resolves definitions and attaches only lifecycle metadata. NinjutsuLoadoutState is a Run child; its pending scrolls commit at the existing Workbench boundary and never enter Backpack items or cells.

**Tech Stack:** Godot 4.7.1, GDScript, GUT, current main scene, built-in image generation.

**Spec:** docs/superpowers/specs/2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md

## Constraints

- Initial combat patterns are katana + shuriken + one selected-school starter spell; no manual spell input, aim control, player attack pose, save/meta system or new normal-wave system.
- Exactly twelve Core, four dedicated Elite and four dedicated Boss definitions; exactly one ranged Core in each school.
- Each Elite has at least two patterns. Each Boss has exactly three base school-specific techniques. Harmful patterns have nonzero telegraph and recovery.
- Enemy harm delegates to PlayerController.take_damage so dash invulnerability remains the only authority.
- Existing StageEncounterState / SchoolCircuitController own gates, existing RestCommitCoordinator owns route/Fate/backpack atomicity, and WaveSpawner retains uncapped horde behavior.
- Generated art is an image-model asset; entries must register path, SHA-256, prompt/provenance, authorization state, consumer and import evidence. Passing a parser/test is not Human Usability, Player Experience, performance, device/export, or release validation.

---

### Task 1: Build actor and spell data catalog

**Files:**
- Create: scripts/data/encounter_actor_definition.gd
- Create: scripts/data/ninjutsu_definition.gd
- Create: scripts/data/ninjutsu_catalog.gd
- Modify: scripts/data/encounter_catalog.gd
- Modify: tests/unit/test_encounter_catalog.gd
- Create: tests/unit/test_ninjutsu_catalog.gd

**Interfaces:**
- EncounterCatalog.build_actor_definitions() -> Dictionary
- EncounterCatalog.actor_definition_for(actor_id: StringName) -> EncounterActorDefinition
- NinjutsuCatalog.build_definitions() -> Dictionary
- NinjutsuCatalog.definition_for_lane(school_id: StringName, lane: StringName) -> NinjutsuDefinition

- [ ] **Step 1: Write failing role/range contract tests.**

~~~gdscript
func test_actor_catalog_has_twelve_core_four_elite_and_four_boss() -> void:
	var actors: Dictionary = _catalog().build_actor_definitions()
	assert_eq(actors.size(), 20)
	assert_eq(_count_role(actors, &"core"), 12)
	assert_eq(_count_role(actors, &"elite"), 4)
	assert_eq(_count_role(actors, &"boss"), 4)

func test_each_school_has_one_ranged_core() -> void:
	for school_id in SCHOOL_IDS:
		assert_eq(_count_ranged_cores(_catalog().build_actor_definitions(), school_id), 1)
~~~

- [ ] **Step 2: Run RED.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_encounter_catalog.gd -gexit

Expected: missing actor-definition catalog API.

- [ ] **Step 3: Implement immutable resources and all twenty roster entries.**

~~~gdscript
extends Resource
class_name EncounterActorDefinition

@export var actor_id: StringName = &""
@export var school_id: StringName = &""
@export var role: StringName = &""
@export var display_name := ""
@export var tags: Array[StringName] = []
@export var max_health := 20
@export var move_speed := 90.0
@export var contact_damage := 10
@export var pattern_ids: Array[StringName] = []
@export var visual_asset_path := ""
~~~

Use DEC-040 exact IDs. Apply ranged only to shikigami_handler, fire_mark_caster, pressure_monk, shuriken_scout. Every Elite must have >=2 primitives and every Boss exactly three base techniques. Catalog validation rejects missing telemetry/recovery, wrong school/role, duplicate ID, unsupported primitive and a missing ranged Core.

- [ ] **Step 4: Write RED for the twelve spell lanes and implement their data.**

~~~gdscript
func test_every_school_has_exact_starter_elite_and_boss_scroll() -> void:
	for school_id in SCHOOL_IDS:
		assert_not_null(_catalog().definition_for_lane(school_id, &"starter"))
		assert_not_null(_catalog().definition_for_lane(school_id, &"elite_scroll"))
		assert_not_null(_catalog().definition_for_lane(school_id, &"boss_scroll"))
~~~

~~~gdscript
extends Resource
class_name NinjutsuDefinition

@export var ninjutsu_id: StringName = &""
@export var school_id: StringName = &""
@export var acquisition_lane: StringName = &""
@export var display_name := ""
@export var primitive_id: StringName = &""
@export var visual_asset_path := ""
~~~

NinjutsuCatalog validates exactly starter, elite_scroll and boss_scroll for each school and rejects foreign/duplicate/unknown lane data.

- [ ] **Step 5: Verify GREEN and commit.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_encounter_catalog.gd,res://tests/unit/test_ninjutsu_catalog.gd -gexit

~~~powershell
git add scripts/data/encounter_actor_definition.gd scripts/data/ninjutsu_definition.gd scripts/data/ninjutsu_catalog.gd scripts/data/encounter_catalog.gd tests/unit/test_encounter_catalog.gd tests/unit/test_ninjutsu_catalog.gd
git commit -m "feat: define four-school encounter rosters"
~~~

### Task 2: Add shared actor, telegraph and recovery execution

**Files:**
- Create: scripts/enemies/school_encounter_actor.gd
- Create: scripts/enemies/encounter_pattern_controller.gd
- Create: scenes/enemies/school_encounter_actor.tscn
- Create: tests/unit/test_school_encounter_actor.gd
- Modify: tests/unit/test_stage_boss.gd

**Interfaces:**
- SchoolEncounterActor.configure_definition(value: EncounterActorDefinition) -> bool
- SchoolEncounterActor.configure_target(target: Node2D) -> bool
- SchoolEncounterActor.pattern_state() -> StringName
- EncounterPatternController.has_telegraph(pattern_id: StringName) -> bool
- EncounterPatternController.has_recovery(pattern_id: StringName) -> bool

- [ ] **Step 1: Write the RED state and dash-damage tests.**

~~~gdscript
func test_pattern_transitions_chase_telegraph_execute_recovery() -> void:
	var actor := _configured_actor(&"heavenly_change_taoist")
	actor.advance_pattern_for_test(0.01)
	assert_eq(actor.pattern_state(), &"telegraph")
	actor.advance_pattern_for_test(actor.current_telegraph_duration())
	assert_eq(actor.pattern_state(), &"execute")
	actor.advance_pattern_for_test(actor.current_execute_duration())
	assert_eq(actor.pattern_state(), &"recovery")

func test_pattern_damage_delegates_to_dashing_player_damage_path() -> void:
	var player := _dashing_player_fixture()
	assert_eq(_configured_actor(&"pressure_monk").resolve_pattern_damage_for_test(player), 0)
~~~

- [ ] **Step 2: Run RED.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_school_encounter_actor.gd -gexit

Expected: missing actor/chassis API.

- [ ] **Step 3: Configure one reusable actor from data.**

~~~gdscript
extends EnemyChaser
class_name SchoolEncounterActor

var definition: EncounterActorDefinition
var pattern_controller: EncounterPatternController

func configure_definition(value: EncounterActorDefinition) -> bool:
	if value == null or value.actor_id == &"" or value.role == &"":
		return false
	definition = value.copy_value()
	max_health = definition.max_health
	move_speed = definition.move_speed
	contact_damage = definition.contact_damage
	return true
~~~

The scene has fixed collision, contact shadow, Visual and controller children. It does not use EnemyVisualVariant.

- [ ] **Step 4: Implement shared pattern state behavior.**

~~~gdscript
enum State { CHASE, TELEGRAPH, EXECUTE, RECOVERY }

func _advance_state() -> void:
	match state:
		State.CHASE: _enter_telegraph()
		State.TELEGRAPH: _enter_execute()
		State.EXECUTE: _enter_recovery()
		State.RECOVERY: _enter_chase()
~~~

Each pattern produces an explicit visual boundary/line/source in TELEGRAPH, applies damage only in EXECUTE using target.take_damage, and produces a visible end cue in RECOVERY. Implement only DEC-026 primitives: line_dash, fan_or_arc_projectile, telegraphed_zone, summon_or_proxy, mark_or_link, pulse_or_ring, barrier_or_lane. Enforce Stage profile advanced-pattern concurrency.

- [ ] **Step 5: Verify GREEN and commit.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_school_encounter_actor.gd,res://tests/unit/test_stage_boss.gd -gexit

~~~powershell
git add scripts/enemies/school_encounter_actor.gd scripts/enemies/encounter_pattern_controller.gd scenes/enemies/school_encounter_actor.tscn tests/unit/test_school_encounter_actor.gd tests/unit/test_stage_boss.gd
git commit -m "feat: add telegraphed school encounter actors"
~~~

### Task 3: Bind exact actor identities to normal, Elite and Boss lifecycle

**Files:**
- Modify: scripts/core/main_controller.gd
- Modify: tests/integration/test_school_circuit_main_runtime.gd
- Create: tests/integration/test_school_encounter_spawn_runtime.gd

**Interfaces:**
- MainController._spawn_school_encounter(encounter_id: StringName, role: StringName) -> SchoolEncounterActor
- Consumes: SchoolCircuitController.next_core_encounter() and its existing elite_id/boss_id snapshot fields.

- [ ] **Step 1: Write the integration RED.**

~~~gdscript
func test_selected_school_spawns_catalog_core_actor() -> void:
	for school_id in SCHOOL_IDS:
		var main := _new_main()
		main._on_school_selected(school_id)
		var actor := _first_live_normal_enemy(main) as SchoolEncounterActor
		assert_not_null(actor)
		assert_eq(actor.definition.actor_id, EXPECTED_FIRST_CORE_IDS[school_id])
		assert_eq(actor.definition.role, &"core")

func test_elite_and_boss_are_not_generic_scenes() -> void:
	var main := _school_at_elite_then_boss(&"guiin")
	assert_true(_role_enemy(main, &"elite") is SchoolEncounterActor)
	assert_true(_role_enemy(main, &"boss") is SchoolEncounterActor)
~~~

- [ ] **Step 2: Run RED.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_school_circuit_main_runtime.gd,res://tests/integration/test_school_encounter_spawn_runtime.gd -gexit

Expected: current EnemyBasic / StageBoss type failure.

- [ ] **Step 3: Implement one definition factory and bind all roles.**

~~~gdscript
func _spawn_school_encounter(encounter_id: StringName, role: StringName) -> SchoolEncounterActor:
	var definition := ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(encounter_id)
	if definition == null or definition.role != role:
		return null
	var actor := SCHOOL_ENCOUNTER_ACTOR_SCENE.instantiate() as SchoolEncounterActor
	if actor == null or not actor.configure_definition(definition):
		actor.queue_free()
		return null
	add_child(actor)
	actor.configure_target(player)
	return actor
~~~

Wire normal Core actor metadata before existing death signal connection. Replace only school circuit Elite/Boss spawning with this factory. Preserve existing role metadata and normal WaveSpawner timing/density/range.

- [ ] **Step 4: Add invalid ID/role test, verify GREEN and commit.**

~~~gdscript
func test_unknown_or_role_mismatched_actor_is_rejected() -> void:
	var main := _new_main()
	assert_null(main._spawn_school_encounter(&"missing", &"boss"))
	assert_null(main._spawn_school_encounter(&"seal_chaser", &"boss"))
~~~

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_school_circuit_main_runtime.gd,res://tests/integration/test_school_encounter_spawn_runtime.gd -gexit

~~~powershell
git add scripts/core/main_controller.gd tests/integration/test_school_circuit_main_runtime.gd tests/integration/test_school_encounter_spawn_runtime.gd
git commit -m "feat: bind stages to school encounter actors"
~~~

### Task 4: Add automatic starter/scroll NinjutsuLoadoutState

**Files:**
- Create: scripts/core/ninjutsu_loadout_state.gd
- Create: scripts/schools/ninjutsu_auto_controller.gd
- Modify: scripts/schools/school_runtime_base.gd
- Modify: scripts/schools/school_runtime_host.gd
- Modify: scripts/core/school_circuit_controller.gd
- Modify: scripts/core/rest_commit_coordinator.gd
- Modify: scripts/core/main_controller.gd
- Create: tests/unit/test_ninjutsu_loadout_state.gd
- Modify: tests/unit/test_school_circuit_controller.gd
- Modify: tests/integration/test_school_circuit_main_runtime.gd

**Interfaces:**
- NinjutsuLoadoutState.activate_starter(school_id: StringName) -> bool
- NinjutsuLoadoutState.stage_scroll(school_id: StringName, lane: StringName) -> bool
- NinjutsuLoadoutState.commit_pending() -> bool
- NinjutsuLoadoutState.active_spell_ids() -> Array[StringName]

- [ ] **Step 1: Write loadout RED.**

~~~gdscript
func test_scroll_is_inactive_before_commit_and_retained_in_later_stage() -> void:
	var loadout := NinjutsuLoadoutState.new()
	assert_true(loadout.activate_starter(&"bongma"))
	assert_true(loadout.stage_scroll(&"bongma", &"elite_scroll"))
	assert_eq(loadout.active_spell_ids().size(), 1)
	assert_true(loadout.commit_pending())
	assert_true(loadout.activate_starter(&"cheonsul"))
	assert_true(loadout.active_spell_ids().has(&"bongma_seal_chain"))
~~~

- [ ] **Step 2: Run RED.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_ninjutsu_loadout_state.gd -gexit

Expected: missing state API.

- [ ] **Step 3: Implement receipt staging and atomic commit integration.**

~~~gdscript
func stage_scroll(school_id: StringName, lane: StringName) -> bool:
	var definition := _catalog.definition_for_lane(school_id, lane)
	if definition == null or lane == &"starter":
		return false
	if _committed_ids.has(definition.ninjutsu_id) or _pending_ids.has(definition.ninjutsu_id):
		return false
	_pending_ids.append(definition.ninjutsu_id)
	return true
~~~

Create the state as a Run child of MainController. Stage starter on Stage selection, stage elite_scroll when the cleared school chest is resolved, stage boss_scroll when its Boss reward is selected. Add receipt validation to RestCommitCoordinator’s existing atomic boundary. Failed Workbench commit leaves scroll inactive; scroll state is not a backpack item.

- [ ] **Step 4: Attach automatic spell controllers with no player/UI control.**

~~~gdscript
func apply_ninjutsu_spell_ids(spell_ids: Array[StringName]) -> void:
	_ninjutsu_controller.configure(player, world, combat_resolver, spell_ids)
	_ninjutsu_controller.set_active(active)
~~~

Use timer-driven nearest/marked target effects for all twelve spells. Do not add a HUD button/input action/body attack animation.

- [ ] **Step 5: Add foreign and failed-commit regressions, verify GREEN and commit.**

~~~gdscript
func test_foreign_and_uncommitted_scrolls_never_activate() -> void:
	var loadout := NinjutsuLoadoutState.new()
	assert_true(loadout.activate_starter(&"cheonsul"))
	assert_false(loadout.stage_scroll(&"bongma", &"boss_scroll"))
	assert_false(loadout.active_spell_ids().has(&"bongma_guardian_ward"))
~~~

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_ninjutsu_loadout_state.gd,res://tests/unit/test_school_circuit_controller.gd,res://tests/integration/test_school_circuit_main_runtime.gd -gexit

~~~powershell
git add scripts/core/ninjutsu_loadout_state.gd scripts/schools/ninjutsu_auto_controller.gd scripts/schools/school_runtime_base.gd scripts/schools/school_runtime_host.gd scripts/core/school_circuit_controller.gd scripts/core/rest_commit_coordinator.gd scripts/core/main_controller.gd tests/unit/test_ninjutsu_loadout_state.gd tests/unit/test_school_circuit_controller.gd tests/integration/test_school_circuit_main_runtime.gd
git commit -m "feat: add automatic ninjutsu scroll loadout"
~~~

### Task 5: Generate, register and bind runtime raster asset families

**Files:**
- Create: assets/runtime/encounters/ twenty actor PNGs
- Create: assets/runtime/encounters/ twelve ninjutsu PNGs
- Create: assets/runtime/encounters/telegraphs/ shared primitive PNGs
- Modify: docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md
- Modify: scenes/enemies/school_encounter_actor.tscn
- Modify: scripts/enemies/school_encounter_actor.gd
- Modify: scripts/enemies/encounter_pattern_controller.gd
- Create: tests/unit/test_encounter_asset_manifest.gd

**Interfaces:**
- Catalog visual_asset_path must map one-to-one to an existing source PNG and manifest row.
- Manifest row contains asset ID, source path, SHA-256, final prompt, generation method, approval state, consumer and import evidence.

- [ ] **Step 1: Generate the declared transparent character/spell/telegraph files with the built-in image model.**

Prompt: top-down/three-quarter runtime cutout; dark moonlit Korean ninja fantasy; premium painterly anime ink; small-scale readable silhouette; black/deep navy base plus the school accent; transparent RGBA background; no text/UI/watermark; contact-shadow-compatible base. Do not substitute vector art, code primitives, generic yokai art or the old Cheonsul Boss image.

- [ ] **Step 2: Hash files and write manifest alignment RED.**

~~~powershell
Get-ChildItem assets\runtime\encounters -Recurse -Filter *.png | ForEach-Object {
	@{ path = $_.FullName; sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash }
}
~~~

~~~gdscript
func test_every_actor_and_spell_visual_has_existing_manifest_consumer() -> void:
	for definition in _all_actor_and_spell_definitions():
		assert_true(ResourceLoader.exists(definition.visual_asset_path))
		assert_true(_manifest_has_sha_and_consumer(definition.visual_asset_path))
~~~

- [ ] **Step 3: Bind exact sprites and telegraphs, verify import/GREEN, commit.**

SchoolEncounterActor loads its fixed definition visual and EncounterPatternController loads the fixed pattern telegraph. No random variant selector runs for a school actor.

Run: & $godot --headless --editor --path . --quit

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_encounter_asset_manifest.gd -gexit

~~~powershell
git add assets/runtime/encounters docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md scenes/enemies/school_encounter_actor.tscn scripts/enemies/school_encounter_actor.gd scripts/enemies/encounter_pattern_controller.gd tests/unit/test_encounter_asset_manifest.gd
git commit -m "feat: add four-school encounter visual assets"
~~~

### Task 6: Four-school machine verification and evidence update

**Files:**
- Create: tests/integration/test_four_school_battle_contract.gd
- Modify: tests/integration/test_school_circuit_main_runtime.gd
- Modify: docs/ACTIVE_CONTEXT.md
- Modify: docs/CURRENT_CONFIRMED_DECISIONS.md
- Modify: docs/superpowers/specs/2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md

**Interfaces:**
- Consumes: all Tasks 1–5 public APIs plus existing main-scene lifecycle.
- Proves: Core -> Elite -> Trace -> Boss -> Workbench from every selected school produces exact actor/spell identities.

- [ ] **Step 1: Write end-to-end RED.**

~~~gdscript
func test_every_school_awards_its_two_scrolls_after_existing_gates() -> void:
	for school_id in SCHOOL_IDS:
		var main := _new_main()
		await _clear_school_through_workbench(main, school_id)
		assert_true(main.ninjutsu_loadout.active_spell_ids().has(_elite_scroll_id(school_id)))
		assert_true(main.ninjutsu_loadout.active_spell_ids().has(_boss_scroll_id(school_id)))
		_assert_boss_patterns_are_telegraphed(main, school_id)
~~~

- [ ] **Step 2: Run RED, implement only reproduced integration corrections, then run exact machine suite.**

Run: & $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_four_school_battle_contract.gd -gexit

~~~powershell
$godot = 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe'
& $godot --headless --editor --path . --quit
& $godot --headless --path . --quit
& $godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
~~~

- [ ] **Step 3: Run five full adversarial loops and update records.**

Every loop re-attacks range tagging, Elite identity, Boss techniques/telegraphs, dash harm path, scroll atomicity, horde nonregression, parser/smoke, focused tests and full GUT. Record reproduced findings/corrections/reruns in ACTIVE_CONTEXT. Set the DEC-040 spec to IMPLEMENTED_MACHINE_VERIFIED only after exact commands are green. Keep runtime render, human/UX/balance/performance/device/release evidence explicitly NOT_RUN unless actually executed.

- [ ] **Step 4: Commit the evidence package.**

~~~powershell
git add tests/integration/test_four_school_battle_contract.gd tests/integration/test_school_circuit_main_runtime.gd docs/ACTIVE_CONTEXT.md docs/CURRENT_CONFIRMED_DECISIONS.md docs/superpowers/specs/2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md
git commit -m "test: verify four-school combat contract"
~~~

## Execution record — 2026-08-31 KST

- Tasks 1–4 and the source/test portion of Task 6 are implemented on the
  unmerged current branch. The roster contains 12 Core, four dedicated Elite,
  four Boss and 12 scroll definitions; the selected starter stays immediate,
  while cleared-Stage Elite/Boss scrolls remain pending until the existing
  Workbench’s atomic Backpack/Fate/route commit succeeds.
- Boss/Elite execution uses shared state with school data. A line dash uses a
  locked lane with a sideways-safe response; a proxy creates a delayed hazard
  rather than generic direct contact damage; marks modify subsequent damage.
- Task 5 is in progress under the per-candidate image gate. The user locked
  the first independent runtime actor candidate, 봉마류 Elite
  `mobile_array_caster` / 이동진 술사. Its source was copied once to
  `assets/runtime/encounters/actors/mobile_array_caster.png`, SHA-256 and
  final prompt were recorded, Godot imported it, and the focused
  source/manifest/`SchoolEncounterActor/Visual` contract passed `2/2`, `14`
  assertions. The full family remains intentionally incomplete: 19 actor,
  12 ninjutsu and shared telegraph candidates still require their own user
  `LOCK`; generic effects remain fallbacks and do not satisfy those slots.
- Exact evidence is recorded in `docs/ACTIVE_CONTEXT.md`. It establishes
  import/parse, headless smoke and automated contracts only; render, Human
  Usability, Player Experience, balance, uncapped-density performance,
  touch/gamepad and device/export remain `NOT_RUN`.
