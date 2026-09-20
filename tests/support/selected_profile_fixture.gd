extends GutTest

const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")
const CODEC = preload("res://scripts/core/run_resume_codec.gd")
const STORE = preload("res://scripts/core/run_resume_store.gd")
const START = preload("res://scripts/core/start_loadout_session.gd")
const ROUTE = preload("res://scripts/core/run_route_state.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SPATIAL = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const CATALOG = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")

var root: String
var fixture_index := 0

class FailingStore:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_open := false
	var fail_read_after_write := false
	var read_blocked := false
	var on_write := Callable()
	func _open_temporary_file(destination: String) -> FileAccess:
		if on_write.is_valid():
			on_write.call()
		if fail_read_after_write:
			read_blocked = true
		return null if fail_open else super._open_temporary_file(destination)
	func load_profile() -> Dictionary:
		return {"ok": false, "reason": &"unreadable"} if read_blocked else super.load_profile()

func before_each() -> void:
	root = "user://gut_trace_transaction_%s_%s" % [OS.get_process_id(), Time.get_ticks_usec()]
	assert_eq(DirAccess.make_dir_recursive_absolute(root), OK)
	fixture_index = 0

func after_each() -> void:
	assert_true(root.begins_with("user://gut_trace_transaction_"))
	for file in DirAccess.get_files_at(root):
		DirAccess.remove_absolute(root.path_join(file))
	DirAccess.remove_absolute(root)

func _fixture(origin: StringName = &"bongma", battlefield: StringName = &"cheonsul") -> Dictionary:
	fixture_index += 1
	var start = add_child_autofree(START.new())
	assert_true(start.begin(origin, 42))
	for unused in range(2):
		assert_true(start.choose(start.snapshot().draft.options[0]))
	assert_true(start.confirm())
	var bundle: Dictionary = start.committed_snapshot()
	var route = ROUTE.new()
	assert_true(route.set_provisional_next_school(battlefield))
	assert_true(route.commit_provisional_next_school())
	var checkpoint := {
		"rules_version": CODEC.PROFILE_CONTRACT, "prepare_session_id": "departure:initial",
		"build": {"gold": 0, "selected_school_id": origin, "owned_items": {}, "selected_fates": [],
			"economy_receipts": [], "equipment": bundle.equipment,
			"committed_backpack_modifiers": MODIFIERS.new().to_persistent_snapshot()},
		"route": route.get_route_snapshot(), "circuit": {"phase": "core", "active_school_id": battlefield},
		"backpack": bundle.backpack, "buffer": [], "loadout": bundle.loadout, "access": bundle.access,
		"ultimate_charge": {"school_id": origin, "resource_amount": 0}}
	var access = ACCESS.new()
	assert_true(access.restore_selected_snapshot(bundle.access))
	assert_true(access.stabilize_school(battlefield))
	var spatial = SPATIAL.new()
	assert_true(spatial.begin(BAG.from_persistent_snapshot(bundle.backpack), RESOLVER.new(),
		CATALOG.build_items(), BAGS.build_bags(), origin, [], true))
	var build = add_child_autofree(load("res://scripts/core/run_build_state.gd").new())
	build.configure(CATALOG.build_items(), FATES.build_fates())
	var rewards = add_child_autofree(load("res://scripts/core/rest_reward_controller.gd").new())
	var rng := RandomNumberGenerator.new()
	rng.seed = 75
	rewards.configure(build, spatial, CATALOG.build_items(), BAGS.build_bags(), rng, access)
	rewards.begin_rest(1, origin, 1, battlefield)
	var preparation := {"prepare_session_id": "prepare:after:1", "phase": "preparing", "revision": 0,
		"access": access.get_snapshot(), "equipment": bundle.equipment,
		"spatial_session": spatial.persistent_preparation_snapshot(), "loadout": bundle.loadout,
		"gold": 150, "reward_state": rewards.persistent_snapshot(), "pending_fate": "",
		"provisional_school": "", "healing_applied": true}
	var raw := {"schema_version": 2, "revision": 0, "content_contract": CODEC.PROFILE_CONTRACT,
		"meta": {"soul_balance": 2, "unlocked_support_choice": false, "settled_run_ids": [],
			"applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": {"run_id": "run:trace", "starting_school": str(origin), "elite_qualified": true,
			"retry_consumed": false, "eligible_boss_ids": [str(battlefield)],
			"checkpoint": checkpoint, "preparation": preparation}}
	raw = JSON.parse_string(JSON.stringify(raw))
	var path := root.path_join("profile_%s.json" % fixture_index)
	var store = FailingStore.new()
	assert_true(store.configure_profile(path))
	assert_true(store.transact_profile(raw, 0, "prepare:initial").ok)
	return {"store": store, "profile": store.load_profile().profile, "path": path}

func _request(fixture: Dictionary, choice := "enhance", slot := "melee") -> Dictionary:
	return {"run_id": "run:trace", "prepare_session_id": "prepare:after:1",
		"school_id": fixture.profile.active_run.checkpoint.route.active_school_id,
		"choice": choice, "slot": slot, "expected_revision": 1,
		"expected_prepare_revision": 0, "expected_equipment_revision": 0}

func _coordinator(store):
	var result = COORDINATOR.new()
	assert_true(result.has_method("configure_selected_profile"), "Missing durable preparation business transaction")
	if not result.has_method("configure_selected_profile"):
		return null
	assert_true(result.configure_selected_profile(store))
	return result
