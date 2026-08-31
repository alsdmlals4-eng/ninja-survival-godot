extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"
const PLAYER_SCENE := "res://scenes/player/player.tscn"
const ENEMY_SCENE := "res://scenes/enemies/enemy_basic.tscn"
const SHURIKEN_SCENE := "res://scenes/projectiles/shuriken_projectile.tscn"
const STAGE_BOSS_SCENE := "res://scenes/enemies/stage_boss.tscn"
const REWARD_ORB_SCENE := "res://scenes/rewards/reward_orb.tscn"
const BONGMA_FAMILIAR_SCENE := "res://scenes/schools/bongma_familiar.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const BATTLEFIELD_FLOOR_TILE := "res://assets/runtime/visual-core/moonlit_battlefield_floor_tile_v1.png"
const BATTLEFIELD_FLOOR_TILE_SIZE := Vector2(1254, 1254)
const BATTLEFIELD_PROP_ATLAS := "res://assets/runtime/visual-core/moonlit_battlefield_prop_atlas_v1.png"
const GROUND_SHADOW_TEXTURE := "res://assets/runtime/visual-core/runtime_contact_shadow_v1.png"
const BASIC_WEAPON_EFFECTS_TEXTURE := "res://assets/runtime/visual-core/basic_weapon_effects_v1.png"
const BATTLEFIELD_PROP_REGIONS := {
	"Lantern": Rect2(0, 0, 632.5, 621.5),
	"DeadTree": Rect2(632.5, 0, 632.5, 621.5),
	"Rocks": Rect2(0, 621.5, 632.5, 621.5),
	"TalismanStele": Rect2(632.5, 621.5, 632.5, 621.5),
}
const REQUIRED_RUNTIME_RESOURCES := [
	"res://scripts/core/main_controller.gd",
	"res://scripts/ui/hud.gd",
	ENEMY_SCENE,
	SHURIKEN_SCENE,
]


func test_main_scene_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MAIN_SCENE), "MVP-0 main scene must exist")


func test_main_scene_has_core_nodes() -> void:
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return

	assert_not_null(main.get_node_or_null("GameState"))
	assert_not_null(main.get_node_or_null("Player"))
	assert_not_null(main.get_node_or_null("HUD"))
	assert_not_null(main.get_node_or_null("Player/Camera2D"))
	assert_not_null(main.get_node_or_null("Player/BasicWeapons"))


func test_main_scene_repeats_the_locked_battlefield_floor_behind_gameplay() -> void:
	assert_true(ResourceLoader.exists(BATTLEFIELD_FLOOR_TILE), "The locked battlefield floor tile source must exist")
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return

	var backdrop := main.get_node_or_null("BattlefieldBackdrop") as Parallax2D
	var player := main.get_node_or_null("Player") as Node2D
	assert_not_null(backdrop, "Main must own a repeating runtime battlefield backdrop")
	assert_not_null(player)
	if backdrop == null or player == null:
		return

	assert_eq(backdrop.repeat_size, BATTLEFIELD_FLOOR_TILE_SIZE)
	assert_eq(backdrop.repeat_times, 1)
	assert_eq(backdrop.scroll_scale, Vector2.ONE)
	var floor_tile := backdrop.get_node_or_null("FloorTile") as Sprite2D
	assert_not_null(floor_tile, "The repeating backdrop must own the locked floor tile")
	if floor_tile == null:
		return
	assert_not_null(floor_tile.texture, "Floor tile must consume the locked local texture")
	assert_eq(floor_tile.texture.resource_path, BATTLEFIELD_FLOOR_TILE)
	assert_lt(backdrop.z_index, player.z_index, "Backdrop must remain behind gameplay")


