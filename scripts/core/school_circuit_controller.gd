# 네 유파의 공통 전장 lifecycle과 기존 Workbench 도메인 조립을 담당한다.
extends Node
class_name SchoolCircuitController

const BACKPACK_STATE_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const BACKPACK_RESOLVER_SCRIPT = preload("res://scripts/backpack/backpack_resolver.gd")
const ENCOUNTER_CATALOG_SCRIPT = preload("res://scripts/data/encounter_catalog.gd")
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
var _reward_controller: RestRewardController
var _commit_coordinator: RestCommitCoordinator
var _access_state: TraditionAccessState
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
	phase_changed.emit(encounter_state.state_name())
	return true


func sync_elapsed(elapsed_seconds: float) -> bool:
	if not _school_started:
		return false
	return encounter_state.sync_elapsed(elapsed_seconds)


func mark_elite_defeated() -> bool:
	return _school_started and encounter_state.mark_elite_cleared()


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
	_school_started = false
	boss_cleared.emit(_active_school_id)
	return true


func workbench_snapshot() -> Dictionary:
	if not _workbench_started or _reward_controller == null or _commit_coordinator == null:
		return {}
	return {
		"route_snapshot": route_state.get_route_snapshot(),
		"fate_candidate_ids": _fate_controller.candidate_ids.duplicate(),
		"pending_fate_id": _fate_controller.pending_fate_id(),
		"boss_reward_pending": _reward_controller.has_pending_boss_reward(),
		"boss_reward_options": _reward_controller.boss_reward_options(),
		"boss_reward_labels": _boss_reward_labels(),
		"boss_reward_lane_ids": _reward_controller.boss_reward_lane_ids(),
		"chest_count": _reward_controller.chest_count(),
		"readiness_failures": _commit_coordinator.commit_failures(
			_reward_controller.chest_count(),
			_reward_controller.has_pending_boss_reward()
		),
	}


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
	if not _commit_coordinator.configure(_committed_backpack_state, _build_state, route_state, _fate_controller):
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


func _boss_reward_labels() -> Array[String]:
	var labels: Array[String] = []
	if _reward_controller == null:
		return labels
	for item_id in _reward_controller.boss_reward_options():
		var definition = _item_defs.get(item_id)
		labels.append(str(item_id) if definition == null else str(definition.display_name))
	return labels


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
