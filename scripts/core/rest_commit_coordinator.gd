extends RefCounted
class_name RestCommitCoordinator

var _committed_backpack_state = null
var _build_state: RunBuildState
var _route_state: RunRouteState
var _fate_controller: FateController
var _session: RestBackpackSession
var _committed_this_rest: bool = false


func configure(
	committed_backpack_state,
	build_state: RunBuildState,
	route_state: RunRouteState,
	fate_controller: FateController
) -> void:
	_committed_backpack_state = committed_backpack_state.copy_value() if committed_backpack_state != null else null
	_build_state = build_state
	_route_state = route_state
	_fate_controller = fate_controller
	_session = null
	_committed_this_rest = false


func begin_rest(session: RestBackpackSession) -> bool:
	if session == null or _build_state == null or _route_state == null or _fate_controller == null:
		return false
	if _session != null:
		return false
	if not _fate_controller._is_bound_to_build_state(_build_state):
		return false
	_session = session
	_committed_this_rest = false
	return true


func committed_backpack_state():
	if _committed_backpack_state == null:
		return null
	return _committed_backpack_state.copy_value()


func commit_failures(
	chest_count: int = 0,
	boss_reward_pending: bool = false,
	combination_pending: bool = false
) -> Array[StringName]:
	var failures: Array[StringName] = []
	if _committed_this_rest:
		failures.append(&"already_committed")
	if _session == null:
		failures.append(&"missing_session")
		return failures

	failures.append_array(_session.commit_failures(chest_count, boss_reward_pending, combination_pending))

	if _fate_controller == null \
		or not _fate_controller._is_bound_to_build_state(_build_state) \
		or not _fate_controller._can_commit_pending():
		failures.append(&"fate_pending")

	if _route_state == null:
		failures.append(&"route_pending")
	else:
		var provisional_school_id: StringName = _route_state.provisional_school_id()
		if provisional_school_id == &"" \
			or _route_state.active_school_id() != &"" \
			or _route_state.is_final_binding_eligible() \
			or not _route_state.is_school_unvisited(provisional_school_id):
			failures.append(&"route_pending")

	return failures


func commit(
	chest_count: int = 0,
	boss_reward_pending: bool = false,
	combination_pending: bool = false
) -> bool:
	if _committed_this_rest:
		return false
	if not commit_failures(chest_count, boss_reward_pending, combination_pending).is_empty():
		return false

	var candidate_state = _session.state
	var resolution = _session.current_resolution()
	if candidate_state == null or resolution == null or not bool(resolution.valid):
		return false

	# Every mutation below has a matching non-mutating prevalidation above. No signal
	# is emitted until Fate is committed, so observers see one coherent final tuple.
	if not _route_state.commit_provisional_next_school():
		return false
	_committed_backpack_state = candidate_state.copy_value()
	_build_state.set_committed_backpack_modifiers(resolution.modifiers)
	if not _fate_controller._commit_pending():
		return false

	_committed_this_rest = true
	_session = null
	return true