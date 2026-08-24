extends RefCounted
class_name CombinationResolver

const MVP4CatalogScript = preload("res://scripts/data/mvp4_catalog.gd")

enum HintStage {
	UNDISCOVERED,
	INGREDIENT_OWNED,
	READY,
	DISCOVERED,
}

var _pending_result: Dictionary = {}
var _pending_session = null
var _discovered_combinations: Dictionary = {}

var pending_result: Dictionary:
	get:
		return _pending_result.duplicate(true)

var discovered_combinations: Dictionary:
	get:
		return _discovered_combinations.duplicate(true)


func eligible_pairs(state, resolution, combos: Dictionary) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	if state == null or resolution == null or not bool(resolution.valid):
		return results

	var items: Dictionary = state.items
	var adjacency_lookup: Dictionary = {}
	for raw_pair in resolution.adjacency_pairs:
		var pair := Vector2i(raw_pair)
		adjacency_lookup[pair] = true

	var combo_ids: Array = combos.keys()
	combo_ids.sort()
	for raw_combo_id in combo_ids:
		var combo_id := StringName(raw_combo_id)
		var combo = combos.get(combo_id)
		if combo == null:
			continue
		var source_a_ids := _matching_instance_ids(items, combo.source_a)
		var source_b_ids := _matching_instance_ids(items, combo.source_b)
		for source_a_id in source_a_ids:
			for source_b_id in source_b_ids:
				if source_a_id == source_b_id:
					continue
				if combo.source_a == combo.source_b and source_a_id > source_b_id:
					continue
				var pair := Vector2i(mini(source_a_id, source_b_id), maxi(source_a_id, source_b_id))
				if not adjacency_lookup.has(pair):
					continue
				results.append({
					"combo_id": combo_id,
					"source_a_instance": source_a_id,
					"source_b_instance": source_b_id,
					"result_item": StringName(combo.result_item),
				})
	return results


func hint_stage(combo_id: StringName, state, resolution, discovered: Dictionary, combos: Dictionary) -> int:
	var combo = combos.get(combo_id)
	if combo == null:
		return HintStage.UNDISCOVERED
	if bool(discovered.get(combo_id, false)) or _discovered_combinations.has(combo_id):
		return HintStage.DISCOVERED
	if state == null:
		return HintStage.UNDISCOVERED
	for pair in eligible_pairs(state, resolution, {combo_id: combo}):
		if pair.get("combo_id") == combo_id:
			return HintStage.READY
	var items: Dictionary = state.items
	for item in items.values():
		if item != null and (item.definition_id == combo.source_a or item.definition_id == combo.source_b):
			return HintStage.INGREDIENT_OWNED
	return HintStage.UNDISCOVERED


func begin_result_preview(session, combo_id: StringName, source_a_instance: int, source_b_instance: int) -> bool:
	if session == null or not _pending_result.is_empty() or _pending_session != null:
		return false
	if source_a_instance <= 0 or source_b_instance <= 0 or source_a_instance == source_b_instance:
		return false

	var combos: Dictionary = MVP4CatalogScript.build_combinations()
	var combo = combos.get(combo_id)
	if combo == null:
		return false
	var session_state = session.state
	if session_state == null:
		return false
	var first = session_state.get_item(source_a_instance)
	var second = session_state.get_item(source_b_instance)
	if first == null or second == null:
		return false

	var canonical_a_id: int = source_a_instance
	var canonical_b_id: int = source_b_instance
	if first.definition_id == combo.source_a and second.definition_id == combo.source_b:
		pass
	elif first.definition_id == combo.source_b and second.definition_id == combo.source_a:
		canonical_a_id = source_b_instance
		canonical_b_id = source_a_instance
	else:
		return false

	var resolution = session.current_resolution()
	if resolution == null or not bool(resolution.valid):
		return false
	var canonical_pair := Vector2i(mini(canonical_a_id, canonical_b_id), maxi(canonical_a_id, canonical_b_id))
	if not resolution.adjacency_pairs.has(canonical_pair):
		return false
	if not session._begin_combination_transaction():
		return false

	_pending_session = session
	_pending_result = {
		"combo_id": combo_id,
		"source_a_instance": canonical_a_id,
		"source_b_instance": canonical_b_id,
		"result_item": StringName(combo.result_item),
	}
	return true


func commit_result(session, origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if session == null or session != _pending_session or _pending_result.is_empty():
		return false
	var combo_id := StringName(_pending_result.get("combo_id", &""))
	var result_instance_id: int = session._commit_combination_transaction(
		int(_pending_result.get("source_a_instance", 0)),
		int(_pending_result.get("source_b_instance", 0)),
		StringName(_pending_result.get("result_item", &"")),
		origin,
		rotation_quarters
	)
	if result_instance_id <= 0:
		return false
	_discovered_combinations[combo_id] = true
	_pending_result.clear()
	_pending_session = null
	return true


func cancel_result(session) -> void:
	if session == null or session != _pending_session:
		return
	session._cancel_combination_transaction()
	_pending_result.clear()
	_pending_session = null


func _matching_instance_ids(items: Dictionary, definition_id: StringName) -> Array[int]:
	var ids: Array[int] = []
	for raw_instance_id in items.keys():
		var instance_id := int(raw_instance_id)
		var item = items[instance_id]
		if item != null and item.definition_id == definition_id:
			ids.append(instance_id)
	ids.sort()
	return ids
