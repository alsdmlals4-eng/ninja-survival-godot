# committed Workbench checkpoint를 JSON primitive로만 보관하고 다시 도메인 snapshot으로 복원한다.
extends GutTest

const CODEC_PATH := "res://scripts/core/run_resume_codec.gd"
const BACKPACK_STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RUN_MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"
const RUN_ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const NINJUTSU_LOADOUT_PATH := "res://scripts/core/ninjutsu_loadout_state.gd"


func test_codec_round_trips_a_committed_checkpoint_using_json_primitives_only() -> void:
	assert_true(ResourceLoader.exists(CODEC_PATH), "Committed resume codec is required.")
	if not ResourceLoader.exists(CODEC_PATH):
		return
	var codec = load(CODEC_PATH).new()
	var encoded: Dictionary = codec.encode_checkpoint(_make_committed_checkpoint())
	assert_eq(encoded.get("schema_version"), 1)
	assert_true(_is_json_safe(encoded), "Persistent checkpoint payload must not contain Godot objects.")

	var decoded: Dictionary = codec.decode_checkpoint(encoded)
	assert_true(decoded.get("ok", false), "A valid committed checkpoint must decode.")
	var restored: Dictionary = decoded.get("checkpoint", {})
	assert_eq(restored.get("route", {}).get("active_school_id"), &"cheonsul")
	assert_eq(restored.get("circuit", {}).get("active_school_id"), &"cheonsul")
	assert_eq(restored.get("loadout", {}).get("active_spell_ids"), [&"cheonsul_flame_mark"])
	assert_eq(restored.get("circuit", {}).get("committed_backpack_state", null).get_item(2).definition_id, &"taijutsu_training")


func test_codec_rejects_an_unknown_item_before_returning_a_partial_checkpoint() -> void:
	assert_true(ResourceLoader.exists(CODEC_PATH), "Committed resume codec is required.")
	if not ResourceLoader.exists(CODEC_PATH):
		return
	var codec = load(CODEC_PATH).new()
	var encoded: Dictionary = codec.encode_checkpoint(_make_committed_checkpoint())
	encoded["checkpoint"]["circuit"]["backpack"]["items"][0]["definition_id"] = "unknown_item"
	var decoded: Dictionary = codec.decode_checkpoint(encoded)
	assert_false(decoded.get("ok", false))
	assert_false(decoded.has("checkpoint"), "Invalid persistence must not leak a partial checkpoint.")


func test_codec_rejects_an_unsupported_schema_version() -> void:
	assert_true(ResourceLoader.exists(CODEC_PATH), "Committed resume codec is required.")
	if not ResourceLoader.exists(CODEC_PATH):
		return
	var codec = load(CODEC_PATH).new()
	var encoded: Dictionary = codec.encode_checkpoint(_make_committed_checkpoint())
	encoded["schema_version"] = 2
	var decoded: Dictionary = codec.decode_checkpoint(encoded)
	assert_false(decoded.get("ok", false))
	assert_eq(decoded.get("reason"), &"unsupported_schema")


func test_codec_round_trips_the_consumed_awakening_retry_without_resetting_it() -> void:
	assert_true(ResourceLoader.exists(CODEC_PATH), "Committed resume codec is required.")
	if not ResourceLoader.exists(CODEC_PATH):
		return
	var codec = load(CODEC_PATH).new()
	var checkpoint := _make_committed_checkpoint()
	checkpoint["retry_consumed"] = true
	var encoded: Dictionary = codec.encode_checkpoint(checkpoint)
	var decoded: Dictionary = codec.decode_checkpoint(encoded)
	assert_true(decoded.get("ok", false))
	assert_true(decoded.get("checkpoint", {}).get("retry_consumed", false), "A consumed Awakening retry must remain consumed after relaunch.")


func _make_committed_checkpoint() -> Dictionary:
	var backpack = load(BACKPACK_STATE_PATH).new().create_starting_state()
	assert_not_null(backpack)
	if backpack == null:
		return {}
	assert_eq(backpack.add_item(&"taijutsu_training", Vector2i(1, 1)), 2)

	var modifiers = load(RUN_MODIFIER_SET_PATH).new()
	modifiers.school_damage_pct = 0.25
	modifiers.move_speed_pct = 0.10

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
			"economy_receipts": [{"source": &"boss", "amount": 25}],
		},
		"route": route.get_route_snapshot(),
		"eligible_school_boss_ids": [&"bongma"],
		"circuit": {
			"active_school_id": &"cheonsul",
			"committed_backpack_state": backpack,
		},
		"loadout": loadout.get_snapshot(),
	}


func _is_json_safe(value) -> bool:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return true
		TYPE_ARRAY:
			for item in value:
				if not _is_json_safe(item):
					return false
			return true
		TYPE_DICTIONARY:
			for key in value.keys():
				if typeof(key) != TYPE_STRING or not _is_json_safe(value.get(key)):
					return false
			return true
		_:
			return false
