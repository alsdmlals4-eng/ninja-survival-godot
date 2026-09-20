# Presentation only. The existing profile store owns compare-by-hash publication.
extends CanvasLayer

signal recovery_confirmed(role: String, inventory: Dictionary)
signal closed

var choice_buttons: Array[Button] = []
var confirm_button: Button
var cancel_button: Button
var status_label: Label
var _choices: VBoxContainer
var _inventory: Dictionary = {}
var _role := ""

func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.color = Color(0.02, 0.03, 0.05, 0.98)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 36)
	background.add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	margin.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 18)
	scroll.add_child(column)
	_label(column, "저장 복구 · 사용할 기록을 직접 선택하세요", 28)
	_label(column, "임시 기록은 확정 저장이 아닙니다. 가장 큰 번호를 자동으로 고르지 않습니다. 선택한 기록으로 돌아가면 이후 진행이 달라질 수 있습니다. 기존 원본은 복구 보관소에 모두 보존됩니다.", 18)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 12)
	column.add_child(_choices)
	status_label = _label(column, "", 18)
	confirm_button = _button(column, "선택한 기록으로 복구 확정")
	confirm_button.pressed.connect(func():
		if _role != "" and not confirm_button.disabled:
			confirm_button.disabled = true
			recovery_confirmed.emit(_role, _inventory.duplicate(true)))
	cancel_button = _button(column, "취소 · 원본 그대로 두기")
	cancel_button.pressed.connect(func(): hide(); closed.emit())
	hide()

func show_inventory(inventory: Dictionary) -> void:
	_inventory = inventory.duplicate(true)
	_role = ""
	confirm_button.disabled = true
	choice_buttons.clear()
	for child in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()
	var labels := {"canonical": "현재 저장", "previous": "직전 저장", "temporary": "임시 기록 · 미확정"}
	for candidate in inventory.get("candidates", []):
		var description := "%s · %s" % [labels[candidate.role], "저장 번호 %d" % candidate.revision if candidate.valid else "사용 불가: " + str(candidate.reason)]
		var button := _button(_choices, description)
		button.disabled = not candidate.valid
		button.pressed.connect(_select.bind(candidate.role, description))
		choice_buttons.append(button)
	status_label.text = "기록을 고르고 내용을 확인한 뒤 복구 확정을 누르세요. 취소하면 파일을 바꾸지 않습니다."
	show()
	cancel_button.grab_focus.call_deferred()

func _select(role: String, description: String) -> void:
	_role = role
	status_label.text = "선택: %s\n복구 직전에 원본의 변경 여부를 다시 검사합니다." % description
	confirm_button.disabled = false

func show_failure(reason: String) -> void:
	status_label.text = "복구하지 못했습니다: %s. 취소 후 다시 열어 기록을 재확인하세요. 원본 보존 경로는 저장 폴더의 .recovery입니다." % reason
	confirm_button.disabled = true

func _label(parent: Node, text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	parent.add_child(button)
	return button
