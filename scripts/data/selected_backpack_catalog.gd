extends RefCounted

# Explicit new-run projection. Never rewrite the schema1 catalog in place.
const LEGACY = preload("res://scripts/data/mvp4_catalog.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const ITEM = preload("res://scripts/data/item_definition.gd")
const REPLACEMENTS := {&"katana": &"melee_manual", &"shuriken": &"projectile_manual", &"bomb": &"blast_powder"}
const START_SUPPORT_IDS := [&"taijutsu_training", &"protection_talisman", &"ninjutsu_training"]
const SUPPORT_UNLOCK_COST := 3


static func build_items() -> Dictionary:
	var items: Dictionary = LEGACY.build_items()
	for old_id in REPLACEMENTS:
		items.erase(old_id)
	_add_manual(items, &"melee_manual", "근접 비전", 35, Vector2i(1, 3), "melee", 0.18)
	_add_manual(items, &"projectile_manual", "투사 비전", 20, Vector2i.ONE, "projectile", 0.10)
	_add_manual(items, &"blast_powder", "폭약 배합서", 40, Vector2i(2, 2), "projectile", 0.12)
	# Replace result meanings; old effects must not coexist with new passives.
	_add_manual(items, &"thunder_blade", "뇌명 비전", 70, Vector2i(1, 3), "melee", 0.20)
	_add_manual(items, &"explosive_bomb", "폭렬 비전", 75, Vector2i(2, 2), "projectile", 0.20)
	var mist = ITEM.new()
	mist.id = &"water_mist"
	mist.display_name = "물안개"
	mist.base_price = 60
	mist.footprint_size = Vector2i(2, 2)
	mist.tags.assign([&"support", &"movement"])
	mist.static_modifier_payload = {&"move_speed_pct": 0.08}
	items[mist.id] = mist
	for id in LEGACY.COMBINATION_RESULT_IDS:
		items[id].school_payload["combination_effect"] = str(id)
	items.merge(BOOKS.build_items())
	for id in START_SUPPORT_IDS:
		var starter = items[id].duplicate(true)
		starter.id = StringName("start_support:" + str(id))
		starter.base_price = 0
		items[starter.id] = starter
	return items


static func base_acquisition_item_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in LEGACY.base_acquisition_item_ids():
		ids.append(REPLACEMENTS.get(id, id))
	return ids


static func build_combinations() -> Dictionary:
	var recipes: Dictionary = LEGACY.build_combinations()
	recipes[&"thunder_blade"].source_a = &"melee_manual"
	recipes[&"explosive_bomb"].source_a = &"blast_powder"
	return recipes


static func _add_manual(items: Dictionary, id: StringName, label: String, price: int, size: Vector2i, slot: String, bonus: float) -> void:
	var item = ITEM.new()
	item.id = id
	item.display_name = label
	item.base_price = price
	item.footprint_size = size
	item.tags.assign([&"support", StringName(slot)])
	item.school_payload = {"weapon_slot": slot, "weapon_damage_bonus": bonus}
	items[id] = item
