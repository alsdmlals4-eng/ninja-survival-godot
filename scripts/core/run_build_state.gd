extends Node
class_name RunBuildState

signal gold_changed(gold: int)
signal inventory_changed
signal fate_changed(fate_id: StringName)
signal item_purchased(item_id: StringName)
signal item_sold(item_id: StringName)

const MAX_OWNED_ITEMS := 6
const MAX_DUPLICATE_ITEMS := 2
const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")
const RunEconomyPolicyScript = preload("res://scripts/data/run_economy_policy.gd")

var gold: int = 0
var selected_school_id: StringName = &""
var owned_items: Dictionary = {}
var selected_fates: Array[StringName] = []

var _item_defs: Dictionary = {}
var _fate_defs: Dictionary = {}
var _committed_backpack_modifiers = RunModifierSetScript.new()
var _modifiers = RunModifierSetScript.new()
var _economy_policy: Resource
var _economy_rng: RandomNumberGenerator
var _economy_receipts: Array[Dictionary] = []


func configure(
	item_defs: Dictionary,
	fate_defs: Dictionary,
	economy_policy: Resource = null,
	economy_rng: RandomNumberGenerator = null
) -> void:
	_item_defs = item_defs.duplicate()
	_fate_defs = fate_defs.duplicate()
	_economy_policy = economy_policy
	if _economy_policy == null or not _economy_policy.has_method("is_valid") or not bool(_economy_policy.call("is_valid")):
		_economy_policy = RunEconomyPolicyScript.new()
	_economy_rng = economy_rng
	if _economy_rng == null:
		_economy_rng = RandomNumberGenerator.new()
		_economy_rng.randomize()
	_economy_receipts.clear()
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
	if _economy_policy == null or _economy_rng == null:
		return 0
	var amount := 0
	if _economy_rng.randf() < float(_economy_policy.normal_kill_gold_chance):
		amount = maxi(int(_economy_policy.normal_kill_gold_amount), 0)
	return _grant_economy_reward(&"normal", amount)


func grant_elite_clear_gold() -> int:
	if _economy_policy == null:
		return 0
	return _grant_economy_reward(&"elite", maxi(int(_economy_policy.elite_clear_gold), 0))


func grant_school_boss_clear_gold() -> int:
	if _economy_policy == null:
		return 0
	return _grant_economy_reward(&"school_boss", maxi(int(_economy_policy.school_boss_clear_gold), 0))


func get_economy_receipts() -> Array[Dictionary]:
	return _economy_receipts.duplicate(true)


func get_checkpoint_snapshot() -> Dictionary:
	return {
		"gold": gold,
		"selected_school_id": selected_school_id,
		"owned_items": owned_items.duplicate(true),
		"selected_fates": selected_fates.duplicate(),
		"committed_backpack_modifiers": get_committed_backpack_modifiers(),
		"economy_receipts": get_economy_receipts(),
	}


func can_restore_from_checkpoint(snapshot: Dictionary) -> bool:
	var restored_gold := int(snapshot.get("gold", -1))
	var restored_school_id := StringName(snapshot.get("selected_school_id", &""))
	var restored_owned_items = snapshot.get("owned_items", null)
	var restored_fates = snapshot.get("selected_fates", null)
	var restored_modifiers = snapshot.get("committed_backpack_modifiers", null)
	if restored_gold < 0 or restored_school_id == &"" or not (restored_owned_items is Dictionary) or not (restored_fates is Array) or restored_modifiers == null:
		return false
	var validated_fates: Array[StringName] = []
	for raw_fate_id in restored_fates:
		var fate_id := StringName(raw_fate_id)
		if fate_id == &"" or validated_fates.has(fate_id):
			return false
		validated_fates.append(fate_id)
	return restored_modifiers.has_method("copy_values")


func restore_from_checkpoint(snapshot: Dictionary) -> bool:
	if not can_restore_from_checkpoint(snapshot):
		return false
	var restored_gold := int(snapshot.get("gold", -1))
	var restored_school_id := StringName(snapshot.get("selected_school_id", &""))
	var restored_owned_items = snapshot.get("owned_items", null)
	var restored_fates = snapshot.get("selected_fates", null)
	var restored_modifiers = snapshot.get("committed_backpack_modifiers", null)
	var validated_fates: Array[StringName] = []
	for raw_fate_id in restored_fates:
		var fate_id := StringName(raw_fate_id)
		validated_fates.append(fate_id)
	gold = restored_gold
	selected_school_id = restored_school_id
	owned_items = restored_owned_items.duplicate(true)
	selected_fates = validated_fates
	_committed_backpack_modifiers = restored_modifiers.copy_values()
	_economy_receipts = Array(snapshot.get("economy_receipts", [])).duplicate(true)
	_recompute_modifiers()
	gold_changed.emit(gold)
	inventory_changed.emit()
	return true


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


func select_fate(fate_id: StringName) -> bool:
	if not can_select_fate(fate_id):
		return false
	selected_fates.append(fate_id)
	_recompute_modifiers()
	fate_changed.emit(fate_id)
	return true


func can_select_fate(fate_id: StringName) -> bool:
	return _fate_defs.has(fate_id) and not has_fate(fate_id)


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


func _grant_economy_reward(source: StringName, amount: int) -> int:
	var granted := grant_gold(maxi(amount, 0))
	_economy_receipts.append({
		"source": source,
		"amount": granted,
		"school_id": selected_school_id,
	})
	return granted


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
