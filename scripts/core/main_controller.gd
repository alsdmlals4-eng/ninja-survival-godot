extends Node2D
class_name MainController

const DEATH_COUNTED_META := &"ninja_main_death_counted"

const MVP3_CATALOG_SCRIPT = preload("res://scripts/data/mvp3_catalog.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")
const RUN_BUILD_STATE_SCRIPT = preload("res://scripts/core/run_build_state.gd")
const SHOP_CONTROLLER_SCRIPT = preload("res://scripts/core/shop_controller.gd")
const FATE_CONTROLLER_SCRIPT = preload("res://scripts/core/fate_controller.gd")
const STAGE_FLOW_SCRIPT = preload("res://scripts/core/stage_flow_controller.gd")
const CONTRIBUTION_TRACKER_SCRIPT = preload("res://scripts/combat/combat_contribution_tracker.gd")
const COMBAT_RESOLVER_SCRIPT = preload("res://scripts/combat/combat_resolver.gd")
const STAGE_BOSS_SCENE = preload("res://scenes/enemies/stage_boss.tscn")
const STAGE_BOSS_SCRIPT = preload("res://scripts/enemies/stage_boss.gd")
const ENEMY_BASIC_SCENE = preload("res://scenes/enemies/enemy_basic.tscn")
const REST_FLOW_UI_SCENE = preload("res://scenes/ui/rest_flow_ui.tscn")
const CHEONSUL_SLICE_SCRIPT = preload("res://scripts/core/cheonsul_vertical_slice_controller.gd")

const CHEONSUL_SLICE_ROLE_META := &"cheonsul_slice_role"
const CHEONSUL_ENCOUNTER_ID_META := &"cheonsul_encounter_id"
const CHEONSUL_ELITE_ROLE := &"elite"
const CHEONSUL_BOSS_ROLE := &"boss"
const CHEONSUL_TEST_ELITE_ROLE := &"test_elite"
const CHEONSUL_TEST_BOSS_ROLE := &"test_boss"

const SCHOOL_ULTIMATE_GUIDANCE := {
	&"bongma": "백귀야행: 임시 식신을 불러 짧은 시간 집중 공격합니다.",
	&"cheonsul": "오행폭주: 상태가 남은 적에게 폭발 피해를 줍니다.",
	&"guiin": "귀인화: 짧은 시간 근접 공격의 범위·속도·피해가 강해집니다.",
	&"heukyeong": "암영처형: 쌓인 표식 대상에게 처형 피해를 줍니다.",
}

@export var reward_orb_scene: PackedScene

var game_over: bool = false
var run_build_state: RunBuildState
var shop_controller: ShopController
var fate_controller: FateController
var stage_flow: StageFlowController
var contribution_tracker: CombatContributionTracker
var combat_resolver: CombatResolver
var rest_flow_ui: RestFlowUI
var current_stage_boss: Node
var cheonsul_slice: CheonsulVerticalSliceController

var _item_defs: Dictionary = {}
var _fate_defs: Dictionary = {}
var _shop_message: String = ""
var _latest_result_snapshot: Dictionary = {}
var _cheonsul_elapsed_seconds: float = 0.0
var _combat_enabled: bool = false

@onready var game_state: GameState = $GameState
@onready var combat_ddd: CombatDDDTracker = $CombatDDD
@onready var player: PlayerController = $Player
@onready var player_visual: PlayerVisualController = $Player/Visual
@onready var auto_attack: AutoAttackController = $Player/AutoAttack
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var school_host: SchoolRuntimeHost = $SchoolRuntimeHost
@onready var school_selection: SchoolSelectionUI = $SchoolSelectionUI
@onready var hud: HUDController = $HUD


