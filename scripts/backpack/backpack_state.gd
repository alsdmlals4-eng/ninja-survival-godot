extends RefCounted
class_name BackpackState

const MVP4CatalogScript = preload("res://scripts/data/mvp4_catalog.gd")
const ItemInstanceScript = preload("res://scripts/data/item_instance.gd")
const BagInstanceScript = preload("res://scripts/data/bag_instance.gd")

const BOARD_SIZE := Vector2i(6, 6)
const STARTING_BAG_ORIGIN := Vector2i(1, 1)

var bags: Dictionary = {}
var items: Dictionary = {}
var next_instance_id: int = 1


func create_starting_state():
	var state = get_script().new()
	var starting_id: int = state.add_bag(MVP4CatalogScript.STARTING_BAG_ID, STARTING_BAG_ORIGIN, 0)
	if starting_id == 0:
		return null
	return state


func add_item(definition_id: StringName, origin: Vector2i, rotation_quarters: int = 0) -> int:
	var rotation := posmod(rotation_quarters, 4)
	if not _can_place_item(definition_id, origin, rotation, -1):
		return 0
	var instance = ItemInstanceScript.new()
	instance.instance_id = next_instance_id
	instance.definition_id = definition_id
	instance.origin = origin
	instance.rotation_quarters = rotation
	items[instance.instance_id] = instance
	next_instance_id += 1
	return instance.instance_id


func add_bag(definition_id: StringName, origin: Vector2i, rotation_quarters: int = 0) -> int:
	var rotation := posmod(rotation_quarters, 4)
	if not _can_place_bag(definition_id, origin, rotation, -1):
		return 0
	var instance = BagInstanceScript.new()
	instance.instance_id = next_instance_id
	instance.definition_id = definition_id
	instance.origin = origin
	instance.rotation_quarters = rotation
	bags[instance.instance_id] = instance
	next_instance_id += 1
	return instance.instance_id


func move_item(instance_id: int, new_origin: Vector2i) -> bool:
	var instance = items.get(instance_id)
	if instance == null:
		return false
	if not _can_place_item(instance.definition_id, new_origin, instance.rotation_quarters, instance_id):
		return false
	instance.origin = new_origin
	return true


func rotate_item(instance_id: int) -> bool:
	var instance = items.get(instance_id)
	if instance == null:
		return false
	var next_rotation := posmod(instance.rotation_quarters + 1, 4)
	if not _can_place_item(instance.definition_id, instance.origin, next_rotation, instance_id):
		return false
	instance.rotation_quarters = next_rotation
	return true


func move_bag(instance_id: int, new_origin: Vector2i) -> bool:
	var instance = bags.get(instance_id)
	if instance == null:
		return false
	if not _can_place_bag(instance.definition_id, new_origin, instance.rotation_quarters, instance_id):
		return false
	var candidate = instance.copy_value()
	candidate.origin = new_origin
	var active_cells := _active_cells_with_replacement(instance_id, candidate)
	if not _items_fit_active_cells(active_cells):
		return false
	instance.origin = new_origin
	return true


func rotate_bag(instance_id: int) -> bool:
	var instance = bags.get(instance_id)
	if instance == null:
		return false
	var next_rotation := posmod(instance.rotation_quarters + 1, 4)
	if not _can_place_bag(instance.definition_id, instance.origin, next_rotation, instance_id):
		return false
	var candidate = instance.copy_value()
	candidate.rotation_quarters = next_rotation
	var active_cells := _active_cells_with_replacement(instance_id, candidate)
	if not _items_fit_active_cells(active_cells):
		return false
	instance.rotation_quarters = next_rotation
	return true


func remove_item(instance_id: int):
	var instance = items.get(instance_id)
	if instance == null:
		return null
	items.erase(instance_id)
	return instance.copy_value()


func remove_bag(instance_id: int):
	var instance = bags.get(instance_id)
	if instance == null:
		return null
	var active_cells := _active_cells_with_replacement(instance_id, null)
	if not _items_fit_active_cells(active_cells):
		return null
	bags.erase(instance_id)
	return instance.copy_value()


func get_item(instance_id: int):
	var instance = items.get(instance_id)
	if instance == null:
		return null
	return instance.copy_value()


