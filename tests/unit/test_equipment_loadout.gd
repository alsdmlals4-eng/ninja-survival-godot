extends GutTest

const STATE_PATH := "res://scripts/core/equipment_loadout_state.gd"


func test_starter_equipment_has_three_external_slots_and_no_spatial_coordinates() -> void:
	assert_true(ResourceLoader.exists(STATE_PATH))
	if not ResourceLoader.exists(STATE_PATH):
		return
	var state = load(STATE_PATH).new()
	var snapshot: Dictionary = state.get_snapshot()
	assert_eq(snapshot["owned_instances"].size(), 3)
	assert_eq(snapshot["equipped_slots"].size(), 3)
	assert_eq(state.equipped_definition(&"melee"), &"katana")
	assert_eq(state.equipped_definition(&"projectile"), &"shuriken")
	assert_eq(state.equipped_definition(&"outfit"), &"ninja_suit")
	for item in snapshot["owned_instances"].values():
		assert_false(item.has("origin"))
		assert_false(item.has("footprint"))
	assert_almost_eq(state.outfit_reduction(), 0.05, 0.00001)


func test_equipment_upgrade_stays_with_instance_when_replaced() -> void:
	assert_true(ResourceLoader.exists(STATE_PATH))
	if not ResourceLoader.exists(STATE_PATH):
		return
	var state = load(STATE_PATH).new()
	assert_true(state.upgrade_equipped(&"melee"))
	assert_almost_eq(state.equipped_damage_bonus(&"melee"), 0.15, 0.00001)
	assert_true(state.acquire(&"naginata"))
	assert_true(state.equip(&"melee", &"naginata"))
	assert_almost_eq(state.equipped_damage_bonus(&"melee"), 0.0, 0.00001)
	assert_true(state.equip(&"melee", &"katana"))
	assert_almost_eq(state.equipped_damage_bonus(&"melee"), 0.15, 0.00001)
	assert_false(state.equip(&"projectile", &"katana"))
	assert_false(state.acquire(&"naginata"))


func test_outfit_rank_cap_and_snapshot_validation_fail_closed() -> void:
	assert_true(ResourceLoader.exists(STATE_PATH))
	if not ResourceLoader.exists(STATE_PATH):
		return
	var state = load(STATE_PATH).new()
	for index in range(4):
		assert_true(state.upgrade_equipped(&"outfit"))
	assert_false(state.upgrade_equipped(&"outfit"))
	assert_almost_eq(state.outfit_reduction(), 0.17, 0.00001)
	var snapshot: Dictionary = state.get_snapshot()
	var corrupt := snapshot.duplicate(true)
	corrupt["upgrade_rank_by_instance"]["gear_ninja_suit"] = 1.5
	assert_false(state.restore_snapshot(corrupt))
	assert_eq(state.get_snapshot(), snapshot)
	var other = load(STATE_PATH).new()
	assert_true(other.restore_snapshot(snapshot))
	assert_eq(other.get_snapshot(), snapshot)


func test_sell_requires_replacement_and_uses_purchase_price_not_upgrade_rank() -> void:
	var state = load(STATE_PATH).new()
	assert_true(state.has_method("sell"))
	if not state.has_method("sell"):
		return
	assert_eq(state.sell(&"katana"), -1)
	assert_true(state.acquire(&"naginata"))
	assert_true(state.equip(&"melee", &"naginata"))
	assert_true(state.upgrade_equipped(&"melee"))
	assert_eq(state.sell(&"naginata"), -1)
	assert_true(state.equip(&"melee", &"katana"))
	assert_eq(state.sell(&"naginata"), 22)
	assert_eq(state.sell(&"naginata"), -1)
	assert_false(state.get_snapshot()["owned_instances"].has("gear_naginata"))
	assert_true(state.acquire(&"dual_tanto"))
	assert_true(state.equip(&"melee", &"dual_tanto"))
	assert_eq(state.sell(&"katana"), 0)
	assert_true(state.is_valid_snapshot(state.get_snapshot()))