func test_main_scene_repeats_locked_sparse_props_between_floor_and_gameplay() -> void:
	assert_true(ResourceLoader.exists(BATTLEFIELD_PROP_ATLAS), "The locked sparse-prop atlas source must exist")
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return

	var floor := main.get_node_or_null("BattlefieldBackdrop") as Parallax2D
	var props := main.get_node_or_null("BattlefieldProps") as Parallax2D
	var player := main.get_node_or_null("Player") as Node2D
	assert_not_null(floor)
	assert_not_null(props, "Main must own independent repeating battlefield props")
	assert_not_null(player)
	if floor == null or props == null or player == null:
		return

	assert_eq(props.repeat_size, BATTLEFIELD_FLOOR_TILE_SIZE)
	assert_eq(props.repeat_times, 1)
	assert_eq(props.scroll_scale, Vector2.ONE)
	assert_gt(props.z_index, floor.z_index, "Props must render above the floor")
	assert_lt(props.z_index, player.z_index, "Props must stay behind gameplay units")
	assert_eq(props.get_child_count(), BATTLEFIELD_PROP_REGIONS.size(), "Only the approved sparse prop set belongs in the layer")
	for prop_name in BATTLEFIELD_PROP_REGIONS:
		var prop := props.get_node_or_null(prop_name) as Sprite2D
		assert_not_null(prop, "Missing approved sparse prop: %s" % prop_name)
		if prop == null:
			continue
		assert_not_null(prop.texture)
		if prop.texture != null:
			assert_eq(prop.texture.resource_path, BATTLEFIELD_PROP_ATLAS)
		assert_true(prop.region_enabled)
		assert_true(prop.region_filter_clip_enabled, "Prop atlas must clip filtered sampling to its own region")
		assert_eq(prop.region_rect, BATTLEFIELD_PROP_REGIONS[prop_name])


func test_player_enemy_and_boss_share_the_locked_ground_shadow() -> void:
	assert_true(ResourceLoader.exists(GROUND_SHADOW_TEXTURE), "The locked contact-shadow source must exist")
	for scene_path in [PLAYER_SCENE, ENEMY_SCENE, STAGE_BOSS_SCENE]:
		var unit = _spawn_scene(scene_path)
		assert_not_null(unit)
		if unit == null:
			continue
		var shadow := unit.get_node_or_null("GroundShadow") as Sprite2D
		var visual := unit.get_node_or_null("Visual") as Sprite2D
		assert_not_null(shadow, "%s must own a grounded contact shadow" % scene_path)
		assert_not_null(visual)
		if shadow == null or visual == null:
			continue
		assert_not_null(shadow.texture)
		if shadow.texture != null:
			assert_eq(shadow.texture.resource_path, GROUND_SHADOW_TEXTURE)
		assert_lt(shadow.z_index, visual.z_index, "Ground shadow must render behind the unit visual")


func test_runtime_resources_exist() -> void:
	for path in REQUIRED_RUNTIME_RESOURCES:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 runtime resource: %s" % path)


func test_player_scene_has_collision_visual_camera_and_basic_weapon_config() -> void:
	var player = _spawn_scene(PLAYER_SCENE)
	assert_not_null(player)
	if player == null:
		return

	assert_not_null(player.get_node_or_null("CollisionShape2D"))
	var visual = player.get_node_or_null("Visual")
	assert_not_null(visual)
	assert_true(visual is Sprite2D, "Player Visual must render the approved Sprite2D pose")
	if visual is Sprite2D:
		assert_almost_eq(visual.scale.x, 0.05, 0.0001)
		assert_almost_eq(visual.scale.y, 0.05, 0.0001)
		assert_not_null(visual.move_texture)
		assert_false(_has_property(visual, "attack_texture"), "Attack effects must no longer swap the player body pose.")
		assert_not_null(visual.hit_texture)
	assert_not_null(player.get_node_or_null("Camera2D"))
	var basic_weapons = player.get_node_or_null("BasicWeapons")
	assert_not_null(basic_weapons)
	if basic_weapons != null:
		assert_not_null(basic_weapons.shuriken_projectile_scene)
		assert_not_null(basic_weapons.weapon_effect_texture)
	assert_eq(player.collision_layer, 1)
	assert_eq(player.collision_mask, 2)


