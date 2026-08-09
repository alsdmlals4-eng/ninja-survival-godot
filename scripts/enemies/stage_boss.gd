extends EnemyChaser
class_name StageBoss

const TIER_STATS := {
	1: {"max_health": 200, "move_speed": 70.0, "contact_damage": 15, "visual_scale": 1.6},
	2: {"max_health": 350, "move_speed": 80.0, "contact_damage": 20, "visual_scale": 1.8},
	3: {"max_health": 500, "move_speed": 90.0, "contact_damage": 25, "visual_scale": 2.0},
}

var tier: int = 1


func configure_tier(new_tier: int) -> bool:
	if not TIER_STATS.has(new_tier):
		return false
	var stats: Dictionary = TIER_STATS[new_tier]
	tier = new_tier
	max_health = int(stats["max_health"])
	move_speed = float(stats["move_speed"])
	contact_damage = int(stats["contact_damage"])
	var visual_scale := float(stats["visual_scale"])
	scale = Vector2.ONE * visual_scale
	return true


func is_stage_boss() -> bool:
	return true
