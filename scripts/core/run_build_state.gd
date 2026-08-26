extends Node
class_name RunBuildState

signal gold_changed(gold: int)
signal inventory_changed
signal fate_changed(fate_id: StringName)
signal item_purchased(item_id: StringName)
signal item_sold(item_id: StringName)

const MAX_OWNED_ITEMS := 6
const MAX_DUPLICATE_ITEMS := 2
const NORMAL_KILL_GOLD := 1
const BOSS_KILL_GOLD := 25

const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")

var gold: int = 0
var selected_school_id: StringName = &""
var owned_items: Dictionary = {}
var selected_fates: Array[StringName] = []

var _item_defs: Dictionary = {}
var _fate_defs: Dictionary = {}
var _committed_backpack_modifiers = RunModifierSetScript.new()
var _modifiers = RunModifierSetScript.new()
var _normal_gold_fraction: float = 0.0


func configure(item_defs: Dictionary, fate_defs: Dictionary) -> void:
	_item_defs = item_defs.duplicate()
	_fate_defs = fate_defs.duplicate()
	_recompute_modifiers()


func set_selected_school(school_id: StringName) -> void:
	selected_school_id = school_id
	_recompute_modifiers()


func grant_gold(amount: int) -> int:
	if amount <= 0:
		return 0
	gold += amount
	gold_changed.emit(gold)
	return amount


func try_spend_gold(amount: int) -> bool:
	if amount <= 0 or gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func grant_normal_kill_gold() -> int:
	var credit := float(NORMAL_KILL_GOLD) * maxf(1.0 + _modifiers.normal_kill_gold_pct, 0.0)
	_normal_gold_fraction += credit
	var whole_gold := floori(_normal_gold_fraction + 0.000001)
	_normal_gold_fraction -= float(whole_gold)
	return grant_gold(whole_gold)


func grant_boss_gold() -> int:
	return grant_gold(BOSS_KILL_GOLD)


func buy_item(item_id: StringName) -> bool:
	var definition = _item_defs.get(item_id)
	if definition == null:
		return false
	if total_item_count() >= MAX_OWNED_ITEMS:
		return false
	if item_count(item_id) >= MAX_DUPLICATE_ITEMS:
		return false
	var price: int = maxi(int(definition.base_price), 0)
	if gold < price:
		return false

	gold -= price
	owned_items[item_id] = item_count(item_id) + 1
	_recompute_modifiers()
	gold_changed.emit(gold)
	inventory_changed.emit()
	item_purchased.emit(item_id)
	return true


func sell_item(item_id: StringName) -> bool:
	var count := item_count(item_id)
	var definition = _item_defs.get(item_id)
	if count <= 0 or definition == null:
		return false

	if count == 1:
		owned_items.erase(item_id)
	else:
		owned_items[item_id] = count - 1
	gold += int(definition.sell_price())
	_recompute_modifiers()
	gold_changed.emit(gold)
	inventory_changed.emit()
	item_sold.emit(item_id)
	return true


func can_select_fate(fate_id: StringName) -> bool:
	return _fate_defs.has(fate_id) and not has_fate(fate_id)


func select_fate(fate_id: StringName) -> bool:
	if not can_select_fate(fate_id):
		return false
	selected_fates.append(fate_id)
	_recompute_modifiers()
	fate_changed.emit(fate_id)
	return true


func item_count(item_id: StringName) -> int:
	return int(owned_items.get(item_id, 0))


func total_item_count() -> int:
	var total := 0
	for count in owned_items.values():
		total += int(count)
	return total


func has_fate(fate_id: StringName) -> bool:
	return selected_fates.has(fate_id)


func set_committed_backpack_modifiers(modifiers) -> void:
	if modifiers == null:
		_committed_backpack_modifiers = RunModifierSetScript.new()
	else:
		_committed_backpack_modifiers = modifiers.copy_values()
	_recompute_modifiers()


func get_committed_backpack_modifiers():
	return _committed_backpack_modifiers.copy_values()


func get_modifiers() -> RunModifierSet:
	return _modifiers.copy_values()


func _recompute_modifiers() -> void:
	var modifiers = _committed_backpack_modifiers.copy_values()

	for fate_id in selected_fates:
		var fate = _fate_defs.get(fate_id)
		if fate == null:
			continue
		for field_name in fate.modifiers.keys():
			_add_modifier(modifiers, field_name, float(fate.modifiers[field_name]))

	if selected_school_id == &"heukyeong":
		modifiers.heukyeong_mark_duration_pct += modifiers.ultimate_charge_gain_pct
		modifiers.ultimate_charge_gain_pct = 0.0

	modifiers.evasion_chance = clampf(modifiers.evasion_chance, 0.0, 0.95)
	modifiers.heukyeong_marked_crit_bonus = clampf(modifiers.heukyeong_marked_crit_bonus, 0.0, 1.0)
	_modifiers = modifiers


func _add_modifier(modifiers, field_name: StringName, amount: float) -> void:
	match field_name:
		&"move_speed_pct": modifiers.move_speed_pct += amount
		&"max_health_flat": modifiers.max_health_flat += amount
		&"max_health_pct": modifiers.max_health_pct += amount
		&"damage_taken_pct": modifiers.damage_taken_pct += amount
		&"healing_pct": modifiers.healing_pct += amount
		&"normal_kill_gold_pct": modifiers.normal_kill_gold_pct += amount
		&"school_damage_pct": modifiers.school_damage_pct += amount
		&"non_ultimate_school_damage_pct": modifiers.non_ultimate_school_damage_pct += amount
		&"school_resource_gain_pct": modifiers.school_resource_gain_pct += amount
		&"ultimate_charge_gain_pct": modifiers.ultimate_charge_gain_pct += amount
		&"ultimate_power_pct": modifiers.ultimate_power_pct += amount
		&"school_status_effect_pct": modifiers.school_status_effect_pct += amount
		&"evasion_chance": modifiers.evasion_chance += amount
		&"rest_start_heal_pct": modifiers.rest_start_heal_pct += amount
		&"bongma_familiar_interval_pct": modifiers.bongma_familiar_interval_pct += amount
		&"cheonsul_reaction_damage_pct": modifiers.cheonsul_reaction_damage_pct += amount
		&"guiin_melee_radius_pct": modifiers.guiin_melee_radius_pct += amount
		&"heukyeong_marked_crit_bonus": modifiers.heukyeong_marked_crit_bonus += amount
		&"heukyeong_mark_duration_pct": modifiers.heukyeong_mark_duration_pct += amount