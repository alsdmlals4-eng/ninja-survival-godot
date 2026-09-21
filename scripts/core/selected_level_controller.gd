extends Node

const GROWTH = preload("res://scripts/core/run_experience_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const CATALOG = preload("res://scripts/data/ninjutsu_catalog.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const ICONS = preload("res://scripts/ui/inventory_icon_catalog.gd")
var growth = GROWTH.new()
var options: Array = []
var _main
var _checkpoint: Dictionary
var _bag
var _panel: CanvasLayer
var _choice_buttons: Array[Button] = []
var _arming := false

func configure(main, checkpoint: Dictionary) -> void:
	_main = main
	_checkpoint = checkpoint.duplicate(true)
	growth = GROWTH.new()
	growth.restore(checkpoint.get("growth", growth.snapshot()))
	_bag = BAG.from_persistent_snapshot(checkpoint.backpack)
	_main.ninjutsu_auto_controller.apply_growth(growth.snapshot())
	_refresh_hud()

func grant_kill(role: StringName) -> void:
	growth.grant(20 if role == &"boss" else (8 if role == &"elite" else 1))
	_refresh_hud()

func _refresh_hud() -> void:
	_main.hud.set_experience(growth.level(), growth.progress(), growth.required())

func capture() -> Dictionary:
	return {"growth": growth.snapshot(), "backpack": _bag.to_persistent_snapshot(),
		"loadout": _main.ninjutsu_loadout.get_snapshot()}

func poll() -> void:
	if is_instance_valid(_panel) or growth.pending_choices() <= 0 or get_tree().paused \
		or not _main._combat_enabled or _main.game_over: return
	options = _offer()
	_show_choices()

func _placement(id: StringName):
	var trial = BAG.from_persistent_snapshot(_bag.to_persistent_snapshot())
	for rotation in [0, 1]:
		for y in range(6):
			for x in range(6):
				if trial.add_item(BOOKS.book_id(id), Vector2i(x, y), rotation) != 0: return trial
	return null

func _offer() -> Array:
	var active: Array = _main.ninjutsu_loadout.active_spell_ids()
	var owned: Array = active.duplicate()
	for raw in _checkpoint.buffer:
		var id := BOOKS.spell_id(StringName(raw.definition_id))
		if id != &"": owned.append(id)
	var upgrades: Array = []
	for id in active:
		if growth.rank(id) < GROWTH.MAX_RANK: upgrades.append({"kind": "upgrade", "id": str(id)})
	var acquisitions: Array = []
	var origin := StringName(_checkpoint.loadout.origin_school_id)
	var foreign := 0
	for id in active:
		if CATALOG.definition_for_id(id).school_id != origin: foreign += 1
	if active.size() < 4:
		for definition in CATALOG.build_definitions().values():
			var id: StringName = definition.ninjutsu_id
			if owned.has(id) or growth.snapshot().learned.has(str(id)): continue
			if not _checkpoint.access.unlocked_ninjutsu_school_ids.has(definition.school_id): continue
			if foreign > 0 and definition.school_id != origin: continue
			if _placement(id) != null: acquisitions.append({"kind": "acquire", "id": str(id)})
	var rng := RandomNumberGenerator.new()
	rng.seed = int(growth.snapshot().xp) * 31 + int(growth.snapshot().spent)
	var result: Array = []
	if not acquisitions.is_empty(): result.append(acquisitions.pop_at(rng.randi_range(0, acquisitions.size() - 1)))
	while result.size() < 3 and not upgrades.is_empty():
		result.append(upgrades.pop_at(rng.randi_range(0, upgrades.size() - 1)))
	while result.size() < 3 and not acquisitions.is_empty():
		result.append(acquisitions.pop_at(rng.randi_range(0, acquisitions.size() - 1)))
	if result.size() < 3: result.append({"kind": "recover", "id": ""})
	return result

func choose(option: Dictionary) -> bool:
	if not options.has(option) or growth.pending_choices() <= 0: return false
	var id := StringName(option.id)
	if option.kind == "upgrade":
		if not _main.ninjutsu_loadout.active_spell_ids().has(id) or not growth.upgrade(id): return false
	elif option.kind == "acquire":
		var trial = _placement(id)
		if trial == null: return false
		var active: Array = _main.ninjutsu_loadout.active_spell_ids()
		active.append(id)
		var loadout: Dictionary = _main.ninjutsu_loadout.get_snapshot()
		loadout.active_spell_ids = active
		if not _main.ninjutsu_loadout.can_restore_selected_snapshot(loadout, active, _checkpoint.access.unlocked_ninjutsu_school_ids): return false
		if not growth.learn(id): return false
		_bag = trial
		_main.ninjutsu_loadout.restore_selected_snapshot(loadout, active, _checkpoint.access.unlocked_ninjutsu_school_ids)
		var resolution = RESOLVER.new().resolve(_bag, ITEMS.build_items(), BAGS.build_bags(), StringName(_checkpoint.loadout.origin_school_id))
		_main.run_build_state.set_committed_backpack_modifiers(resolution.modifiers)
		_main.basic_weapons.apply_committed_backpack(_bag)
		_main._sync_run_modifiers()
	else:
		if not growth.recover(): return false
		# Player.heal intentionally rejects paused gameplay; resolve the reward
		# as a bounded health update while the modal owns this paused transaction.
		_main.player.health = mini(_main.player.health + 10, _main.player.max_health)
		_main.player.health_changed.emit(_main.player.health, _main.player.max_health)
	_main.ninjutsu_auto_controller.apply_growth(growth.snapshot())
	_refresh_hud()
	options.clear()
	if is_instance_valid(_panel):
		_panel.hide()
		_panel.queue_free()
	_panel = null
	_arming = false
	_main.selected_run.resume_after_menu_release()
	return true

func _show_choices() -> void:
	_panel = CanvasLayer.new()
	_panel.layer = 30
	_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_panel)
	var background := ColorRect.new()
	background.color = Color(0.02, 0.025, 0.04, 0.94)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)
	var title := Label.new()
	title.text = "레벨 상승 · Lv.%d\n인술 획득 / 강화 중 하나를 선택하세요" % growth.level()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_choice_buttons.clear()
	for option in options:
		var button := Button.new()
		button.custom_minimum_size = Vector2(570, 90)
		button.disabled = true
		if option.kind == "recover":
			button.text = "숨 고르기 · 체력 10 회복\n선택 가능한 강화가 적거나 가방이 가득 찼을 때"
		else:
			var id := StringName(option.id)
			var definition = CATALOG.definition_for_id(id)
			button.icon = ICONS.icon(_main.inventory_icon_atlas, id)
			button.add_theme_constant_override("icon_max_width", 52)
			if option.kind == "upgrade":
				button.text = "%s · %d → %d단계\n%s" % [definition.display_name, growth.rank(id), growth.rank(id) + 1, _upgrade_summary(id, definition.effect_config)]
			else:
				button.text = "%s · 새 인술\n가방 빈 공간 1×2에 자동 배치 · 배치 후 자동 사용" % definition.display_name
			button.tooltip_text = CodexPresentation.new()._selected_effect_detail(growth.scaled_config(id, definition.effect_config))
		button.pressed.connect(func(): choose(option))
		column.add_child(button)
		_choice_buttons.append(button)
	_arming = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _upgrade_summary(id: StringName, config: Dictionary) -> String:
	var preview = GROWTH.new()
	preview.restore(growth.snapshot())
	preview.upgrade(id)
	var before: Dictionary = growth.scaled_config(id, config)
	var after: Dictionary = preview.scaled_config(id, config)
	var parts: Array[String] = []
	for key in ["damage", "burn_damage", "poison_damage", "shield", "damage_reduction", "move_speed_bonus", "cooldown"]:
		if not before.has(key) or before[key] == after[key]: continue
		var names := {"damage": "피해", "burn_damage": "화상", "poison_damage": "독", "shield": "보호막", "damage_reduction": "피해 감소", "move_speed_bonus": "이동 속도", "cooldown": "주기"}
		var percent: bool = key in ["damage_reduction", "move_speed_bonus"]
		var factor := 100.0 if percent else 1.0
		parts.append("%s %.2f → %.2f%s" % [names[key], float(before[key]) * factor, float(after[key]) * factor, "%" if percent else ("초" if key == "cooldown" else "")])
	return " · ".join(parts)

func _process(_delta: float) -> void:
	if not _arming or not is_instance_valid(_panel): return
	if Input.is_action_pressed(&"ui_accept") or Input.is_action_pressed(&"dash") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	_arming = false
	for button in _choice_buttons: button.disabled = false
	_choice_buttons[0].grab_focus()
