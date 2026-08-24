extends Resource
class_name EncounterPatternDefinition

@export var primitive_id: StringName = &""
@export var display_name: String = ""
@export var telegraph_parameters: Dictionary = {}
@export var execution_parameters: Dictionary = {}
@export var tags: Array[StringName] = []
@export var presentation_hooks: Dictionary = {}


func copy_value() -> EncounterPatternDefinition:
	var copied := EncounterPatternDefinition.new()
	copied.primitive_id = primitive_id
	copied.display_name = display_name
	copied.telegraph_parameters = telegraph_parameters.duplicate(true)
	copied.execution_parameters = execution_parameters.duplicate(true)
	copied.tags = tags.duplicate()
	copied.presentation_hooks = presentation_hooks.duplicate(true)
	return copied
