extends Resource
class_name BagDefinition

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_price: int = 0
@export var cells: Array[Vector2i] = []
@export var affected_item_tag: StringName = &""
@export var auxiliary_effect_kind: StringName = &""
@export var auxiliary_effect_value: float = 0.0


func footprint(rotation_quarters: int) -> Array[Vector2i]:
	var turns := posmod(rotation_quarters, 4)
	var rotated: Array[Vector2i] = []
	for cell in cells:
		var value := cell
		for _turn in range(turns):
			value = Vector2i(-value.y, value.x)
		rotated.append(value)

	if rotated.is_empty():
		return rotated

	var min_x := rotated[0].x
	var min_y := rotated[0].y
	for cell in rotated:
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)

	var offset := Vector2i(min_x, min_y)
	for index in range(rotated.size()):
		rotated[index] -= offset
	return rotated
