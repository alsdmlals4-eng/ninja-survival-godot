extends RefCounted
## Bounded conservative candidate search, not proof against future moving enemies.
## Convex circle/capsule hazards may be exited when starting inside, not crossed
## when starting outside. Physics sweeps are supplied by the actual player body.

static func find_escape(origin: Vector2, speed: float, clearance: float, hazards: Array, path_clear: Callable) -> Dictionary:
	if not origin.is_finite() or not is_finite(speed) or speed <= 0.0 or not is_finite(clearance) or clearance < 0.0:
		return {"ok": false}
	var inside := false
	for hazard in hazards:
		if _contains(hazard, origin, clearance): inside = true; break
	if not inside:
		return {"ok": true, "destination": origin, "locked_duration": 0.65}
	for distance in [64.0, 128.0, 192.0, 256.0]:
		for step in range(16):
			var destination: Vector2 = origin + Vector2.from_angle(TAU * float(step) / 16.0) * distance
			var safe := true
			for hazard in hazards:
				if _contains(hazard, destination, clearance) or (not _contains(hazard, origin, clearance) and _crosses(hazard, origin, destination, clearance)):
					safe = false
					break
			if safe and (not path_clear.is_valid() or bool(path_clear.call(destination))):
				return {"ok": true, "destination": destination, "locked_duration": maxf(0.65, distance / speed + 0.15)}
	return {"ok": false}

static func _contains(hazard, point: Vector2, clearance: float) -> bool:
	var nearest := Geometry2D.get_closest_point_to_segment(point, hazard.start, hazard.end)
	return point.distance_squared_to(nearest) <= pow(hazard.radius + clearance, 2.0)

static func _crosses(hazard, from: Vector2, to: Vector2, clearance: float) -> bool:
	var pair := Geometry2D.get_closest_points_between_segments(from, to, hazard.start, hazard.end)
	return pair[0].distance_squared_to(pair[1]) <= pow(hazard.radius + clearance, 2.0)
