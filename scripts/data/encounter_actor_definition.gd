extends Resource
class_name EncounterActorDefinition

@export var actor_id: StringName = &""
@export var school_id: StringName = &""
@export var role: StringName = &""
@export var display_name: String = ""
@export var tags: Array[StringName] = []
@export var max_health: int = 20
@export var move_speed: float = 90.0
@export var contact_damage: int = 10
@export var contact_range: float = 28.0
@export var pattern_definitions: Array[Dictionary] = []
@export var visual_asset_path: String = ""


func copy_value():
	var copied = get_script().new()
	copied.actor_id = actor_id
	copied.school_id = school_id
	copied.role = role
	copied.display_name = display_name
	copied.tags = tags.duplicate()
	copied.max_health = max_health
	copied.move_speed = move_speed
	copied.contact_damage = contact_damage
	copied.contact_range = contact_range
	copied.pattern_definitions = pattern_definitions.duplicate(true)
	copied.visual_asset_path = visual_asset_path
	return copied