func _ready() -> void:
	_setup_mvp3_nodes()
	_connect_existing_signals()
	_connect_mvp3_signals()

	hud.set_health(player.health, player.max_health)
	hud.set_score(game_state.score, game_state.kill_count)
	hud.set_combo(combat_ddd.combo_count, combat_ddd.max_combo)
	hud.set_stylish_score(combat_ddd.stylish_score)
	hud.set_reward_count(combat_ddd.reward_count)
	hud.set_ultimate_ready(false)
	hud.set_stage(1, 3)
	hud.set_stage_time(stage_flow.segment_duration_seconds)
	hud.set_gold(run_build_state.gold)

	wave_spawner.configure(self, player)
	school_host.configure(player, self)
	school_host.configure_run_systems(combat_resolver, contribution_tracker)

	for child in get_children():
		if child.is_in_group("enemies"):
			_wire_enemy(child)

	contribution_tracker.reset_segment(combat_ddd.reward_count, run_build_state.gold)
	_set_combat_enabled(false)
	rest_flow_ui.hide_all()


func _setup_mvp3_nodes() -> void:
	_item_defs = MVP3_CATALOG_SCRIPT.build_items()
	_fate_defs = MVP3_CATALOG_SCRIPT.build_fates()

	run_build_state = _ensure_script_node("RunBuildState", RUN_BUILD_STATE_SCRIPT) as RunBuildState
	shop_controller = _ensure_script_node("ShopController", SHOP_CONTROLLER_SCRIPT) as ShopController
	fate_controller = _ensure_script_node("FateController", FATE_CONTROLLER_SCRIPT) as FateController
	stage_flow = _ensure_script_node("StageFlow", STAGE_FLOW_SCRIPT) as StageFlowController
	contribution_tracker = _ensure_script_node("ContributionTracker", CONTRIBUTION_TRACKER_SCRIPT) as CombatContributionTracker
	combat_resolver = _ensure_script_node("CombatResolver", COMBAT_RESOLVER_SCRIPT) as CombatResolver

	var existing_rest_ui := get_node_or_null("RestFlowUI")
	if existing_rest_ui is RestFlowUI:
		rest_flow_ui = existing_rest_ui as RestFlowUI
	else:
		var rest_instance := REST_FLOW_UI_SCENE.instantiate()
		rest_instance.name = "RestFlowUI"
		add_child(rest_instance)
		rest_flow_ui = rest_instance as RestFlowUI

	run_build_state.configure(_item_defs, _fate_defs)
	shop_controller.configure(run_build_state, _item_defs)
	fate_controller.configure(run_build_state, _fate_defs)
	combat_resolver.configure(contribution_tracker)


func _ensure_script_node(node_name: String, script: Script) -> Node:
	var existing := get_node_or_null(NodePath(node_name))
	if existing != null:
		return existing
	var node := script.new() as Node
	node.name = node_name
	add_child(node)
	return node


func _connect_existing_signals() -> void:
	game_state.score_changed.connect(hud.set_score)
	combat_ddd.combo_changed.connect(hud.set_combo)
	combat_ddd.stylish_score_changed.connect(hud.set_stylish_score)
	combat_ddd.reward_count_changed.connect(hud.set_reward_count)
	combat_ddd.title_triggered.connect(hud.show_combo_title)
	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	wave_spawner.enemy_spawned.connect(_wire_enemy)
	school_selection.school_selected.connect(_on_school_selected)
	school_host.resource_changed.connect(hud.set_school_resource)
	school_host.ultimate_ready_changed.connect(hud.set_ultimate_ready)
	school_host.school_feedback.connect(hud.show_school_feedback)
	school_host.player_action_resolved.connect(player_visual.show_attack)
	hud.restart_requested.connect(_restart_run)
	hud.school_help_requested.connect(_on_school_help_requested)
	hud.trace_recovery_requested.connect(_on_trace_recovery_requested)
	hud.ultimate_requested.connect(_on_ultimate_requested)
	hud.test_elite_requested.connect(_on_test_elite_requested)
	hud.test_boss_requested.connect(_on_test_boss_requested)


