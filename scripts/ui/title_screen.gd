extends CanvasLayer
class_name TitleScreen

## MainController owns run transitions, persisted records and application exit.
## This scene owns only visible title-menu state and focus movement.
const CODEX_PRESENTATION_SCRIPT = preload("res://scripts/ui/codex_presentation.gd")

signal start_requested
signal new_game_requested
signal new_game_confirmed
signal continue_requested
signal quit_requested
signal support_unlock_requested
signal recovery_requested
signal preferences_requested

@onready var start_button: Button = $LogoLockup/MenuButtons/StartButton
@onready var continue_button: Button = $LogoLockup/MenuButtons/ContinueButton
@onready var continue_status_label: Label = $LogoLockup/MenuButtons/ContinueStatusLabel
@onready var awakening_button: Button = $LogoLockup/MenuButtons/AwakeningButton
@onready var codex_button: Button = $LogoLockup/MenuButtons/CodexButton
@onready var guide_button: Button = $LogoLockup/MenuButtons/GuideButton
@onready var settings_button: Button = $LogoLockup/MenuButtons/SettingsButton
@onready var quit_button: Button = $LogoLockup/MenuButtons/QuitButton
@onready var guide_panel: Control = $GuidePanel
@onready var guide_close_button: Button = $GuidePanel/Dialog/Margin/Actions/CloseButton
@onready var settings_panel: Control = $SettingsPanel
@onready var fullscreen_button: Button = $SettingsPanel/Dialog/Margin/Actions/FullscreenButton
@onready var settings_close_button: Button = $SettingsPanel/Dialog/Margin/Actions/CloseButton
@onready var awakening_panel: Control = $AwakeningPanel
@onready var awakening_balance_label: Label = $AwakeningPanel/Dialog/Margin/Actions/BalanceLabel
@onready var awakening_close_button: Button = $AwakeningPanel/Dialog/Margin/Actions/CloseButton
@onready var codex_panel: Control = $CodexPanel
@onready var codex_entries: RichTextLabel = $CodexPanel/Dialog/Margin/Actions/Entries
@onready var codex_close_button: Button = $CodexPanel/Dialog/Margin/Actions/CloseButton
@onready var new_game_confirm_panel: Control = $NewGameConfirmPanel
@onready var new_game_confirm_button: Button = $NewGameConfirmPanel/Dialog/Margin/Actions/Buttons/ConfirmButton
@onready var new_game_cancel_button: Button = $NewGameConfirmPanel/Dialog/Margin/Actions/Buttons/CancelButton
@onready var quit_confirm_panel: Control = $QuitConfirmPanel
@onready var quit_confirm_button: Button = $QuitConfirmPanel/Dialog/Margin/Actions/Buttons/ConfirmButton
@onready var quit_cancel_button: Button = $QuitConfirmPanel/Dialog/Margin/Actions/Buttons/CancelButton

var _codex_sections: Array = []
var _support_tab: Button
var support_unlock_button: Button
var recovery_button: Button
var _selected_rules := false

func set_selected_rules() -> void:
	_selected_rules = true
	_codex_sections = CODEX_PRESENTATION_SCRIPT.new().build_selected_sections()
	if _support_tab == null:
		_support_tab = Button.new()
		_support_tab.name = "SupportTab"
		_support_tab.text = "보조품"
		_support_tab.toggle_mode = true
		$CodexPanel/Dialog/Margin/Actions/Tabs.add_child(_support_tab)
		_support_tab.pressed.connect(_show_codex_section.bind(&"support"))
	if support_unlock_button == null:
		support_unlock_button = Button.new()
		support_unlock_button.name = "SupportUnlockButton"
		support_unlock_button.custom_minimum_size.y = 44
		var actions = $AwakeningPanel/Dialog/Margin/Actions
		actions.add_child(support_unlock_button)
		actions.move_child(support_unlock_button, awakening_close_button.get_index())
		support_unlock_button.pressed.connect(func(): support_unlock_requested.emit())
	set_support_unlock_state(false, 0)
	if recovery_button == null:
		recovery_button = Button.new()
		recovery_button.name = "RecoveryButton"
		recovery_button.text = "저장 복구 기록 확인"
		recovery_button.custom_minimum_size.y = 44
		$LogoLockup/MenuButtons.add_child(recovery_button)
		$LogoLockup/MenuButtons.move_child(recovery_button, continue_status_label.get_index() + 1)
		recovery_button.pressed.connect(func(): recovery_requested.emit())
		recovery_button.hide()

