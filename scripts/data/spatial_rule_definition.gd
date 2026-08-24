extends Resource
class_name SpatialRuleDefinition

enum Aggregation {
	ONCE_IF_ANY,
	PER_DISTINCT_NEIGHBOR,
}

@export var required_neighbor_tags: Array[StringName] = []
@export var required_neighbor_definition_ids: Array[StringName] = []
@export var aggregation: Aggregation = Aggregation.ONCE_IF_ANY
@export var max_matches: int = 1
@export var modifier_payload: Dictionary[StringName, float] = {}
