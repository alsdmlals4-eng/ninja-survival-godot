# Main's selected-rules orchestration. Domain rules and disk writes stay in owners.
extends Node

const STORE = preload("res://scripts/core/run_resume_store.gd")
const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")
const START_UI = preload("res://scripts/ui/start_loadout_ui.gd")
const REST_SCREEN = preload("res://scripts/ui/selected_rest_screen.gd")
const CIRCUIT = preload("res://scripts/core/school_circuit_controller.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")
const GROWTH = preload("res://scripts/data/equipment_growth_catalog.gd")
const RECOVERY_UI = preload("res://scripts/ui/selected_profile_recovery_ui.gd")

var store
var start_ui
var rest_screen
var choosing_first_battlefield := false
var emergency_potions := 0
var _main
var _profile: Dictionary = {}
var _bundle: Dictionary = {}
var _start_revision := 0
var _new_run_id := ""
var _start_layer: CanvasLayer
var _waiting_input_release := false
var _waiting_pause_release := false
var _pause_release_tick := -1

func resume_after_menu_release() -> void:
	_waiting_pause_release = true
	_pause_release_tick = -1
	process_mode = Node.PROCESS_MODE_ALWAYS
var _entry_request: Dictionary = {}
var _rest_charge: Dictionary = {}
var _victory_pending := false
var _retry_readback_pending := false
var recovery_ui

func configure(main, path: String) -> void:
	_main = main
	store = STORE.new()
	store.configure_profile(path)
	_main.title_screen.set_selected_rules()
	_main.title_screen.support_unlock_requested.connect(_unlock_support)
	_main.title_screen.recovery_requested.connect(_open_recovery)

func _open_recovery() -> void:
	if is_instance_valid(recovery_ui): recovery_ui.queue_free()
	recovery_ui = RECOVERY_UI.new()
	add_child(recovery_ui)
	recovery_ui.closed.connect(func(): _main.title_screen.recovery_button.grab_focus.call_deferred())
	recovery_ui.recovery_confirmed.connect(_confirm_recovery)
	recovery_ui.show_inventory(store.inspect_profile_recovery())

func _confirm_recovery(role: String, inventory: Dictionary) -> void:
	var result: Dictionary = store.publish_recovery_candidate(role, inventory)
	if not result.ok:
		recovery_ui.show_failure(str(result.get("reason", "unknown")))
		return
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok:
		recovery_ui.show_failure(str(loaded.get("reason", "unknown")))
		return
	recovery_ui.hide()
	refresh_title()
	_main.title_screen.continue_status_label.text = "복구 완료 · 원본은 보관했습니다. 이어하기로 선택한 기록을 확인하세요."
	_main.title_screen.continue_button.grab_focus.call_deferred()

func _unlock_support() -> void:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: refresh_title(); return
	var result: Dictionary = _main.run_settlement_ledger.unlock_selected_support(store, int(loaded.profile.revision))
	refresh_title()
	if not result.ok:
		_main.title_screen.set_support_unlock_state(false, int(loaded.profile.meta.soul_balance), "저장 확인 실패 · %s. 다시 누르면 저장된 결과를 재확인합니다." % result.get("reason", "unknown"))

func is_active() -> bool:
	return not _profile.is_empty() and _profile.get("active_run") is Dictionary

func refresh_title() -> void:
	var loaded: Dictionary = store.load_profile()
	_main.title_screen.set_recovery_available(not loaded.ok and loaded.get("reason") != &"missing")
	if loaded.ok:
		_main.title_screen.set_continue_state(loaded.profile.active_run != null)
		_main.title_screen.set_support_unlock_state(loaded.profile.meta.unlocked_support_choice, int(loaded.profile.meta.soul_balance))
	else:
		var legacy: Dictionary = _main.run_resume_store.load_checkpoint() if loaded.get("reason") == &"missing" else {}
		_main.title_screen.set_continue_state(legacy.get("ok", false), "이전 규칙의 저장으로 이어합니다. 새 게임은 새 규칙을 사용합니다." if legacy.get("ok", false) else ("" if loaded.get("reason") == &"missing" else "저장 상태를 확인해야 합니다. 원본은 보존됩니다."))

func request_new_game() -> void:
	var loaded: Dictionary = store.load_profile()
	if loaded.ok and loaded.profile.active_run != null:
		_main.title_screen.show_new_game_confirmation()
	elif loaded.ok or loaded.get("reason") == &"missing": begin_new_game()
	else: refresh_title()

