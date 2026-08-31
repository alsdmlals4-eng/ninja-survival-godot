# 네 유파의 공통 전장 lifecycle과 기존 Workbench 도메인 조립을 담당한다.
extends Node
class_name SchoolCircuitController

const BACKPACK_STATE_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const BACKPACK_RESOLVER_SCRIPT = preload("res://scripts/backpack/backpack_resolver.gd")
const COMBINATION_RESOLVER_SCRIPT = preload("res://scripts/backpack/combination_resolver.gd")
const ENCOUNTER_CATALOG_SCRIPT = preload("res://scripts/data/encounter_catalog.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")
const REST_BACKPACK_SESSION_SCRIPT = preload("res://scripts/backpack/rest_backpack_session.gd")
const REST_COMMIT_COORDINATOR_SCRIPT = preload("res://scripts/core/rest_commit_coordinator.gd")
const REST_REWARD_CONTROLLER_SCRIPT = preload("res://scripts/core/rest_reward_controller.gd")
const TRADITION_ACCESS_STATE_SCRIPT = preload("res://scripts/core/tradition_access_state.gd")

signal phase_changed(phase: StringName)
signal chest_token_granted(amount: int)
signal trace_spawn_requested
signal boss_warning_requested
signal boss_spawn_requested
signal normal_spawn_permission_changed(allowed: bool)
signal boss_cleared(school_id: StringName)

var route_state := RunRouteState.new()
var encounter_state := StageEncounterState.new()

var _build_state: RunBuildState
var _fate_controller: FateController
var _committed_backpack_state = null
var _backpack_session: RestBackpackSession
var _combination_resolver: CombinationResolver
var _reward_controller: RestRewardController
var _commit_coordinator: RestCommitCoordinator
var _access_state: TraditionAccessState
var _ninjutsu_loadout: Node
var _item_defs: Dictionary = {}
var _bag_defs: Dictionary = {}
var _rng: RandomNumberGenerator
var _encounter: Dictionary = {}
var _active_school_id: StringName = &""
var _chest_token_count: int = 0
var _next_core_encounter_index: int = 0
var _workbench_configured: bool = false
var _workbench_started: bool = false
var _school_started: bool = false


func _ready() -> void:
	_connect_encounter_signals()


func configure_workbench(
	build_state: RunBuildState,
	fate_controller: FateController,
	item_defs: Dictionary,
	bag_defs: Dictionary,
	rng: RandomNumberGenerator
) -> bool:
	if _workbench_configured or build_state == null or fate_controller == null or item_defs.is_empty() or bag_defs.is_empty():
		return false
	if not fate_controller._is_bound_to_build_state(build_state):
		return false
	_committed_backpack_state = BACKPACK_STATE_SCRIPT.new().create_starting_state()
	if _committed_backpack_state == null:
		return false
	_backpack_session = REST_BACKPACK_SESSION_SCRIPT.new()
	_combination_resolver = COMBINATION_RESOLVER_SCRIPT.new()
	_access_state = TRADITION_ACCESS_STATE_SCRIPT.new()
	_reward_controller = REST_REWARD_CONTROLLER_SCRIPT.new()
	add_child(_reward_controller)
	_build_state = build_state
	_fate_controller = fate_controller
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
	_rng = rng
	_workbench_configured = true
	return true


func configure_ninjutsu_loadout(ninjutsu_loadout: Node) -> bool:
	if _school_started or _workbench_started or _ninjutsu_loadout != null or ninjutsu_loadout == null:
		return false
	if not ninjutsu_loadout.has_method("can_stage_scroll") \
		or not ninjutsu_loadout.has_method("stage_scroll") \
		or not ninjutsu_loadout.has_method("get_snapshot"):
		return false
	_ninjutsu_loadout = ninjutsu_loadout
	return true


func begin_school(school_id: StringName) -> bool:
	_connect_encounter_signals()
	if _school_started or not _load_encounter_identity(school_id):
		return false
	if route_state.active_school_id() == &"":
		if not route_state.cleared_school_ids().is_empty():
			return false
		if not route_state.set_provisional_next_school(school_id):
			return false
		if not route_state.commit_provisional_next_school():
			return false
	elif route_state.active_school_id() != school_id:
		return false
	if _access_state != null and not _access_state.is_initialized():
		if not _access_state.initialize(school_id):
			return false
	_reset_school_progress(school_id)
	if _build_state != null:
		_build_state.set_selected_school(school_id)
	phase_changed.emit(encounter_state.state_name())
	return true


func sync_elapsed(elapsed_seconds: float) -> bool:
	if not _school_started:
		return false
	return encounter_state.sync_elapsed(elapsed_seconds)


