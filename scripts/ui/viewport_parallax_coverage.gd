extends Parallax2D

## Cover the visible world plus a complete repeat seam on either side.
## Tile size and prop density stay authored; fullscreen does not stretch art.
func _ready() -> void:
	_update_coverage()

func _process(_delta: float) -> void:
	_update_coverage()

func _update_coverage() -> void:
	var canvas_scale := get_viewport().get_canvas_transform().get_scale().abs()
	var visible_size := get_viewport_rect().size / canvas_scale.max(Vector2(0.01, 0.01))
	var tiles := visible_size / repeat_size.max(Vector2.ONE)
	var required := maxi(ceili(maxf(tiles.x, tiles.y)) + 2, 3)
	if repeat_times != required:
		repeat_times = required
