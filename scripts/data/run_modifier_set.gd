extends RefCounted
class_name RunModifierSet

var move_speed_pct: float = 0.0
var max_health_flat: float = 0.0
var max_health_pct: float = 0.0
var damage_taken_pct: float = 0.0
var healing_pct: float = 0.0
var normal_kill_gold_pct: float = 0.0
var school_damage_pct: float = 0.0
var non_ultimate_school_damage_pct: float = 0.0
var school_resource_gain_pct: float = 0.0
var ultimate_charge_gain_pct: float = 0.0
var ultimate_power_pct: float = 0.0
var school_status_effect_pct: float = 0.0
var evasion_chance: float = 0.0
var rest_start_heal_pct: float = 0.0
var bongma_familiar_interval_pct: float = 0.0
var cheonsul_reaction_damage_pct: float = 0.0
var guiin_melee_radius_pct: float = 0.0
var heukyeong_marked_crit_bonus: float = 0.0
var heukyeong_mark_duration_pct: float = 0.0


func copy_values() -> RunModifierSet:
	var copied := RunModifierSet.new()
	copied.move_speed_pct = move_speed_pct
	copied.max_health_flat = max_health_flat
	copied.max_health_pct = max_health_pct
	copied.damage_taken_pct = damage_taken_pct
	copied.healing_pct = healing_pct
	copied.normal_kill_gold_pct = normal_kill_gold_pct
	copied.school_damage_pct = school_damage_pct
	copied.non_ultimate_school_damage_pct = non_ultimate_school_damage_pct
	copied.school_resource_gain_pct = school_resource_gain_pct
	copied.ultimate_charge_gain_pct = ultimate_charge_gain_pct
	copied.ultimate_power_pct = ultimate_power_pct
	copied.school_status_effect_pct = school_status_effect_pct
	copied.evasion_chance = evasion_chance
	copied.rest_start_heal_pct = rest_start_heal_pct
	copied.bongma_familiar_interval_pct = bongma_familiar_interval_pct
	copied.cheonsul_reaction_damage_pct = cheonsul_reaction_damage_pct
	copied.guiin_melee_radius_pct = guiin_melee_radius_pct
	copied.heukyeong_marked_crit_bonus = heukyeong_marked_crit_bonus
	copied.heukyeong_mark_duration_pct = heukyeong_mark_duration_pct
	return copied