func record_normal_enemy_defeated() -> int:
	if not _school_started or _build_state == null:
		return 0
	return _build_state.grant_normal_kill_gold()


func mark_elite_defeated() -> bool:
	if not _school_started:
		return false
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("can_stage_scroll", _active_school_id, &"elite_scroll")):
		return false
	if not encounter_state.mark_elite_cleared():
		return false
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("stage_scroll", _active_school_id, &"elite_scroll")):
		return false
	if _build_state != null:
		_build_state.grant_elite_clear_gold()
	return true


func recover_trace() -> bool:
	return _school_started and encounter_state.recover_trace()


func mark_boss_defeated() -> bool:
	if not _school_started or not _workbench_configured or _workbench_started:
		return false
	if not encounter_state.mark_boss_cleared():
		return false
	if not route_state.mark_active_school_cleared():
		return false
	if _access_state != null:
		_access_state.stabilize_school(_active_school_id)
	if not _begin_workbench_for_cleared_school():
		return false
	if _build_state != null:
		_build_state.grant_school_boss_clear_gold()
	_school_started = false
	boss_cleared.emit(_active_school_id)
	return true


func workbench_snapshot() -> Dictionary:
	if not _workbench_started or _reward_controller == null or _commit_coordinator == null:
		return {}
	var combination_pending := _has_pending_combination()
	return {
		"route_snapshot": route_state.get_route_snapshot(),
		"fate_candidate_ids": _fate_controller.candidate_ids.duplicate(),
		"pending_fate_id": _fate_controller.pending_fate_id(),
		"boss_reward_pending": _reward_controller.has_pending_boss_reward(),
		"boss_reward_options": _reward_controller.boss_reward_options(),
		"boss_reward_labels": _boss_reward_labels(),
		"boss_reward_lane_ids": _reward_controller.boss_reward_lane_ids(),
		"chest_count": _reward_controller.chest_count(),
		"buffer": _buffer_snapshot(),
		"bag_offer": _bag_offer_snapshot(),
		"pending_bag": _pending_bag_snapshot(),
		"gold": int(_build_state.gold) if _build_state != null else 0,
		"can_undo": not _backpack_session._undo_stack.is_empty(),
		"backpack_board": _backpack_board_snapshot(),
		"combination_options": _combination_options(),
		"combination_pending": combination_pending,
		"pending_combination": _pending_combination_snapshot(),
		"ninjutsu_active_spell_ids": _ninjutsu_active_spell_ids(),
		"ninjutsu_pending_spell_ids": _ninjutsu_pending_spell_ids(),
		"readiness_failures": _commit_coordinator.commit_failures(
			_reward_controller.chest_count(),
			_reward_controller.has_pending_boss_reward(),
			combination_pending
		),
	}


func choose_boss_reward(index: int) -> bool:
	if not _workbench_started or _reward_controller == null:
		return false
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("can_stage_scroll", _active_school_id, &"boss_scroll")):
		return false
	if not _reward_controller.choose_boss_reward(index):
		return false
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("stage_scroll", _active_school_id, &"boss_scroll")):
		return false
	return true


