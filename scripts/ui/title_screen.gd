extends CanvasLayer
class_name TitleScreen

## Presentation-only front door. MainController retains every run and combat
## transition; this surface emits only the player's explicit Start intent.
signal start_requested

@onready var start_button: Button = $LogoLockup/StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	_focus_start_button()


func show_title() -> void:
	show()
	_focus_start_button()


func hide_title() -> void:
	hide()


func _on_start_pressed() -> void:
	start_requested.emit()


func _focus_start_button() -> void:
	start_button.grab_focus.call_deferred()
