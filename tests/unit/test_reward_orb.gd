extends GutTest

const ORB_PATH := "res://scripts/combat/reward_orb.gd"


func test_configure_stores_target() -> void:
	var orb = _make_orb()
	if orb == null:
		return
	var target := Node2D.new()
	add_child_autofree(target)
	orb.configure(target)
	assert_eq(orb.target, target)


func test_orb_moves_toward_target() -> void:
	var orb = _make_orb()
	if orb == null:
		return
	var target := Node2D.new()
	add_child_autofree(target)
	orb.global_position = Vector2.ZERO
	target.global_position = Vector2(100, 0)
	orb.move_speed = 100.0
	orb.collect_radius = 1.0
	orb.configure(target)
	orb._physics_process(0.25)
	assert_gt(orb.global_position.x, 0.0)
	assert_lt(orb.global_position.x, 100.0)


func test_collection_emits_once_and_consumes_orb() -> void:
	var orb = _make_orb()
	if orb == null:
		return
	var target := Node2D.new()
	add_child_autofree(target)
	orb.global_position = Vector2.ZERO
	target.global_position = Vector2(10, 0)
	orb.collect_radius = 18.0
	watch_signals(orb)
	orb.configure(target)
	orb._physics_process(0.016)
	orb._physics_process(0.016)
	assert_signal_emit_count(orb, "collected", 1)
	assert_true(orb.is_queued_for_deletion())


func test_invalid_target_cleans_up_without_collection() -> void:
	var orb = _make_orb()
	if orb == null:
		return
	watch_signals(orb)
	orb._physics_process(0.016)
	assert_signal_emit_count(orb, "collected", 0)
	assert_true(orb.is_queued_for_deletion())


func test_lifetime_expiry_consumes_orb_without_collection() -> void:
	var orb = _make_orb()
	if orb == null:
		return
	var target := Node2D.new()
	add_child_autofree(target)
	target.global_position = Vector2(1000, 0)
	orb.move_speed = 0.0
	orb.collect_radius = 1.0
	orb.lifetime = 0.01
	watch_signals(orb)
	orb.configure(target)
	orb._physics_process(0.02)
	assert_signal_emit_count(orb, "collected", 0)
	assert_true(orb.is_queued_for_deletion())


func _make_orb() -> Node2D:
	assert_true(ResourceLoader.exists(ORB_PATH), "RewardOrb script must exist")
	if not ResourceLoader.exists(ORB_PATH):
		return null
	var script = load(ORB_PATH)
	assert_not_null(script)
	if script == null:
		return null
	var orb = script.new()
	add_child_autofree(orb)
	return orb
