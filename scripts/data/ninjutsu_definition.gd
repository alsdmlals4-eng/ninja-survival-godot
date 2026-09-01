extends Resource
class_name NinjutsuDefinition

@export var ninjutsu_id: StringName = &""
@export var school_id: StringName = &""
@export var acquisition_lane: StringName = &""
@export var display_name: String = ""
@export var primitive_id: StringName = &""
@export var visual_asset_path: String = ""


func copy_value():
	var copied = get_script().new()
	copied.ninjutsu_id = ninjutsu_id
	copied.school_id = school_id
	copied.acquisition_lane = acquisition_lane
	copied.display_name = display_name
	copied.primitive_id = primitive_id
	copied.visual_asset_path = visual_asset_path
	return copied
