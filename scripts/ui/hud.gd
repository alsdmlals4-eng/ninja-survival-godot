extends CanvasLayer
class_name HUDController

## The HUD is a presentation and intent surface. Combat, route, backpack,
## Fate, economy, and tradition runtime state remain outside this controller.
signal settings_requested
signal resume_requested
signal current_tradition_help_requested
signal restart_requested
signal retry_requested
signal ultimate_requested

@onready var combat_top_bar: MarginContainer = $CombatTopBar
@onready var dash_label: Label = $CombatTopBar/Row/DashLabel
@onready var stage_phase_label: Label = $CombatTopBar/Row/StagePhaseLabel
@onready var play_label: Label = $CombatTopBar/Row/PlayLabel
@onready var settings_button: Button = $CombatTopBar/Row/SettingsButton
@onready var ultimate_button: Button = $CombatTopBar/Row/UltimateButton
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
var _ultimate_ready: bool = false
var _ultimate_feedback_remaining: float = 0.0
var _input_help_enabled := true
var _vitals: VBoxContainer
var _health_gauge: ProgressBar
var _ultimate_gauge: ProgressBar
var _ultimate_effect := "유파를 선택하면 해당 오의를 사용할 수 있습니다."

func _make_gauge(node_name: String, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = node_name
	bar.custom_minimum_size = Vector2(244, 26)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_PASS
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.025, 0.035, 0.06, 0.92)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)
	_vitals.add_child(bar)
	var label := Label.new()
	label.name = "Value"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	bar.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return bar

func set_ultimate_resource(_label: String, current: float, maximum: float) -> void:
	_ultimate_gauge.max_value = maxf(maximum, 1.0)
	_ultimate_gauge.value = clampf(current, 0.0, _ultimate_gauge.max_value)
	_ultimate_gauge.get_node("Value").text = "오의 %.1f / %.0f" % [_ultimate_gauge.value, _ultimate_gauge.max_value]

func set_school(school: StringName) -> void:
	_ultimate_effect = {
		&"bongma": "백귀진 · 영력 100 소모\n6초 동안 식신 2기를 추가 소환하고 식신 공격을 가속합니다.",
		&"cheonsul": "오행폭주 · 반응 게이지 충전 후 발동\n바라보는 방향에 속성 브레스를 연속 방출합니다.\n전방 화면 안에 적이 있어야 발동하며 방향은 발동 시 고정됩니다.",
		&"guiin": "귀인화 · 귀혈 충전 후 발동\n6초 동안 검 공격을 강화합니다.\n수리검과 자동 인술은 중단되고, 이동·무적 대시는 사용할 수 있습니다.",
		&"heukyeong": "암영처형 · 처형 게이지 충전 후 발동\n가까운 위험 표적을 우선해 최대 3명에게 연속 피해를 줍니다.\n표식 대상은 추가 피해. 보스 즉사 기술이 아니며 대상이 없으면 소모하지 않습니다.",
	}.get(school, "유파를 선택하면 해당 오의를 사용할 수 있습니다.")
	_refresh_tooltips()

func _refresh_tooltips() -> void:
	var detail := _ultimate_effect + "\nE / 패드 Y / 클릭·터치로 발동. 일반 공격은 자동입니다."
	ultimate_button.tooltip_text = detail
	if is_instance_valid(_ultimate_gauge): _ultimate_gauge.tooltip_text = detail

func set_input_help_enabled(enabled: bool) -> void:
	_input_help_enabled = enabled
	_render_ultimate_ready()


func _ready() -> void:
	_vitals = VBoxContainer.new()
	_vitals.name = "PlayerVitals"
	_vitals.position = Vector2(30, 74)
	_vitals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_vitals)
	_health_gauge = _make_gauge("HealthGauge", Color(0.65, 0.08, 0.12))
	_ultimate_gauge = _make_gauge("UltimateGauge", Color(0.42, 0.30, 0.12))
	set_health(0, 100)
	set_ultimate_resource("", 0, 100)
	_vitals.hide()
	dash_label.mouse_filter = Control.MOUSE_FILTER_PASS
	dash_label.tooltip_text = "무적 대시 · Shift / Space / 패드 A\n이동 방향으로 빠르게 회피합니다. 대시 중 피해를 받지 않습니다.\n최대 2회 충전, 사용한 충전은 시간이 지나면 회복됩니다."
	dash_button.tooltip_text = dash_label.tooltip_text
	var help_theme := Theme.new()
	var help_panel := StyleBoxFlat.new()
	help_panel.bg_color = Color(0.025, 0.035, 0.06, 0.98)
	help_panel.set_content_margin_all(12)
	help_theme.set_stylebox("panel", "TooltipPanel", help_panel)
	for control in [dash_label, dash_button, ultimate_button, _ultimate_gauge]:
		control.theme = help_theme
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
	ultimate_button.pressed.connect(_on_ultimate_pressed)
	set_ultimate_ready(false)
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
	_vitals.visible = enabled
	touch_controls.visible = enabled and _touch_available
	stage_phase_label.visible = enabled and _stage_phase_requested_visible
	if not enabled:
		close_settings()
		_release_touch_actions()


func combat_persistent_control_names() -> Array[String]:
	return ["DashLabel", "PlayLabel", "UltimateButton", "SettingsButton"]


func _process(delta: float) -> void:
	if _ultimate_feedback_remaining <= 0.0:
		return
	_ultimate_feedback_remaining = maxf(_ultimate_feedback_remaining - delta, 0.0)
	if _ultimate_feedback_remaining <= 0.0:
		_render_ultimate_ready()


func set_ultimate_ready(ready: bool) -> void:
	_ultimate_ready = ready
	if _ultimate_feedback_remaining <= 0.0:
		_render_ultimate_ready()


func show_ultimate_feedback(result: StringName) -> void:
	var messages := {
		&"activated": "오의 · 발동",
		&"charging": "오의 · 충전 부족",
		&"no_target": "오의 · 대상 없음",
		&"inactive": "오의 · 사용 불가",
		&"unavailable": "오의 · 지금 사용 불가",
	}
	ultimate_button.text = messages.get(result, "오의 · 지금 사용 불가")
	_ultimate_feedback_remaining = 1.4


func _render_ultimate_ready() -> void:
	ultimate_button.text = ("오의 · 준비" if _ultimate_ready else "오의 · 충전 중") + (" [E/Y]" if _input_help_enabled else "")
	_refresh_tooltips()


func _on_ultimate_pressed() -> void:
	if _combat_hud_visible and not settings_panel.visible and not game_over_panel.visible and not get_tree().paused:
		ultimate_requested.emit()


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


func set_health(current: int, maximum: int) -> void:
	_health_gauge.max_value = maxi(maximum, 1)
	_health_gauge.value = clampi(current, 0, maxi(maximum, 1))
	_health_gauge.get_node("Value").text = "체력 %d / %d" % [int(_health_gauge.value), int(_health_gauge.max_value)]


func set_score(_score: int, _kills: int) -> void:
	pass