func set_recovery_available(available: bool) -> void:
	if is_instance_valid(recovery_button): recovery_button.visible = available

func set_support_unlock_state(unlocked: bool, balance: int, status := "") -> void:
	if not _selected_rules: return
	set_awakening_balance(balance)
	var cost: int = preload("res://scripts/data/selected_backpack_catalog.gd").SUPPORT_UNLOCK_COST
	support_unlock_button.text = "시작 지원품 선택 · 해금 완료" if unlocked else "시작 지원품 선택 해금 · 닌자소울 %d개" % cost
	support_unlock_button.disabled = unlocked or balance < cost
	$AwakeningPanel/Dialog/Margin/Actions/BodyLabel.text = "다음 새 게임부터 체술단련·호신 부적·인법단련 중 1개를 선택합니다. 가방을 차지하며 판매가는 0엽전입니다. 현재 런은 바뀌지 않습니다.\n" + status


func _ready() -> void:
	start_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	awakening_button.pressed.connect(_open_awakening)
	codex_button.pressed.connect(_open_codex)
	guide_button.pressed.connect(_open_guide)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(_open_quit_confirmation)
	guide_close_button.pressed.connect(_close_guide)
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	settings_close_button.pressed.connect(_close_settings)
	awakening_close_button.pressed.connect(_close_awakening)
	codex_close_button.pressed.connect(_close_codex)
	new_game_confirm_button.pressed.connect(_confirm_new_game)
	new_game_cancel_button.pressed.connect(_close_new_game_confirmation)
	quit_confirm_button.pressed.connect(_confirm_quit)
	quit_cancel_button.pressed.connect(_close_quit_confirmation)
	for tab_button in _codex_tab_buttons():
		tab_button.pressed.connect(_show_codex_section.bind(_section_id_for_tab(tab_button)))
	_close_all_panels()
	set_continue_state(false)
	set_awakening_balance(0)
	_codex_sections = CODEX_PRESENTATION_SCRIPT.new().build_sections()
	_refresh_fullscreen_button()
	_focus_start_button()


func show_title() -> void:
	show()
	_close_all_panels()
	_focus_start_button()


func hide_title() -> void:
	_close_all_panels()
	hide()


func set_continue_state(available: bool, status_text: String = "") -> void:
	continue_button.disabled = not available
	continue_status_label.text = status_text if not status_text.is_empty() else ("" if available else "확정된 워크벤치 기록이 없습니다.")


func set_awakening_balance(balance: int) -> void:
	awakening_balance_label.text = ("보유 닌자소울 · %d" if _selected_rules else "보유 각성 · %d") % maxi(balance, 0)


func show_new_game_confirmation() -> void:
	_close_all_panels()
	new_game_confirm_panel.show()
	new_game_cancel_button.grab_focus.call_deferred()


func _on_new_game_pressed() -> void:
	_close_all_panels()
	new_game_requested.emit()
	start_requested.emit()


func _on_continue_pressed() -> void:
	if continue_button.disabled:
		return
	_close_all_panels()
	continue_requested.emit()


func _open_guide() -> void:
	_close_all_panels()
	guide_panel.show()
	guide_close_button.grab_focus.call_deferred()


func _close_guide() -> void:
	guide_panel.hide()
	guide_button.grab_focus.call_deferred()


