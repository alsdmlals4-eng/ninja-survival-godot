extends RefCounted

const NINJUTSU = preload("res://scripts/data/ninjutsu_catalog.gd")
const ITEM = preload("res://scripts/data/item_definition.gd")
const CONTRACT := "selectable-books-v2"


static func build_items() -> Dictionary:
	var items: Dictionary = {}
	for spell in NINJUTSU.build_definitions().values():
		for starter in [false, true]:
			var item = ITEM.new()
			item.id = book_id(spell.ninjutsu_id, starter)
			item.display_name = spell.display_name
			item.base_price = 0 if starter else 40
			item.footprint_size = Vector2i(1, 2)
			item.tags = spell.tags.duplicate()
			item.school_payload = {"ninjutsu_id": str(spell.ninjutsu_id), "school_id": str(spell.school_id), "starter": starter}
			items[item.id] = item
	return items


static func book_id(spell_id: StringName, starter: bool = false) -> StringName:
	return StringName(("start_book:" if starter else "book:") + str(spell_id))


static func spell_id(definition_id: StringName) -> StringName:
	var text := str(definition_id)
	var prefix := "start_book:" if text.begins_with("start_book:") else "book:"
	if not text.begins_with(prefix):
		return &""
	var id := StringName(text.trim_prefix(prefix))
	return id if NINJUTSU.definition_for_id(id) != null else &""