func _connect_mvp3_signals() -> void:
	run_build_state.gold_changed.connect(hud.set_gold)
	stage_flow.segment_time_changed.connect(_on_segment_time_changed)
	stage_flow.boss_requested.connect(_on_boss_requested)
	player.healing_resolved.connect(contribution_tracker.record_healing)
	player.damage_resolved.connect(_on_player_damage_resolved)
	shop_controller.transaction_failed.connect(_on_shop_transaction_failed)

	rest_flow_ui.result_continue_requested.connect(_on_result_continue_requested)
	rest_flow_ui.shop_buy_requested.connect(_on_shop_buy_requested)
	rest_flow_ui.shop_sell_requested.connect(_on_shop_sell_requested)
	rest_flow_ui.shop_reroll_requested.connect(_on_shop_reroll_requested)
	rest_flow_ui.shop_continue_requested.connect(_on_shop_continue_requested)
	rest_flow_ui.fate_selected_requested.connect(_on_fate_selected_requested)
	rest_flow_ui.workbench_route_selected_requested.connect(_on_workbench_route_selected_requested)
	rest_flow_ui.workbench_commit_requested.connect(_on_workbench_commit_requested)
	rest_flow_ui.preview_start_requested.connect(_on_preview_start_requested)
	rest_flow_ui.restart_requested.connect(_restart_run)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_on_trace_recovery_requested()
		return
	if not event.is_action_pressed("ui_accept"):
		return
	if game_over:
		_restart_run()
		return
	if cheonsul_slice != null:
		if cheonsul_slice.get_snapshot().get("state", &"") in [&"core", &"elite_warning", &"elite_active", &"trace_available", &"trace_recovered", &"boss_warning", &"boss_active"]:
			_try_use_selected_ultimate()
		return
	if stage_flow != null and stage_flow.phase != StageFlowController.Phase.COMBAT and stage_flow.phase != StageFlowController.Phase.BOSS:
		return
	_try_use_selected_ultimate()


func _restart_run() -> void:
	get_tree().reload_current_scene()


func _on_ultimate_requested() -> void:
	_try_use_selected_ultimate()


func _try_use_selected_ultimate() -> bool:
	if game_over or not _combat_enabled or school_host.selected_school_id == &"":
		return false
	return school_host.try_use_ultimate()


func _on_test_elite_requested() -> void:
	if not _can_spawn_cheonsul_test_encounter():
		return
	_spawn_cheonsul_test_elite()


func _on_test_boss_requested() -> void:
	if not _can_spawn_cheonsul_test_encounter():
		return
	_spawn_cheonsul_test_boss()


func _on_trace_recovery_requested() -> void:
	if game_over or cheonsul_slice == null:
		return
	if cheonsul_slice.get_snapshot().get("state", &"") != &"trace_available":
		return
	if cheonsul_slice.recover_trace():
		hud.show_school_feedback("흔적을 회수했습니다. 보스 경고를 기다리세요.")


func _can_spawn_cheonsul_test_encounter() -> bool:
	return (
		not game_over
		and _combat_enabled
		and cheonsul_slice != null
		and school_host.selected_school_id == &"cheonsul"
	)


func _on_school_selected(school_id: StringName) -> void:
	if game_over:
		return
	if not school_host.select_school(school_id):
		return

	run_build_state.set_selected_school(school_id)
	_sync_run_modifiers()
	hud.set_school(school_host.selected_school_name)
	contribution_tracker.reset_segment(combat_ddd.reward_count, run_build_state.gold)
	if school_id == &"cheonsul":
		if _start_cheonsul_vertical_slice():
			_set_combat_enabled(true)
		return
	if not stage_flow.start_after_school_selection():
		return
	_set_combat_enabled(true)


