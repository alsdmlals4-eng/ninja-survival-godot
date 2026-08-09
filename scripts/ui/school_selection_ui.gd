extends CanvasLayer
class_name SchoolSelectionUI

signal school_selected(school_id: StringName)

var _selected: bool = false


func _ready() -> void:
	_connect_button("Panel/Margin/Choices/BongmaButton", &"bongma")
	_connect_button("Panel/Margin/Choices/CheonsulButton", &"cheonsul")
	_connect_button("Panel/Margin/Choices/GuiinButton", &"guiin")
	_connect_button("Panel/Margin/Choices/HeukyeongButton", &"heukyeong")


func _unhandled_input(event: InputEvent) -> void:
	if _selected or not visible:
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


func _choose(school_id: StringName) -> void:
	if _selected:
		return
	_selected = true
	visible = false
	school_selected.emit(school_id)
