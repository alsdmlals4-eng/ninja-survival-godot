extends Node

const LOADOUT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const BACKPACK = preload("res://scripts/backpack/backpack_state.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const EQUIPMENT = preload("res://scripts/core/equipment_loadout_state.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const LEGACY = preload("res://scripts/data/mvp4_catalog.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")

var _loadout: Node
var _backpack
var _equipment
var _school: StringName = &""
var _seed: int = 0
var _committed: Dictionary = {}
var _support_enabled := false
var _support_id: StringName = &""


func begin(school_id: StringName, seed_value: int, support_enabled := false) -> bool:
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
	_support_enabled = support_enabled
	_support_id = &""
	_backpack = BACKPACK.new().create_selectable_starting_state()
	_equipment = EQUIPMENT.new()
	return true

func choose_support(id: StringName) -> bool:
	if not _editable() or not _support_enabled or not ITEMS.START_SUPPORT_IDS.has(id) or not _loadout.start_draft_snapshot().complete:
		return false
	var candidate = _backpack.copy_value()
	for item in candidate.items.values():
		if str(item.definition_id).begins_with("start_support:"): candidate.remove_item(item.instance_id)
	var definition_id := StringName("start_support:" + str(id))
	for y in range(1, 4):
		for x in range(1, 4):
			for rotation in range(2):
				if candidate.add_item(definition_id, Vector2i(x, y), rotation) > 0:
					_backpack = candidate
					_support_id = id
					return true
	return false


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
	var support_enabled := _support_enabled
	cancel()
	return begin(school, seed_value, support_enabled)


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
	if _support_enabled and _support_id == &"": return false
	var resolution = RESOLVER.new().resolve(_backpack, ITEMS.build_items(), LEGACY.build_bags(), _school)
	if not resolution.valid:
		return false
	var placed: Array = []
	for item in _backpack.items.values():
		var spell := BOOKS.spell_id(item.definition_id)
		if spell != &"": placed.append(spell)
	if not _loadout.commit_drafted_start(placed):
		return false
	var access = ACCESS.new()
	access.initialize_selected(_school)
	var bundle := {"backpack": _backpack.to_persistent_snapshot(), "loadout": _loadout.get_snapshot(), "equipment": _equipment.get_snapshot(), "access": access.get_snapshot()}
	if not COORDINATOR.validate_selected_build_bundle(bundle):
		return false
	_committed = bundle
	return true


func snapshot() -> Dictionary:
	if _loadout == null:
		return {}
	return {"draft": _loadout.start_draft_snapshot(), "backpack": _backpack.to_persistent_snapshot(), "equipment": _equipment.get_snapshot(), "active_spell_ids": _loadout.active_spell_ids(), "confirmed": not _committed.is_empty(), "support_enabled": _support_enabled, "support_id": _support_id}


func committed_snapshot() -> Dictionary:
	return _committed.duplicate(true)


func _editable() -> bool:
	return _loadout != null and _committed.is_empty()