func test_enemy_scene_has_collision_and_visual() -> void:
	var enemy = _spawn_scene(ENEMY_SCENE)
	assert_not_null(enemy)
	if enemy == null:
		return

	assert_not_null(enemy.get_node_or_null("CollisionShape2D"))
	var visual = enemy.get_node_or_null("Visual")
	assert_not_null(visual)
	assert_true(visual is Sprite2D, "Generic enemy Visual must use an approved Sprite2D")
	if visual is Sprite2D:
		assert_not_null(visual.texture)
		assert_eq(visual.texture_candidates.size(), 3)
	assert_eq(enemy.collision_layer, 2)
	assert_eq(enemy.collision_mask, 1)


func test_shuriken_projectile_scene_has_collision_enemy_mask_and_locked_atlas_region() -> void:
	assert_true(ResourceLoader.exists(BASIC_WEAPON_EFFECTS_TEXTURE))
	var projectile = _spawn_scene(SHURIKEN_SCENE)
	assert_not_null(projectile)
	if projectile == null:
		return

	assert_not_null(projectile.get_node_or_null("CollisionShape2D"))
	var visual = projectile.get_node_or_null("Visual")
	assert_not_null(visual)
	assert_true(visual is Sprite2D, "Projectile Visual must use an approved Sprite2D")
	if visual is Sprite2D:
		assert_not_null(visual.texture)
		assert_eq(visual.texture.resource_path, BASIC_WEAPON_EFFECTS_TEXTURE)
		assert_true(visual.region_enabled)
		assert_gt(visual.region_rect.position.x, 0.0)
	assert_eq(projectile.collision_layer, 4)
	assert_eq(projectile.collision_mask, 2)
	assert_true(projectile.monitoring)


func test_visual_core_support_scenes_use_approved_sprite_textures() -> void:
	for scene_path in [STAGE_BOSS_SCENE, REWARD_ORB_SCENE, BONGMA_FAMILIAR_SCENE]:
		var instance = _spawn_scene(scene_path)
		assert_not_null(instance)
		if instance == null:
			continue
		var visual = instance.get_node_or_null("Visual")
		assert_true(visual is Sprite2D, "%s Visual must use Sprite2D" % scene_path)
		if visual is Sprite2D:
			assert_not_null(visual.texture)


func test_hud_renders_compact_combat_values_and_game_over_visibility() -> void:
	var hud = _spawn_scene(HUD_SCENE)
	assert_not_null(hud)
	if hud == null:
		return

	assert_true(hud.has_method("set_dash_state"))
	assert_true(hud.has_method("set_play_time"))
	assert_true(hud.has_method("show_game_over"))
	var dash_label = hud.get_node_or_null("CombatTopBar/Row/DashLabel")
	var play_label = hud.get_node_or_null("CombatTopBar/Row/PlayLabel")
	var game_over_panel = hud.get_node_or_null("GameOverPanel")
	assert_not_null(dash_label)
	assert_not_null(play_label)
	assert_not_null(game_over_panel)
	if not hud.has_method("set_dash_state") or not hud.has_method("set_play_time") or not hud.has_method("show_game_over"):
		return
	if dash_label == null or play_label == null or game_over_panel == null:
		return

	hud.set_dash_state(1, 2)
	hud.set_play_time(61.0)
	assert_eq(dash_label.text, "DASH 1 / 2")
	assert_eq(play_label.text, "PLAY 01:01")
	assert_false(game_over_panel.visible)
	hud.show_game_over()
	assert_true(game_over_panel.visible)


