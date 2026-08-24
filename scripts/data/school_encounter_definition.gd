extends Resource
class_name SchoolEncounterDefinition

@export var school_id: StringName = &""
@export var core_monster_ids: Array[StringName] = []
@export var core_monster_display_names: Array[String] = []
@export var elite_id: StringName = &""
@export var elite_display_name: String = ""
@export var boss_id: StringName = &""
@export var boss_display_name: String = ""
@export var pattern_refs: Array[StringName] = []
@export var stage4_boss_capstone_id: StringName = &""
@export var stage4_boss_capstone_display_name: String = ""


func copy_value() -> SchoolEncounterDefinition:
	var copied := SchoolEncounterDefinition.new()
	copied.school_id = school_id
	copied.core_monster_ids = core_monster_ids.duplicate()
	copied.core_monster_display_names = core_monster_display_names.duplicate()
	copied.elite_id = elite_id
	copied.elite_display_name = elite_display_name
	copied.boss_id = boss_id
	copied.boss_display_name = boss_display_name
	copied.pattern_refs = pattern_refs.duplicate()
	copied.stage4_boss_capstone_id = stage4_boss_capstone_id
	copied.stage4_boss_capstone_display_name = stage4_boss_capstone_display_name
	return copied
