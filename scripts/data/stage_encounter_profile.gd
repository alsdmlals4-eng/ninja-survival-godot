extends Resource
class_name StageEncounterProfile

@export var stage_index: int = 1
@export var density_multiplier: float = 1.0
@export var stat_multiplier: float = 1.0
@export var pattern_depth_tier: int = 1
@export var max_concurrent_advanced_gimmicks: int = 1
@export var boss_capstone_enabled: bool = false


func copy_value() -> StageEncounterProfile:
	var copied := StageEncounterProfile.new()
	copied.stage_index = stage_index
	copied.density_multiplier = density_multiplier
	copied.stat_multiplier = stat_multiplier
	copied.pattern_depth_tier = pattern_depth_tier
	copied.max_concurrent_advanced_gimmicks = max_concurrent_advanced_gimmicks
	copied.boss_capstone_enabled = boss_capstone_enabled
	return copied
