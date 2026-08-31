extends CanvasLayer
class_name TitleScreen

## Presentation-only front door. MainController retains every run and combat
## transition; secondary actions remain local presentation controls.
signal start_requested

@onready var start_button: Button = $LogoLockup/MenuButtons/StartButton
@onready var guide_button: Button = $LogoLockup/MenuButtons/GuideButton
@onready var settings_button: Button = $LogoLockup/MenuButtons/SettingsButton
@onready var guide_panel: Control = $GuidePanel
@onready var guide_close_button: Button = $GuidePanel/Dialog/Margin/Actions/CloseButton
@onready var settings_panel: Control = $SettingsPanel
@onready var fullscreen_button: Button = $SettingsPanel/Dialog/Margin/Actions/FullscreenButton
@onready var settings_close_button: Button = $SettingsPanel/Dialog/Margin/Actions/CloseButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	guide_button.pressed.connect(_open_guide)
	settings_button.pressed.connect(_open_settings)
	guide_close_button.pressed.connect(_close_guide)
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	settings_close_button.pressed.connect(_close_settings)
	guide_panel.hide()
	settings_panel.hide()
	_refresh_fullscreen_button()
	_focus_start_button()


func show_title() -> void:
	show()
	guide_panel.hide()
	settings_panel.hide()
	_focus_start_button()


func hide_title() -> void:
	guide_panel.hide()
	settings_panel.hide()
	hide()


func _on_start_pressed() -> void:
	guide_panel.hide()
	settings_panel.hide()
	start_requested.emit()


func _open_guide() -> void:
	settings_panel.hide()
	guide_panel.show()
	guide_close_button.grab_focus.call_deferred()


func _close_guide() -> void:
	guide_panel.hide()
	guide_button.grab_focus.call_deferred()


func _open_settings() -> void:
	guide_panel.hide()
	settings_panel.show()
	_refresh_fullscreen_button()
	fullscreen_button.grab_focus.call_deferred()


func _close_settings() -> void:
	settings_panel.hide()
	settings_button.grab_focus.call_deferred()


func _toggle_fullscreen() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_fullscreen_button()


func _refresh_fullscreen_button() -> void:
	var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_button.text = "전체 화면 끄기" if fullscreen else "전체 화면 켜기"


func _focus_start_button() -> void:
	start_button.grab_focus.call_deferred()
