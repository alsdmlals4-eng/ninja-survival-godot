extends GutTest

const ProjectileScript = preload("res://scripts/combat/projectile.gd")
const CombatResolverScript = preload("res://scripts/combat/combat_resolver.gd")
const ContributionTrackerScript = preload("res://scripts/combat/combat_contribution_tracker.gd")

class DamageReceiver:
	extends Node
	var damage_taken: int = 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


func test_configure_normalizes_direction_and_sets_combat_values() -> void:
	var projectile = ProjectileScript.new()
	add_child_autofree(projectile)

	projectile.configure(Vector2(10, 0), 600.0, 12)

	assert_eq(projectile.direction, Vector2.RIGHT)
	assert_eq(projectile.speed, 600.0)
	assert_eq(projectile.damage, 12)


func test_configure_preserves_zero_direction() -> void:
	var projectile = ProjectileScript.new()
	add_child_autofree(projectile)

	projectile.configure(Vector2.ZERO, 450.0, 7)

	assert_eq(projectile.direction, Vector2.ZERO)
	assert_eq(projectile.speed, 450.0)
	assert_eq(projectile.damage, 7)


func test_projectile_moves_using_configured_direction_and_speed() -> void:
	var projectile = ProjectileScript.new()
	projectile.lifetime = 2.0
	add_child_autofree(projectile)
	projectile.configure(Vector2.RIGHT, 100.0, 10)
	assert_true(projectile.has_method("_physics_process"))
	if not projectile.has_method("_physics_process"):
		return

	projectile._physics_process(0.5)

	assert_eq(projectile.position, Vector2(50, 0))


func test_hit_body_applies_damage_and_consumes_projectile() -> void:
	var projectile = ProjectileScript.new()
	add_child_autofree(projectile)
	projectile.configure(Vector2.RIGHT, 100.0, 13)
	var receiver = DamageReceiver.new()
	add_child_autofree(receiver)

	var did_hit = projectile.hit_body(receiver)

	assert_true(did_hit)
	assert_eq(receiver.damage_taken, 13)
	assert_true(projectile.is_queued_for_deletion())


func test_projectile_uses_basic_weapon_resolver_when_configured() -> void:
	var tracker = ContributionTrackerScript.new()
	tracker.reset_segment(0, 0)
	add_child_autofree(tracker)
	var resolver = CombatResolverScript.new()
	resolver.configure(tracker)
	add_child_autofree(resolver)
	var projectile = ProjectileScript.new()
	add_child_autofree(projectile)
	projectile.configure(Vector2.RIGHT, 100.0, 13, resolver)
	var receiver = DamageReceiver.new()
	add_child_autofree(receiver)

	assert_true(projectile.hit_body(receiver))
	assert_eq(receiver.damage_taken, 13)
	assert_eq(tracker.damage, 0, "Void-returning legacy receiver is ignored by resolver contribution accounting.")


func test_projectile_expires_after_lifetime() -> void:
	var projectile = ProjectileScript.new()
	projectile.lifetime = 0.1
	add_child_autofree(projectile)
	assert_true(projectile.has_method("_physics_process"))
	if not projectile.has_method("_physics_process"):
		return

	projectile._physics_process(0.2)

	assert_true(projectile.is_queued_for_deletion())
