extends Resource
class_name ItemDefinition

@export var id: StringName = &""
@export var display_name: String = ""
@export var base_price: int = 0
@export var tags: Array[StringName] = []
@export var effect_kind: StringName = &""
@export var effect_value: float = 0.0
@export var school_payload: Dictionary = {}


func sell_price() -> int:
	return floori(float(maxi(base_price, 0)) / 2.0)
