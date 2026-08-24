extends Resource
class_name ItemDefinition

const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_price: int = 0
@export var tags: Array[StringName] = []
@export var effect_kind: StringName = &""
@export var effect_value: float = 0.0
@export var school_payload: Dictionary = {}
@export var footprint_size: Vector2i = Vector2i.ONE
@export var static_modifier_payload: Dictionary[StringName, float] = {}
@export var spatial_rules: Array[SpatialRuleDefinition] = []


func sell_price() -> int:
	return floori(float(maxi(base_price, 0)) / 2.0)


func footprint(rotation_quarters: int) -> Array[Vector2i]:
	var size := footprint_size
	if posmod(rotation_quarters, 2) == 1:
		size = Vector2i(size.y, size.x)
	var result: Array[Vector2i] = []
	for y in range(maxi(size.y, 0)):
		for x in range(maxi(size.x, 0)):
			result.append(Vector2i(x, y))
	return result


func resolved_static_modifier_payload() -> Dictionary[StringName, float]:
	if not static_modifier_payload.is_empty():
		return static_modifier_payload.duplicate(true)
	var payload: Dictionary[StringName, float] = {}
	if RunModifierSetScript.is_supported_field(effect_kind):
		payload[effect_kind] = effect_value
	return payload
