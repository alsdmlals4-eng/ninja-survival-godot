extends RefCounted
## World-space circle/capsule shared by damage and its warning renderer.
## Projectile travel and non-damaging marks retain their own existing owners.

var start := Vector2.ZERO
var end := Vector2.ZERO
var radius := 0.0

func _init(from: Vector2, to: Vector2, half_width: float) -> void:
	start = from
	end = to
	radius = maxf(half_width, 0.0)

func contains(point: Vector2) -> bool:
	var nearest := start if start.is_equal_approx(end) else Geometry2D.get_closest_point_to_segment(point, start, end)
	return radius > 0.0 and point.distance_squared_to(nearest) <= radius * radius

func outline() -> PackedVector2Array:
	var points := PackedVector2Array()
	if start.is_equal_approx(end):
		for step in range(64):
			points.append(start + Vector2.from_angle(TAU * float(step) / 64.0) * radius)
		return points
	var angle := (end - start).angle()
	for step in range(33):
		points.append(end + Vector2.from_angle(angle - PI / 2.0 + PI * float(step) / 32.0) * radius)
	for step in range(33):
		points.append(start + Vector2.from_angle(angle + PI / 2.0 + PI * float(step) / 32.0) * radius)
	return points
