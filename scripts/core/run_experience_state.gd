extends RefCounted

const CATALOG = preload("res://scripts/data/ninjutsu_catalog.gd")
const MAX_RANK := 5
var _xp := 0
var _spent := 0
var _ranks: Dictionary = {}
var _learned: Array = []

func level() -> int:
	# Sum of costs 12,18,24,... before level L: 3*(L-1)*(L+2).
	return maxi(int(floor((-3.0 + sqrt(9.0 + 4.0 * float(_xp) / 3.0)) / 2.0)) + 1, 1)

func progress() -> int:
	var steps := level() - 1
	return _xp - 3 * steps * (steps + 3)

func required() -> int:
	return 12 + 6 * (level() - 1)

func pending_choices() -> int:
	return level() - 1 - _spent

func grant(amount: int) -> void:
	if amount > 0: _xp = mini(_xp + amount, 10000000)

func rank(id: StringName) -> int:
	return int(_ranks.get(str(id), 1))

func upgrade(id: StringName) -> bool:
	if pending_choices() <= 0 or CATALOG.definition_for_id(id) == null or rank(id) >= MAX_RANK: return false
	_ranks[str(id)] = rank(id) + 1
	_spent += 1
	return true

func learn(id: StringName) -> bool:
	if pending_choices() <= 0 or CATALOG.definition_for_id(id) == null or _learned.has(str(id)): return false
	_learned.append(str(id))
	_spent += 1
	return true

func recover() -> bool:
	if pending_choices() <= 0: return false
	_spent += 1
	return true

func snapshot() -> Dictionary:
	return {"xp": _xp, "spent": _spent, "ranks": _ranks.duplicate(true), "learned": _learned.duplicate()}

func restore(raw) -> bool:
	if not (raw is Dictionary) or raw.size() != 4: return false
	for key in ["xp", "spent"]:
		var value = raw.get(key)
		if not (value is int or value is float) or not is_finite(value) or value < 0 or value > 10000000 or floor(value) != value: return false
	if not (raw.get("ranks") is Dictionary) or not (raw.get("learned") is Array): return false
	var earned := maxi(int(floor((-3.0 + sqrt(9.0 + 4.0 * float(raw.xp) / 3.0)) / 2.0)), 0)
	if raw.spent > earned: return false
	var cost: int = raw.learned.size()
	var seen := {}
	for id in raw.learned:
		if not (id is String) or CATALOG.definition_for_id(StringName(id)) == null or seen.has(id): return false
		seen[id] = true
	for id in raw.ranks:
		if not (id is String) or CATALOG.definition_for_id(StringName(id)) == null: return false
		var value = raw.ranks[id]
		if not (value is int or value is float) or not is_finite(value) or floor(value) != value or value < 2 or value > MAX_RANK: return false
		cost += int(value) - 1
	if cost > int(raw.spent): return false
	_xp = int(raw.xp)
	_spent = int(raw.spent)
	_ranks = raw.ranks.duplicate(true)
	_learned = raw.learned.duplicate()
	return true

func scaled_config(id: StringName, source: Dictionary) -> Dictionary:
	var result := source.duplicate(true)
	var extra := rank(id) - 1
	for key in ["damage", "burn_damage", "poison_damage", "shield"]:
		if result.has(key): result[key] = float(result[key]) * (1.0 + 0.15 * extra)
	if result.has("cooldown"): result.cooldown = float(result.cooldown) * (1.0 - 0.04 * extra)
	for key in ["damage_reduction", "move_speed_bonus"]:
		if result.has(key): result[key] = minf(float(result[key]) * (1.0 + 0.15 * extra), 0.75)
	return result

static func valid_battle_progress(checkpoint: Dictionary, progress_data) -> bool:
	if not (progress_data is Dictionary) or progress_data.size() != 3: return false
	# Persisted JSON uses float/String while live owners use int/StringName.
	# Normalize both through the existing strict primitive gate before equality.
	var codec = load("res://scripts/core/run_resume_codec.gd").new()
	var primitive: Dictionary = codec._to_json_primitive(progress_data)
	if not primitive.ok: return false
	progress_data = JSON.parse_string(JSON.stringify(primitive.value))
	if not (progress_data.get("backpack") is Dictionary) or not (progress_data.get("loadout") is Dictionary): return false
	var previous = new()
	if not previous.restore(checkpoint.get("growth", previous.snapshot())): return false
	var next = new()
	if not next.restore(progress_data.get("growth")): return false
	if next._xp < previous._xp or next._spent < previous._spent: return false
	for id in previous._learned:
		if not next._learned.has(id): return false
	for id in previous._ranks:
		if next.rank(StringName(id)) < previous.rank(StringName(id)): return false
	var bundle := {"backpack": progress_data.backpack, "loadout": progress_data.loadout,
		"buffer": checkpoint.buffer, "access": checkpoint.access, "equipment": checkpoint.build.equipment}
	if not load("res://scripts/core/rest_commit_coordinator.gd").validate_selected_build_bundle(bundle): return false
	if progress_data.loadout.draft_picks != checkpoint.loadout.draft_picks: return false
	if progress_data.backpack.bags != checkpoint.backpack.bags: return false
	var originals := {}
	for item in checkpoint.backpack.items: originals[int(item.instance_id)] = item
	var added: Array = []
	var existing_found := 0
	for item in progress_data.backpack.items:
		if originals.has(int(item.instance_id)):
			if item != originals[int(item.instance_id)]: return false
			existing_found += 1
		else:
			var spell := str(load("res://scripts/data/ninjutsu_book_catalog.gd").spell_id(StringName(item.definition_id)))
			if not next._learned.has(spell) or previous._learned.has(spell) or added.has(spell): return false
			added.append(spell)
	if existing_found != originals.size(): return false
	for id in next._learned:
		if not previous._learned.has(id) and not added.has(id): return false
	var owned: Array = []
	for item in progress_data.backpack.items + checkpoint.buffer:
		owned.append(str(load("res://scripts/data/ninjutsu_book_catalog.gd").spell_id(StringName(item.definition_id))))
	for id in next._ranks:
		if next.rank(StringName(id)) > previous.rank(StringName(id)) and not owned.has(id): return false
	return true
