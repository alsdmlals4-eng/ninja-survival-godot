extends Node

const LOADOUT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const BACKPACK = preload("res://scripts/backpack/backpack_state.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const EQUIPMENT = preload("res://scripts/core/equipment_loadout_state.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const LEGACY = preload("res://scripts/data/mvp4_catalog.gd")

var _loadout: Node
var _backpack
var _equipment
var _school: StringName = &""
var _seed: int = 0
var _committed: Dictionary = {}


func begin(school_id: StringName, seed_value: int) -> bool:
	if _loadout != null or not _committed.is_empty():
		return false
	var candidate = LOADOUT.new()
	if not candidate.begin_start_draft(school_id, seed_value):
		candidate.free()
		return false
	_loadout = candidate
	add_child(_loadout)
	_school = school_id
	_seed = seed_value
	_backpack = BACKPACK.new().create_selectable_starting_state()
	_equipment = EQUIPMENT.new()
	return true


func choose(spell_id: StringName) -> bool:
	if not _editable() or not _loadout.choose_start_draft(spell_id):
		return false
	var draft: Dictionary = _loadout.start_draft_snapshot()
	if draft.complete:
		var candidate = BACKPACK.new().create_selectable_starting_state()
		for index in range(2):
			if candidate.add_item(BOOKS.book_id(draft.picks[index], true), Vector2i(1 + index, 1)) == 0:
				return false
		_backpack = candidate
	return true


func move_book(instance_id: int, origin: Vector2i) -> bool:
	return _editable() and _backpack.move_item(instance_id, origin)


func rotate_book(instance_id: int) -> bool:
	return _editable() and _backpack.rotate_item(instance_id)


func restart_choices() -> bool:
	if not _editable():
		return false
	var school := _school
	var seed_value := _seed
	cancel()
	return begin(school, seed_value)


func cancel() -> bool:
	if not _editable():
		return false
	remove_child(_loadout)
	_loadout.free()
	_loadout = null
	_backpack = null
	_equipment = null
	_school = &""
	return true


func confirm() -> bool:
	if not _editable() or not _loadout.start_draft_snapshot().complete:
		return false
	var resolution = RESOLVER.new().resolve(_backpack, BOOKS.build_items(), LEGACY.build_bags(), _school)
	if not resolution.valid:
		return false
	var placed: Array = []
	for item in _backpack.items.values():
		var spell := BOOKS.spell_id(item.definition_id)
		if spell == &"":
			return false
		placed.append(spell)
	if not _loadout.commit_drafted_start(placed):
		return false
	_committed = {"backpack": _backpack.to_persistent_snapshot(), "loadout": _loadout.get_snapshot(), "equipment": _equipment.get_snapshot()}
	return true


func snapshot() -> Dictionary:
	if _loadout == null:
		return {}
	return {"draft": _loadout.start_draft_snapshot(), "backpack": _backpack.to_persistent_snapshot(), "equipment": _equipment.get_snapshot(), "active_spell_ids": _loadout.active_spell_ids(), "confirmed": not _committed.is_empty()}


func committed_snapshot() -> Dictionary:
	return _committed.duplicate(true)


func _editable() -> bool:
	return _loadout != null and _committed.is_empty()
