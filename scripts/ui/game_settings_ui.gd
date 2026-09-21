# Shared title/pause presentation. The controller owns validation and persistence.
extends CanvasLayer

signal apply_requested(values: Dictionary)
signal closed

var volume: HSlider
var effects: HSlider
var shake: CheckButton
var input_help: CheckButton
var fullscreen: CheckButton
var status: Label
var apply_button: Button
var close_button: Button

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.color = Color(0.02, 0.03, 0.05, 0.98)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 32)
	background.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	margin.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	scroll.add_child(column)
	_label(column, "환경 설정 · 적용 전까지 기존 설정을 유지합니다")
	volume = _slider(column, "전체 음량", 0)
	effects = _slider(column, "일본도·인법 효과 농도 (적 전조와 투사체는 유지)", 20)
	shake = _toggle(column, "피격 시 화면 흔들림")
	input_help = _toggle(column, "전투 조작 키 안내 표시")
	fullscreen = _toggle(column, "전체 화면")
	_label(column, "공격 자동 · WASD/방향키/왼쪽 스틱 이동 · Space/패드 아래 버튼 대시 · E/패드 위 버튼 오의\n화면 버튼은 마우스·터치로 누를 수 있습니다. 설정 중에는 전투가 멈춥니다.")
	status = _label(column, "")
	apply_button = _button(column, "적용하고 저장")
	apply_button.pressed.connect(func(): apply_requested.emit({"volume": int(volume.value), "effects": int(effects.value), "shake": shake.button_pressed, "input_help": input_help.button_pressed, "fullscreen": fullscreen.button_pressed}))
	close_button = _button(column, "돌아가기 · 미적용 변경 취소")
	close_button.pressed.connect(_close)
	hide()

func present(values: Dictionary, message := "") -> void:
	volume.value = values.volume
	effects.value = values.effects
	shake.button_pressed = values.shake
	input_help.button_pressed = values.input_help
	fullscreen.button_pressed = values.fullscreen
	status.text = message
	show()
	volume.grab_focus.call_deferred()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel") and not event.is_echo():
		_close()
		get_viewport().set_input_as_handled()

func _close() -> void:
	hide()
	closed.emit()

func _label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	parent.add_child(label)
	return label

func _slider(parent: Node, caption: String, minimum: int) -> HSlider:
	var label := _label(parent, caption)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = 100
	slider.step = 5
	slider.custom_minimum_size.y = 36
	slider.value_changed.connect(func(value): label.text = "%s · %d%%" % [caption, value])
	parent.add_child(slider)
	return slider

func _toggle(parent: Node, text: String) -> CheckButton:
	var toggle := CheckButton.new()
	toggle.text = text
	toggle.custom_minimum_size.y = 44
	parent.add_child(toggle)
	return toggle

func _button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 44
	parent.add_child(button)
	return button
