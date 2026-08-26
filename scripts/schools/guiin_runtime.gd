extends SchoolRuntimeBase
class_name GuiinRuntime

const PULSE_INTERVAL := 0.90
const PULSE_RADIUS := 80.0
const PULSE_DAMAGE := 10.0
const BERSERKER_RADIUS := 110.0
const BERSERKER_DAMAGE := 15.0
const HIGH_GWIHYEOL_THRESHOLD := 75.0
const HIGH_GWIHYEOL_MULTIPLIER := 1.20
const HIT_GWIHYEOL := 4.0
const KILL_GWIHYEOL := 12.0
const GWIHYEOL_MAX := 100.0
const DECAY_DELAY := 1.0
const DECAY_PER_SECOND := 6.0
const ULTIMATE_DURATION := 6.0
const ULTIMATE_INTERVAL := 0.45
const ULTIMATE_RADIUS := 130.0
const ULTIMATE_DAMAGE_MULTIPLIER := 1.25
const TIMER_EPSILON := 0.000001

var gwihyeol: float = 0.0
var time_since_gain: float = 0.0
var ultimate_time_remaining: float = 0.0
var _pulse_remaining: float = PULSE_INTERVAL
var _last_ultimate_ready: bool = false


func activate() -> void:
	if active:
		return
	super.activate()
	gwihyeol = 0.0
	time_since_gain = 0.0
	ultimate_time_remaining = 0.0
	_pulse_remaining = PULSE_INTERVAL
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	super.deactivate()


func _process(delta: float) -> void:
	if not active or delta <= 0.0:
		return

	if ultimate_time_remaining > 0.0:
		ultimate_time_remaining = maxf(ultimate_time_remaining - delta, 0.0)

	var previous_time_since_gain := time_since_gain
	time_since_gain += delta
	var previous_decay_time := maxf(previous_time_since_gain - DECAY_DELAY, 0.0)
	var current_decay_time := maxf(time_since_gain - DECAY_DELAY, 0.0)
	var decay_delta := maxf(current_decay_time - previous_decay_time, 0.0)
	if decay_delta > 0.0 and gwihyeol > 0.0:
		_set_gwihyeol(gwihyeol - DECAY_PER_SECOND * decay_delta, false)

	_pulse_remaining -= delta
	if _pulse_remaining <= TIMER_EPSILON:
		perform_melee_pulse()
		_pulse_remaining = current_pulse_interval()

	_emit_ultimate_ready_if_changed()


func perform_melee_pulse() -> int:
	if not active or not is_instance_valid(player):
		return 0
	var hit_count := 0
	var radius := current_pulse_radius()
	var base_damage := float(current_pulse_damage())
	var damage_kind: StringName = &"ultimate" if ultimate_time_remaining > 0.0 else &"normal"
	for enemy in _valid_enemies():
		if enemy.global_position.distance_squared_to(player.global_position) > radius * radius:
			continue
		var actual_damage := _deal_damage(enemy, base_damage, damage_kind)
		if actual_damage <= 0:
			continue
		hit_count += 1
	if hit_count > 0:
		_gain_gwihyeol(HIT_GWIHYEOL * float(hit_count))
		emit_player_action_resolved()
	return hit_count


func current_pulse_interval() -> float:
	return ULTIMATE_INTERVAL if ultimate_time_remaining > 0.0 else PULSE_INTERVAL


func current_pulse_radius() -> float:
	var radius := BERSERKER_RADIUS if _is_berserker_active() else PULSE_RADIUS
	if ultimate_time_remaining > 0.0:
		radius = maxf(radius, ULTIMATE_RADIUS)
	return radius * maxf(1.0 + run_modifiers.guiin_melee_radius_pct, 0.0)


func current_pulse_damage() -> int:
	var value := BERSERKER_DAMAGE if _is_berserker_active() else PULSE_DAMAGE
	if gwihyeol >= HIGH_GWIHYEOL_THRESHOLD:
		value *= HIGH_GWIHYEOL_MULTIPLIER
	if ultimate_time_remaining > 0.0:
		value *= ULTIMATE_DAMAGE_MULTIPLIER
	return maxi(roundi(value), 1)


func on_enemy_died(_enemy: Node) -> void:
	if not active:
		return
	_gain_gwihyeol(KILL_GWIHYEOL)


func is_ultimate_ready() -> bool:
	return active and ultimate_time_remaining <= 0.0 and gwihyeol >= GWIHYEOL_MAX


func try_use_ultimate() -> bool:
	if not is_ultimate_ready():
		return false
	_set_gwihyeol(0.0, true)
	ultimate_time_remaining = ULTIMATE_DURATION
	_pulse_remaining = minf(_pulse_remaining, ULTIMATE_INTERVAL)
	_emit_ultimate_ready_if_changed(true)
	school_feedback.emit("귀인화")
	return true


func _is_berserker_active() -> bool:
	if not is_instance_valid(player):
		return false
	var safe_maximum := maxi(player.max_health, 1)
	return float(player.health) <= float(safe_maximum) * 0.5


func _gain_gwihyeol(amount: float) -> void:
	if amount <= 0.0:
		return
	var gain_multiplier := maxf(1.0 + run_modifiers.school_resource_gain_pct, 0.0)
	gain_multiplier *= maxf(1.0 + run_modifiers.ultimate_charge_gain_pct, 0.0)
	_set_gwihyeol(gwihyeol + amount * gain_multiplier, true)


func _set_gwihyeol(value: float, reset_gain_timer: bool) -> void:
	var previous := gwihyeol
	gwihyeol = clampf(value, 0.0, GWIHYEOL_MAX)
	if reset_gain_timer:
		time_since_gain = 0.0
	if not is_equal_approx(previous, gwihyeol):
		_emit_resource()
		_emit_ultimate_ready_if_changed()


func _deal_damage(target: Node, base_damage: float, damage_kind: StringName) -> int:
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if combat_resolver != null:
		return combat_resolver.deal_school_damage(target, base_damage, damage_kind)
	var requested := maxi(roundi(base_damage), 1)
	var result = target.call("take_damage", requested)
	if result is int:
		return maxi(int(result), 0)
	return requested


func _valid_enemies() -> Array[Node2D]:
	var result: Array[Node2D] = []
	if get_tree() == null:
		return result
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		if candidate.is_queued_for_deletion():
			continue
		if candidate.has_method("is_dead") and candidate.is_dead():
			continue
		if not candidate.has_method("take_damage"):
			continue
		result.append(candidate as Node2D)
	return result


func _emit_resource() -> void:
	resource_changed.emit("GWIHYEOL", gwihyeol, GWIHYEOL_MAX)


func _emit_ultimate_ready_if_changed(force: bool = false) -> void:
	var ready := is_ultimate_ready()
	if force or ready != _last_ultimate_ready:
		_last_ultimate_ready = ready
		ultimate_ready_changed.emit(ready)
