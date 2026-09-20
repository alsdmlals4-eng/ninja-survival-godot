extends GutTest

const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")

class Target extends Node2D:
	var health := 100
	func take_damage(amount: int) -> int:
		var actual := mini(amount, health)
		health -= actual
		return actual
	func is_dead() -> bool: return health <= 0

func _main(school_index: int = 0):
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.selected_run.begin_new_game()
	main.selected_run.start_ui.school_buttons[school_index].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	main._set_combat_enabled(false)
	return main

func test_committed_combo_is_adopted_by_real_main_and_removed_on_next_adoption() -> void:
	var main = _main()
	var profile: Dictionary = main.selected_run.store.load_profile().profile
	profile.meta.soul_balance = 2
	var before: Dictionary = profile.duplicate(true)
	var cp: Dictionary = profile.active_run.checkpoint
	var bag = BAG.from_persistent_snapshot(cp.backpack)
	assert_gt(bag.add_item(&"thunder_blade", Vector2i(3,1)), 0)
	cp.backpack = bag.to_persistent_snapshot()
	var resolution = load("res://scripts/backpack/backpack_resolver.gd").new().resolve(bag, ITEMS.build_items(), load("res://scripts/data/mvp4_catalog.gd").build_bags(), &"bongma")
	assert_true(resolution.valid)
	cp.build.committed_backpack_modifiers = resolution.modifiers.to_persistent_snapshot()
	assert_true(main.selected_run.store.transact_profile(profile, int(profile.revision), "test:committed-combo").ok)
	# Continue uses the durable checkpoint, not a direct call to the weapon helper.
	main.selected_run.continue_run()
	main._set_combat_enabled(false)
	var primary := Target.new()
	var side := Target.new()
	main.add_child(primary)
	main.add_child(side)
	primary.global_position = main.player.global_position + Vector2(20,0)
	side.global_position = main.player.global_position + Vector2(20,60)
	primary.add_to_group("enemies")
	side.add_to_group("enemies")
	main.basic_weapons.swing_katana_once()
	assert_eq(primary.health, 88, "Committed thunder manual adds20 percent to the actual weapon.")
	assert_eq(side.health, 94, "Side target outside the cone receives the actual combination callback.")
	var old_projectile = main.basic_weapons.fire_shuriken_once()
	assert_not_null(old_projectile)
	main._on_player_died()
	main.selected_run.retry()
	assert_false(main.game_over)
	main._set_combat_enabled(false)
	assert_true(old_projectile.is_queued_for_deletion(), "Retry must not resume a projectile from the failed battle.")
	var retry_primary := Target.new()
	var retry_side := Target.new()
	main.add_child(retry_primary)
	main.add_child(retry_side)
	retry_primary.global_position = main.player.global_position + Vector2(20,0)
	retry_side.global_position = main.player.global_position + Vector2(20,60)
	retry_primary.add_to_group("enemies")
	retry_side.add_to_group("enemies")
	main.basic_weapons.swing_katana_once()
	assert_eq(retry_primary.health, 88, "Retry reapplies the committed bonus.")
	assert_eq(retry_side.health, 94, "A failed battle's combination cooldown is not in the checkpoint.")
	assert_true(main.selected_run.adopt(before))
	# The previous targets are retired by adoption; fresh targets prove no stale bonus.
	var next := Target.new()
	main.add_child(next)
	next.global_position = main.player.global_position + Vector2(20,0)
	next.add_to_group("enemies")
	main.basic_weapons.swing_katana_once()
	assert_eq(next.health, 90)
	await get_tree().process_frame

func test_checkpoint_adoption_can_exit_a_running_sword_form() -> void:
	var main = _main(2)
	var profile: Dictionary = main.selected_run.store.load_profile().profile
	assert_true(main.basic_weapons.begin_guiin_form())
	assert_true(main.selected_run.adopt(profile), "Retry/continue must retire temporary sword mode before applying saved equipment.")
	assert_true(main.basic_weapons._guiin_original.is_empty())
	await get_tree().process_frame
