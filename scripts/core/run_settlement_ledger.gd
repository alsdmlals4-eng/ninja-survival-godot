# Run 안에서 서로 다른 학교 Boss의 소울 집계 자격을 중복 없이 기록한다.
extends RefCounted
class_name RunSettlementLedger

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]

var _eligible_school_boss_ids: Array[StringName] = []


func record_school_boss(school_id: StringName) -> bool:
	if not SCHOOL_IDS.has(school_id) or _eligible_school_boss_ids.has(school_id):
		return false
	_eligible_school_boss_ids.append(school_id)
	return true


func eligible_school_boss_ids() -> Array[StringName]:
	return _eligible_school_boss_ids.duplicate()


func get_snapshot() -> Dictionary:
	return {"eligible_school_boss_ids": eligible_school_boss_ids()}


func can_restore_from_snapshot(snapshot: Dictionary) -> bool:
	var restored: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("eligible_school_boss_ids", [])):
		var school_id := StringName(raw_school_id)
		if not SCHOOL_IDS.has(school_id) or restored.has(school_id):
			return false
		restored.append(school_id)
	return true


func restore_from_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_from_snapshot(snapshot):
		return false
	var restored: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("eligible_school_boss_ids", [])):
		var school_id := StringName(raw_school_id)
		restored.append(school_id)
	_eligible_school_boss_ids = restored
	return true