func _open_settings() -> void:
	_close_all_panels()
	if preferences_requested.has_connections():
		preferences_requested.emit()
		return
	settings_panel.show()
	_refresh_fullscreen_button()
	fullscreen_button.grab_focus.call_deferred()


func _close_settings() -> void:
	settings_panel.hide()
	settings_button.grab_focus.call_deferred()


func _open_awakening() -> void:
	_close_all_panels()
	awakening_panel.show()
	awakening_close_button.grab_focus.call_deferred()


func _close_awakening() -> void:
	awakening_panel.hide()
	awakening_button.grab_focus.call_deferred()


func _open_codex() -> void:
	_close_all_panels()
	codex_panel.show()
	_show_codex_section(&"enemies")
	($CodexPanel/Dialog/Margin/Actions/Tabs/EnemyTab as Button).grab_focus.call_deferred()


func _close_codex() -> void:
	codex_panel.hide()
	codex_button.grab_focus.call_deferred()


func _show_codex_section(section_id: StringName) -> void:
	var selected_section := {}
	for section in _codex_sections:
		if StringName(section.get("section_id", &"")) == section_id:
			selected_section = section
			break
	if selected_section.is_empty():
		return
	for tab_button in _codex_tab_buttons():
		tab_button.set_pressed_no_signal(_section_id_for_tab(tab_button) == section_id)
	var lines: Array[String] = ["[b]%s[/b]" % selected_section.get("title", "도감")]
	for entry in Array(selected_section.get("entries", [])):
		lines.append("[b]%s[/b]\n%s" % [entry.get("title", ""), entry.get("detail", "")])
	codex_entries.text = "\n\n".join(lines)


func _open_quit_confirmation() -> void:
	_close_all_panels()
	quit_confirm_panel.show()
	quit_cancel_button.grab_focus.call_deferred()


func _close_quit_confirmation() -> void:
	quit_confirm_panel.hide()
	quit_button.grab_focus.call_deferred()


func _close_new_game_confirmation() -> void:
	new_game_confirm_panel.hide()
	start_button.grab_focus.call_deferred()


func _confirm_new_game() -> void:
	new_game_confirm_panel.hide()
	new_game_confirmed.emit()


func _confirm_quit() -> void:
	quit_confirm_panel.hide()
	quit_requested.emit()


func _toggle_fullscreen() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_fullscreen_button()


func _refresh_fullscreen_button() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_button.text = "전체 화면 끄기" if fullscreen else "전체 화면 켜기"


func _close_all_panels() -> void:
	guide_panel.hide()
	settings_panel.hide()
	awakening_panel.hide()
	codex_panel.hide()
	new_game_confirm_panel.hide()
	quit_confirm_panel.hide()


func _codex_tab_buttons() -> Array[Button]:
	var buttons: Array[Button] = [
		$CodexPanel/Dialog/Margin/Actions/Tabs/EnemyTab,
		$CodexPanel/Dialog/Margin/Actions/Tabs/NinjutsuTab,
		$CodexPanel/Dialog/Margin/Actions/Tabs/EquipmentTab,
		$CodexPanel/Dialog/Margin/Actions/Tabs/BagsTab,
		$CodexPanel/Dialog/Margin/Actions/Tabs/CombinationsTab,
	]
	if is_instance_valid(_support_tab): buttons.append(_support_tab)
	return buttons


func _section_id_for_tab(tab_button: Button) -> StringName:
	match tab_button.name:
		&"EnemyTab":
			return &"enemies"
		&"NinjutsuTab":
			return &"ninjutsu"
		&"EquipmentTab":
			return &"equipment"
		&"BagsTab":
			return &"bags"
		&"CombinationsTab":
			return &"combinations"
		&"SupportTab":
			return &"support"
		_:
			return &""


func _focus_start_button() -> void:
	start_button.grab_focus.call_deferred()
