extends RefCounted
class_name BackpackResolver

const BackpackStateScript = preload("res://scripts/backpack/backpack_state.gd")
const BackpackResolutionScript = preload("res://scripts/backpack/backpack_resolution.gd")
const SpatialRuleDefinitionScript = preload("res://scripts/data/spatial_rule_definition.gd")

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]


func resolve(state, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName):
	if state == null:
		return BackpackResolutionScript.new().fail(&"missing_state")
	return _resolve_views(state.items, state.bags, item_defs, bag_defs, selected_school_id)


func can_place_item(state, candidate, item_defs: Dictionary, bag_defs: Dictionary):
	if state == null:
		return BackpackResolutionScript.new().fail(&"missing_state")
	if candidate == null:
		return BackpackResolutionScript.new().fail(&"missing_candidate")
	var items: Dictionary = state.items
	var bags: Dictionary = state.bags
	var candidate_id: int = int(candidate.instance_id)
	if candidate_id <= 0 or not items.has(candidate_id):
		candidate_id = _preview_id(items)
	items[candidate_id] = candidate.copy_value()
	return _resolve_views(items, bags, item_defs, bag_defs, &"")


func can_place_bag(state, candidate, item_defs: Dictionary, bag_defs: Dictionary):
	if state == null:
		return BackpackResolutionScript.new().fail(&"missing_state")
	if candidate == null:
		return BackpackResolutionScript.new().fail(&"missing_candidate")
	var items: Dictionary = state.items
	var bags: Dictionary = state.bags
	var candidate_id: int = int(candidate.instance_id)
	if candidate_id <= 0 or not bags.has(candidate_id):
		candidate_id = _preview_id(bags)
	bags[candidate_id] = candidate.copy_value()
	return _resolve_views(items, bags, item_defs, bag_defs, &"")


func translated_state(state, delta: Vector2i, item_defs: Dictionary, bag_defs: Dictionary) -> Dictionary:
	if state == null:
		return {
			"valid": false,
			"bags": {},
			"items": {},
			"resolution": BackpackResolutionScript.new().fail(&"missing_state"),
		}

	var original_items: Dictionary = state.items
	var original_bags: Dictionary = state.bags
	var shifted_items := _copy_shifted_instances(original_items, delta)
	var shifted_bags := _copy_shifted_instances(original_bags, delta)
	var resolution = _resolve_views(shifted_items, shifted_bags, item_defs, bag_defs, &"")
	if not resolution.valid:
		return {
			"valid": false,
			"bags": original_bags,
			"items": original_items,
			"resolution": resolution,
		}
	return {
		"valid": true,
		"bags": shifted_bags,
		"items": shifted_items,
		"resolution": resolution,
	}


func _resolve_views(items: Dictionary, bags: Dictionary, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName):
	var resolution = BackpackResolutionScript.new()
	var bag_cells_by_id: Dictionary = {}
	var bag_occupancy: Dictionary = {}

	for bag_id in _sorted_instance_ids(bags):
		var bag = bags[bag_id]
		var definition = bag_defs.get(bag.definition_id)
		if definition == null:
			return resolution.fail(&"unknown_bag_definition")
		var cells: Array[Vector2i] = _translated_cells(definition.footprint(bag.rotation_quarters), bag.origin)
		if cells.is_empty():
			return resolution.fail(&"empty_bag_footprint")
		for cell in cells:
			if not _is_inside_board(cell):
				return resolution.fail(&"bag_out_of_bounds", [cell])
			if bag_occupancy.has(cell):
				return resolution.fail(&"bag_overlap", [cell])
			bag_occupancy[cell] = bag_id
			resolution.active_cells[cell] = true
		bag_cells_by_id[bag_id] = cells

	if resolution.active_cells.is_empty():
		return resolution.fail(&"no_active_cells")

	var disconnected_cells := _disconnected_cells(resolution.active_cells)
	if not disconnected_cells.is_empty():
		return resolution.fail(&"disconnected_active_cells", disconnected_cells)

	var item_occupancy: Dictionary = {}
	for item_id in _sorted_instance_ids(items):
		var item = items[item_id]
		var definition = item_defs.get(item.definition_id)
		if definition == null:
			return resolution.fail(&"unknown_item_definition")
		var cells: Array[Vector2i] = _translated_cells(definition.footprint(item.rotation_quarters), item.origin)
		if cells.is_empty():
			return resolution.fail(&"empty_item_footprint")
		for cell in cells:
			if not _is_inside_board(cell):
				return resolution.fail(&"item_out_of_bounds", [cell])
			if not resolution.active_cells.has(cell):
				return resolution.fail(&"inactive_item_cell", [cell])
			if item_occupancy.has(cell):
				return resolution.fail(&"item_overlap", [cell])
			item_occupancy[cell] = item_id
		resolution.item_cells[item_id] = cells

	resolution.adjacency_pairs = _build_adjacency_pairs(item_occupancy)
	_apply_static_modifiers(resolution, items, item_defs, selected_school_id)
	_apply_spatial_rules(resolution, items, item_defs)
	_apply_special_bags(resolution, items, bags, item_defs, bag_defs, bag_cells_by_id)
	return resolution


