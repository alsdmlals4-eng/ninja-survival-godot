# Temporary clocks for committed equipment. No progression or save authority.
extends RefCounted

const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const GROWTH = preload("res://scripts/data/equipment_growth_catalog.gd")
const SHIELD_SOURCE := &"equipment_bongma_shield"
var _powers: Dictionary = {}
var _clocks: Dictionary = {}
var _life_fraction := 0.0
var _rng := RandomNumberGenerator.new()

func configure(snapshot: Dictionary, player) -> bool:
	var gear = GEAR.new()
	if not gear.restore_snapshot(snapshot): return false
	clear(player)
	for slot in GEAR.SLOTS:
		_powers[slot] = []
		for school in gear.equipped_imbuements(StringName(slot)):
			var power := GROWTH.power(StringName(school), StringName(slot))
			_powers[slot].append(power)
			if power.kind in ["regeneration", "periodic_shield"]:
				_clocks[power.kind] = float(power.cooldown)
	return true

func clear(player) -> void:
	_powers.clear()
	_clocks.clear()
	_life_fraction = 0.0
	if is_instance_valid(player) and player.has_method("remove_ninjutsu_boon"):
		player.remove_ninjutsu_boon(SHIELD_SOURCE)

func advance(delta: float, player) -> void:
	if delta <= 0 or not is_finite(delta) or not _alive(player): return
	for key in _clocks:
		_clocks[key] = maxf(float(_clocks[key]) - delta, 0.0)
	for power in _powers.get("outfit", []):
		if power.kind not in ["regeneration", "periodic_shield"] or float(_clocks.get(power.kind, 0.0)) > 0: continue
		_clocks[power.kind] = float(power.cooldown)
		if power.kind == "regeneration": player.heal(int(power.amount))
		else: player.set_ninjutsu_boon(SHIELD_SOURCE, 0.0, 0.0, int(power.amount))

# BasicWeaponController calls once for the first actual hit of each cast. School,
# combination, ultimate and this callback's own damage never enter here.
func on_weapon_hit(slot: StringName, target, actual: int, player, resolver) -> void:
	if actual <= 0 or not _alive(player): return
	for power in _powers.get(str(slot), []):
		match power.kind:
			"lifesteal":
				if float(_clocks.get("lifesteal", 0.0)) > 0: continue
				_life_fraction += float(actual) * float(power.ratio)
				var amount := mini(floori(_life_fraction), int(power.cap))
				if amount > 0:
					_life_fraction = fmod(_life_fraction, 1.0)
					_clocks["lifesteal"] = float(power.cooldown)
					player.heal(amount, int(power.cap))
			"hit_shield":
				if float(_clocks.get("hit_shield", 0.0)) > 0: continue
				_clocks["hit_shield"] = float(power.cooldown)
				player.set_ninjutsu_boon(SHIELD_SOURCE, 0.0, 0.0, int(power.amount))
			"elemental_hit":
				if _rng.randf() < float(power.chance) and is_instance_valid(resolver) and is_instance_valid(target):
					resolver.deal_equipment_damage(target, float(actual) * float(power.ratio))

func _alive(player) -> bool:
	return is_instance_valid(player) and player.has_method("heal") and not player.is_dead() \
		and player.health > 0 and player.is_inside_tree() and not player.get_tree().paused
