extends CanvasLayer
class_name HUDController

## The HUD is a presentation and intent surface. Combat, route, backpack,
## Fate, economy, and tradition runtime state remain outside this controller.
signal settings_requested
signal resume_requested
signal current_tradition_help_requested
signal restart_requested
signal retry_requested

@onready var combat_top_bar: MarginContainer = $CombatTopBar
@onready var dash_label: Label = $CombatTopBar/Row/DashLabel
@onready var stage_phase_label: Label = $CombatTopBar/Row/StagePhaseLabel
@onready var play_label: Label = $CombatTopBar/Row/PlayLabel
@onready var settings_button: Button = $CombatTopBar/Row/SettingsButton
@onready var settings_panel: Control = $SettingsPanel
@onready var resume_button: Button = $SettingsPanel/Dialog/Margin/Actions/ResumeButton
@onready var tradition_help_button: Button = $SettingsPanel/Dialog/Margin/Actions/TraditionHelpButton
@onready var restart_button: Button = $SettingsPanel/Dialog/Margin/Actions/RestartButton
@onready var touch_controls: Control = $TouchControls
@onready var move_up_button: Button = $TouchControls/MovePad/MoveUpButton
@onready var move_down_button: Button = $TouchControls/MovePad/MoveDownButton
@onready var move_left_button: Button = $TouchControls/MovePad/MoveLeftButton
@onready var move_right_button: Button = $TouchControls/MovePad/MoveRightButton
@onready var dash_button: Button = $TouchControls/DashButton
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_message: Label = $GameOverPanel/Message
@onready var retry_button: Button = $GameOverPanel/RetryButton

var _combat_hud_visible: bool = false
var _touch_available: bool = false
var _stage_phase_requested_visible: bool = false


func _ready() -> void:
	_touch_available = DisplayServer.is_touchscreen_available()
	combat_top_bar.hide()
	stage_phase_label.hide()
	settings_panel.hide()
	touch_controls.hide()
	game_over_panel.hide()

	settings_button.pressed.connect(open_settings)
	resume_button.pressed.connect(_on_resume_pressed)
	tradition_help_button.pressed.connect(_on_tradition_help_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	_connect_touch_button(move_up_button, &"move_up")
	_connect_touch_button(move_down_button, &"move_down")
	_connect_touch_button(move_left_button, &"move_left")
	_connect_touch_button(move_right_button, &"move_right")
	_connect_touch_button(dash_button, &"dash")


func set_dash_state(charges: int, maximum_charges: int) -> void:
	dash_label.text = "DASH %d / %d" % [maxi(charges, 0), maxi(maximum_charges, 1)]


func set_play_time(elapsed_seconds: float) -> void:
	var total_seconds := maxi(floori(elapsed_seconds), 0)
	play_label.text = "PLAY %02d:%02d" % [total_seconds / 60, total_seconds % 60]


func set_stage_phase(stage_text: String, phase_text: String, visible: bool) -> void:
	_stage_phase_requested_visible = visible
	stage_phase_label.visible = visible
	stage_phase_label.text = "%s · %s" % [stage_text, phase_text] if visible else ""


func show_combat_hud(enabled: bool) -> void:
	_combat_hud_visible = enabled
	combat_top_bar.visible = enabled
	touch_controls.visible = enabled and _touch_available
	stage_phase_label.visible = enabled and _stage_phase_requested_visible
	if not enabled:
		close_settings()
		_release_touch_actions()


func combat_persistent_control_names() -> Array[String]:
	return ["DashLabel", "PlayLabel", "SettingsButton"]


func dash_text() -> String:
	return dash_label.text


func play_text() -> String:
	return play_label.text


func open_settings() -> void:
	if settings_panel.visible:
		return
	settings_panel.show()
	resume_button.grab_focus()
	settings_requested.emit()


func close_settings() -> void:
	settings_panel.hide()
	if _combat_hud_visible and settings_button.visible:
		settings_button.grab_focus()


func show_game_over(retry_available: bool = false, ninja_soul_balance: int = 0) -> void:
	close_settings()
	_release_touch_actions()
	game_over_message.text = "GAME OVER"
	if retry_available:
		game_over_message.text += "\n각성 1로 현재 학교 재도전"
	retry_button.visible = retry_available
	retry_button.disabled = not retry_available
	retry_button.text = "재도전 · 각성 1 (보유 %d)" % maxi(ninja_soul_balance, 0)
	game_over_panel.show()
	if retry_available:
		retry_button.grab_focus()


func hide_game_over() -> void:
	game_over_panel.hide()


func _on_resume_pressed() -> void:
	close_settings()
	resume_requested.emit()


func _on_tradition_help_pressed() -> void:
	current_tradition_help_requested.emit()


func _on_restart_pressed() -> void:
	close_settings()
	restart_requested.emit()


func _on_retry_pressed() -> void:
	if retry_button.disabled:
		return
	retry_requested.emit()


func _connect_touch_button(button: Button, action_name: StringName) -> void:
	button.button_down.connect(_press_touch_action.bind(action_name))
	button.button_up.connect(_release_touch_action.bind(action_name))


func _press_touch_action(action_name: StringName) -> void:
	Input.action_press(action_name)


func _release_touch_action(action_name: StringName) -> void:
	Input.action_release(action_name)


func _release_touch_actions() -> void:
	for action_name in [&"move_left", &"move_right", &"move_up", &"move_down", &"dash"]:
		Input.action_release(action_name)


## Historical parser compatibility only. MainController has no live health or
## score HUD consumers; normal combat continues to render only the compact bar.
func set_health(_current: int, _maximum: int) -> void:
	pass


func set_score(_score: int, _kills: int) -> void:
	pass
