extends GutTest

const GameStateScript = preload("res://scripts/core/game_state.gd")


func test_register_kill_increments_count_and_score() -> void:
	var state = GameStateScript.new()
	add_child_autofree(state)

	state.register_kill(125)

	assert_eq(state.kill_count, 1)
	assert_eq(state.score, 125)


func test_register_kill_never_subtracts_score() -> void:
	var state = GameStateScript.new()
	add_child_autofree(state)

	state.register_kill(-10)

	assert_eq(state.kill_count, 1)
	assert_eq(state.score, 0)