func _start_cheonsul_vertical_slice() -> bool:
	if cheonsul_slice != null:
		return false
	var slice := CHEONSUL_SLICE_SCRIPT.new() as CheonsulVerticalSliceController
	if slice == null:
		return false
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if not slice.configure_workbench(
		run_build_state,
		fate_controller,
		MVP4_CATALOG_SCRIPT.build_items(),
		MVP4_CATALOG_SCRIPT.build_bags(),
		rng
	):
		slice.queue_free()
		return false
	add_child(slice)
	cheonsul_slice = slice
	cheonsul_slice.phase_changed.connect(_on_cheonsul_slice_phase_changed)
	cheonsul_slice.chest_token_granted.connect(_on_cheonsul_chest_token_granted)
	cheonsul_slice.boss_spawn_requested.connect(_on_cheonsul_boss_spawn_requested)
	cheonsul_slice.normal_spawn_permission_changed.connect(_on_cheonsul_normal_spawn_permission_changed)
	if not cheonsul_slice.begin_first_school():
		cheonsul_slice.queue_free()
		cheonsul_slice = null
		return false
	for child in get_children():
		if child.is_in_group("enemies") and not child.has_meta(CHEONSUL_SLICE_ROLE_META):
			_wire_enemy(child)
	_cheonsul_elapsed_seconds = 0.0
	hud.set_stage(1, 4)
	hud.set_stage_time(270.0)
	hud.show_school_feedback("천술류: 원소 반응을 준비하세요.")
	return true


func _process(delta: float) -> void:
	if game_over or cheonsul_slice == null or delta <= 0.0:
		return
	var state_name := StringName(cheonsul_slice.get_snapshot().get("state", &""))
	if state_name == &"cleared":
		return
	_cheonsul_elapsed_seconds += delta
	cheonsul_slice.sync_elapsed(_cheonsul_elapsed_seconds)
	hud.set_stage_time(maxf(270.0 - _cheonsul_elapsed_seconds, 0.0))


func _on_cheonsul_slice_phase_changed(phase: StringName) -> void:
	hud.set_trace_recovery_available(phase == &"trace_available")
	match phase:
		&"elite_warning":
			hud.show_school_feedback("정예 경고: %s가 접근합니다." % _cheonsul_encounter_name("elite_display_name", "정예"))
		&"elite_active":
			hud.show_school_feedback("정예: 두 원소 준비 뒤 반응을 노리세요.")
			_spawn_cheonsul_elite()
		&"trace_available":
			hud.show_school_feedback("흔적 발견: R 또는 버튼으로 회수하세요.")
		&"trace_recovered":
			hud.show_school_feedback("흔적 회수 완료. 보스 게이트를 확인합니다.")
		&"boss_warning":
			hud.show_school_feedback("보스 경고: %s가 다가옵니다." % _cheonsul_encounter_name("boss_display_name", "보스"))
		&"boss_active":
			hud.show_school_feedback("보스: 준비한 원소 반응을 연결하세요.")


func _on_cheonsul_chest_token_granted(_amount: int) -> void:
	hud.show_school_feedback("정예 보상: 상자 토큰과 흔적을 얻었습니다.")


func _on_cheonsul_normal_spawn_permission_changed(allowed: bool) -> void:
	if cheonsul_slice == null:
		return
	wave_spawner.set_spawning_enabled(allowed)


func _spawn_cheonsul_elite() -> void:
	if game_over or cheonsul_slice == null:
		return
	var elite := ENEMY_BASIC_SCENE.instantiate()
	if elite == null:
		return
	add_child(elite)
	if elite is Node2D:
		(elite as Node2D).global_position = player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance
	elite.set_meta(CHEONSUL_SLICE_ROLE_META, CHEONSUL_ELITE_ROLE)
	elite.set_meta(CHEONSUL_ENCOUNTER_ID_META, _cheonsul_encounter_id("elite_id"))
	_wire_enemy(elite)


func _spawn_cheonsul_test_elite() -> void:
	if _has_live_cheonsul_test_encounter(CHEONSUL_TEST_ELITE_ROLE):
		return
	var elite := ENEMY_BASIC_SCENE.instantiate()
	if elite == null:
		return
	if elite is EnemyChaser:
		(elite as EnemyChaser).max_health = 120
		(elite as EnemyChaser).move_speed = 105.0
		(elite as EnemyChaser).contact_damage = 14
	if elite is Node2D:
		(elite as Node2D).scale = Vector2.ONE * 1.35
	add_child(elite)
	if elite is Node2D:
		(elite as Node2D).global_position = player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance
	elite.set_meta(CHEONSUL_SLICE_ROLE_META, CHEONSUL_TEST_ELITE_ROLE)
	_wire_enemy(elite)
	hud.show_school_feedback("TEST 정예: Trace·보상·진행에는 반영되지 않습니다.")


