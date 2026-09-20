extends Node2D
## Rendering only: the actor owns and resolves this locked geometry.

var geometry
var warning_color := Color("ffb454")

func configure(value, color: Color) -> void:
	geometry = value
	warning_color = color
	queue_redraw()

func _draw() -> void:
	if geometry == null or geometry.radius <= 0.0:
		return
	var points: PackedVector2Array = geometry.outline()
	for index in range(points.size()):
		points[index] = to_local(points[index])
	draw_colored_polygon(points, Color(warning_color, 0.16))
	points.append(points[0])
	draw_polyline(points, Color("15151f"), 5.0, true)
	draw_polyline(points, Color(warning_color, 0.95), 2.0, true)
