extends GutTest

const PATH := "res://scripts/core/run_experience_state.gd"

func test_kill_experience_queues_levels_without_losing_overflow() -> void:
	assert_true(ResourceLoader.exists(PATH))
	if not ResourceLoader.exists(PATH): return
	var growth = load(PATH).new()
	growth.grant(31)
	assert_eq(growth.level(), 3)
	assert_eq(growth.progress(), 1)
	assert_eq(growth.required(), 24)
	assert_eq(growth.pending_choices(), 2)
	assert_false(growth.restore({"xp": -1, "spent": 0, "ranks": {}, "learned": []}))

func test_upgrade_changes_real_config_without_mutating_catalog() -> void:
	if not ResourceLoader.exists(PATH): assert_true(false); return
	var growth = load(PATH).new()
	growth.grant(12)
	assert_true(growth.upgrade(&"cheonsul_flame_mark"))
	var source := {"damage": 20.0, "cooldown": 5.0, "duration": 2.0}
	var result: Dictionary = growth.scaled_config(&"cheonsul_flame_mark", source)
	assert_eq(result.damage, 23.0)
	assert_eq(result.cooldown, 4.8)
	assert_eq(source.damage, 20.0)
	assert_eq(growth.pending_choices(), 0)
	assert_false(growth.upgrade(&"cheonsul_flame_mark"))
	var restored = load(PATH).new()
	assert_true(restored.restore(growth.snapshot()))
	assert_eq(restored.snapshot(), growth.snapshot())

func test_invalid_growth_cannot_spend_unearned_points_or_forge_spell_rank() -> void:
	if not ResourceLoader.exists(PATH): assert_true(false); return
	var growth = load(PATH).new()
	assert_false(growth.restore({"xp": 0, "spent": 1, "ranks": {}, "learned": []}))
	assert_false(growth.restore({"xp": 12, "spent": 1, "ranks": {"missing": 2}, "learned": []}))
	assert_false(growth.restore({"xp": 12, "spent": 1, "ranks": {"cheonsul_flame_mark": 5}, "learned": []}))
