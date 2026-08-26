extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"
const PLAYER_SCENE := "res://scenes/player/player.tscn"
const ENEMY_SCENE := "res://scenes/enemies/enemy_basic.tscn"
const PROJECTILE_SCENE := "res://scenes/projectiles/projectile_basic.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const REQUIRED_RUNTIME_RESOURCES := [
	"res://scripts/core/main_controller.gd",
	"res://scripts/ui/hud.gd",
	ENEMY_SCENE,
	PROJECTILE_SCENE,
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
	assert_not_null(main.get_node_or_null("Player/AutoAttack"))


func test_runtime_resources_exist() -> void:
	for path in REQUIRED_RUNTIME_RESOURCES:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 runtime resource: %s" % path)


func test_player_scene_has_collision_visual_camera_and_projectile_config() -> void:
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
		assert_not_null(visual.attack_texture)
		assert_not_null(visual.hit_texture)
	assert_not_null(player.get_node_or_null("Camera2D"))
	var auto_attack = player.get_node_or_null("AutoAttack")
	assert_not_null(auto_attack)
	if auto_attack != null:
		assert_not_null(auto_attack.projectile_scene)
	assert_eq(player.collision_layer, 1)
	assert_eq(player.collision_mask, 2)


func test_enemy_scene_has_collision_and_visual() -> void:
	var enemy = _spawn_scene(ENEMY_SCENE)
	assert_not_null(enemy)
	if enemy == null:
		return

	assert_not_null(enemy.get_node_or_null("CollisionShape2D"))
	assert_not_null(enemy.get_node_or_null("Visual"))
	assert_eq(enemy.collision_layer, 2)
	assert_eq(enemy.collision_mask, 1)


func test_projectile_scene_has_collision_and_enemy_mask() -> void:
	var projectile = _spawn_scene(PROJECTILE_SCENE)
	assert_not_null(projectile)
	if projectile == null:
		return

	assert_not_null(projectile.get_node_or_null("CollisionShape2D"))
	assert_not_null(projectile.get_node_or_null("Visual"))
	assert_eq(projectile.collision_layer, 4)
	assert_eq(projectile.collision_mask, 2)
	assert_true(projectile.monitoring)


func test_hud_updates_health_score_and_game_over_visibility() -> void:
	var hud = _spawn_scene(HUD_SCENE)
	assert_not_null(hud)
	if hud == null:
		return

	assert_true(hud.has_method("set_health"))
	assert_true(hud.has_method("set_score"))
	assert_true(hud.has_method("show_game_over"))
	var health_label = hud.get_node_or_null("HealthLabel")
	var score_label = hud.get_node_or_null("ScoreLabel")
	var game_over_panel = hud.get_node_or_null("GameOverPanel")
	assert_not_null(health_label)
	assert_not_null(score_label)
	assert_not_null(game_over_panel)
	if not hud.has_method("set_health") or not hud.has_method("set_score") or not hud.has_method("show_game_over"):
		return
	if health_label == null or score_label == null or game_over_panel == null:
		return

	hud.set_health(75, 100)
	hud.set_score(240, 3)
	assert_eq(health_label.text, "HP 75 / 100")
	assert_eq(score_label.text, "KILLS 3  SCORE 240")
	assert_false(game_over_panel.visible)
	hud.show_game_over()
	assert_true(game_over_panel.visible)


func test_main_wires_enemies_score_health_and_game_over() -> void:
	var main = _spawn_main()
	assert_not_null(main)
	if main == null:
		return

	assert_true(_has_property(main, "game_over"))
	var state = main.get_node_or_null("GameState")
	var player = main.get_node_or_null("Player")
	var hud = main.get_node_or_null("HUD")
	assert_not_null(state)
	assert_not_null(player)
	assert_not_null(hud)
	if state == null or player == null or hud == null or not _has_property(main, "game_over"):
		return

	var health_label = hud.get_node_or_null("HealthLabel")
	var score_label = hud.get_node_or_null("ScoreLabel")
	var game_over_panel = hud.get_node_or_null("GameOverPanel")
	assert_not_null(health_label)
	assert_not_null(score_label)
	assert_not_null(game_over_panel)
	if health_label == null or score_label == null or game_over_panel == null:
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

	assert_eq(health_label.text, "HP 100 / 100")
	assert_eq(score_label.text, "KILLS 0  SCORE 0")

	state.register_kill(100)
	assert_eq(score_label.text, "KILLS 1  SCORE 100")

	var first_enemy = enemies[0]
	first_enemy.take_damage(first_enemy.max_health)
	assert_eq(state.kill_count, 2)
	assert_eq(score_label.text, "KILLS 2  SCORE 200")

	player.take_damage(25)
	assert_eq(health_label.text, "HP 75 / 100")

	player.take_damage(1000)
	assert_true(main.game_over)
	assert_true(game_over_panel.visible)
	assert_eq(player.process_mode, Node.PROCESS_MODE_DISABLED)
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			assert_eq(enemy.process_mode, Node.PROCESS_MODE_DISABLED)


func test_main_uses_resolved_actions_and_damage_for_player_poses() -> void:
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
	assert_eq(visual.current_pose(), visual.Pose.ATTACK)
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
