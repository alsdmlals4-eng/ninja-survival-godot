extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_mvp1_combat_metrics_remain_domain_data_not_persistent_hud_controls() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in ["ComboLabel", "StyleLabel", "RewardLabel", "ComboTitleLabel"]:
		assert_null(
			hud.get_node_or_null(node_name),
			"Automatic-combat HUD must not persist MVP-1 metric control: %s" % node_name,
		)


func test_mvp1_hud_exposes_only_compact_combat_presentation_controls() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	hud.show_combat_hud(true)
	assert_eq(hud.combat_persistent_control_names(), ["DashLabel", "PlayLabel", "SettingsButton"])
	assert_true((hud.get_node("CombatTopBar/Row/DashLabel") as Label).visible)
	assert_true((hud.get_node("CombatTopBar/Row/PlayLabel") as Label).visible)
	assert_true((hud.get_node("CombatTopBar/Row/SettingsButton") as Button).visible)