func place_buffer_item(buffer_index: int, origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if not _workbench_started or _backpack_session == null:
		return false
	return _backpack_session.place_buffer_item(buffer_index, origin, rotation_quarters)


func open_chest() -> bool:
	if not _workbench_started or _reward_controller == null:
		return false
	return _reward_controller.open_chest()


func buy_shop_bag() -> bool:
	if not _workbench_started or _reward_controller == null:
		return false
	return _reward_controller.buy_shop_bag()


func place_pending_bag(origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if not _workbench_started or _backpack_session == null:
		return false
	return _backpack_session.place_pending_bag(origin, rotation_quarters)


func move_workbench_item(instance_id: int, origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if not _workbench_started or _backpack_session == null:
		return false
	var preview = _backpack_session.preview_item(instance_id, origin, rotation_quarters)
	if preview == null or not preview.valid:
		return false
	return _backpack_session.commit_item_preview()


func undo_workbench_edit() -> bool:
	return _workbench_started and _backpack_session != null and _backpack_session.undo()


func begin_workbench_combination(index: int) -> bool:
	if not _workbench_started or _combination_resolver == null:
		return false
	var options := _combination_options()
	if index < 0 or index >= options.size():
		return false
	var option: Dictionary = options[index]
	return _combination_resolver.begin_result_preview(
		_backpack_session,
		StringName(option.get("combo_id", &"")),
		int(option.get("source_a_instance", 0)),
		int(option.get("source_b_instance", 0))
	)


func commit_workbench_combination(origin: Vector2i, rotation_quarters: int = 0) -> bool:
	return (
		_workbench_started
		and _combination_resolver != null
		and _combination_resolver.commit_result(_backpack_session, origin, rotation_quarters)
	)


func cancel_workbench_combination() -> bool:
	if not _workbench_started or _combination_resolver == null or not _has_pending_combination():
		return false
	_combination_resolver.cancel_result(_backpack_session)
	return true


func choose_fate(fate_id: StringName) -> bool:
	if not _workbench_started or _fate_controller == null:
		return false
	return _fate_controller.choose_pending(fate_id)


func choose_next_route(school_id: StringName) -> bool:
	if not _workbench_started:
		return false
	return route_state.set_provisional_next_school(school_id)


func commit_workbench() -> bool:
	if not _workbench_started or _commit_coordinator == null or _reward_controller == null:
		return false
	if not _commit_coordinator.commit(
		_reward_controller.chest_count(),
		_reward_controller.has_pending_boss_reward(),
		_has_pending_combination()
	):
		return false
	_committed_backpack_state = _commit_coordinator.committed_backpack_state()
	_workbench_started = false
	return true


func get_checkpoint_snapshot() -> Dictionary:
	if _committed_backpack_state == null or _active_school_id == &"":
		return {}
	return {
		"active_school_id": _active_school_id,
		"committed_backpack_state": _committed_backpack_state.copy_value(),
	}


func can_restore_after_retry(checkpoint_snapshot: Dictionary) -> bool:
	if not _school_started or _workbench_started:
		return false
	var checkpoint_school_id := StringName(checkpoint_snapshot.get("active_school_id", &""))
	var checkpoint_backpack_state = checkpoint_snapshot.get("committed_backpack_state", null)
	return (
		checkpoint_school_id == _active_school_id
		and checkpoint_school_id == route_state.active_school_id()
		and checkpoint_backpack_state != null
		and checkpoint_backpack_state.has_method("copy_value")
	)


func restore_after_retry(checkpoint_snapshot: Dictionary) -> bool:
	if not can_restore_after_retry(checkpoint_snapshot):
		return false
	var checkpoint_backpack_state = checkpoint_snapshot.get("committed_backpack_state", null)
	_committed_backpack_state = checkpoint_backpack_state.copy_value()
	encounter_state = StageEncounterState.new()
	_connect_encounter_signals()
	_chest_token_count = 0
	_next_core_encounter_index = 0
	phase_changed.emit(&"core")
	return true


func next_core_encounter() -> Dictionary:
	var core_ids: Array = _encounter.get("core_monster_ids", [])
	var core_names: Array = _encounter.get("core_monster_display_names", [])
	if core_ids.is_empty() or core_ids.size() != core_names.size():
		return {}
	var index := _next_core_encounter_index % core_ids.size()
	_next_core_encounter_index += 1
	return {
		"id": StringName(core_ids[index]),
		"display_name": str(core_names[index]),
	}


func get_snapshot() -> Dictionary:
	var encounter_snapshot := encounter_state.get_snapshot()
	return {
		"route": route_state.get_route_snapshot(),
		"state": encounter_snapshot.get("state", &"unknown"),
		"boss_requested": encounter_snapshot.get("boss_requested", false),
		"trace_recovered": encounter_snapshot.get("trace_recovered", false),
		"normal_spawning_allowed": encounter_snapshot.get("normal_spawning_allowed", false),
		"elapsed_seconds": encounter_snapshot.get("elapsed_seconds", 0.0),
		"encounter": _encounter.duplicate(true),
		"selected_fate_ids": _build_state.selected_fates.duplicate() if _build_state != null else [],
	}


func _reset_school_progress(school_id: StringName) -> void:
	if encounter_state.state_name() != &"core" or encounter_state.get_snapshot().get("elapsed_seconds", 0.0) != 0.0:
		encounter_state = StageEncounterState.new()
		_connect_encounter_signals()
	_active_school_id = school_id
	_chest_token_count = 0
	_next_core_encounter_index = 0
	_workbench_started = false
	_school_started = true


func _begin_workbench_for_cleared_school() -> bool:
	if _backpack_session == null or _reward_controller == null or _fate_controller == null or _access_state == null:
		return false
	_backpack_session.begin(
		_committed_backpack_state,
		BACKPACK_RESOLVER_SCRIPT.new(),
		_item_defs,
		_bag_defs,
		_active_school_id
	)
	_reward_controller.configure(
		_build_state,
		_backpack_session,
		_item_defs,
		_bag_defs,
		_rng,
		_access_state
	)
	_commit_coordinator = REST_COMMIT_COORDINATOR_SCRIPT.new()
	if not _commit_coordinator.configure(
		_committed_backpack_state,
		_build_state,
		route_state,
		_fate_controller,
		_ninjutsu_loadout
	):
		return false
	_reward_controller.begin_rest(
		route_state.stage_index(),
		_active_school_id,
		_chest_token_count,
		_active_school_id
	)
	_fate_controller.begin_rest()
	if not _commit_coordinator.begin_rest(_backpack_session):
		return false
	_workbench_started = true
	return true


func _ninjutsu_active_spell_ids() -> Array:
	if _ninjutsu_loadout == null:
		return []
	return Array(_ninjutsu_loadout.call("get_snapshot").get("active_spell_ids", [])).duplicate()


func _ninjutsu_pending_spell_ids() -> Array:
	if _ninjutsu_loadout == null:
		return []
	return Array(_ninjutsu_loadout.call("get_snapshot").get("pending_spell_ids", [])).duplicate()


func _boss_reward_labels() -> Array[String]:
	var labels: Array[String] = []
	if _reward_controller == null:
		return labels
	for item_id in _reward_controller.boss_reward_options():
		var definition = _item_defs.get(item_id)
		labels.append(str(item_id) if definition == null else str(definition.display_name))
	return labels


func _buffer_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _backpack_session == null:
		return result
	for raw_item in _backpack_session.buffer:
		var definition = _item_defs.get(raw_item.definition_id)
		result.append({
			"instance_id": raw_item.instance_id,
			"definition_id": raw_item.definition_id,
			"display_name": str(raw_item.definition_id) if definition == null else str(definition.display_name),
			"rotation_quarters": raw_item.rotation_quarters,
		})
	return result


func _bag_offer_snapshot() -> Dictionary:
	if _reward_controller == null:
		return {}
	var bag_id := _reward_controller.shop_bag_option()
	var definition = _bag_defs.get(bag_id)
	if bag_id == &"" or definition == null:
		return {}
	return {
		"definition_id": bag_id,
		"display_name": str(definition.display_name),
		"price": int(definition.base_price),
	}


func _pending_bag_snapshot() -> Dictionary:
	if _backpack_session == null:
		return {}
	var pending_bag = _backpack_session.pending_bag
	if pending_bag == null:
		return {}
	var definition = _bag_defs.get(pending_bag.definition_id)
	return {
		"instance_id": pending_bag.instance_id,
		"definition_id": pending_bag.definition_id,
		"display_name": str(pending_bag.definition_id) if definition == null else str(definition.display_name),
		"rotation_quarters": pending_bag.rotation_quarters,
	}


func _backpack_board_snapshot() -> Dictionary:
	if _backpack_session == null or _backpack_session.state == null:
		return {}
	var state = _backpack_session.state
	var active_cells: Array[Vector2i] = []
	var active_lookup: Dictionary = state.get_active_cells()
	for y in range(BACKPACK_STATE_SCRIPT.BOARD_SIZE.y):
		for x in range(BACKPACK_STATE_SCRIPT.BOARD_SIZE.x):
			var cell := Vector2i(x, y)
			if active_lookup.has(cell):
				active_cells.append(cell)
	var board_items: Array[Dictionary] = []
	var instances: Dictionary = state.items
	var instance_ids: Array[int] = []
	for raw_instance_id in instances.keys():
		instance_ids.append(int(raw_instance_id))
	instance_ids.sort()
	for instance_id in instance_ids:
		var item = instances.get(instance_id)
		if item == null:
			continue
		var definition = _item_defs.get(item.definition_id)
		if definition == null:
			continue
		var cells: Array[Vector2i] = []
		for relative_cell in definition.footprint(item.rotation_quarters):
			cells.append(item.origin + relative_cell)
		board_items.append({
			"instance_id": item.instance_id,
			"definition_id": item.definition_id,
			"display_name": str(definition.display_name),
			"origin": item.origin,
			"rotation_quarters": item.rotation_quarters,
			"cells": cells,
		})
	return {"active_cells": active_cells, "items": board_items}


func _combination_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	if _backpack_session == null or _combination_resolver == null or _has_pending_combination():
		return options
	var state = _backpack_session.state
	var resolution = _backpack_session.current_resolution()
	if state == null or resolution == null or not bool(resolution.valid):
		return options
	var pairs: Array = _combination_resolver.eligible_pairs(
		state,
		resolution,
		MVP4_CATALOG_SCRIPT.build_combinations()
	)
	for raw_pair in pairs:
		var pair: Dictionary = raw_pair
		var source_a = state.get_item(int(pair.get("source_a_instance", 0)))
		var source_b = state.get_item(int(pair.get("source_b_instance", 0)))
		var result_definition = _item_defs.get(StringName(pair.get("result_item", &"")))
		if source_a == null or source_b == null or result_definition == null:
			continue
		var source_a_definition = _item_defs.get(source_a.definition_id)
		var source_b_definition = _item_defs.get(source_b.definition_id)
		if source_a_definition == null or source_b_definition == null:
			continue
		options.append({
			"combo_id": StringName(pair.get("combo_id", &"")),
			"source_a_instance": int(pair.get("source_a_instance", 0)),
			"source_b_instance": int(pair.get("source_b_instance", 0)),
			"result_item": StringName(pair.get("result_item", &"")),
			"display_name": "%s + %s → %s" % [
				str(source_a_definition.display_name),
				str(source_b_definition.display_name),
				str(result_definition.display_name),
			],
		})
	return options


func _has_pending_combination() -> bool:
	return _combination_resolver != null and not _combination_resolver.pending_result.is_empty()


func _pending_combination_snapshot() -> Dictionary:
	if not _has_pending_combination():
		return {}
	var pending: Dictionary = _combination_resolver.pending_result
	var result_definition = _item_defs.get(StringName(pending.get("result_item", &"")))
	pending["display_name"] = str(pending.get("result_item", "조합 결과")) if result_definition == null else str(result_definition.display_name)
	return pending


func _load_encounter_identity(school_id: StringName) -> bool:
	var schools: Dictionary = ENCOUNTER_CATALOG_SCRIPT.build_school_encounters()
	var definition = schools.get(school_id)
	if definition == null or definition.school_id != school_id:
		return false
	if definition.core_monster_ids.size() != 3 or definition.core_monster_display_names.size() != 3:
		return false
	if definition.elite_id == &"" or definition.boss_id == &"" or definition.pattern_refs.is_empty():
		return false
	_encounter = {
		"school_id": definition.school_id,
		"core_monster_ids": definition.core_monster_ids.duplicate(),
		"core_monster_display_names": definition.core_monster_display_names.duplicate(),
		"elite_id": definition.elite_id,
		"elite_display_name": definition.elite_display_name,
		"boss_id": definition.boss_id,
		"boss_display_name": definition.boss_display_name,
		"pattern_refs": definition.pattern_refs.duplicate(),
	}
	return true


func _connect_encounter_signals() -> void:
	if not encounter_state.elite_warning_requested.is_connected(_on_elite_warning_requested):
		encounter_state.elite_warning_requested.connect(_on_elite_warning_requested)
	if not encounter_state.elite_requested.is_connected(_on_elite_requested):
		encounter_state.elite_requested.connect(_on_elite_requested)
	if not encounter_state.chest_token_requested.is_connected(_on_chest_token_requested):
		encounter_state.chest_token_requested.connect(_on_chest_token_requested)
	if not encounter_state.trace_spawn_requested.is_connected(_on_trace_spawn_requested):
		encounter_state.trace_spawn_requested.connect(_on_trace_spawn_requested)
	if not encounter_state.trace_recovered.is_connected(_on_trace_recovered):
		encounter_state.trace_recovered.connect(_on_trace_recovered)
	if not encounter_state.boss_warning_requested.is_connected(_on_boss_warning_requested):
		encounter_state.boss_warning_requested.connect(_on_boss_warning_requested)
	if not encounter_state.boss_requested.is_connected(_on_boss_requested):
		encounter_state.boss_requested.connect(_on_boss_requested)
	if not encounter_state.normal_spawn_permission_changed.is_connected(_on_normal_spawn_permission_changed):
		encounter_state.normal_spawn_permission_changed.connect(_on_normal_spawn_permission_changed)


func _on_elite_warning_requested() -> void:
	phase_changed.emit(&"elite_warning")


func _on_elite_requested() -> void:
	phase_changed.emit(&"elite_active")


func _on_chest_token_requested(amount: int) -> void:
	_chest_token_count += maxi(amount, 0)
	chest_token_granted.emit(amount)


func _on_trace_spawn_requested() -> void:
	phase_changed.emit(&"trace_available")
	trace_spawn_requested.emit()


func _on_trace_recovered() -> void:
	phase_changed.emit(&"trace_recovered")


func _on_boss_warning_requested() -> void:
	phase_changed.emit(&"boss_warning")
	boss_warning_requested.emit()


func _on_boss_requested() -> void:
	phase_changed.emit(&"boss_active")
	boss_spawn_requested.emit()


func _on_normal_spawn_permission_changed(allowed: bool) -> void:
	normal_spawn_permission_changed.emit(allowed)
