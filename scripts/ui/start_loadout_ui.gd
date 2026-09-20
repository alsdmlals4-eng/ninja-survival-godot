extends Control

signal prepared(snapshot: Dictionary)
signal cancelled

const SESSION = preload("res://scripts/core/start_loadout_session.gd")
const NINJUTSU = preload("res://scripts/data/ninjutsu_catalog.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const SCHOOLS := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const SCHOOL_NAMES := ["봉마류", "천술류", "귀인류", "흑영류"]

var session: Node
var school_buttons: Array[Button] = []
var option_buttons: Array[Button] = []
var cell_buttons: Array[Button] = []
var confirm_button: Button
var cancel_button: Button
var status_label: Label
var _draft_label: Label
var _bag_label: Label
var _book_labels: Array[Label] = []
var _rotate_button: Button
var _restart_button: Button
var _selected_book: int = 0
var _cell_owners: Dictionary = {}
var _seed: int = 0
var support_enabled := false
var support_buttons: Array[Button] = []


func _ready() -> void:
	_seed = randi()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var scroll := ScrollContainer.new()
	scroll.follow_focus = true
	margin.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 14)
	scroll.add_child(column)
	_label(column, "출전 준비 · 시작 빌드", 30)
	_label(column, "시작 유파와 인법 두 권을 고릅니다. 확정 후 첫 전장을 따로 선택합니다.", 16)
	var schools := HBoxContainer.new()
	column.add_child(schools)
	for index in range(4):
		var button := _button(schools, SCHOOL_NAMES[index])
		button.pressed.connect(_select_school.bind(index))
		school_buttons.append(button)
	_label(column, "캐릭터 장비 · 가방 공간을 사용하지 않습니다", 20)
	var gear := HBoxContainer.new()
	column.add_child(gear)
	for text in ["근접  |  일본도", "투사  |  수리검", "의복  |  닌자복"]:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		gear.add_child(panel)
		_label(panel, text, 19)
	_draft_label = _label(column, "", 20)
	var options := HBoxContainer.new()
	column.add_child(options)
	for index in range(3):
		var button := _button(options, "")
		button.pressed.connect(_choose.bind(index))
		option_buttons.append(button)
	if support_enabled:
		_label(column, "각성 · 시작 지원품 1개 선택 (실제 가방 점유 · 판매 0엽전)", 20)
		var support_row := HBoxContainer.new()
		column.add_child(support_row)
		for id in ITEMS.START_SUPPORT_IDS:
			var definition = ITEMS.build_items()[id]
			var button := _button(support_row, "%s · %d×%d" % [definition.display_name, definition.footprint_size.x, definition.footprint_size.y])
			button.pressed.connect(_choose_support.bind(id))
			support_buttons.append(button)
	_bag_label = _label(column, "", 20)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	column.add_child(content)
	var grid := GridContainer.new()
	grid.columns = 3
	content.add_child(grid)
	for index in range(9):
		var button := _button(grid, "·")
		button.custom_minimum_size = Vector2(76, 64)
		button.pressed.connect(_cell_pressed.bind(index))
		cell_buttons.append(button)
	var legend := VBoxContainer.new()
	legend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(legend)
	for index in range(3 if support_enabled else 2):
		_book_labels.append(_label(legend, "", 20))
	_label(legend, "아이템 클릭 → 빈칸 클릭으로 이동\n선택한 아이템은 회전 버튼으로 90° 회전\n각 책은 2칸을 사용합니다.", 17)
	var controls := HBoxContainer.new()
	column.add_child(controls)
	_rotate_button = _button(controls, "선택 아이템 회전")
	_rotate_button.pressed.connect(_rotate)
	_restart_button = _button(controls, "인법 다시 선택")
	_restart_button.pressed.connect(_restart)
	confirm_button = _button(controls, "준비 확정")
	confirm_button.pressed.connect(_confirm)
	cancel_button = _button(controls, "제목으로 · 선택 취소")
	cancel_button.pressed.connect(func(): cancelled.emit())
	status_label = _label(column, "인법을 두 번 선택하세요.", 17)
	_select_school(0)


