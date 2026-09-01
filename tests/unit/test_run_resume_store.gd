# 이어하기 기록은 유효한 확정 checkpoint만 저장하고, 손상 파일은 지우지 않은 채 거부한다.
extends GutTest

const STORE_PATH := "res://scripts/core/run_resume_store.gd"
const BACKPACK_STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RUN_MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"
const RUN_ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const NINJUTSU_LOADOUT_PATH := "res://scripts/core/ninjutsu_loadout_state.gd"

var _storage_path := "user://gut_run_resume_store.json"


func before_each() -> void:
	_remove_storage_files()


func after_each() -> void:
	_remove_storage_files()


func test_store_round_trips_only_a_valid_committed_checkpoint() -> void:
	assert_true(ResourceLoader.exists(STORE_PATH), "Resume store is required.")
	if not ResourceLoader.exists(STORE_PATH):
		return
	var store = load(STORE_PATH).new()
	assert_true(store.configure(_storage_path))
	assert_true(store.save_checkpoint(_make_committed_checkpoint()))
	assert_true(store.has_record())

	var loaded: Dictionary = store.load_checkpoint()
	assert_true(loaded.get("ok", false))
	assert_eq(loaded.get("checkpoint", {}).get("route", {}).get("active_school_id"), &"cheonsul")
	assert_eq(loaded.get("checkpoint", {}).get("loadout", {}).get("active_spell_ids"), [&"cheonsul_flame_mark"])


func test_store_preserves_a_corrupt_record_instead_of_silently_deleting_it() -> void:
	assert_true(ResourceLoader.exists(STORE_PATH), "Resume store is required.")
	if not ResourceLoader.exists(STORE_PATH):
		return
	var corrupt_text := '{"schema_version":99}'
	var file := FileAccess.open(_storage_path, FileAccess.WRITE)
	assert_not_null(file)
	if file == null:
		return
	file.store_string(corrupt_text)
	file.flush()
	file = null

	var store = load(STORE_PATH).new()
	assert_true(store.configure(_storage_path))
	var loaded: Dictionary = store.load_checkpoint()
	assert_false(loaded.get("ok", false))
	assert_eq(loaded.get("reason"), &"unsupported_schema")
	assert_true(store.has_record(), "An invalid record remains for the player to replace deliberately.")
	assert_eq(FileAccess.get_file_as_string(_storage_path), corrupt_text)


func test_store_clear_removes_only_its_own_record() -> void:
	assert_true(ResourceLoader.exists(STORE_PATH), "Resume store is required.")
	if not ResourceLoader.exists(STORE_PATH):
		return
	var store = load(STORE_PATH).new()
	assert_true(store.configure(_storage_path))
	assert_true(store.save_checkpoint(_make_committed_checkpoint()))
	assert_true(store.clear_record())
	assert_false(store.has_record())
	assert_eq(store.load_checkpoint().get("reason"), &"missing")


func _make_committed_checkpoint() -> Dictionary:
	var backpack = load(BACKPACK_STATE_PATH).new().create_starting_state()
	assert_not_null(backpack)
	if backpack == null:
		return {}
	assert_eq(backpack.add_item(&"taijutsu_training", Vector2i(1, 1)), 2)

	var modifiers = load(RUN_MODIFIER_SET_PATH).new()
	modifiers.school_damage_pct = 0.25

	var route = load(RUN_ROUTE_STATE_PATH).new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	assert_true(route.commit_provisional_next_school())

	var loadout = load(NINJUTSU_LOADOUT_PATH).new()
	add_child_autofree(loadout)
	assert_true(loadout.activate_starter(&"cheonsul"))

	return {
		"build": {
			"gold": 31,
			"selected_school_id": &"cheonsul",
			"owned_items": {&"taijutsu_training": 1},
			"selected_fates": [],
			"committed_backpack_modifiers": modifiers,
			"economy_receipts": [],
		},
		"route": route.get_route_snapshot(),
		"eligible_school_boss_ids": [&"bongma"],
		"circuit": {
			"active_school_id": &"cheonsul",
			"committed_backpack_state": backpack,
		},
		"loadout": loadout.get_snapshot(),
	}


func _remove_storage_files() -> void:
	for suffix in ["", ".tmp", ".previous"]:
		var storage_path: String = _storage_path + String(suffix)
		if FileAccess.file_exists(storage_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))