func _spawn_cheonsul_test_boss() -> void:
	if _has_live_cheonsul_test_encounter(CHEONSUL_TEST_BOSS_ROLE):
		return
	var boss_node := STAGE_BOSS_SCENE.instantiate()
	if not boss_node.has_method("configure_tier") or not boss_node.configure_tier(2):
		boss_node.free()
		return
	add_child(boss_node)
	if boss_node is Node2D:
		(boss_node as Node2D).global_position = player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance
	boss_node.set_meta(CHEONSUL_SLICE_ROLE_META, CHEONSUL_TEST_BOSS_ROLE)
	_wire_enemy(boss_node)
	hud.show_school_feedback("TEST 중간 보스: Trace·보상·진행에는 반영되지 않습니다.")


func _has_live_cheonsul_test_encounter(role: StringName) -> bool:
	for child in get_children():
		if not child.is_in_group("enemies") or child.is_queued_for_deletion():
			continue
		if StringName(child.get_meta(CHEONSUL_SLICE_ROLE_META, &"")) == role:
			return true
	return false


func _on_cheonsul_boss_spawn_requested() -> void:
	if game_over or cheonsul_slice == null:
		return
	wave_spawner.set_spawning_enabled(false)
	if is_instance_valid(current_stage_boss) and not current_stage_boss.is_queued_for_deletion():
		return
	var boss_node := STAGE_BOSS_SCENE.instantiate()
	if not boss_node.has_method("configure_tier") or not boss_node.configure_tier(1):
		boss_node.free()
		return
	add_child(boss_node)
	current_stage_boss = boss_node
	if boss_node is Node2D:
		(boss_node as Node2D).global_position = player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance
	boss_node.set_meta(CHEONSUL_SLICE_ROLE_META, CHEONSUL_BOSS_ROLE)
	boss_node.set_meta(CHEONSUL_ENCOUNTER_ID_META, _cheonsul_encounter_id("boss_id"))
	_wire_enemy(boss_node)


func _sync_run_modifiers() -> void:
	var modifiers := run_build_state.get_modifiers()
	combat_resolver.set_modifiers(modifiers)
	player.apply_run_modifiers(modifiers)
	school_host.apply_run_modifiers(modifiers)


func _set_combat_enabled(enabled: bool) -> void:
	_combat_enabled = enabled
	var gameplay_mode := Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	player.process_mode = gameplay_mode
	auto_attack.process_mode = Node.PROCESS_MODE_DISABLED
	wave_spawner.set_spawning_enabled(enabled)
	wave_spawner.process_mode = gameplay_mode
	combat_ddd.process_mode = gameplay_mode
	school_host.process_mode = gameplay_mode

	for child in get_children():
		if child.is_in_group("enemies"):
			child.process_mode = gameplay_mode
		elif child is RewardOrb:
			child.process_mode = gameplay_mode

	if enabled and not game_over and school_host.selected_school_id != &"":
		hud.show_school_help(school_host.selected_school_name)
		hud.show_combat_controls(
			school_host.selected_school_name,
			_school_ultimate_guidance(school_host.selected_school_id),
			school_host.selected_school_id == &"cheonsul"
		)
	else:
		hud.hide_school_help()
		hud.hide_combat_controls()
		school_selection.dismiss_school_help()


func _on_school_help_requested() -> void:
	if game_over or not _combat_enabled or school_host.selected_school_id == &"":
		return
	school_selection.open_runtime_school_help(school_host.selected_school_id, hud.school_help_button)


func _school_ultimate_guidance(school_id: StringName) -> String:
	return str(SCHOOL_ULTIMATE_GUIDANCE.get(school_id, "궁극기 효과가 준비 중입니다."))


