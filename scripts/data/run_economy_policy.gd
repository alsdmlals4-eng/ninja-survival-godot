# Run 전용 G 수입 규칙의 단일 데이터 source를 정의한다.
extends Resource
class_name RunEconomyPolicy

@export_range(0.0, 1.0, 0.01) var normal_kill_gold_chance := 0.20
@export_range(0, 99, 1) var normal_kill_gold_amount := 1
@export_range(0, 99, 1) var elite_clear_gold := 5
@export_range(0, 99, 1) var school_boss_clear_gold := 10


func is_valid() -> bool:
	return (
		is_finite(normal_kill_gold_chance)
		and normal_kill_gold_chance >= 0.0
		and normal_kill_gold_chance <= 1.0
		and normal_kill_gold_amount >= 0
		and elite_clear_gold >= 0
		and school_boss_clear_gold >= 0
	)
