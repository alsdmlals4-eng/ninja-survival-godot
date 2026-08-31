# 확정 인법서가 자동 전투에서만 추가 공격을 만드는지 검증한다.
extends GutTest

const AUTO_CONTROLLER_PATH := "res://scripts/schools/ninjutsu_auto_controller.gd"
const LOADOUT_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")


class DummyEnemy extends Node2D:
	var health: int = 50

	func take_damage(amount: int) -> int:
		var resolved := mini(maxi(amount, 0), health)
		health -= resolved
		return resolved

	func is_dead() -> bool:
		return health <= 0


func test_starter_is_not_duplicated_but_committed_scroll_auto_casts() -> void:
	assert_true(ResourceLoader.exists(AUTO_CONTROLLER_PATH), "확정 인법서 자동 시전기가 필요합니다.")
	if not ResourceLoader.exists(AUTO_CONTROLLER_PATH):
		return
	var player := Node2D.new()
	add_child_autofree(player)
	var enemy := DummyEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = Vector2(96.0, 0.0)
	enemy.add_to_group("enemies")

	var loadout = LOADOUT_SCRIPT.new()
	add_child_autofree(loadout)
	assert_true(loadout.activate_starter(&"cheonsul"))

	var controller = load(AUTO_CONTROLLER_PATH).new()
	add_child_autofree(controller)
	assert_true(controller.configure(player, self, null, loadout))
	controller.tick_auto_cast(2.0)
	assert_eq(enemy.health, 50, "시작 인법은 기존 유파 런타임이 처리하므로 별도 시전기가 중복 공격하면 안 됩니다.")

	assert_true(loadout.stage_scroll(&"cheonsul", &"elite_scroll"))
	assert_true(loadout.commit_pending())
	controller.tick_auto_cast(1.0)
	assert_lt(enemy.health, 50, "확정된 엘리트 인법서는 수동 입력 없이 자동으로 전장에 적용돼야 합니다.")
	controller.clear_runtime_effects()
	await get_tree().process_frame
