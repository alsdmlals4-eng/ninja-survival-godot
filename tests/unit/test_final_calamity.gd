extends GutTest

const BOSS_PATH := "res://scenes/enemies/final_calamity.tscn"


func test_final_boss_uses_clear_order_and_waits_until_pattern_ends() -> void:
	assert_true(ResourceLoader.exists(BOSS_PATH))
	if not ResourceLoader.exists(BOSS_PATH):
		return
	var boss = load(BOSS_PATH).instantiate()
	assert_true(boss.configure_clear_order([&"heukyeong", &"guiin", &"bongma", &"cheonsul"]))
	add_child_autofree(boss)
	assert_eq(boss.max_health, 1800)
	assert_eq(boss.theme_school_id(), &"heukyeong")
	boss.pattern_controller.force_start_for_test()
	boss.take_damage(1000)
	boss._physics_process(0.01)
	assert_eq(boss.theme_school_id(), &"heukyeong", "Never replace a visible telegraph mid-pattern.")
	for step in range(3):
		boss.pattern_controller.advance(10.0)
	boss._physics_process(0.01)
	assert_eq(boss.theme_school_id(), &"bongma", "Large hits skip directly to the current HP quarter.")
	assert_eq(boss.health, 800, "Theme transition must not heal or clamp damage.")


func test_invalid_or_duplicate_clear_order_cannot_configure_final_boss() -> void:
	assert_true(ResourceLoader.exists(BOSS_PATH))
	if not ResourceLoader.exists(BOSS_PATH):
		return
	var boss = load(BOSS_PATH).instantiate()
	add_child_autofree(boss)
	assert_false(boss.configure_clear_order([&"bongma", &"bongma", &"guiin", &"cheonsul"]))
	assert_false(boss.configure_clear_order([&"bongma"]))


func test_each_theme_grants_reading_time_only_to_its_first_pattern() -> void:
	var boss = load(BOSS_PATH).instantiate()
	assert_true(boss.configure_clear_order([&"heukyeong", &"guiin", &"bongma", &"cheonsul"]))
	add_child_autofree(boss)
	var base_duration: float = boss.definition.pattern_definitions[0]["telegraph_duration"]
	boss.pattern_controller.force_start_for_test()
	assert_almost_eq(boss.current_telegraph_duration(), base_duration + 0.2, 0.001)
	for step in range(3):
		boss.pattern_controller.advance(10.0)
	boss.pattern_controller.force_start_for_test()
	assert_almost_eq(boss.current_telegraph_duration(), float(boss.definition.pattern_definitions[1]["telegraph_duration"]), 0.001)