func _apply_static_modifiers(resolution, items: Dictionary, item_defs: Dictionary, selected_school_id: StringName) -> void:
	for item_id in _sorted_instance_ids(items):
		var item = items[item_id]
		var definition = item_defs.get(item.definition_id)
		if definition == null:
			continue
		_apply_payload(resolution.modifiers, definition.resolved_static_modifier_payload(), 1)
		if definition.effect_kind == &"school_emblem" and selected_school_id != &"" and definition.school_payload.has(selected_school_id):
			var school_payload: Dictionary = definition.school_payload[selected_school_id]
			var field_name: StringName = StringName(school_payload.get(&"field", &""))
			var amount: float = float(school_payload.get(&"value", 0.0))
			resolution.modifiers.add_delta(field_name, amount)


func _apply_spatial_rules(resolution, items: Dictionary, item_defs: Dictionary) -> void:
	var neighbors_by_id: Dictionary = {}
	for pair in resolution.adjacency_pairs:
		if not neighbors_by_id.has(pair.x):
			neighbors_by_id[pair.x] = []
		if not neighbors_by_id.has(pair.y):
			neighbors_by_id[pair.y] = []
		neighbors_by_id[pair.x].append(pair.y)
		neighbors_by_id[pair.y].append(pair.x)

	for item_id in _sorted_instance_ids(items):
		var item = items[item_id]
		var definition = item_defs.get(item.definition_id)
		if definition == null:
			continue
		var neighbor_ids: Array = neighbors_by_id.get(item_id, [])
		neighbor_ids.sort()
		for rule in definition.spatial_rules:
			var matches: int = 0
			for neighbor_id in neighbor_ids:
				var neighbor = items.get(int(neighbor_id))
				if neighbor == null:
					continue
				var neighbor_definition = item_defs.get(neighbor.definition_id)
				if neighbor_definition != null and _neighbor_matches_rule(neighbor_definition, rule):
					matches += 1
			if matches <= 0:
				continue
			var multiplier: int = 1
			if rule.aggregation == SpatialRuleDefinitionScript.Aggregation.PER_DISTINCT_NEIGHBOR:
				multiplier = mini(matches, maxi(int(rule.max_matches), 1))
			_apply_payload(resolution.modifiers, rule.modifier_payload, multiplier)


func _neighbor_matches_rule(definition, rule) -> bool:
	if rule.required_neighbor_definition_ids.has(definition.id):
		return true
	for required_tag in rule.required_neighbor_tags:
		if definition.tags.has(required_tag):
			return true
	return false


func _apply_special_bags(resolution, items: Dictionary, bags: Dictionary, item_defs: Dictionary, bag_defs: Dictionary, bag_cells_by_id: Dictionary) -> void:
	for bag_id in _sorted_instance_ids(bags):
		var bag = bags[bag_id]
		var bag_definition = bag_defs.get(bag.definition_id)
		if bag_definition == null or bag_definition.affected_item_tag == &"":
			continue
		var bag_cells: Array = bag_cells_by_id.get(bag_id, [])
		for item_id in _sorted_instance_ids(items):
			var item = items[item_id]
			var item_definition = item_defs.get(item.definition_id)
			if item_definition == null or not item_definition.tags.has(bag_definition.affected_item_tag):
				continue
			var item_cells: Array = resolution.item_cells.get(item_id, [])
			if not _cells_overlap(item_cells, bag_cells):
				continue
			if not resolution.special_bag_hits.has(item_id):
				resolution.special_bag_hits[item_id] = []
			resolution.special_bag_hits[item_id].append(bag_id)
			if bag_definition.auxiliary_effect_kind != &"":
				resolution.modifiers.add_delta(bag_definition.auxiliary_effect_kind, float(bag_definition.auxiliary_effect_value))


