extends CanvasLayer
class_name SchoolSelectionUI

signal school_selected(school_id: StringName)

const VALID_SCHOOL_IDS := {
	&"bongma": true,
	&"cheonsul": true,
	&"guiin": true,
	&"heukyeong": true,
}

const SCHOOL_HELP := {
	&"bongma": {
		"title": "봉마류 기능 도움말",
		"body": "소환수는 자동으로 공격합니다. SPIRIT은 시간이 지나거나 적을 처치하면 쌓이며, 결계 안에서는 소환수 공격이 빨라집니다. SPIRIT이 100이 되면 백귀야행으로 임시 소환수를 불러 짧은 시간 집중 공격합니다.",
	},
	&"cheonsul": {
		"title": "천술류 기능 도움말",
		"body": "가까운 적에게 불 장판을 펼쳐 BURN을 남깁니다. 이어서 WET과 SHOCK 상태를 번갈아 걸며, WET 뒤에 SHOCK이 닿으면 주변까지 번지는 반응 피해가 발생합니다. 반응을 3번 만들면 오행폭주가 준비됩니다.",
	},
	&"guiin": {
		"title": "귀인류 기능 도움말",
		"body": "가까운 적에게 자동 근접 공격을 가합니다. 적중과 처치로 GWIHYEOL이 쌓이고, 높은 수치에서는 공격이 강해집니다. 체력이 낮을 때는 근접 공격 범위가 넓어지며, GWIHYEOL 100에서는 귀인화로 짧은 난전을 버팁니다.",
	},
	&"heukyeong": {
		"title": "흑영류 기능 도움말",
		"body": "가까운 적 여러 명을 자동으로 노립니다. 치명타는 표식을 더 빠르게 쌓고, 표식 3개가 쌓인 적은 MARK BURST로 폭발합니다. 전장에 쌓인 표식이 많아지면 암영처형이 준비됩니다.",
	},
}

var _selected: bool = false
var _help_open: bool = false
var _help_opener: Button

@onready var _help_dialog := $HelpDialog as Control
@onready var _help_title := $HelpDialog/Margin/Content/TitleLabel as Label
@onready var _help_body := $HelpDialog/Margin/Content/BodyLabel as Label
@onready var _help_close_button := $HelpDialog/Margin/Content/CloseButton as Button


func _ready() -> void:
	_connect_button("Panel/Margin/Choices/BongmaButton", &"bongma")
	_connect_button("Panel/Margin/Choices/CheonsulButton", &"cheonsul")
	_connect_button("Panel/Margin/Choices/GuiinButton", &"guiin")
	_connect_button("Panel/Margin/Choices/HeukyeongButton", &"heukyeong")
	_connect_help_button("Panel/Margin/Choices/BongmaHelpButton", &"bongma")
	_connect_help_button("Panel/Margin/Choices/CheonsulHelpButton", &"cheonsul")
	_connect_help_button("Panel/Margin/Choices/GuiinHelpButton", &"guiin")
	_connect_help_button("Panel/Margin/Choices/HeukyeongHelpButton", &"heukyeong")
	_help_close_button.pressed.connect(_close_school_help)


func _unhandled_input(event: InputEvent) -> void:
	if _selected or not visible:
		return
	if _help_open:
		if event.is_action_pressed(&"ui_cancel"):
			_close_school_help()
		return
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_1:
			_choose(&"bongma")
		KEY_2:
			_choose(&"cheonsul")
		KEY_3:
			_choose(&"guiin")
		KEY_4:
			_choose(&"heukyeong")


func _connect_button(path: NodePath, school_id: StringName) -> void:
	var button := get_node_or_null(path) as Button
	if button == null:
		return
	button.pressed.connect(func() -> void: _choose(school_id))


func _connect_help_button(path: NodePath, school_id: StringName) -> void:
	var button := get_node_or_null(path) as Button
	if button == null:
		return
	button.pressed.connect(func() -> void: _open_school_help(school_id, button))


func _open_school_help(school_id: StringName, opener: Button) -> void:
	if _selected or not SCHOOL_HELP.has(school_id):
		return
	var help := SCHOOL_HELP[school_id] as Dictionary
	_help_title.text = help["title"]
	_help_body.text = help["body"]
	_help_opener = opener
	_help_open = true
	_help_dialog.show()
	_help_close_button.grab_focus()


func _close_school_help() -> void:
	_help_open = false
	_help_dialog.hide()
	if is_instance_valid(_help_opener):
		_help_opener.grab_focus()


func _choose(school_id: StringName) -> void:
	if _selected or _help_open or not VALID_SCHOOL_IDS.has(school_id):
		return
	_selected = true
	visible = false
	school_selected.emit(school_id)
