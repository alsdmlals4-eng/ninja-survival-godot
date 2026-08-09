extends GutTest

const BOSS_SCRIPT_PATH := "res://scripts/enemies/stage_boss.gd"
const BOSS_SCENE_PATH := "res://scenes/enemies/stage_boss.tscn"


func test_stage_boss_resources_exist() -> void:
	assert_true(ResourceLoader.exists(BOSS_SCRIPT_PATH), "Missing stage boss script")
	assert_true(ResourceLoader.exists(BOSS_SCENE_PATH), "Missing stage boss scene")


func test_each_tier_applies_approved_stats_before_ready_initializes_health() -> void:
	var expected := {
		1: [200, 70.0, 15, 1.6],
		2: [350, 80.0, 20, 1.8],
		3: [500, 90.0, 25, 2.0],
	}
	for tier in expected.keys():
		var boss = _new_unparented_boss()
		if boss == null:
			return
		assert_true(boss.configure_tier(tier))
		assert_eq(boss.tier, tier)
		assert_eq(boss.max_health, expected[tier][0])
		assert_almost_eq(boss.move_speed, expected[tier][1], 0.001)
		assert_eq(boss.contact_damage, expected[tier][2])
		assert_almost_eq(boss.scale.x, expected[tier][3], 0.001)
		assert_almost_eq(boss.scale.y, expected[tier][3], 0.001)
		add_child_autofree(boss)
		assert_eq(boss.health, expected[tier][0])
		assert_true(boss.is_stage_boss())


func test_invalid_tier_is_atomic() -> void:
	var boss = _new_unparented_boss()
	if boss == null:
		return
	assert_true(boss.configure_tier(2))
	var before := [boss.tier, boss.max_health, boss.move_speed, boss.contact_damage, boss.scale]
	assert_false(boss.configure_tier(99))
	assert_eq([boss.tier, boss.max_health, boss.move_speed, boss.contact_damage, boss.scale], before)
	boss.free()


func test_stage_boss_keeps_existing_enemy_group_and_damage_contract() -> void:
	var boss = _new_unparented_boss()
	if boss == null:
		return
	assert_true(boss.configure_tier(1))
	add_child_autofree(boss)
	assert_true(boss.is_in_group("enemies"))
	assert_eq(boss.take_damage(50), 50)
	assert_eq(boss.health, 150)


func _new_unparented_boss():
	if not ResourceLoader.exists(BOSS_SCENE_PATH):
		return null
	return load(BOSS_SCENE_PATH).instantiate()
