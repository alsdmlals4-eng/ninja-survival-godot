extends GutTest

const ProjectileScript = preload("res://scripts/combat/projectile.gd")


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
