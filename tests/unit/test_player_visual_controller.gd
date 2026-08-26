extends GutTest

const VISUAL_PATH := "res://scripts/player/player_visual_controller.gd"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"


func _make_visual():
	assert_true(ResourceLoader.exists(VISUAL_PATH), "Player visual controller must exist")
	if not ResourceLoader.exists(VISUAL_PATH):
		return null
	var visual = load(VISUAL_PATH).new()
	visual.move_texture = GradientTexture2D.new()
	visual.attack_texture = GradientTexture2D.new()
	visual.hit_texture = GradientTexture2D.new()
	add_child_autofree(visual)
	return visual


func test_visual_starts_in_move_pose() -> void:
	var visual = _make_visual()
	if visual == null:
		return
	assert_eq(visual.current_pose(), visual.Pose.MOVE)
	assert_eq(visual.texture, visual.move_texture)


func test_hit_overrides_attack_and_returns_to_move() -> void:
	var visual = _make_visual()
	if visual == null:
		return
	visual.show_attack()
	assert_eq(visual.current_pose(), visual.Pose.ATTACK)
	assert_eq(visual.texture, visual.attack_texture)
	visual.show_hit()
	assert_eq(visual.current_pose(), visual.Pose.HIT)
	assert_eq(visual.texture, visual.hit_texture)
	visual.advance_pose(visual.hit_hold_seconds)
	assert_eq(visual.current_pose(), visual.Pose.MOVE)
	assert_eq(visual.texture, visual.move_texture)


func test_attack_does_not_replace_an_active_hit_pose() -> void:
	var visual = _make_visual()
	if visual == null:
		return
	visual.show_hit()
	visual.show_attack()
	assert_eq(visual.current_pose(), visual.Pose.HIT)


func test_parent_resolved_damage_shows_hit_but_evaded_damage_does_not() -> void:
	var player = load(PLAYER_PATH).new()
	add_child_autofree(player)
	var visual = load(VISUAL_PATH).new()
	visual.move_texture = GradientTexture2D.new()
	visual.attack_texture = GradientTexture2D.new()
	visual.hit_texture = GradientTexture2D.new()
	player.add_child(visual)

	player.damage_resolved.emit(10, 0, 10, true)
	assert_eq(visual.current_pose(), visual.Pose.MOVE)
	player.take_damage(1)
	assert_eq(visual.current_pose(), visual.Pose.HIT)
