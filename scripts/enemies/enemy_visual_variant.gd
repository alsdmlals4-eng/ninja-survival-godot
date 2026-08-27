# 일반 적 Sprite2D가 승인된 3종 요괴 텍스처 중 하나를 안전하게 선택한다.
extends Sprite2D
class_name EnemyVisualVariant

@export var texture_candidates: Array[Texture2D] = []


func _ready() -> void:
	if texture_candidates.is_empty():
		return
	texture = texture_candidates[randi() % texture_candidates.size()]