func begin_new_game() -> void:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok and loaded.get("reason") != &"missing": refresh_title(); return
	_start_revision = int(loaded.profile.revision) if loaded.ok else 0
	_new_run_id = "run:" + str(Time.get_unix_time_from_system()) + ":" + str(Time.get_ticks_usec())
	_main.title_screen.hide_title()
	_start_layer = CanvasLayer.new()
	_start_layer.layer = 20
	add_child(_start_layer)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_start_layer.add_child(panel)
	start_ui = START_UI.new()
	start_ui.support_enabled = loaded.ok and loaded.profile.meta.unlocked_support_choice
	start_ui.custom_minimum_size = Vector2(1000, 650)
	panel.add_child(start_ui)
	start_ui.prepared.connect(_prepared)
	start_ui.cancelled.connect(_cancel_start)

func _cancel_start() -> void:
	choosing_first_battlefield = false
	_bundle = {}
	_main.school_selection.hide()
	if is_instance_valid(_start_layer): _start_layer.queue_free()
	start_ui = null
	_main.title_screen.show_title()
	refresh_title()

func _prepared(bundle: Dictionary) -> void:
	_bundle = bundle.duplicate(true)
	_start_layer.hide()
	choosing_first_battlefield = true
	_main.school_selection._selected = false
	_main.school_selection.get_node("Panel/Margin/Choices/Title").text = "첫 전장 선택 · 시작 유파와 인법은 그대로 유지됩니다"
	_main.school_selection.show_starting_school_selection()

func start_battlefield(school: StringName) -> void:
	if not choosing_first_battlefield: return
	# Import only on confirmed start. Legacy run and wallet bytes remain read-only.
	if _start_revision == 0 and FileAccess.file_exists(_main.wallet_storage_path):
		var imported: Dictionary = store.import_legacy_wallet(_main.wallet_storage_path)
		if not imported.ok:
			_show_start_error(imported)
			return
		var imported_readback: Dictionary = store.load_profile()
		if not imported_readback.ok:
			_show_start_error(imported_readback)
			return
		_start_revision = int(imported_readback.profile.revision)
	var result: Dictionary = _main.run_settlement_ledger.start_selected_run(store, _bundle, school,
		_new_run_id, _start_revision, _main.player._base_max_health)
	if not result.ok: _show_start_error(result); return
	choosing_first_battlefield = false
	_start_layer.queue_free()
	start_ui = null
	_main.school_selection.hide()
	adopt(result.profile)

func _show_start_error(result: Dictionary) -> void:
	_main.school_selection.hide()
	_start_layer.show()
	start_ui.status_label.text = "출전 저장 실패 · %s. 선택한 빌드는 유지됩니다." % result.get("reason", "unknown")
	# The committed bundle is immutable; re-confirm merely retries battlefield selection.
	start_ui.confirm_button.disabled = false
	if not start_ui.confirm_button.pressed.is_connected(_retry_first_choice): start_ui.confirm_button.pressed.connect(_retry_first_choice)

func _retry_first_choice() -> void:
	_start_layer.hide()
	_main.school_selection._selected = false
	_main.school_selection.show_starting_school_selection()

func continue_run() -> void:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok and loaded.get("reason") == &"missing":
		var legacy: Dictionary = _main.run_resume_store.load_checkpoint()
		if legacy.get("ok", false): _main._restore_persistent_resume(legacy.checkpoint); return
	if not loaded.ok or loaded.profile.active_run == null: refresh_title(); return
	adopt(loaded.profile)

