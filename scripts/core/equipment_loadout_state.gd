extends RefCounted

const CATALOG = preload("res://scripts/data/equipment_catalog.gd")
const SLOTS := ["melee", "projectile", "outfit"]
const STARTERS := ["katana", "shuriken", "ninja_suit"]
var _snapshot: Dictionary = {}


func _init() -> void:
	_snapshot = {"owned_instances": {}, "equipped_slots": {}, "upgrade_rank_by_instance": {}, "revision": 0}
	for id in STARTERS:
		var instance_id: String = "gear_" + str(id)
		_snapshot["owned_instances"][instance_id] = {"definition_id": id, "acquisition_price": 0, "starter": true}
		_snapshot["upgrade_rank_by_instance"][instance_id] = 0
		_snapshot["equipped_slots"][CATALOG.definition(StringName(id))["slot"]] = instance_id


func get_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func equipped_definition(slot: StringName) -> StringName:
	var id: String = _snapshot["equipped_slots"].get(str(slot), "")
	return StringName(_snapshot["owned_instances"].get(id, {}).get("definition_id", ""))


func acquire(id: StringName) -> bool:
	var definition := CATALOG.definition(id)
	var instance_id := "gear_" + str(id)
	if definition.is_empty() or _snapshot["owned_instances"].has(instance_id):
		return false
	_snapshot["owned_instances"][instance_id] = {"definition_id": str(id), "acquisition_price": definition["price"], "starter": false}
	_snapshot["upgrade_rank_by_instance"][instance_id] = 0
	_snapshot["revision"] += 1
	return true


func equip(slot: StringName, id: StringName) -> bool:
	var instance_id := "gear_" + str(id)
	if not _snapshot["owned_instances"].has(instance_id) or CATALOG.definition(id).get("slot", "") != str(slot):
		return false
	if _snapshot["equipped_slots"].get(str(slot), "") == instance_id:
		return false
	_snapshot["equipped_slots"][str(slot)] = instance_id
	_snapshot["revision"] += 1
	return true


# Negative means rejected; zero is a successful sale of a free starter.
func sell(id: StringName) -> int:
	var instance_id := "gear_" + str(id)
	if not _snapshot["owned_instances"].has(instance_id) or instance_id in _snapshot["equipped_slots"].values():
		return -1
	var item: Dictionary = _snapshot["owned_instances"][instance_id]
	var proceeds := floori(float(item["acquisition_price"]) * 0.5)
	_snapshot["owned_instances"].erase(instance_id)
	_snapshot["upgrade_rank_by_instance"].erase(instance_id)
	_snapshot["revision"] += 1
	return proceeds


func upgrade_equipped(slot: StringName) -> bool:
	var id: String = _snapshot["equipped_slots"].get(str(slot), "")
	var rank: int = _snapshot["upgrade_rank_by_instance"].get(id, -1)
	if rank < 0 or rank >= 4:
		return false
	_snapshot["upgrade_rank_by_instance"][id] = rank + 1
	_snapshot["revision"] += 1
	return true


func equipped_damage_bonus(slot: StringName) -> float:
	if str(slot) not in ["melee", "projectile"]:
		return 0.0
	return 0.15 * float(_snapshot["upgrade_rank_by_instance"][_snapshot["equipped_slots"][str(slot)]])


func outfit_reduction() -> float:
	var rank := int(_snapshot["upgrade_rank_by_instance"][_snapshot["equipped_slots"]["outfit"]])
	return 0.05 + 0.03 * rank


static func is_valid_snapshot(value: Dictionary) -> bool:
	var owned = value.get("owned_instances")
	var slots = value.get("equipped_slots")
	var ranks = value.get("upgrade_rank_by_instance")
	if not (owned is Dictionary) or not (slots is Dictionary) or not (ranks is Dictionary):
		return false
	if owned.size() < 3 or owned.size() > 9 or ranks.size() != owned.size() or slots.size() != 3:
		return false
	if not _whole(value.get("revision")) or float(value["revision"]) < 0:
		return false
	for instance_id in owned:
		var item = owned[instance_id]
		if not (item is Dictionary) or not (item.get("definition_id") is String):
			return false
		var id := StringName(item["definition_id"])
		var definition := CATALOG.definition(id)
		if definition.is_empty() or str(instance_id) != "gear_" + str(id):
			return false
		var rank = ranks.get(instance_id)
		if not _whole(rank) or float(rank) < 0 or float(rank) > 4:
			return false
		if not (item.get("starter") is bool) or not _whole(item.get("acquisition_price")):
			return false
		if item["starter"]:
			if str(id) not in STARTERS or int(item["acquisition_price"]) != 0:
				return false
		elif int(item["acquisition_price"]) != int(definition["price"]):
			return false
	for slot in SLOTS:
		var instance_id = slots.get(slot)
		if not (instance_id is String) or not owned.has(instance_id):
			return false
		if CATALOG.definition(StringName(owned[instance_id]["definition_id"]))["slot"] != slot:
			return false
	return true


func restore_snapshot(value: Dictionary) -> bool:
	if not is_valid_snapshot(value):
		return false
	_snapshot = value.duplicate(true)
	_snapshot["revision"] = int(_snapshot["revision"])
	for id in _snapshot["upgrade_rank_by_instance"]:
		_snapshot["upgrade_rank_by_instance"][id] = int(_snapshot["upgrade_rank_by_instance"][id])
	return true


static func _whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))