func _on_segment_time_changed(segment: int, remaining: float) -> void:
	hud.set_stage(segment, 3)
	hud.set_stage_time(remaining)


func _on_boss_requested(tier: int) -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.BOSS:
		return
	wave_spawner.set_spawning_enabled(false)
	if is_instance_valid(current_stage_boss) and not current_stage_boss.is_queued_for_deletion():
		return

	var boss_node := STAGE_BOSS_SCENE.instantiate()
	if not boss_node.has_method("configure_tier") or not boss_node.configure_tier(tier):
		boss_node.free()
		return
	add_child(boss_node)
	current_stage_boss = boss_node
	if boss_node is Node2D:
		(boss_node as Node2D).global_position = player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance
	_wire_enemy(boss_node)


func _on_enemy_died(enemy: Node) -> void:
	if game_over or not is_instance_valid(enemy):
		return
	if enemy.has_meta(DEATH_COUNTED_META):
		return
	enemy.set_meta(DEATH_COUNTED_META, true)

	var death_position := Vector2.ZERO
	if enemy is Node2D:
		death_position = (enemy as Node2D).global_position

	var is_boss := enemy.has_method("is_stage_boss") and bool(enemy.call("is_stage_boss"))
	var cheonsul_role := StringName(enemy.get_meta(CHEONSUL_SLICE_ROLE_META, &""))
	var is_test_encounter := cheonsul_role in [CHEONSUL_TEST_ELITE_ROLE, CHEONSUL_TEST_BOSS_ROLE]
	game_state.register_kill(100)
	combat_ddd.register_kill()
	school_host.forward_enemy_died(enemy)
	if is_test_encounter:
		return
	if is_boss:
		run_build_state.grant_boss_gold()
	else:
		run_build_state.grant_normal_kill_gold()
	contribution_tracker.record_kill(combat_ddd.combo_count)
	_spawn_reward_orb(death_position)

	if cheonsul_role == CHEONSUL_ELITE_ROLE and cheonsul_slice != null:
		cheonsul_slice.mark_elite_defeated()
	elif cheonsul_role == CHEONSUL_BOSS_ROLE and cheonsul_slice != null:
		_settle_cheonsul_boss_death(enemy)
	elif is_boss:
		_settle_boss_death(enemy)


func _settle_cheonsul_boss_death(enemy: Node) -> void:
	if game_over or cheonsul_slice == null or enemy != current_stage_boss:
		return
	if not cheonsul_slice.mark_boss_defeated():
		return
	_cleanup_remaining_normal_enemies()
	current_stage_boss = null
	_set_combat_enabled(false)
	_render_cheonsul_workbench()


func _render_cheonsul_workbench() -> void:
	if cheonsul_slice == null:
		return
	var snapshot: Dictionary = cheonsul_slice.workbench_snapshot()
	if snapshot.is_empty():
		return
	rest_flow_ui.show_workbench(
		snapshot.get("route_snapshot", {}),
		snapshot.get("fate_candidate_ids", []),
		_fate_defs,
		StringName(snapshot.get("pending_fate_id", &"")),
		snapshot.get("readiness_failures", []),
		{
			"boss_reward_pending": snapshot.get("boss_reward_pending", false),
			"boss_reward_labels": snapshot.get("boss_reward_labels", []),
		}
	)


func _settle_boss_death(enemy: Node) -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.BOSS:
		return
	if enemy != current_stage_boss:
		return

	_latest_result_snapshot = contribution_tracker.freeze_snapshot(
		combat_ddd.reward_count,
		run_build_state.gold,
		run_build_state
	)
	if not stage_flow.enter_result_after_boss():
		return
	_cleanup_remaining_normal_enemies()
	current_stage_boss = null
	_set_combat_enabled(false)
	rest_flow_ui.show_result(_latest_result_snapshot)