func _apply_payload(modifiers, payload: Dictionary, multiplier: int) -> void:
	var field_names: Array = payload.keys()
	field_names.sort()
	for raw_field_name in field_names:
		var field_name: StringName = StringName(raw_field_name)
		var amount: float = float(payload[raw_field_name]) * float(multiplier)
		modifiers.add_delta(field_name, amount)


func _build_adjacency_pairs(item_occupancy: Dictionary) -> Array[Vector2i]:
	var seen: Dictionary = {}
	var pairs: Array[Vector2i] = []
	var occupied_cells := _sorted_cells(item_occupancy.keys())
	for cell in occupied_cells:
		var first_id: int = int(item_occupancy[cell])
		for offset in NEIGHBOR_OFFSETS:
			var neighbor_cell := cell + offset
			if not item_occupancy.has(neighbor_cell):
				continue
			var second_id: int = int(item_occupancy[neighbor_cell])
			if first_id == second_id:
				continue
			var pair := Vector2i(mini(first_id, second_id), maxi(first_id, second_id))
			if seen.has(pair):
				continue
			seen[pair] = true
			pairs.append(pair)
	pairs.sort_custom(_pair_less)
	return pairs


func _disconnected_cells(active_cells: Dictionary) -> Array[Vector2i]:
	var all_cells := _sorted_cells(active_cells.keys())
	if all_cells.is_empty():
		return []
	var visited: Dictionary = {all_cells[0]: true}
	var queue: Array[Vector2i] = [all_cells[0]]
	var index: int = 0
	while index < queue.size():
		var cell: Vector2i = queue[index]
		index += 1
		for offset in NEIGHBOR_OFFSETS:
			var neighbor := cell + offset
			if active_cells.has(neighbor) and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	if visited.size() == active_cells.size():
		return []
	var disconnected: Array[Vector2i] = []
	for cell in all_cells:
		if not visited.has(cell):
			disconnected.append(cell)
	return disconnected


func _cells_overlap(first: Array, second: Array) -> bool:
	var second_lookup: Dictionary = {}
	for cell in second:
		second_lookup[Vector2i(cell)] = true
	for cell in first:
		if second_lookup.has(Vector2i(cell)):
			return true
	return false


func _translated_cells(local_cells: Array[Vector2i], origin: Vector2i) -> Array[Vector2i]:
	var translated: Array[Vector2i] = []
	for local_cell in local_cells:
		translated.append(origin + local_cell)
	return translated


func _copy_shifted_instances(instances: Dictionary, delta: Vector2i) -> Dictionary:
	var shifted: Dictionary = {}
	for instance_id in _sorted_instance_ids(instances):
		var copied = instances[instance_id].copy_value()
		copied.origin += delta
		shifted[instance_id] = copied
	return shifted


func _preview_id(instances: Dictionary) -> int:
	var candidate_id: int = -1
	while instances.has(candidate_id):
		candidate_id -= 1
	return candidate_id


func _sorted_instance_ids(instances: Dictionary) -> Array[int]:
	var ids: Array[int] = []
	for raw_id in instances.keys():
		ids.append(int(raw_id))
	ids.sort()
	return ids


func _sorted_cells(raw_cells: Array) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for raw_cell in raw_cells:
		cells.append(Vector2i(raw_cell))
	cells.sort_custom(_cell_less)
	return cells


func _pair_less(first: Vector2i, second: Vector2i) -> bool:
	if first.x != second.x:
		return first.x < second.x
	return first.y < second.y


func _cell_less(first: Vector2i, second: Vector2i) -> bool:
	if first.y != second.y:
		return first.y < second.y
	return first.x < second.x


func _is_inside_board(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < BackpackStateScript.BOARD_SIZE.x and cell.y < BackpackStateScript.BOARD_SIZE.y