func _select_school(index: int) -> void:
	if session != null and not session.committed_snapshot().is_empty():
		return
	if session != null:
		remove_child(session)
		session.free()
	session = SESSION.new()
	add_child(session)
	session.begin(SCHOOLS[index], _seed, support_enabled)
	_selected_book = 0
	status_label.text = "인법을 두 번 선택하세요. 선택 중에는 전투 능력이 생기지 않습니다."
	_refresh()

func _choose_support(id: StringName) -> void:
	status_label.text = "지원품을 배치했습니다." if session.choose_support(id) else "인법 두 권 선택 후 지원품이 들어갈 빈칸을 확보하세요."
	_refresh()


func _choose(index: int) -> void:
	var options: Array = session.snapshot().draft.options
	if index < options.size() and session.choose(options[index]):
		status_label.text = "인법 두 권을 골랐습니다. 배치를 확인하고 준비 확정을 누르세요." if session.snapshot().draft.complete else "첫 인법을 골랐습니다. 두 번째 인법을 선택하세요."
		_refresh()


func _cell_pressed(index: int) -> void:
	if not session.committed_snapshot().is_empty():
		return
	var cell := Vector2i(index % 3 + 1, index / 3 + 1)
	if _cell_owners.has(cell):
		_selected_book = _cell_owners[cell]
	elif _selected_book > 0:
		status_label.text = "배치를 변경했습니다." if session.move_book(_selected_book, cell) else "책의 두 칸 모두 가방 안의 빈칸이어야 합니다."
	_refresh()


func _rotate() -> void:
	status_label.text = "회전했습니다." if session.rotate_book(_selected_book) else "회전할 공간이 부족합니다. 빈 공간으로 먼저 이동하세요."
	_refresh()


func _restart() -> void:
	if session.restart_choices():
		_selected_book = 0
		status_label.text = "같은 선택지에서 다시 선택합니다."
		_refresh()


func _confirm() -> void:
	if session.confirm():
		status_label.text = "준비 확정: 인법 두 권과 장비 세 슬롯. 다음으로 첫 전장을 선택하세요."
		_refresh()
		prepared.emit(session.committed_snapshot())


func _refresh() -> void:
	var state: Dictionary = session.snapshot()
	var confirmed: bool = state.confirmed
	_draft_label.text = "시작 인법 선택 · %d / 2" % state.draft.picks.size()
	for index in range(3):
		var button := option_buttons[index]
		button.visible = index < state.draft.options.size()
		if button.visible:
			var definition = NINJUTSU.definition_for_id(state.draft.options[index])
			button.text = definition.display_name
	for index in range(4):
		school_buttons[index].disabled = confirmed or SCHOOLS[index] == state.draft.school_id
	_cell_owners.clear()
	var defs: Dictionary = ITEMS.build_items()
	var letters: Dictionary = {}
	for index in range(_book_labels.size()):
		_book_labels[index].text = "%s · 선택 전" % ["A", "B", "C"][index]
	for index in range(state.backpack.items.size()):
		var item: Dictionary = state.backpack.items[index]
		var definition = defs[StringName(item.definition_id)]
		letters[int(item.instance_id)] = ["A", "B", "C"][index]
		_book_labels[index].text = "%s · %s · %d×%d" % [["A", "B", "C"][index], definition.display_name, definition.footprint_size.x, definition.footprint_size.y]
		for local_cell in definition.footprint(int(item.rotation_quarters)):
			_cell_owners[Vector2i(item.origin_x, item.origin_y) + local_cell] = int(item.instance_id)
	for index in range(9):
		var owner: int = _cell_owners.get(Vector2i(index % 3 + 1, index / 3 + 1), 0)
		cell_buttons[index].text = ("[%s]" if owner == _selected_book else "%s") % letters[owner] if owner > 0 else "·"
		cell_buttons[index].disabled = confirmed
	_bag_label.text = "시작 가방 · 3×3 · %d / 9칸 사용" % _cell_owners.size()
	confirm_button.disabled = confirmed or not state.draft.complete or (support_enabled and state.support_id == &"")
	for index in range(support_buttons.size()):
		support_buttons[index].disabled = confirmed or not state.draft.complete or state.support_id == ITEMS.START_SUPPORT_IDS[index]
	_restart_button.disabled = confirmed
	_rotate_button.disabled = confirmed or _selected_book == 0


func _button(parent: Node, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(150, 46)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(button)
	return button


func _label(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label
