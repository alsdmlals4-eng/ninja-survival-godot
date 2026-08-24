extends RefCounted
class_name ItemInstance

var instance_id: int = 0
var definition_id: StringName = &""
var origin: Vector2i = Vector2i.ZERO
var rotation_quarters: int = 0


func copy_value() -> ItemInstance:
	var copied := ItemInstance.new()
	copied.instance_id = instance_id
	copied.definition_id = definition_id
	copied.origin = origin
	copied.rotation_quarters = posmod(rotation_quarters, 4)
	return copied