func adopt(profile: Dictionary) -> bool:
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(profile)
	if not decoded.ok or decoded.profile.active_run == null: return false
	_profile = decoded.profile
	_retry_readback_pending = false
	process_mode = Node.PROCESS_MODE_INHERIT
	_main._set_combat_enabled(false)
	_main._clear_failed_school_runtime_nodes()
	if is_instance_valid(rest_screen):
		remove_child(rest_screen)
		rest_screen.queue_free()
		rest_screen = null
	if is_instance_valid(_main.school_circuit):
		_main.remove_child(_main.school_circuit)
		_main.school_circuit.queue_free()
		_main.school_circuit = null
	var run: Dictionary = _profile.active_run
	var cp: Dictionary = run.checkpoint
	var build: Dictionary = cp.build.duplicate(true)
	build.committed_backpack_modifiers = MODIFIERS.from_persistent_snapshot(cp.build.committed_backpack_modifiers)
	_main.run_build_state.configure(ITEMS.build_items(), _main._fate_defs)
	if not _main.run_build_state.restore_from_checkpoint(build): return false
	if not _main.ninjutsu_loadout.restore_selected_snapshot(cp.loadout, cp.loadout.active_spell_ids, cp.access.unlocked_ninjutsu_school_ids): return false
	_main.basic_weapons.reset_for_checkpoint()
	if not _main.basic_weapons.apply_equipment_snapshot(cp.build.equipment): return false
	var committed_bag = load("res://scripts/backpack/backpack_state.gd").from_persistent_snapshot(cp.backpack)
	if not _main.basic_weapons.apply_committed_backpack(committed_bag): return false
	_main.school_host.deactivate()
	_main.school_host.selected_school_id = &""
	_main._sync_run_modifiers()
	if not _main.school_host.select_school(StringName(run.starting_school)): return false
	_restore_charge(cp.ultimate_charge)
	_main.player.restore_after_retry()
	_main.player.health = mini(int(cp.get("vitals", {}).get("health", _main.player.max_health)), _main.player.max_health)
	emergency_potions = int(cp.get("vitals", {}).get("emergency_potions", 0))
	_main.player.health_changed.emit(_main.player.health, _main.player.max_health)
	_main.game_over = false
	_main._final_battle_started = false
	_main._school_circuit_elapsed_seconds = 0.0
	_main.title_screen.hide_title()
	_main.school_selection.hide()
	_main.rest_flow_ui.hide_all()
	_main.hud.hide_game_over()
	_main.ninjutsu_auto_controller.configure(_main.player, _main, _main.combat_resolver, _main.ninjutsu_loadout)
	_main.contribution_tracker.reset_segment(_main.combat_ddd.reward_count, _main.run_build_state.gold)
	var circuit = CIRCUIT.new()
	if not circuit.configure_selected_encounters(_main.run_build_state, cp.route): circuit.free(); return false
	_main.add_child(circuit)
	_main.school_circuit = circuit
	circuit.phase_changed.connect(_main._on_school_circuit_phase_changed)
	circuit.trace_spawn_requested.connect(_main._on_school_circuit_trace_spawn_requested)
	circuit.boss_spawn_requested.connect(_main._on_school_circuit_boss_spawn_requested)
	circuit.normal_spawn_permission_changed.connect(_main._on_school_circuit_normal_spawn_permission_changed)
	_entry_request = {}
	_waiting_input_release = false
	if run.preparation is Dictionary:
		_rest_charge = run.preparation.get("ultimate_charge", cp.ultimate_charge).duplicate(true)
		_restore_charge(_rest_charge)
		_open_rest()
	elif cp.circuit.phase == "final_boss":
		_main._start_final_calamity()
		_main._set_combat_enabled(false)
		_waiting_input_release = true
	else:
		if not circuit.begin_school(StringName(cp.route.active_school_id)): return false
		_main._set_combat_enabled(false)
		_waiting_input_release = true
	return true

func _process(_delta: float) -> void:
	if _waiting_pause_release:
		if Input.is_action_pressed(&"dash") or Input.is_action_pressed(&"ultimate") or Input.is_action_pressed(&"ui_accept"):
			_pause_release_tick = -1
			return
		# Godot retains just_pressed separately for physics even after release.
		# Drain that input edge while the whole battle remains paused.
		if _pause_release_tick < 0: _pause_release_tick = Engine.get_physics_frames()
		if Engine.get_physics_frames() < _pause_release_tick + 2: return
		_waiting_pause_release = false
		get_tree().paused = false
	if get_tree().paused: return
	if _waiting_input_release and not Input.is_action_pressed(&"dash") and not Input.is_action_pressed(&"ultimate") and not Input.is_action_pressed(&"ui_accept"):
		_waiting_input_release = false
		_main._set_combat_enabled(true)
	if is_active() and _main._combat_enabled and not _main.game_over and emergency_potions > 0 \
		and _main.player.health > 0 and _main.player.health <= _main.player.max_health * 0.25:
		emergency_potions -= 1
		_main.player.heal(int(GROWTH.CONSUMABLES.emergency.healing))

