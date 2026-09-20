# Main-owned local presentation preferences. Never reads/writes run progress.
extends Node

const DEFAULTS := {"volume": 100, "effects": 100, "shake": false, "input_help": true, "fullscreen": false}
static var _host_owner: WeakRef
var values: Dictionary = DEFAULTS.duplicate(true)
var storage_path := ""
var ui
var _main
var _return_focus: Control
var _shake_remaining := 0.0
var _load_message := ""

func configure(main, path: String) -> void:
	_main = main
	storage_path = path
	ui = preload("res://scripts/ui/game_settings_ui.gd").new()
	add_child(ui)
	ui.apply_requested.connect(_apply_requested)
	ui.closed.connect(_restore_focus)
	main.title_screen.preferences_requested.connect(open.bind(main.title_screen.settings_button))
	var button := Button.new()
	button.name = "PreferencesButton"
	button.text = "음량·효과·화면 설정"
	button.custom_minimum_size.y = 44
	var actions = main.hud.resume_button.get_parent()
	actions.add_child(button)
	actions.move_child(button, 1)
	button.pressed.connect(open.bind(button))
	main.player.damage_resolved.connect(on_damage_resolved)
	get_tree().node_added.connect(_apply_effect)
	if FileAccess.file_exists(storage_path):
		var config := ConfigFile.new()
		if config.load(storage_path) == OK:
			var loaded: Dictionary = {}
			for key in DEFAULTS: loaded[key] = config.get_value("presentation", key, DEFAULTS[key])
			if _valid(loaded): values = loaded
			else: _load_message = "저장된 설정이 올바르지 않아 기본값을 사용합니다. 적용 전에는 원본을 바꾸지 않습니다."
		else: _load_message = "설정을 읽지 못해 기본값을 사용합니다. 적용 전에는 원본을 바꾸지 않습니다."
	_publish()

func open(return_focus: Control) -> void:
	_return_focus = return_focus
	ui.present(values, _load_message)

func _restore_focus() -> void:
	if is_instance_valid(_return_focus) and _return_focus.is_visible_in_tree(): _return_focus.grab_focus.call_deferred()

func _valid(candidate: Dictionary) -> bool:
	if candidate.size() != DEFAULTS.size(): return false
	for key in DEFAULTS:
		if not candidate.has(key) or typeof(candidate[key]) != typeof(DEFAULTS[key]): return false
	return candidate.volume >= 0 and candidate.volume <= 100 and candidate.effects >= 20 and candidate.effects <= 100

func commit(candidate: Dictionary) -> Dictionary:
	if not _valid(candidate): return {"ok": false, "reason": "invalid_values"}
	var config := ConfigFile.new()
	for key in DEFAULTS: config.set_value("presentation", key, candidate[key])
	var temporary := storage_path + ".pending"
	if config.save(temporary) != OK: return {"ok": false, "reason": "write_failed"}
	var readback := ConfigFile.new()
	if readback.load(temporary) != OK: return {"ok": false, "reason": "readback_failed"}
	for key in DEFAULTS:
		if readback.get_value("presentation", key) != candidate[key]: return {"ok": false, "reason": "readback_mismatch"}
	# Preserve unreadable settings only when the user explicitly replaces them.
	if not _load_message.is_empty() and FileAccess.file_exists(storage_path):
		if DirAccess.copy_absolute(storage_path, storage_path + ".preserved_%d" % Time.get_ticks_usec()) != OK:
			return {"ok": false, "reason": "preserve_failed"}
	if DirAccess.rename_absolute(temporary, storage_path) != OK: return {"ok": false, "reason": "publish_failed"}
	values = candidate.duplicate(true)
	_load_message = ""
	_publish()
	return {"ok": true}

func _apply_requested(candidate: Dictionary) -> void:
	var result := commit(candidate)
	ui.status.text = "저장했습니다. 다음 실행에도 유지됩니다." if result.ok else "설정을 저장하지 못했습니다. 기존 설정을 유지합니다. (%s)" % result.reason

func _publish() -> void:
	_main.hud.set_input_help_enabled(values.input_help)
	# One active Main owns host-wide presentation. Auxiliary/isolated scenes do not.
	var owner = _host_owner.get_ref() if _host_owner != null else null
	if not is_instance_valid(owner) or not owner.is_inside_tree() or owner.is_queued_for_deletion():
		_host_owner = weakref(self)
		owner = self
	if owner == self:
		AudioServer.set_bus_volume_linear(0, float(values.volume) / 100.0)
		if DisplayServer.get_name() != "headless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	for effect in get_tree().get_nodes_in_group("player_cosmetic_effect"): _apply_effect(effect)
	if not values.shake:
		_shake_remaining = 0.0
		_main.player.get_node("Camera2D").offset = Vector2.ZERO

func _apply_effect(node: Node) -> void:
	if is_instance_valid(_main) and _main.is_ancestor_of(node) and node is CanvasItem and node.is_in_group("player_cosmetic_effect"):
		node.self_modulate.a = float(values.effects) / 100.0

func on_damage_resolved(_requested: int, resolved: int, _prevented: int, evaded: bool) -> void:
	if values.shake and resolved > 0 and not evaded: _shake_remaining = 0.16

func _process(delta: float) -> void:
	if not is_instance_valid(_main): return
	if not _main._combat_enabled or _main.game_over: _shake_remaining = 0.0
	advance_shake(delta)

func advance_shake(delta: float) -> void:
	_shake_remaining = maxf(_shake_remaining - delta, 0.0)
	var amplitude := 3.0 * _shake_remaining / 0.16 if values.shake else 0.0
	_main.player.get_node("Camera2D").offset = Vector2(sin(_shake_remaining * 160.0), cos(_shake_remaining * 190.0)) * amplitude
