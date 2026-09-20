extends RefCounted
## One Main-owned concurrency budget, not a second wave or damage authority.
var _capacity := 1
var _owners: Dictionary = {}

func set_capacity(value: int) -> bool:
	if value < 1 or value > 2: return false
	_capacity = value
	return true

func try_reserve(owner: Node) -> bool:
	if not is_instance_valid(owner) or not owner.is_inside_tree() or owner.is_queued_for_deletion(): return false
	var count := active_count()
	var id := owner.get_instance_id()
	if _owners.has(id) or count >= _capacity: return false
	_owners[id] = weakref(owner)
	return true

func release(owner: Node) -> void:
	if is_instance_valid(owner): _owners.erase(owner.get_instance_id())

func active_count() -> int:
	for id in _owners.keys():
		var owner = _owners[id].get_ref()
		if not is_instance_valid(owner) or not owner.is_inside_tree() or owner.is_queued_for_deletion():
			_owners.erase(id)
	return _owners.size()
