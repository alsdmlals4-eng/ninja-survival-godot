# 플레이어 본체는 이동과 피격만 보이며, 자동 공격은 별도 무기 이펙트가 표현한다.
extends Sprite2D
class_name PlayerVisualController

enum Pose {
	MOVE,
	HIT,
}

@export var move_texture: Texture2D
@export var hit_texture: Texture2D
@export var hit_hold_seconds: float = 0.16

var _pose: Pose = Pose.MOVE
var _remaining_seconds: float = 0.0


func _ready() -> void:
	_show_move()
	var player := get_parent() as PlayerController
	if player != null:
		player.damage_resolved.connect(_on_player_damage_resolved)


func _process(delta: float) -> void:
	advance_pose(delta)


func show_hit() -> void:
	_pose = Pose.HIT
	_remaining_seconds = maxf(hit_hold_seconds, 0.0)
	texture = hit_texture


func advance_pose(delta: float) -> void:
	if _pose == Pose.MOVE or delta <= 0.0:
		return
	_remaining_seconds = maxf(_remaining_seconds - delta, 0.0)
	if _remaining_seconds <= 0.0:
		_show_move()


func current_pose() -> Pose:
	return _pose


func _show_move() -> void:
	_pose = Pose.MOVE
	_remaining_seconds = 0.0
	texture = move_texture


func _on_player_damage_resolved(_requested: int, resolved: int, _prevented: int, evaded: bool) -> void:
	if resolved > 0 and not evaded:
		show_hit()
