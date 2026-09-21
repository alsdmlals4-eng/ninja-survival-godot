extends Node2D
## Direction notice, not an instantaneous filled damage area.
## Actor snapshots these rays once and uses the same rays for actual projectiles.
var rays := PackedVector2Array()
var warning_color := Color.WHITE

func configure(directions: PackedVector2Array, color: Color) -> void:
	rays = directions.duplicate()
	warning_color = color
	queue_redraw()

func _draw() -> void:
	for direction in rays:
		var end := direction * 180.0
		draw_line(direction * 18.0, end, Color("15151f"), 5.0, true)
		draw_line(direction * 18.0, end, Color(warning_color, 0.9), 2.0, true)
		var side := direction.orthogonal() * 5.0
		draw_polyline(PackedVector2Array([end - direction * 10.0 + side, end, end - direction * 10.0 - side]), warning_color, 2.0, true)