func enter_rest() -> void:
	if is_instance_valid(rest_screen): return
	if _entry_request.is_empty():
		var cp: Dictionary = _profile.active_run.checkpoint
		_rest_charge = _capture_charge()
		_entry_request = {"run_id": _profile.active_run.run_id, "expected_revision": int(_profile.revision),
			"departure_id": cp.prepare_session_id, "school_id": cp.route.active_school_id,
			"encounter": _main.school_circuit.encounter_state.get_snapshot(), "gold": _main.run_build_state.gold,
			"health": _main.player.health, "maximum_health": _main.player.max_health, "emergency_potions": emergency_potions,
			"ultimate_charge": _rest_charge.duplicate(true)}
	var coordinator = COORDINATOR.new()
	coordinator.configure_selected_profile(store)
	var result: Dictionary = coordinator.commit_selected_entry(_entry_request)
	if not result.ok:
		_main.rest_flow_ui.show_complete({"headline": "휴식 저장 실패 · %s. 원본을 보존했습니다." % result.get("reason", "unknown")})
		return
	_profile = result.profile
	_open_rest()

func _open_rest() -> void:
	_main._set_combat_enabled(false)
	var prep: Dictionary = _profile.active_run.preparation
	_rest_charge = prep.get("ultimate_charge", _profile.active_run.checkpoint.ultimate_charge).duplicate(true)
	_main.player.health = mini(int(prep.get("vitals", {}).get("health", _main.player.health)), _main.player.max_health)
	_main.player.health_changed.emit(_main.player.health, _main.player.max_health)
	emergency_potions = int(prep.get("vitals", {}).get("emergency_potions", 0))
	rest_screen = REST_SCREEN.new()
	add_child(rest_screen)
	var result: Dictionary = rest_screen.configure(_main.rest_flow_ui, store, _rest_charge)
	if result.ok: rest_screen.departed.connect(adopt)

func _capture_charge() -> Dictionary:
	var fields := {"bongma": "spirit", "cheonsul": "reaction_count", "guiin": "gwihyeol", "heukyeong": "execution_charge"}
	var origin: String = _profile.active_run.starting_school
	return {"school_id": origin, "resource_amount": float(_main.school_host.active_runtime.get(fields[origin]))}

func _restore_charge(charge: Dictionary) -> void:
	var fields := {"bongma": "spirit", "cheonsul": "reaction_count", "guiin": "gwihyeol", "heukyeong": "execution_charge"}
	_main.school_host.active_runtime.set(fields[str(charge.school_id)], float(charge.resource_amount))
	_main.school_host.active_runtime._emit_resource()

func _elite_qualified() -> bool:
	return is_active() and (_profile.active_run.elite_qualified or (_main.school_circuit != null and _main.school_circuit.encounter_state.get_snapshot().get("elite_cleared", false)))

func soul_balance() -> int:
	var loaded: Dictionary = store.load_profile()
	return int(loaded.profile.meta.soul_balance) if loaded.ok else 0

func can_retry() -> bool:
	return is_active() and (_retry_readback_pending or (not _profile.active_run.retry_consumed and soul_balance() >= 1))

func retry() -> void:
	if not _main.game_over or not can_retry(): return
	var result: Dictionary = _main.run_settlement_ledger.retry_selected_run(store,
		_profile.active_run.run_id, int(_profile.revision), _elite_qualified())
	if result.ok: adopt(result.profile)
	else:
		_retry_readback_pending = _retry_readback_pending or result.get("persisted", false)
		_main.hud.show_game_over(can_retry(), soul_balance())

func finish_victory() -> void:
	_victory_pending = true
	_finish(true)

func _finish(victory: bool) -> bool:
	if not is_active(): return true
	var result: Dictionary = _main.run_settlement_ledger.settle_selected_run(store,
		_profile.active_run.run_id, int(_profile.revision), victory, _elite_qualified())
	if not result.ok:
		_main.rest_flow_ui.show_complete({"headline": "정산 저장 실패 · 다시 누르면 재시도합니다. 원본은 보존됩니다."})
		return false
	_profile = result.profile
	_victory_pending = false
	if victory: _main.rest_flow_ui.show_complete({"headline": "최종 재앙 격파 · 네 전장 여정 완료 · 닌자소울 +%d" % int(result.get("reward", 0)), "gold": _main.run_build_state.gold})
	return true

func return_to_title() -> bool:
	if _retry_readback_pending:
		# Resolve the already-paid retry rather than settling from a stale revision.
		retry()
		return false
	if not _entry_request.is_empty() and is_active() and _profile.active_run.preparation == null and not _main.game_over:
		enter_rest()
		return false
	return _finish(_victory_pending) if _main.game_over else true
