# Ownership-only bridge for a legal spatial draft. Geometry stays in RestBackpackSession.
extends RefCounted

static func same_owned_inventory(before: Dictionary, after: Dictionary) -> bool:
	if not primitive(after) or after.size() != 4 or not (after.get("backpack") is Dictionary) \
		or not (after.get("buffer") is Array) or not after.has("pending_bag") \
		or after.get("preserve_buffer") != before.preserve_buffer: return false
	var bag: Dictionary = after.backpack
	if bag.size() != 4 or not integer(bag.get("next_instance_id")) \
		or not (bag.get("items") is Array) or not (bag.get("bags") is Array): return false
	for records in [bag.items, bag.bags, after.buffer]:
		for record in records:
			if not (record is Dictionary): return false
			for key in ["instance_id", "rotation_quarters", "origin_x", "origin_y"]:
				if record.has(key) and not integer(record[key]): return false
	if inventory(before.backpack.items + before.buffer) != inventory(bag.items + after.buffer): return false
	var expected_bags: Array = before.backpack.bags.duplicate(true)
	var expected_next := int(before.backpack.next_instance_id)
	if before.pending_bag != null and after.pending_bag == null:
		var acquired: Dictionary = before.pending_bag.duplicate(true)
		if int(acquired.instance_id) == 0:
			acquired.instance_id = expected_next
			expected_next += 1
		expected_bags.append(acquired)
	elif before.pending_bag != after.pending_bag:
		return false
	return bag.next_instance_id == expected_next and inventory(expected_bags) == inventory(bag.bags)

static func inventory(records: Array) -> Dictionary:
	var result := {}
	for record in records:
		if not (record is Dictionary) or not integer(record.get("instance_id")) \
			or not (record.get("definition_id") is String or record.get("definition_id") is StringName): return {"invalid": true}
		var id := int(record.instance_id)
		if result.has(id): return {"duplicate": true}
		result[id] = str(record.definition_id)
	return result

static func integer(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) \
		and float(value) == floor(float(value)) and absf(float(value)) <= 9007199254740991

static func primitive(value, depth := 0) -> bool:
	if depth > 16: return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME: return true
		TYPE_INT, TYPE_FLOAT: return is_finite(float(value)) and absf(float(value)) <= 9007199254740991
		TYPE_ARRAY:
			for child in value:
				if not primitive(child, depth + 1): return false
			return true
		TYPE_DICTIONARY:
			for key in value:
				if not (key is String or key is StringName) or not primitive(value[key], depth + 1): return false
			return true
	return false
