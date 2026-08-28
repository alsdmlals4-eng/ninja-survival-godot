# 최근 피격 적 하나만 HP를 잠시 표시하는 계약을 검증한다.
extends GutTest

const PRESENTER_PATH := "res://scripts/ui/recent_hit_hp_presenter.gd"
const ENEMY_SCRIPT = preload("res://scripts/enemies/enemy_chaser.gd")


func _make_enemy(maximum_health: int = 20) -> EnemyChaser:
	var enemy := ENEMY_SCRIPT.new() as EnemyChaser
	enemy.max_health = maximum_health
	add_child_autofree(enemy)
	return enemy


func test_recent_hit_hp_presenter_resource_exists() -> void:
	assert_true(ResourceLoader.exists(PRESENTER_PATH), "최근 피격 HP 표시 owner가 필요합니다.")


func test_latest_hit_replaces_the_previous_enemy_bar() -> void:
	if not ResourceLoader.exists(PRESENTER_PATH):
		return
	var presenter = load(PRESENTER_PATH).new()
	add_child_autofree(presenter)
	var first := _make_enemy(20)
	var second := _make_enemy(30)
	assert_true(presenter.observe_enemy(first))
	assert_true(presenter.observe_enemy(second))

	first.take_damage(6)
	var first_bar: ProgressBar = presenter.visible_bar()
	assert_eq(presenter.visible_enemy(), first)
	assert_not_null(first_bar)
	assert_eq(first_bar.value, 14.0)
	assert_eq(first_bar.max_value, 20.0)

	second.take_damage(9)
	assert_eq(presenter.visible_enemy(), second)
	assert_true(first_bar.is_queued_for_deletion(), "새 피격은 이전 적의 HP bar를 즉시 정리해야 합니다.")
	assert_eq(presenter.visible_bar().value, 21.0)
	assert_eq(presenter.visible_bar().max_value, 30.0)


func test_recent_hit_bar_expires_after_one_point_two_five_seconds_or_death() -> void:
	if not ResourceLoader.exists(PRESENTER_PATH):
		return
	var presenter = load(PRESENTER_PATH).new()
	add_child_autofree(presenter)
	var enemy := _make_enemy(20)
	assert_true(presenter.observe_enemy(enemy))
	enemy.take_damage(1)
	presenter._process(1.24)
	assert_eq(presenter.visible_enemy(), enemy)
	presenter._process(0.02)
	assert_null(presenter.visible_enemy())

	enemy.take_damage(1)
	assert_eq(presenter.visible_enemy(), enemy)
	enemy.take_damage(99)
	assert_null(presenter.visible_enemy(), "사망한 적은 HP bar를 남기지 않아야 합니다.")