func _cleanup_remaining_normal_enemies() -> void:
	for child in get_children():
		if not child.is_in_group("enemies"):
			continue
		if StringName(child.get_meta(CHEONSUL_SLICE_ROLE_META, &"")) in [CHEONSUL_TEST_ELITE_ROLE, CHEONSUL_TEST_BOSS_ROLE]:
			if not child.is_queued_for_deletion():
				child.queue_free()
			continue
		if child.has_method("is_stage_boss") and bool(child.call("is_stage_boss")):
			continue
		if not child.is_queued_for_deletion():
			child.queue_free()


func _spawn_reward_orb(spawn_position: Vector2) -> void:
	if reward_orb_scene == null or not is_instance_valid(player):
		return

	var orb_node := reward_orb_scene.instantiate()
	if not orb_node is RewardOrb:
		orb_node.free()
		return

	add_child(orb_node)
	var orb := orb_node as RewardOrb
	orb.global_position = spawn_position
	orb.configure(player)
	orb.collected.connect(_on_reward_collected)
	if not _is_reward_orb_combat_active():
		orb.process_mode = Node.PROCESS_MODE_DISABLED


func _is_reward_orb_combat_active() -> bool:
	if stage_flow.phase == StageFlowController.Phase.COMBAT or stage_flow.phase == StageFlowController.Phase.BOSS:
		return true
	if cheonsul_slice == null:
		return false
	return cheonsul_slice.get_snapshot().get("state", &"") in [
		&"core", &"elite_warning", &"elite_active", &"trace_available",
		&"trace_recovered", &"boss_warning", &"boss_active",
	]


func _on_reward_collected(_orb: RewardOrb) -> void:
	if game_over:
		return
	combat_ddd.register_reward_collected()


func _wire_enemy(enemy: Node) -> void:
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	if cheonsul_slice != null and enemy.is_in_group("enemies") and not enemy.has_meta(CHEONSUL_SLICE_ROLE_META):
		var encounter := cheonsul_slice.next_core_encounter()
		var encounter_id := StringName(encounter.get("id", &""))
		if encounter_id != &"":
			enemy.set_meta(CHEONSUL_ENCOUNTER_ID_META, encounter_id)
	if enemy.has_signal("died"):
		var death_callback := Callable(self, "_on_enemy_died")
		if not enemy.is_connected("died", death_callback):
			enemy.connect("died", death_callback)


func _cheonsul_encounter_id(key: String) -> StringName:
	if cheonsul_slice == null:
		return &""
	var encounter: Dictionary = cheonsul_slice.get_snapshot().get("encounter", {})
	return StringName(encounter.get(key, &""))


func _cheonsul_encounter_name(key: String, fallback: String) -> String:
	if cheonsul_slice == null:
		return fallback
	var encounter: Dictionary = cheonsul_slice.get_snapshot().get("encounter", {})
	return str(encounter.get(key, fallback))


func _on_player_damage_resolved(_requested: int, _resolved: int, prevented: int, _evaded: bool) -> void:
	contribution_tracker.record_defense(prevented)


func _on_result_continue_requested() -> void:
	if game_over or not stage_flow.continue_to_shop():
		return
	_shop_message = ""
	shop_controller.begin_rest()
	_render_shop()


func _on_shop_buy_requested(index: int) -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.SHOP:
		return
	if index < 0 or index >= shop_controller.offer_ids.size():
		return
	_shop_message = ""
	var item_id: StringName = shop_controller.offer_ids[index]
	var old_max_health := player.max_health
	if shop_controller.buy_offer(index):
		_sync_run_modifiers()
		if item_id == &"protection_talisman":
			var max_increase := maxi(player.max_health - old_max_health, 0)
			if max_increase > 0:
				player.heal(max_increase)
	_render_shop(_shop_message)


func _on_shop_sell_requested(item_id: StringName) -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.SHOP:
		return
	_shop_message = ""
	if shop_controller.sell_item(item_id):
		_sync_run_modifiers()
	_render_shop(_shop_message)


func _on_shop_reroll_requested() -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.SHOP:
		return
	_shop_message = ""
	shop_controller.reroll()
	_render_shop(_shop_message)