func test_main_keeps_enemy_and_game_over_owners_without_persistent_score_or_health_hud() -> void:
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return
	(main.get_node("SchoolSelectionUI") as SchoolSelectionUI)._choose(&"bongma")

	assert_true(_has_property(main, "game_over"))
	var state = main.get_node_or_null("GameState")
	var player = main.get_node_or_null("Player")
	var hud = main.get_node_or_null("HUD")
	assert_not_null(state)
	assert_not_null(player)
	assert_not_null(hud)
	if state == null or player == null or hud == null or not _has_property(main, "game_over"):
		return

	var game_over_panel = hud.get_node_or_null("GameOverPanel")
	assert_not_null(game_over_panel)
	if game_over_panel == null:
		return

	var enemies: Array[Node] = []
	for child in main.get_children():
		if child.is_in_group("enemies"):
			enemies.append(child)
	assert_gt(enemies.size(), 0)
	if enemies.is_empty():
		return
	for enemy in enemies:
		assert_eq(enemy.target, player)

	assert_null(hud.get_node_or_null("HealthLabel"))
	assert_null(hud.get_node_or_null("ScoreLabel"))

	state.register_kill(100)
	assert_eq(state.kill_count, 1)
	assert_eq(state.score, 100)

	var first_enemy = enemies[0]
	var recent_hit_presenter = main.get_node_or_null("RecentHitHpPresenter")
	assert_not_null(recent_hit_presenter, "Main은 최근 피격 HP 표시 owner 하나를 가져야 합니다.")
	if recent_hit_presenter == null:
		return
	first_enemy.take_damage(1)
	assert_eq(recent_hit_presenter.visible_enemy(), first_enemy)
	assert_eq(recent_hit_presenter.visible_bar().max_value, float(first_enemy.max_health))
	first_enemy.take_damage(first_enemy.max_health)
	assert_null(recent_hit_presenter.visible_enemy(), "사망한 적의 HP bar는 즉시 정리해야 합니다.")
	assert_eq(state.kill_count, 2)

	player.take_damage(25)
	assert_eq(player.health, 75)

	player.take_damage(1000)
	assert_true(main.game_over)
	assert_true(game_over_panel.visible)
	assert_eq(player.process_mode, Node.PROCESS_MODE_DISABLED)
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			assert_eq(enemy.process_mode, Node.PROCESS_MODE_DISABLED)


func test_main_wires_dash_play_time_and_settings_intents_without_manual_ultimate() -> void:
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return
	(main.get_node("SchoolSelectionUI") as SchoolSelectionUI)._choose(&"bongma")
	var selector := main.get_node_or_null("SchoolSelectionUI") as SchoolSelectionUI
	var player := main.get_node_or_null("Player") as PlayerController
	var hud := main.get_node_or_null("HUD") as HUDController
	assert_not_null(selector)
	assert_not_null(player)
	assert_not_null(hud)
	if selector == null or player == null or hud == null:
		return

	selector._choose(&"bongma")
	assert_true((hud.get_node("CombatTopBar") as Control).visible)
	assert_eq(hud.dash_text(), "DASH 2 / 2")
	player.set_pointer_target(player.global_position + Vector2.RIGHT * 120.0)
	assert_true(player.request_dash())
	assert_eq(hud.dash_text(), "DASH 1 / 2")
	main._process(61.0)
	assert_eq(hud.play_text(), "PLAY 01:01")

	hud.open_settings()
	assert_true(get_tree().paused, "Main must pause only after the HUD settings panel emits its intent.")
	hud._on_resume_pressed()
	assert_false(get_tree().paused, "Resume must restore the active combat tree state.")

	var bongma = main.get_node("SchoolRuntimeHost").active_runtime
	bongma.spirit = 100.0
	var accept := InputEventAction.new()
	accept.action = &"ui_accept"
	accept.pressed = true
	main._unhandled_input(accept)
	assert_almost_eq(bongma.ultimate_time_remaining, 0.0, 0.001, "Automatic combat must not expose an ui_accept ultimate route.")


func test_main_uses_resolved_damage_but_not_school_actions_for_player_poses() -> void:
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return
	var player = main.get_node_or_null("Player")
	var visual = main.get_node_or_null("Player/Visual")
	var school_host = main.get_node_or_null("SchoolRuntimeHost")
	assert_not_null(player)
	assert_not_null(visual)
	assert_not_null(school_host)
	if player == null or visual == null or school_host == null:
		return

	school_host.player_action_resolved.emit()
	assert_eq(visual.current_pose(), visual.Pose.MOVE)
	player.take_damage(1)
	assert_eq(visual.current_pose(), visual.Pose.HIT)


func _spawn_main() -> Node:
	return _spawn_scene(MAIN_SCENE)


func _spawn_scene(path: String) -> Node:
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	if packed == null:
		return null
	var instance = packed.instantiate()
	add_child_autofree(instance)
	return instance


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
