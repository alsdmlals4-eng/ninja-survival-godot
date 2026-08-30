extends RefCounted
class_name BackpackState

const MVP4CatalogScript = preload("res://scripts/data/mvp4_catalog.gd")
const ItemInstanceScript = preload("res://scripts/data/item_instance.gd")
const BagInstanceScript = preload("res://scripts/data/bag_instance.gd")

const BOARD_SIZE := Vector2i(6, 6)
const STARTING_BAG_ORIGIN := Vector2i(1, 1)

var _bags: Dictionary = {}
var _items: Dictionary = {}
var next_instance_id: int = 1

var bags: Dictionary:
	get:
		return _copy_bag_instances()

var items: Dictionary:
	get:
		return _copy_item_instances()


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
	_items[instance.instance_id] = instance
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
	_bags[instance.instance_id] = instance
	next_instance_id += 1
	return instance.instance_id


func restore_item_instance(instance) -> bool:
	if instance == null:
		return false
	var instance_id: int = int(instance.instance_id)
	if instance_id <= 0 or _items.has(instance_id) or _bags.has(instance_id):
		return false
	var restored = instance.copy_value()
	restored.rotation_quarters = posmod(restored.rotation_quarters, 4)
	if not _can_place_item(restored.definition_id, restored.origin, restored.rotation_quarters, -1):
		return false
	_items[instance_id] = restored
	next_instance_id = maxi(next_instance_id, instance_id + 1)
	return true


func restore_bag_instance(instance) -> bool:
	if instance == null:
		return false
	var instance_id: int = int(instance.instance_id)
	if instance_id <= 0 or _bags.has(instance_id) or _items.has(instance_id):
		return false
	var restored = instance.copy_value()
	restored.rotation_quarters = posmod(restored.rotation_quarters, 4)
	if not _can_place_bag(restored.definition_id, restored.origin, restored.rotation_quarters, -1):
		return false
	_bags[instance_id] = restored
	next_instance_id = maxi(next_instance_id, instance_id + 1)
	return true


func move_item(instance_id: int, new_origin: Vector2i) -> bool:
	var instance = _items.get(instance_id)
	if instance == null:
		return false
	if not _can_place_item(instance.definition_id, new_origin, instance.rotation_quarters, instance_id):
		return false
	instance.origin = new_origin
	return true


func rotate_item(instance_id: int) -> bool:
	var instance = _items.get(instance_id)
	if instance == null:
		return false
	var next_rotation := posmod(instance.rotation_quarters + 1, 4)
	if not _can_place_item(instance.definition_id, instance.origin, next_rotation, instance_id):
		return false
	instance.rotation_quarters = next_rotation
	return true


func move_bag(instance_id: int, new_origin: Vector2i) -> bool:
	var instance = _bags.get(instance_id)
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
	var instance = _bags.get(instance_id)
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
	var instance = _items.get(instance_id)
	if instance == null:
		return null
	_items.erase(instance_id)
	return instance.copy_value()


func remove_bag(instance_id: int):
	var instance = _bags.get(instance_id)
	if instance == null:
		return null
	if instance.definition_id == MVP4CatalogScript.STARTING_BAG_ID:
		return null
	var active_cells := _active_cells_with_replacement(instance_id, null)
	if not _items_fit_active_cells(active_cells):
		return null
	_bags.erase(instance_id)
	return instance.copy_value()


func get_item(instance_id: int):
	var instance = _items.get(instance_id)
	if instance == null:
		return null
	return instance.copy_value()


func get_bag(instance_id: int):
	var instance = _bags.get(instance_id)
	if instance == null:
		return null
	return instance.copy_value()


func get_active_cells() -> Dictionary:
	return _active_cells_with_replacement(-1, null)


func copy_value():
	var copied = get_script().new()
	copied.next_instance_id = next_instance_id
	for raw_id in _items.keys():
		var instance_id := int(raw_id)
		copied._items[instance_id] = _items[instance_id].copy_value()
	for raw_id in _bags.keys():
		var instance_id := int(raw_id)
		copied._bags[instance_id] = _bags[instance_id].copy_value()
	return copied


func _copy_item_instances() -> Dictionary:
	var copied := {}
	for raw_id in _items.keys():
		var instance_id := int(raw_id)
		copied[instance_id] = _items[instance_id].copy_value()
	return copied


func _copy_bag_instances() -> Dictionary:
	var copied := {}
	for raw_id in _bags.keys():
		var instance_id := int(raw_id)
		copied[instance_id] = _bags[instance_id].copy_value()
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
	for raw_id in _items.keys():
		var instance_id := int(raw_id)
		if instance_id == ignored_instance_id:
			continue
		var instance = _items[instance_id]
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			continue
		for cell in _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin):
			occupied[cell] = instance_id
	return occupied


func _occupied_bag_cells(ignored_instance_id: int = -1) -> Dictionary:
	var occupied := {}
	var definitions: Dictionary = MVP4CatalogScript.build_bags()
	for raw_id in _bags.keys():
		var instance_id := int(raw_id)
		if instance_id == ignored_instance_id:
			continue
		var instance = _bags[instance_id]
		var definition = definitions.get(instance.definition_id)
		if definition == null:
			continue
		for cell in _translated_cells(definition.footprint(instance.rotation_quarters), instance.origin):
			occupied[cell] = instance_id
	return occupied


func _active_cells_with_replacement(replaced_instance_id: int, replacement) -> Dictionary:
	var active := {}
	var definitions: Dictionary = MVP4CatalogScript.build_bags()
	for raw_id in _bags.keys():
		var instance_id := int(raw_id)
		if instance_id == replaced_instance_id:
			continue
		var instance = _bags[instance_id]
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
	for instance in _items.values():
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
