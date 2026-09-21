extends SceneTree
## 4 origins x 6 remaining battlefield orders through real Main, transactions and actors.
## Encounter clock/damage accelerated. NOT natural play or fun verification.
const SCHOOLS := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
var main
var completed := 0
var shard := 0
var shards := 1

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2:
		shard = int(args[0])
		shards = int(args[1])
	if shards < 1 or shard < 0 or shard >= shards: quit(2); return
	var case_index := 0
	for origin in range(4):
		for order in _permutations(SCHOOLS):
			if order[0] != SCHOOLS[origin]: continue
			case_index += 1
			if (case_index - 1) % shards != shard: continue
			if not await _route(origin, order):
				quit(1)
				return
			completed += 1
			print("ROUTE_PASS case=", case_index, "/24 origin=", SCHOOLS[origin], " order=", order)
	print("SELECTED_ROUTE_MATRIX_SHARD_PASS shard=", shard, "/", shards, " count=", completed, " · accelerated Main/actor/store; natural play NOT_RUN")
	quit(0)

func _permutations(items: Array) -> Array:
	if items.is_empty(): return [[]]
	var result: Array = []
	for item in items:
		var rest := items.duplicate()
		rest.erase(item)
		for tail in _permutations(rest): result.append([item] + tail)
	return result

func _route(origin: int, order: Array) -> bool:
	main = load("res://scenes/main/main_scene.tscn").instantiate()
	var prefix := "user://qa_route_matrix_%d_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec(), completed]
	main.profile_storage_path = prefix + "_profile.json"
	main.wallet_storage_path = prefix + "_wallet.json"
	main.resume_storage_path = prefix + "_resume.json"
	root.add_child(main)
	main.title_screen.new_game_requested.emit()
	var ui = main.selected_run.start_ui
	ui.school_buttons[origin].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	if ui.confirm_button.disabled: return _fail("start draft")
	ui.confirm_button.pressed.emit()
	await process_frame
	await process_frame
	for index in range(4):
		if not main._combat_enabled or main.school_circuit.route_state.active_school_id() != order[index]: return _fail("school start")
		if main.school_host.selected_school_id != SCHOOLS[origin]: return _fail("origin changed")
		main.school_circuit.sync_elapsed(180.0)
		var elite = _actor(&"elite")
		if elite == null: return _fail("elite spawn")
		elite.take_damage(99999)
		var trace = main.current_trace_pickup
		if trace == null: return _fail("trace")
		main.player.global_position = trace.global_position
		trace._process(0.75)
		main.school_circuit.sync_elapsed(290.0)
		var boss = _actor(&"boss")
		if boss == null: return _fail("boss spawn")
		boss.take_damage(99999)
		var screen = main.selected_run.rest_screen
		if screen == null or main._combat_enabled: return _fail("camp entry")
		# Exercise both trace paths; origin is the enhance-only case.
		screen.action_button("trace", "melee" if order[index] == SCHOOLS[origin] else "absorb").pressed.emit()
		main.rest_flow_ui.workbench_boss_reward_choices.get_child(0).pressed.emit()
		main.rest_flow_ui.workbench_chest_open_button.pressed.emit()
		for unused in range(6):
			if screen.adapter.spatial.buffer.is_empty(): break
			main.rest_flow_ui.workbench_shop_sell_requested.emit(screen.adapter.spatial.buffer[0].instance_id)
		if index < 3:
			main.rest_flow_ui.workbench_route_selected_requested.emit(order[index + 1])
			var fates: Array = screen.adapter.snapshot().fate_state.candidate_ids
			if not fates.is_empty(): main.rest_flow_ui.fate_selected_requested.emit(StringName(fates[0]))
		if main.rest_flow_ui.workbench_commit_button.disabled: return _fail("departure " + str(screen.adapter.readiness(screen._charge)))
		main.rest_flow_ui.workbench_commit_button.pressed.emit()
		await process_frame
		await process_frame
	if not main._final_battle_started or main.school_circuit.route_state.clear_order() != order: return _fail("final route")
	var final = _actor(&"final_boss")
	if final == null: return _fail("final spawn")
	final.take_damage(99999)
	var profile: Dictionary = main.selected_run.store.load_profile().profile
	if profile.active_run != null or int(profile.meta.soul_balance) != 6 or not main.rest_flow_ui.complete_view.visible: return _fail("settlement")
	main.queue_free()
	await process_frame
	await process_frame
	return true

func _actor(role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion(): return child
	return null

func _fail(reason: String) -> bool:
	push_error("SELECTED_ROUTE_MATRIX_FAIL case=%d %s" % [completed + 1, reason])
	return false