func get_bag(instance_id: int):
	var instance = bags.get(instance_id)
	if instance == null:
		return null
	return instance.copy_value()


func get_active_cells() -> Dictionary:
	return _active_cells_with_replacement(-1, null)


func copy_value():
	var copied = get_script().new()
	copied.next_instance_id = next_instance_id
	for raw_id in items.keys():
		var instance_id := int(raw_id)
		copied.items[instance_id] = items[instance_id].copy_value()
	for raw_id in bags.keys():
		var instance_id := int(raw_id)
		copied.bags[instance_id] = bags[instance_id].copy_value()
	return copied


func _can_place_item(definition_id: StringName, origin: Vector2i, rotation_quarters: int, ignored_instance_id: int) -> bool:
	var definitions: Dictionary = MVP4CatalogScript.build_items()
	var definition = definitions.get(definition_id)
	if definition == null:
		return false
	var cells := _translated_cells(definition.footprint(rotation_quarters), origin)
	if cells.is_empty():
		return false
	var active_cells := get_active_cells()
	var occupied_cells := _occupied_item_cells(ignored_instance_id)
	for cell in cells:
		if not _is_inside_board(cell):
			return false
		if not active_cells.has(cell):
			return false
		if occupied_cells.has(cell):
			return false
	return true


func _can_place_bag(definition_id: StringName, origin: Vector2i, rotation_quarters: int, ignored_instance_id: int) -> bool:
	var definitions: Dictionary = MVP4CatalogScript.build_bags()
	var definition = definitions.get(definition_id)
	if definition == null:
		return false
	var cells := _translated_cells(definition.footprint(rotation_quarters), origin)
	if cells.is_empty():
		return false
	var occupied_cells := _occupied_bag_cells(ignored_instance_id)
	for cell in cells:
		if not _is_inside_board(cell):
			return false
		if occupied_cells.has(cell):
			return false
	return true


func _occupied_item_cells(ignored_instance_id: int = -1) -> Dictionary:
	var occupied := {}
	var definitions: Dictionary = MVP4CatalogScript.build_items()
	for raw_id in items.keys():
		var instance_id := int(raw_id)
		if instance_id == ignored_instance_id:
			continue
		var instance = items[instance_id]
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			continue
		for cell in _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin):
			occupied[cell] = instance_id
	return occupied


func _occupied_bag_cells(ignored_instance_id: int = -1) -> Dictionary:
	var occupied := {}
	var definitions: Dictionary = MVP4CatalogScript.build_bags()
	for raw_id in bags.keys():
		var instance_id := int(raw_id)
		if instance_id == ignored_instance_id:
			continue
		var instance = bags[instance_id]
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			continue
		for cell in _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin):
			occupied[cell] = instance_id
	return occupied


func _active_cells_with_replacement(replaced_instance_id: int, replacement) -> Dictionary:
	var active := {}
	var definitions: Dictionary = MVP4CatalogScript.build_bags()
	for raw_id in bags.keys():
		var instance_id := int(raw_id)
		if instance_id == replaced_instance_id:
			continue
		var instance = bags[instance_id]
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			continue
		for cell in _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin):
			if _is_inside_board(cell):
				active[cell] = true
	if replacement != null:
		var definition = definitions.get(replacement.definition_id)
		if definition != null:
			for cell in _translated_cells(definition.footprint(replacement.rotation_quarters), replacement.origin):
				if _is_inside_board(cell):
					active[cell] = true
	return active


func _items_fit_active_cells(active_cells: Dictionary) -> bool:
	var definitions: Dictionary = MVP4CatalogScript.build_items()
	for instance in items.values():
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			return false
		var cells := _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin)
		if cells.is_empty():
			return false
		for cell in cells:
			if not active_cells.has(cell):
				return false
	return true


func _translated_cells(local_cells: Array[Vector2i], origin: Vector2i) -> Array[Vector2i]:
	var translated: Array[Vector2i] = []
	for local_cell in local_cells:
		translated.append(origin + local_cell)
	return translated


func _is_inside_board(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < BOARD_SIZE.x and cell.y < BOARD_SIZE.y