func _on_shop_transaction_failed(reason: String) -> void:
	_shop_message = reason


func _render_shop(message: String = "") -> void:
	rest_flow_ui.show_shop(
		run_build_state.gold,
		shop_controller.offer_ids,
		_item_defs,
		run_build_state.owned_items,
		shop_controller.get_reroll_cost(),
		message
	)


func _on_shop_continue_requested() -> void:
	if game_over or not stage_flow.continue_to_fate():
		return
	fate_controller.begin_rest()
	rest_flow_ui.show_fate(fate_controller.candidate_ids, _fate_defs)


func _on_fate_selected_requested(fate_id: StringName) -> void:
	if cheonsul_slice != null:
		if fate_controller.choose_pending(fate_id):
			_render_cheonsul_workbench()
		return
	if game_over or stage_flow.phase != StageFlowController.Phase.FATE:
		return
	if not fate_controller.choose(fate_id):
		return
	_sync_run_modifiers()
	var summary := _build_preview_summary(fate_id)
	if not stage_flow.continue_to_preview(fate_controller.can_continue()):
		return
	if stage_flow.phase == StageFlowController.Phase.COMPLETE:
		rest_flow_ui.show_complete(summary)
	else:
		rest_flow_ui.show_preview(summary)


func _on_workbench_route_selected_requested(school_id: StringName) -> void:
	if game_over or cheonsul_slice == null:
		return
	if cheonsul_slice.route_state.set_provisional_next_school(school_id):
		_render_cheonsul_workbench()


func _on_workbench_commit_requested() -> void:
	if cheonsul_slice == null:
		return
	_render_cheonsul_workbench()


func _build_preview_summary(new_fate_id: StringName) -> Dictionary:
	var headline := "구간 %d 완료" % stage_flow.segment_index
	var hints: Array = _latest_result_snapshot.get("growth_hints", [])
	if not hints.is_empty():
		headline = str(hints[0])

	var selected_fate_names: Array[String] = []
	for fate_id in run_build_state.selected_fates:
		selected_fate_names.append(_fate_name(fate_id))

	var summary := {
		"headline": headline,
		"shop_changes": shop_controller.rest_changes.duplicate(),
		"new_fate": _fate_name(new_fate_id),
		"selected_fates": selected_fate_names,
		"gold": run_build_state.gold,
	}

	if stage_flow.segment_index < 3:
		var next_tier := stage_flow.segment_index + 1
		var stats: Dictionary = STAGE_BOSS_SCRIPT.TIER_STATS.get(next_tier, {})
		summary["next_boss"] = "BOSS %d HP %d / CONTACT %d" % [
			next_tier,
			int(stats.get("max_health", 0)),
			int(stats.get("contact_damage", 0)),
		]
	return summary


func _fate_name(fate_id: StringName) -> String:
	var definition = _fate_defs.get(fate_id)
	return str(fate_id) if definition == null else str(definition.display_name)


func _on_preview_start_requested() -> void:
	if game_over or stage_flow.phase != StageFlowController.Phase.PREVIEW:
		return
	if not stage_flow.start_next_combat():
		return

	contribution_tracker.reset_segment(combat_ddd.reward_count, run_build_state.gold)
	var modifiers := run_build_state.get_modifiers()
	var rest_heal := maxi(roundi(float(player.max_health) * maxf(modifiers.rest_start_heal_pct, 0.0)), 0)
	if rest_heal > 0:
		player.heal(rest_heal)

	current_stage_boss = null
	rest_flow_ui.hide_all()
	_set_combat_enabled(true)


func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	if stage_flow != null:
		stage_flow.mark_game_over()
	wave_spawner.set_spawning_enabled(false)
	school_host.deactivate()
	if rest_flow_ui != null:
		rest_flow_ui.hide_all()
	_set_combat_enabled(false)
	_stop_gameplay()
	hud.show_game_over()


func _stop_gameplay() -> void:
	for child in get_children():
		if child == game_state or child == hud:
			continue
		child.process_mode = Node.PROCESS_MODE_DISABLED
