extends Node2D
## Direction-only spawn notice; never a damaging floor area or collision owner.
var target_position := Vector2.ZERO

func _ready() -> void:
	top_level = true
	z_index = 3
	_process(0.0)

func _process(_delta: float) -> void:
	var canvas := get_canvas_transform()
	var screen_target := canvas * target_position
	var safe_rect := get_viewport_rect().grow(-24.0)
	var edge := screen_target.clamp(safe_rect.position, safe_rect.end)
	global_position = canvas.affine_inverse() * edge
	rotation = (target_position - global_position).angle()

func _draw() -> void:
	draw_polyline(PackedVector2Array([Vector2(-7, -5), Vector2.ZERO, Vector2(-7, 5)]), Color("d8c899a0"), 2.0, true)
