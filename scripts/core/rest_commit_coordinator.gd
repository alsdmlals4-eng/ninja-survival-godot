# Workbench 백팩·Fate·다음 경로를 한 번에 확정하는 T12 도메인 조정자다.
extends RefCounted
class_name RestCommitCoordinator

var _committed_backpack_state = null
var _source_backpack_state = null
var _build_state: RunBuildState
var _route_state: RunRouteState
var _fate_controller: FateController
var _session: RestBackpackSession
var _configured: bool = false
var _committed_this_rest: bool = false
var _commit_in_progress: bool = false


func configure(
	committed_backpack_state,
	build_state: RunBuildState,
	route_state: RunRouteState,
	fate_controller: FateController
) -> bool:
	if _session != null or _commit_in_progress:
		return false
	if committed_backpack_state == null or build_state == null or route_state == null or fate_controller == null:
		return false
	_source_backpack_state = committed_backpack_state
	_committed_backpack_state = committed_backpack_state.copy_value()
	_build_state = build_state
	_route_state = route_state
	_fate_controller = fate_controller
	_configured = true
	_committed_this_rest = false
	return true


func begin_rest(session: RestBackpackSession) -> bool:
	if not _configured or _committed_this_rest or _commit_in_progress or _session != null or session == null:
		return false
	if not _fate_controller._is_bound_to_build_state(_build_state):
		return false
	if not session._is_bound_to_committed_state(_source_backpack_state):
		return false
	_session = session
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
	if _commit_in_progress:
		failures.append(&"commit_in_progress")
	if _session == null:
		failures.append(&"missing_session")
		return failures

	failures.append_array(_session.commit_failures(chest_count, boss_reward_pending, combination_pending))
	if _fate_controller == null \
		or not _fate_controller._is_bound_to_build_state(_build_state) \
		or not _fate_controller._can_commit_pending():
		failures.append(&"fate_pending")
	if _route_state == null \
		or _route_state.cleared_school_ids().is_empty() \
		or _route_state.is_final_binding_eligible() \
		or not _route_state.can_commit_provisional_next_school():
		failures.append(&"route_pending")
	return failures


func commit(
	chest_count: int = 0,
	boss_reward_pending: bool = false,
	combination_pending: bool = false
) -> bool:
	if not commit_failures(chest_count, boss_reward_pending, combination_pending).is_empty():
		return false
	var candidate_state = _session.state
	var resolution = _session.current_resolution()
	if candidate_state == null or resolution == null or not bool(resolution.valid):
		return false

	# 사전검증 뒤 세 확정 호출은 외부 시그널 이전의 실패 불가능한 상태 전이이다.
	_commit_in_progress = true
	_committed_backpack_state = candidate_state.copy_value()
	_build_state.set_committed_backpack_modifiers(resolution.modifiers)
	if not _route_state.commit_provisional_next_school():
		_commit_in_progress = false
		return false
	if not _fate_controller._commit_pending():
		_commit_in_progress = false
		return false
	_committed_this_rest = true
	_session = null
	_commit_in_progress = false
	return true
