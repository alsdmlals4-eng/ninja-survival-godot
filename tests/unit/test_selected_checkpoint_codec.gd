extends GutTest

const CODEC = preload("res://scripts/core/run_resume_codec.gd")
const START = preload("res://scripts/core/start_loadout_session.gd")
const ROUTE = preload("res://scripts/core/run_route_state.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")
const STORE = preload("res://scripts/core/run_resume_store.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")


func test_profile_accepts_post_boss_preparation_without_replaying_boss() -> void:
	var checkpoint := _checkpoint(&"bongma")
	var access = ACCESS.new()
	assert_true(access.restore_selected_snapshot(checkpoint.access))
	assert_true(access.stabilize_school(&"cheonsul"))
	var spatial = load("res://scripts/backpack/rest_backpack_session.gd").new()
	var catalog = load("res://scripts/data/selected_backpack_catalog.gd")
	var bags: Dictionary = load("res://scripts/data/mvp4_catalog.gd").build_bags()
	assert_true(spatial.begin(load("res://scripts/backpack/backpack_state.gd").from_persistent_snapshot(checkpoint.backpack),
		load("res://scripts/backpack/backpack_resolver.gd").new(), catalog.build_items(), bags, &"bongma", [], true))
	var rewards = load("res://scripts/core/rest_reward_controller.gd").new()
	add_child_autofree(rewards)
	var rng := RandomNumberGenerator.new()
	rng.seed = 75
	rewards.configure(null, spatial, catalog.build_items(), bags, rng, access)
	# Shop requires a build owner even before any spending.
	var build = add_child_autofree(load("res://scripts/core/run_build_state.gd").new())
	build.configure(catalog.build_items(), load("res://scripts/data/mvp3_catalog.gd").build_fates())
	rewards.configure(build, spatial, catalog.build_items(), bags, rng, access)
	rewards.begin_rest(1, &"bongma", 1, &"cheonsul")
	var preparation := {"prepare_session_id": "prepare:after:1", "phase": "preparing", "revision": 0,
		"access": access.get_snapshot(), "equipment": checkpoint.build.equipment,
		"spatial_session": spatial.persistent_preparation_snapshot(), "loadout": checkpoint.loadout,
		"gold": 150, "reward_state": rewards.persistent_snapshot(), "pending_fate": "",
		"provisional_school": "", "healing_applied": true}
	var raw := {"schema_version": 2, "revision": 0, "content_contract": CODEC.PROFILE_CONTRACT,
		"meta": {"soul_balance": 2, "unlocked_support_choice": false, "settled_run_ids": [],
			"applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": {"run_id": "run:prep", "starting_school": "bongma", "elite_qualified": true,
			"retry_consumed": false, "eligible_boss_ids": ["cheonsul"], "checkpoint": checkpoint,
			"preparation": JSON.parse_string(JSON.stringify(preparation))}}
	var result: Dictionary = CODEC.new().decode_profile_v2(raw)
	assert_true(result.ok, str(result))
	if not result.ok:
		return
	var path := "user://gut_selected_preparation_20260914.json"
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	var store = STORE.new()
	assert_true(store.configure_profile(path))
	assert_true(store.transact_profile(raw, 0, "prepare:after:1").ok)
	var reopened = STORE.new()
	assert_true(reopened.configure_profile(path))
	var restored: Dictionary = reopened.load_profile()
	assert_true(restored.ok)
	if restored.ok:
		assert_eq(restored.profile.active_run.checkpoint, checkpoint)
		assert_eq(restored.profile.active_run.preparation.reward_state.chests, 1.0)
		assert_eq(restored.profile.active_run.preparation.gold, 150.0)
		assert_eq(restored.profile.active_run.eligible_boss_ids, ["cheonsul"])
		assert_true(reopened.transact_profile(raw, 0, "prepare:after:1").already_applied)
		var retry_request: Dictionary = restored.profile.duplicate(true)
		retry_request.meta.soul_balance -= 1
		retry_request.active_run.preparation = null
		retry_request.active_run.retry_consumed = true
		assert_true(reopened.transact_profile(retry_request, 1, "retry:run:prep").ok)
		var after_retry: Dictionary = reopened.load_profile().profile
		assert_eq(after_retry.meta.soul_balance, 1)
		assert_eq(after_retry.active_run.eligible_boss_ids, ["cheonsul"])
		assert_eq(after_retry.active_run.checkpoint, checkpoint)
		assert_true(after_retry.active_run.retry_consumed)
		assert_null(after_retry.active_run.preparation)
		assert_true(reopened.transact_profile(retry_request, 1, "retry:run:prep").already_applied)
		assert_eq(reopened.load_profile().profile.meta.soul_balance, 1)
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	var broken := raw.duplicate(true)
	broken.active_run.preparation.reward_state.chests = -1
	assert_false(CODEC.new().decode_profile_v2(broken).ok)
	broken = raw.duplicate(true)
	broken.active_run.preparation.reward_state.segment = 2
	assert_false(CODEC.new().decode_profile_v2(broken).ok, "Preparation must belong to the completed departure stage")
	broken = raw.duplicate(true)
	broken.active_run.preparation.prepare_session_id = checkpoint.prepare_session_id
	assert_false(CODEC.new().decode_profile_v2(broken).ok)
	broken = raw.duplicate(true)
	broken.active_run.eligible_boss_ids = []
	assert_false(CODEC.new().decode_profile_v2(broken).ok)
	# A retry rolls back the departure, never the already-earned boss eligibility.
	var retry := raw.duplicate(true)
	retry.active_run.preparation = null
	retry.active_run.retry_consumed = true
	assert_false(CODEC.new().decode_profile_v2(retry).ok, "A retry requires its durable transaction receipt")
	assert_true(CODEC.new().decode_profile_v2(retry, "retry:run:prep").ok, "Pending retry preserves this battlefield's already-earned eligibility")
	retry.active_run.eligible_boss_ids.append("guiin")
	assert_false(CODEC.new().decode_profile_v2(retry, "retry:run:prep").ok, "An unvisited unrelated battlefield cannot gain eligibility")
	retry.active_run.eligible_boss_ids = []
	assert_false(CODEC.new().decode_profile_v2(retry).ok, "Even an empty eligibility retry needs a receipt")
	assert_true(CODEC.new().decode_profile_v2(retry, "retry:run:prep").ok, "Retry before boss death has no new boss eligibility")
	retry.active_run.retry_consumed = false
	retry.active_run.eligible_boss_ids = ["cheonsul"]
	assert_false(CODEC.new().decode_profile_v2(retry).ok, "Ordinary departure cannot invent an extra clear")


func _checkpoint(school: StringName) -> Dictionary:
	var session = add_child_autofree(START.new())
	assert_true(session.begin(school, 42))
	for index in range(2):
		assert_true(session.choose(session.snapshot().draft.options[0]))
	assert_true(session.confirm())
	var bundle: Dictionary = session.committed_snapshot()
	var route = ROUTE.new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	assert_true(route.commit_provisional_next_school())
	return JSON.parse_string(JSON.stringify({
		"rules_version": CODEC.PROFILE_CONTRACT, "prepare_session_id": "prepare:test:1",
		"build": {"gold": 0, "selected_school_id": school, "owned_items": {},
			"selected_fates": [], "economy_receipts": [], "equipment": bundle.equipment,
			"committed_backpack_modifiers": MODIFIERS.new().to_persistent_snapshot()},
		"route": route.get_route_snapshot(),
		"circuit": {"phase": "core", "active_school_id": "cheonsul"},
		"backpack": bundle.backpack, "buffer": [], "loadout": bundle.loadout,
		"access": bundle.access, "ultimate_charge": {"school_id": school, "resource_amount": 0}
	}))


func test_departure_checkpoint_accepts_four_origins_without_equating_origin_and_battlefield() -> void:
	var codec = CODEC.new()
	assert_true(codec.has_method("decode_selected_checkpoint"))
	if not codec.has_method("decode_selected_checkpoint"):
		return
	for school in [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]:
		var raw := _checkpoint(school)
		var result: Dictionary = codec.decode_selected_checkpoint(raw)
		assert_true(result.ok, str(result))
		if result.ok:
			assert_eq(result.checkpoint, raw)
			result.checkpoint.build.gold = 999
			assert_eq(raw.build.gold, 0.0, "Decoder must not mutate live/caller data")


func test_departure_checkpoint_rejects_cross_owner_drift_and_malformed_types() -> void:
	var codec = CODEC.new()
	assert_true(codec.has_method("decode_selected_checkpoint"))
	if not codec.has_method("decode_selected_checkpoint"):
		return
	var raw := _checkpoint(&"bongma")
	for path in [["route", "active_school_id"], ["route", "cleared_school_ids"],
		["route", "stage_index"], ["route", "final_binding_eligible"],
		["build", "gold"], ["build", "selected_fates"], ["ultimate_charge", "resource_amount"]]:
		var broken: Dictionary = raw.duplicate(true)
		broken[path[0]][path[1]] = null
		assert_false(codec.decode_selected_checkpoint(broken).ok, str(path))
	var mismatched: Dictionary = raw.duplicate(true)
	mismatched.circuit.active_school_id = "guiin"
	assert_false(codec.decode_selected_checkpoint(mismatched).ok)
	mismatched = raw.duplicate(true)
	mismatched.build.selected_school_id = "guiin"
	assert_false(codec.decode_selected_checkpoint(mismatched).ok)
	mismatched = raw.duplicate(true)
	mismatched.ultimate_charge.resource_amount = 121
	assert_false(codec.decode_selected_checkpoint(mismatched).ok)
	mismatched = raw.duplicate(true)
	mismatched.build.committed_backpack_modifiers.move_speed_pct = 9.0
	assert_false(codec.decode_selected_checkpoint(mismatched).ok, "Saved computed power must match actual placement")
	mismatched = raw.duplicate(true)
	mismatched.route.clear_order = ["guiin"]
	assert_false(codec.decode_selected_checkpoint(mismatched).ok, "Derived route mirrors cannot disagree")
	mismatched = raw.duplicate(true)
	mismatched.circuit.phase = "boss"
	assert_false(codec.decode_selected_checkpoint(mismatched).ok, "Only departure boundaries can be restored")


func test_profile_persists_departure_and_rejects_settled_or_mismatched_active_run() -> void:
	var path := "user://gut_selected_departure_20260914.json"
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))
	var checkpoint := _checkpoint(&"bongma")
	checkpoint.route.stage_index = 1 # Live snapshots use int; JSON reload uses float.
	checkpoint.ultimate_charge.resource_amount = 0.123456789012345
	var profile := {"schema_version": 2, "revision": 0, "content_contract": CODEC.PROFILE_CONTRACT,
		"meta": {"soul_balance": 0, "unlocked_support_choice": false,
			"settled_run_ids": [], "applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": {"run_id": "run:test", "starting_school": "bongma", "eligible_boss_ids": [],
			"elite_qualified": false, "retry_consumed": false, "checkpoint": checkpoint, "preparation": null}}
	var store = STORE.new()
	assert_true(store.configure_profile(path))
	var result: Dictionary = store.transact_profile(profile, 0, "depart:prepare:test:1")
	assert_true(result.ok, str(result))
	if result.ok:
		var restored: Dictionary = store.load_profile().profile
		assert_eq(restored.active_run.checkpoint.loadout.active_spell_ids.size(), 2)
		assert_eq(restored.active_run.checkpoint.ultimate_charge.resource_amount, 0.123456789012345)
		var replay: Dictionary = store.transact_profile(restored, 0, "depart:prepare:test:1")
		assert_true(replay.ok, "Equivalent replay after JSON reload must not conflict: " + str(replay))
		assert_true(replay.get("already_applied", false))
		var before := FileAccess.get_file_as_string(path)
		restored.active_run.starting_school = "guiin"
		assert_false(store.transact_profile(restored, 1, "invalid:origin").ok)
		assert_eq(FileAccess.get_file_as_string(path), before)
		var settled: Dictionary = store.load_profile().profile
		settled.meta.settled_run_ids.append("run:test")
		assert_false(store.transact_profile(settled, 1, "settle:run:test").ok, "Settled run cannot remain resumable")
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func test_all_clear_orders_preserve_trace_decisions_and_final_departure() -> void:
	var schools := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
	var orders := 0
	for first in schools:
		for second in schools:
			for third in schools:
				if first == second or first == third or second == third:
					continue
				var remaining: Array = schools.duplicate()
				for school in [first, second, third]:
					remaining.erase(school)
				var order := [first, second, third, remaining[0]]
				var raw := _checkpoint(&"bongma")
				var route = ROUTE.new()
				var access = ACCESS.new()
				var gear = GEAR.new()
				assert_true(access.restore_selected_snapshot(raw.access))
				assert_true(gear.restore_snapshot(raw.build.equipment))
				for school in order:
					assert_true(route.set_provisional_next_school(school))
					assert_true(route.commit_provisional_next_school())
					raw.route = JSON.parse_string(JSON.stringify(route.get_route_snapshot()))
					raw.circuit.active_school_id = str(school)
					assert_true(CODEC.new().decode_selected_checkpoint(raw).ok)
					assert_true(route.mark_active_school_cleared())
					assert_true(access.stabilize_school(school))
					assert_true(access.decide_trace(school, &"enhance", gear, &"melee", int(gear.get_snapshot().revision)))
					raw.access = JSON.parse_string(JSON.stringify(access.get_snapshot()))
					raw.build.equipment = JSON.parse_string(JSON.stringify(gear.get_snapshot()))
				raw.route = JSON.parse_string(JSON.stringify(route.get_route_snapshot()))
				raw.circuit = {"phase": "final_boss", "active_school_id": ""}
				assert_true(CODEC.new().decode_selected_checkpoint(raw).ok)
				raw.access.trace_decisions.erase(str(first))
				assert_false(CODEC.new().decode_selected_checkpoint(raw).ok, "Final departure requires all resolved traces")
				orders += 1
	assert_eq(orders, 24)
