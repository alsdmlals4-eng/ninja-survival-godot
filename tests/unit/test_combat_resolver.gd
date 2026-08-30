extends GutTest

const RESOLVER_PATH := "res://scripts/combat/combat_resolver.gd"
const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"

class DamageTarget:
	extends Node
	var health: int = 100

	func take_damage(amount: int) -> int:
		if amount <= 0 or health <= 0:
			return 0
		var before := health
		health = maxi(health - amount, 0)
		return before - health


func test_combat_resolver_resource_exists() -> void:
	assert_true(ResourceLoader.exists(RESOLVER_PATH), "Missing MVP-3 combat resolver")


func test_normal_school_damage_applies_school_and_non_ultimate_channels() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	add_child_autofree(target)
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.20
	modifiers.non_ultimate_school_damage_pct = -0.15
	fixture.resolver.set_modifiers(modifiers)
	assert_eq(fixture.resolver.deal_school_damage(target, 20.0), 20)
	assert_eq(target.health, 80)
	assert_eq(fixture.tracker.damage, 20)


func test_ultimate_damage_uses_ultimate_power_not_non_ultimate_penalty() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	add_child_autofree(target)
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.20
	modifiers.non_ultimate_school_damage_pct = -0.90
	modifiers.ultimate_power_pct = 0.25
	fixture.resolver.set_modifiers(modifiers)
	assert_eq(fixture.resolver.deal_school_damage(target, 20.0, &"ultimate"), 30)
	assert_eq(target.health, 70)
	assert_eq(fixture.tracker.damage, 30)


func test_extra_multiplier_is_applied_after_run_modifiers() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	add_child_autofree(target)
	assert_eq(fixture.resolver.deal_school_damage(target, 10.0, &"normal", 1.5), 15)
	assert_eq(fixture.tracker.damage, 15)


func test_basic_weapon_damage_records_actual_hp_loss_without_school_only_modifiers() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	add_child_autofree(target)
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.80
	modifiers.non_ultimate_school_damage_pct = 0.60
	fixture.resolver.set_modifiers(modifiers)

	assert_eq(fixture.resolver.deal_basic_weapon_damage(target, 10.0), 10)
	assert_eq(target.health, 90)
	assert_eq(fixture.tracker.damage, 10)


func test_overkill_records_actual_hp_loss_only() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	target.health = 7
	add_child_autofree(target)
	assert_eq(fixture.resolver.deal_school_damage(target, 100.0), 7)
	assert_eq(fixture.tracker.damage, 7)


func test_invalid_zero_or_non_damage_target_is_noop() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	assert_eq(fixture.resolver.deal_school_damage(null, 10.0), 0)
	var plain := Node.new()
	add_child_autofree(plain)
	assert_eq(fixture.resolver.deal_school_damage(plain, 10.0), 0)
	var target := DamageTarget.new()
	add_child_autofree(target)
	assert_eq(fixture.resolver.deal_school_damage(target, 0.0), 0)
	assert_eq(fixture.resolver.deal_school_damage(target, 10.0, &"normal", 0.0), 0)
	assert_eq(fixture.tracker.damage, 0)


func test_set_modifiers_copies_snapshot_instead_of_sharing_it() -> void:
	var fixture := _new_fixture()
	if fixture.is_empty():
		return
	var target := DamageTarget.new()
	add_child_autofree(target)
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.50
	fixture.resolver.set_modifiers(modifiers)
	modifiers.school_damage_pct = 9.0
	assert_eq(fixture.resolver.deal_school_damage(target, 10.0), 15)


func _new_fixture() -> Dictionary:
	if not ResourceLoader.exists(RESOLVER_PATH):
		return {}
	var tracker = load(TRACKER_PATH).new()
	add_child_autofree(tracker)
	tracker.reset_segment(0, 0)
	var resolver = load(RESOLVER_PATH).new()
	add_child_autofree(resolver)
	resolver.configure(tracker)
	return {"tracker": tracker, "resolver": resolver}
