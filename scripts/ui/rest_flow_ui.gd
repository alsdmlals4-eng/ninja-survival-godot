extends CanvasLayer
class_name RestFlowUI

const WORKBENCH_SCHOOL_DETAILS := {
	&"bongma": {
		"name": "봉마류",
		"risk": "위험: 이동 중 봉인 공간을 지켜야 합니다",
		"gimmick": "기믹: 식신과 결계를 배치합니다",
		"reward": "보상: 부적·식신 계열 접근",
		"tag": "태그: 이동 요새",
	},
	&"cheonsul": {
		"name": "천술류",
		"risk": "위험: 상태 순서를 읽어야 합니다",
		"gimmick": "기믹: 원소 반응을 준비합니다",
		"reward": "보상: 차크라·반응 계열 접근",
		"tag": "태그: 필드 변환",
	},
	&"guiin": {
		"name": "귀인류",
		"risk": "위험: 가까운 거리의 압박을 버텨야 합니다",
		"gimmick": "기믹: 근접 위험과 회복 창을 관리합니다",
		"reward": "보상: 오니가면·귀기 계열 접근",
		"tag": "태그: 위험한 근접",
	},
	&"heukyeong": {
		"name": "흑영류",
		"risk": "위험: 가장 위험한 표적을 먼저 골라야 합니다",
		"gimmick": "기믹: 표식과 처형 타이밍을 만듭니다",
		"reward": "보상: 그림자·처형 계열 접근",
		"tag": "태그: 위협 우선",
	},
}

const WORKBENCH_FAILURE_TEXT := {
	&"missing_session": "작업대 세션을 다시 열어야 합니다.",
	&"already_committed": "이 작업대는 이미 확정되었습니다.",
	&"commit_in_progress": "작업대 확정을 처리 중입니다.",
	&"boss_reward_pending": "보스 보상을 먼저 선택하세요.",
	&"chest_pending": "남은 상자를 먼저 정리하세요.",
	&"buffer_not_empty": "작업 버퍼의 아이템을 모두 배치하세요.",
	&"pending_bag": "대기 중인 가방을 먼저 배치하세요.",
	&"item_preview_pending": "아이템 미리보기를 확정하거나 취소하세요.",
	&"whole_layout_mode_active": "전체 배치 이동 모드를 종료하세요.",
	&"missing_state": "백팩 상태를 다시 불러와야 합니다.",
	&"missing_resolver": "백팩 배치 규칙을 다시 불러와야 합니다.",
	&"invalid_backpack": "백팩 배치가 유효하지 않습니다.",
	&"unknown_item_definition": "아이템 정의를 다시 확인해야 합니다.",
	&"unknown_bag_definition": "가방 정의를 다시 확인해야 합니다.",
	&"empty_bag_footprint": "가방 모양이 비어 있습니다.",
	&"bag_out_of_bounds": "가방 범위를 벗어났습니다.",
	&"bag_overlap": "가방이 겹치지 않게 배치하세요.",
	&"no_active_cells": "사용 가능한 활성 칸이 없습니다.",
	&"disconnected_active_cells": "활성 칸이 서로 이어져야 합니다.",
	&"empty_item_footprint": "아이템 모양이 비어 있습니다.",
	&"item_out_of_bounds": "아이템 범위를 벗어났습니다.",
	&"inactive_item_cell": "아이템이 사용할 수 없는 칸에 놓였습니다.",
	&"item_overlap": "아이템이 겹치지 않게 배치하세요.",
	&"combination_transaction_active": "조합 작업이 끝날 때까지 기다리세요.",
	&"unknown_item_instance": "선택한 아이템을 다시 확인하세요.",
	&"invalid_item_placement": "아이템 배치가 유효하지 않습니다.",
	&"missing_resolution": "백팩 배치 결과를 다시 확인하세요.",
	&"combination_pending": "조합 작업을 먼저 마무리하세요.",
	&"fate_pending": "운명을 하나 선택하세요.",
	&"route_pending": "다음 유파를 임시 선택하세요.",
	&"session_rebound": "작업대 세션을 다시 열어야 합니다.",
}

const BACKPACK_BOARD_SIZE := 6

signal result_continue_requested
signal shop_buy_requested(index: int)
signal shop_sell_requested(item_id: StringName)
signal shop_reroll_requested
signal shop_continue_requested
signal fate_selected_requested(fate_id: StringName)
signal workbench_route_selected_requested(school_id: StringName)
signal workbench_boss_reward_selected(index: int)
signal workbench_chest_open_requested
signal workbench_bag_purchase_requested
signal workbench_bag_placement_requested(origin: Vector2i, rotation_quarters: int)
signal workbench_buffer_placement_requested(buffer_index: int, origin: Vector2i, rotation_quarters: int)
signal workbench_existing_item_move_requested(instance_id: int, origin: Vector2i, rotation_quarters: int)
signal workbench_combination_begin_requested(combo_id: StringName, source_a_instance: int, source_b_instance: int)
signal workbench_combination_commit_requested(origin: Vector2i, rotation_quarters: int)
signal workbench_combination_cancel_requested
signal workbench_undo_requested
signal workbench_commit_requested
signal preview_start_requested
signal restart_requested

@onready var panel: Control = $Panel
@onready var result_view: Control = $Panel/Margin/Content/ResultView
@onready var shop_view: Control = $Panel/Margin/Content/ShopView
@onready var fate_view: Control = $Panel/Margin/Content/FateView
@onready var workbench_view: Control = $Panel/Margin/Content/WorkbenchView
@onready var preview_view: Control = $Panel/Margin/Content/PreviewView
@onready var complete_view: Control = $Panel/Margin/Content/CompleteView

@onready var result_damage_label: Label = $Panel/Margin/Content/ResultView/DamageLabel
@onready var result_healing_label: Label = $Panel/Margin/Content/ResultView/HealingLabel
@onready var result_defense_label: Label = $Panel/Margin/Content/ResultView/DefenseLabel
@onready var result_status_label: Label = $Panel/Margin/Content/ResultView/StatusLabel
@onready var result_combo_label: Label = $Panel/Margin/Content/ResultView/ComboLabel
@onready var result_gold_label: Label = $Panel/Margin/Content/ResultView/GoldLabel
@onready var result_hints_label: Label = $Panel/Margin/Content/ResultView/HintsLabel
@onready var result_continue_button: Button = $Panel/Margin/Content/ResultView/ContinueButton

@onready var shop_gold_label: Label = $Panel/Margin/Content/ShopView/GoldLabel
@onready var shop_offers: Container = $Panel/Margin/Content/ShopView/Offers
@onready var shop_owned_list: Container = $Panel/Margin/Content/ShopView/OwnedList
@onready var shop_reroll_button: Button = $Panel/Margin/Content/ShopView/RerollButton
@onready var shop_message_label: Label = $Panel/Margin/Content/ShopView/MessageLabel
@onready var shop_continue_button: Button = $Panel/Margin/Content/ShopView/ContinueButton

@onready var fate_candidates: Container = $Panel/Margin/Content/FateView/Candidates
@onready var workbench_route_cards: Container = $Panel/Margin/Content/WorkbenchView/RouteCards
@onready var workbench_fate_candidates: Container = $Panel/Margin/Content/WorkbenchView/FateCandidates
@onready var workbench_reward_status_label: Label = $Panel/Margin/Content/WorkbenchView/RewardStatusLabel
@onready var workbench_boss_reward_choices: Container = $Panel/Margin/Content/WorkbenchView/BossRewardChoices
@onready var workbench_chest_open_button: Button = $Panel/Margin/Content/WorkbenchView/ChestOpenButton
@onready var workbench_gold_label: Label = $Panel/Margin/Content/WorkbenchView/GoldLabel
@onready var workbench_bag_offer_button: Button = $Panel/Margin/Content/WorkbenchView/BagOfferButton
@onready var workbench_pending_bag_button: Button = $Panel/Margin/Content/WorkbenchView/PendingBagButton
@onready var workbench_buffer_items: Container = $Panel/Margin/Content/WorkbenchView/BufferItems
@onready var workbench_buffer_rotate_button: Button = $Panel/Margin/Content/WorkbenchView/BufferRotateButton
@onready var workbench_board_grid: GridContainer = $Panel/Margin/Content/WorkbenchView/BoardGrid
@onready var workbench_combination_title_label: Label = $Panel/Margin/Content/WorkbenchView/CombinationTitleLabel
@onready var workbench_combination_choices: Container = $Panel/Margin/Content/WorkbenchView/CombinationChoices
@onready var workbench_combination_cancel_button: Button = $Panel/Margin/Content/WorkbenchView/CombinationCancelButton
@onready var workbench_undo_button: Button = $Panel/Margin/Content/WorkbenchView/UndoButton
@onready var workbench_commit_status_label: Label = $Panel/Margin/Content/WorkbenchView/CommitStatusLabel
@onready var workbench_commit_button: Button = $Panel/Margin/Content/WorkbenchView/CommitButton
@onready var preview_summary_label: Label = $Panel/Margin/Content/PreviewView/SummaryLabel
@onready var preview_start_button: Button = $Panel/Margin/Content/PreviewView/StartButton
@onready var complete_summary_label: Label = $Panel/Margin/Content/CompleteView/SummaryLabel
@onready var complete_restart_button: Button = $Panel/Margin/Content/CompleteView/RestartButton

var _selected_buffer_index := -1
var _selected_buffer_rotation := 0
var _workbench_buffer: Array = []
var _workbench_pending_bag: Dictionary = {}
var _selected_pending_bag := false
var _selected_board_item_id := -1
var _board_item_by_cell: Dictionary = {}
var _active_board_cells: Dictionary = {}
var _pending_combination: Dictionary = {}


func _ready() -> void:
	result_continue_button.pressed.connect(_on_result_continue_pressed)
	shop_reroll_button.pressed.connect(_on_shop_reroll_pressed)
	shop_continue_button.pressed.connect(_on_shop_continue_pressed)
	workbench_commit_button.pressed.connect(_on_workbench_commit_pressed)
	workbench_chest_open_button.pressed.connect(_on_workbench_chest_open_pressed)
	workbench_bag_offer_button.pressed.connect(_on_workbench_bag_offer_pressed)
	workbench_pending_bag_button.pressed.connect(_on_workbench_pending_bag_pressed)
	workbench_buffer_rotate_button.pressed.connect(_on_workbench_buffer_rotate_pressed)
	workbench_combination_cancel_button.pressed.connect(_on_workbench_combination_cancel_pressed)
	workbench_undo_button.pressed.connect(_on_workbench_undo_pressed)
	preview_start_button.pressed.connect(_on_preview_start_pressed)
	complete_restart_button.pressed.connect(_on_restart_pressed)
	hide_all()


func show_result(snapshot: Dictionary) -> void:
	_show_only(result_view)
	result_damage_label.text = "피해 %d" % maxi(int(snapshot.get("damage", 0)), 0)
	result_healing_label.text = _contribution_text("회복", int(snapshot.get("healing", 0)))
	result_defense_label.text = _contribution_text("방어", int(snapshot.get("defense", 0)))
	result_status_label.text = "상태/반응 %d" % maxi(int(snapshot.get("status_events", 0)), 0)
	result_combo_label.text = "처치 %d  MAX COMBO %d" % [
		maxi(int(snapshot.get("kills", 0)), 0),
		maxi(int(snapshot.get("max_combo", 0)), 0),
	]
	result_gold_label.text = "획득 GOLD %d" % maxi(int(snapshot.get("gold_earned", 0)), 0)
	var hints: Array = snapshot.get("growth_hints", [])
	result_hints_label.text = "추천 없음" if hints.is_empty() else "\n".join(_string_array(hints))


func show_shop(
	gold: int,
	offer_ids: Array[StringName],
	item_defs: Dictionary,
	owned_items: Dictionary,
	reroll_cost: int,
	message: String = ""
) -> void:
	_show_only(shop_view)
	shop_gold_label.text = "GOLD %d" % maxi(gold, 0)
	shop_reroll_button.text = "리롤 %dG" % maxi(reroll_cost, 0)
	shop_message_label.text = message
	_clear_children(shop_offers)
	_clear_children(shop_owned_list)

	for index in range(offer_ids.size()):
		var item_id: StringName = offer_ids[index]
		var definition = item_defs.get(item_id)
		var button := Button.new()
		if definition == null:
			button.text = str(item_id)
		else:
			button.text = "%s\n%dG" % [definition.display_name, definition.base_price]
		button.pressed.connect(_on_shop_offer_pressed.bind(index))
		shop_offers.add_child(button)

	for raw_id in owned_items.keys():
		var item_id := StringName(raw_id)
		var count := maxi(int(owned_items.get(item_id, 0)), 0)
		if count <= 0:
			continue
		var definition = item_defs.get(item_id)
		var button := Button.new()
		if definition == null:
			button.text = "%s x%d" % [item_id, count]
		else:
			button.text = "%s x%d  판매 %dG" % [definition.display_name, count, definition.sell_price()]
		button.pressed.connect(_on_shop_sell_pressed.bind(item_id))
		shop_owned_list.add_child(button)


func show_fate(candidate_ids: Array[StringName], fate_defs: Dictionary) -> void:
	_show_only(fate_view)
	_clear_children(fate_candidates)
	for fate_id in candidate_ids:
		var definition = fate_defs.get(fate_id)
		var button := Button.new()
		if definition == null:
			button.text = str(fate_id)
		else:
			button.text = "%s\n장점: %s\n대가: %s" % [
				definition.display_name,
				definition.benefit_text,
				definition.cost_text,
			]
		button.pressed.connect(_on_fate_pressed.bind(fate_id))
		fate_candidates.add_child(button)


func show_workbench(
	route_snapshot: Dictionary,
	fate_candidate_ids: Array[StringName],
	fate_definitions: Dictionary,
	pending_fate_id: StringName,
	readiness_failures: Array[StringName],
	workbench_context: Dictionary = {}
) -> void:
	_show_only(workbench_view)
	var provisional_school_id := StringName(route_snapshot.get("provisional_school_id", &""))
	var has_route := _render_workbench_routes(route_snapshot, provisional_school_id)
	var has_fate := _render_workbench_fates(fate_candidate_ids, fate_definitions, pending_fate_id)
	_render_workbench_reward_status(workbench_context)
	_render_workbench_spatial_inputs(workbench_context)
	_render_workbench_commit(has_route, has_fate, readiness_failures)


func show_preview(summary: Dictionary) -> void:
	_show_only(preview_view)
	preview_summary_label.text = _summary_text(summary)


func show_complete(summary: Dictionary) -> void:
	_show_only(complete_view)
	complete_summary_label.text = _summary_text(summary)


func hide_all() -> void:
	panel.visible = false
	for view in _all_views():
		view.visible = false


func _show_only(view: Control) -> void:
	panel.visible = true
	for candidate in _all_views():
		candidate.visible = candidate == view


func _all_views() -> Array[Control]:
	return [result_view, shop_view, fate_view, workbench_view, preview_view, complete_view]


func _contribution_text(label: String, value: int) -> String:
	if value <= 0:
		return "%s 기여 없음" % label
	return "%s %d" % [label, value]


func _summary_text(summary: Dictionary) -> String:
	var lines: Array[String] = []
	var headline := str(summary.get("headline", ""))
	if not headline.is_empty():
		lines.append(headline)
	var shop_changes: Array = summary.get("shop_changes", [])
	if not shop_changes.is_empty():
		lines.append("상점: %s" % " / ".join(_string_array(shop_changes)))
	var new_fate := str(summary.get("new_fate", ""))
	if not new_fate.is_empty():
		lines.append("이번 운명: %s" % new_fate)
	var selected_fates: Array = summary.get("selected_fates", [])
	if not selected_fates.is_empty():
		lines.append("누적 운명: %s" % " / ".join(_string_array(selected_fates)))
	if summary.has("gold"):
		lines.append("GOLD %d" % maxi(int(summary.get("gold", 0)), 0))
	var next_boss := str(summary.get("next_boss", ""))
	if not next_boss.is_empty():
		lines.append(next_boss)
	return "\n".join(lines)


func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result


func _render_workbench_routes(route_snapshot: Dictionary, provisional_school_id: StringName) -> bool:
	_clear_children(workbench_route_cards)
	var rendered_provisional := false
	var focus_target: Button = null
	var rendered_school_ids: Array[StringName] = []
	var unvisited_school_ids: Array = route_snapshot.get("unvisited_school_ids", [])
	for raw_school_id in unvisited_school_ids:
		var school_id := StringName(raw_school_id)
		if rendered_school_ids.has(school_id):
			continue
		var details: Dictionary = WORKBENCH_SCHOOL_DETAILS.get(school_id, {})
		if details.is_empty():
			continue
		rendered_school_ids.append(school_id)
		var button := Button.new()
		var lines := [
			str(details.get("name", school_id)),
			str(details.get("risk", "")),
			str(details.get("gimmick", "")),
			str(details.get("reward", "")),
			str(details.get("tag", "")),
		]
		if school_id == provisional_school_id:
			lines.append("임시 선택")
			rendered_provisional = true
			focus_target = button
		elif focus_target == null:
			focus_target = button
		button.text = "\n".join(lines)
		button.pressed.connect(_on_workbench_route_pressed.bind(school_id))
		workbench_route_cards.add_child(button)
	if focus_target != null:
		focus_target.call_deferred("grab_focus")
	return rendered_provisional


func _render_workbench_fates(
	fate_candidate_ids: Array[StringName],
	fate_definitions: Dictionary,
	pending_fate_id: StringName
) -> bool:
	_clear_children(workbench_fate_candidates)
	var rendered_pending := false
	var rendered_fate_ids: Array[StringName] = []
	for fate_id in fate_candidate_ids:
		if rendered_fate_ids.has(fate_id):
			continue
		var definition = fate_definitions.get(fate_id)
		if definition == null:
			continue
		rendered_fate_ids.append(fate_id)
		var button := Button.new()
		var lines := [
			str(definition.display_name),
			"장점: %s" % str(definition.benefit_text),
			"대가: %s" % str(definition.cost_text),
		]
		if fate_id == pending_fate_id:
			lines.append("임시 선택")
			rendered_pending = true
		button.text = "\n".join(lines)
		button.pressed.connect(_on_fate_pressed.bind(fate_id))
		workbench_fate_candidates.add_child(button)
	return rendered_pending


func _render_workbench_commit(
	has_route: bool,
	has_fate: bool,
	readiness_failures: Array[StringName]
) -> void:
	var messages: Array[String] = []
	if not has_route:
		messages.append("다음 유파를 임시 선택하세요.")
	if not has_fate:
		messages.append("운명을 하나 선택하세요.")
	for failure in readiness_failures:
		messages.append(str(WORKBENCH_FAILURE_TEXT.get(failure, "작업대 상태를 다시 확인하세요.")))
	workbench_commit_button.disabled = not has_route or not has_fate or not readiness_failures.is_empty()
	workbench_commit_status_label.text = "확정 가능" if messages.is_empty() else "\n".join(messages)


func _render_workbench_reward_status(workbench_context: Dictionary) -> void:
	workbench_reward_status_label.text = ""
	if not bool(workbench_context.get("boss_reward_pending", false)):
		return
	var labels: Array = workbench_context.get("boss_reward_labels", [])
	var names: Array[String] = []
	for label in labels:
		var text := str(label)
		if not text.is_empty():
			names.append(text)
	var candidates := " / ".join(names)
	if candidates.is_empty():
		workbench_reward_status_label.text = "보스 보상이 준비되었습니다. 선택과 배치를 먼저 완료하세요."
		return
	workbench_reward_status_label.text = "보스 보상 후보: %s\n선택·배치 조작은 자동으로 확정되지 않습니다." % candidates


func _render_workbench_spatial_inputs(workbench_context: Dictionary) -> void:
	_selected_buffer_index = -1
	_selected_buffer_rotation = 0
	_selected_pending_bag = false
	_selected_board_item_id = -1
	_workbench_buffer = workbench_context.get("buffer", []).duplicate(true)
	_workbench_pending_bag = workbench_context.get("pending_bag", {}).duplicate(true)
	_pending_combination = workbench_context.get("pending_combination", {}).duplicate(true)
	_render_workbench_boss_rewards(workbench_context)
	_render_workbench_chest(workbench_context)
	_render_workbench_gold(workbench_context)
	_render_workbench_bag_offer(workbench_context)
	_render_workbench_buffer()
	_render_workbench_board(workbench_context)
	_render_workbench_combinations(workbench_context)
	_render_workbench_undo(workbench_context)


func _render_workbench_boss_rewards(workbench_context: Dictionary) -> void:
	_clear_children(workbench_boss_reward_choices)
	if not bool(workbench_context.get("boss_reward_pending", false)):
		return
	var labels: Array = workbench_context.get("boss_reward_labels", [])
	for index in range(labels.size()):
		var button := Button.new()
		button.text = str(labels[index])
		button.tooltip_text = "보상 후보를 작업 버퍼로 옮깁니다. 배치와 작업대 확정은 별도입니다."
		button.pressed.connect(_on_workbench_boss_reward_pressed.bind(index))
		workbench_boss_reward_choices.add_child(button)


func _render_workbench_chest(workbench_context: Dictionary) -> void:
	var chest_count := maxi(int(workbench_context.get("chest_count", 0)), 0)
	workbench_chest_open_button.text = "상자 열기 (%d)" % chest_count
	workbench_chest_open_button.tooltip_text = "상자 하나를 열어 작업 버퍼에 두 아이템을 넣습니다. 배치와 확정은 별도입니다."
	workbench_chest_open_button.disabled = chest_count <= 0


func _render_workbench_gold(workbench_context: Dictionary) -> void:
	workbench_gold_label.text = "보유 G %dG" % maxi(int(workbench_context.get("gold", 0)), 0)


func _render_workbench_bag_offer(workbench_context: Dictionary) -> void:
	var bag_offer: Dictionary = workbench_context.get("bag_offer", {})
	var display_name := str(bag_offer.get("display_name", "가방 없음"))
	var price := maxi(int(bag_offer.get("price", 0)), 0)
	workbench_bag_offer_button.text = "가방 구매: %s · %dG" % [display_name, price]
	workbench_bag_offer_button.tooltip_text = "가방을 작업대 대기 상태로 받고, 6×6 보드의 시작 칸을 선택해 배치합니다."
	var gold := maxi(int(workbench_context.get("gold", 0)), 0)
	workbench_bag_offer_button.disabled = bag_offer.is_empty() or not _workbench_pending_bag.is_empty() or not _pending_combination.is_empty() or gold < price
	workbench_pending_bag_button.visible = not _workbench_pending_bag.is_empty()
	workbench_pending_bag_button.disabled = _workbench_pending_bag.is_empty() or not _pending_combination.is_empty()
	if not _workbench_pending_bag.is_empty():
		workbench_pending_bag_button.text = "%s 배치" % str(_workbench_pending_bag.get("display_name", "대기 가방"))
		workbench_pending_bag_button.tooltip_text = "가방을 선택한 뒤 회전하고 6×6 보드의 시작 칸을 누르세요."


func _render_workbench_buffer() -> void:
	_clear_children(workbench_buffer_items)
	for index in range(_workbench_buffer.size()):
		var item: Dictionary = _workbench_buffer[index]
		var button := Button.new()
		var item_name := str(item.get("display_name", item.get("definition_id", "아이템")))
		button.text = item_name
		button.tooltip_text = "배치할 아이템을 선택합니다. 회전 후 6×6 보드의 칸을 누르세요."
		button.disabled = not _pending_combination.is_empty()
		button.pressed.connect(_on_workbench_buffer_item_pressed.bind(index))
		workbench_buffer_items.add_child(button)
	workbench_buffer_rotate_button.disabled = _selected_buffer_index < 0 and not _selected_pending_bag and _selected_board_item_id <= 0 and _pending_combination.is_empty()
	_update_workbench_buffer_selection()


func _render_workbench_board(workbench_context: Dictionary = {}) -> void:
	if not workbench_context.is_empty():
		_board_item_by_cell.clear()
		_active_board_cells.clear()
		var board: Dictionary = workbench_context.get("backpack_board", {})
		for raw_cell in board.get("active_cells", []):
			_active_board_cells[Vector2i(raw_cell)] = true
		for raw_item in board.get("items", []):
			var item: Dictionary = raw_item
			for raw_cell in item.get("cells", []):
				_board_item_by_cell[Vector2i(raw_cell)] = item.duplicate(true)
	_clear_children(workbench_board_grid)
	for y in range(BACKPACK_BOARD_SIZE):
		for x in range(BACKPACK_BOARD_SIZE):
			var cell := Vector2i(x, y)
			var board_item: Dictionary = _board_item_by_cell.get(cell, {})
			var is_active := _active_board_cells.has(cell)
			var button := Button.new()
			button.custom_minimum_size = Vector2(40.0, 40.0)
			button.text = "·"
			button.tooltip_text = "비활성 칸 %d, %d" % [x + 1, y + 1]
			if not board_item.is_empty():
				button.text = str(board_item.get("display_name", "아이템"))
				button.tooltip_text = "%s — 눌러서 이동·회전" % button.text
			elif is_active:
				button.text = "□"
				button.tooltip_text = "활성 칸 %d, %d" % [x + 1, y + 1]
			button.disabled = not is_active and not _selected_pending_bag
			button.pressed.connect(_on_workbench_board_cell_pressed.bind(cell))
			workbench_board_grid.add_child(button)


func _render_workbench_undo(workbench_context: Dictionary) -> void:
	workbench_undo_button.disabled = not bool(workbench_context.get("can_undo", false)) or not _pending_combination.is_empty()


func _render_workbench_combinations(workbench_context: Dictionary) -> void:
	_clear_children(workbench_combination_choices)
	var options: Array = workbench_context.get("combination_options", [])
	var pending := not _pending_combination.is_empty()
	workbench_combination_title_label.visible = pending or not options.is_empty()
	workbench_combination_choices.visible = not options.is_empty()
	workbench_combination_cancel_button.visible = pending
	workbench_combination_cancel_button.disabled = not pending
	if pending:
		workbench_combination_title_label.text = "%s 배치 — 6×6 보드의 시작 칸을 누르세요" % str(_pending_combination.get("display_name", "조합 결과"))
		return
	workbench_combination_title_label.text = "조합 가능 — 인접한 재료를 선택해 결과를 배치"
	for raw_option in options:
		var option: Dictionary = raw_option
		var button := Button.new()
		button.text = str(option.get("display_name", "조합"))
		button.tooltip_text = "두 재료를 소비하기 전에 결과 배치 칸을 먼저 선택합니다."
		button.pressed.connect(_on_workbench_combination_begin_pressed.bind(
			StringName(option.get("combo_id", &"")),
			int(option.get("source_a_instance", 0)),
			int(option.get("source_b_instance", 0))
		))
		workbench_combination_choices.add_child(button)


func _update_workbench_buffer_selection() -> void:
	for index in range(workbench_buffer_items.get_child_count()):
		var button := workbench_buffer_items.get_child(index) as Button
		if button == null:
			continue
		button.disabled = not _pending_combination.is_empty()
		if not _selected_pending_bag and index == _selected_buffer_index:
			button.text = "%s  선택됨 · %d°" % [
				str(_workbench_buffer[index].get("display_name", _workbench_buffer[index].get("definition_id", "아이템"))),
				_selected_buffer_rotation * 90,
			]
	workbench_pending_bag_button.text = "%s%s" % [
		str(_workbench_pending_bag.get("display_name", "대기 가방")),
		"  선택됨 · %d°" % (_selected_buffer_rotation * 90) if _selected_pending_bag and not _workbench_pending_bag.is_empty() else " 배치",
	]
	var selection_name := "선택 대상"
	if _selected_board_item_id > 0:
		selection_name = "배치 아이템"
	elif not _pending_combination.is_empty():
		selection_name = "조합 결과"
	workbench_buffer_rotate_button.text = "%s 회전 %d°" % [selection_name, _selected_buffer_rotation * 90]


func _on_workbench_boss_reward_pressed(index: int) -> void:
	workbench_boss_reward_selected.emit(index)


func _on_workbench_chest_open_pressed() -> void:
	if workbench_chest_open_button.disabled:
		return
	workbench_chest_open_requested.emit()


func _on_workbench_bag_offer_pressed() -> void:
	if workbench_bag_offer_button.disabled:
		return
	workbench_bag_purchase_requested.emit()


func _on_workbench_pending_bag_pressed() -> void:
	if _workbench_pending_bag.is_empty():
		return
	_selected_pending_bag = true
	_selected_buffer_index = -1
	_selected_board_item_id = -1
	_selected_buffer_rotation = int(_workbench_pending_bag.get("rotation_quarters", 0)) % 4
	_update_workbench_buffer_selection()


func _on_workbench_buffer_item_pressed(index: int) -> void:
	if index < 0 or index >= _workbench_buffer.size():
		return
	_selected_buffer_index = index
	_selected_pending_bag = false
	_selected_board_item_id = -1
	_selected_buffer_rotation = int(_workbench_buffer[index].get("rotation_quarters", 0)) % 4
	_update_workbench_buffer_selection()


func _on_workbench_buffer_rotate_pressed() -> void:
	if _selected_buffer_index < 0 and not _selected_pending_bag and _selected_board_item_id <= 0 and _pending_combination.is_empty():
		return
	_selected_buffer_rotation = (_selected_buffer_rotation + 1) % 4
	_update_workbench_buffer_selection()


func _on_workbench_board_cell_pressed(origin: Vector2i) -> void:
	if not _pending_combination.is_empty():
		workbench_combination_commit_requested.emit(origin, _selected_buffer_rotation)
		return
	if _selected_pending_bag:
		workbench_bag_placement_requested.emit(origin, _selected_buffer_rotation)
		return
	if _selected_buffer_index < 0:
		if _selected_board_item_id > 0:
			workbench_existing_item_move_requested.emit(
				_selected_board_item_id,
				origin,
				_selected_buffer_rotation
			)
			return
		var board_item: Dictionary = _board_item_by_cell.get(origin, {})
		if board_item.is_empty():
			return
		_selected_board_item_id = int(board_item.get("instance_id", -1))
		_selected_pending_bag = false
		_selected_buffer_rotation = int(board_item.get("rotation_quarters", 0)) % 4
		_update_workbench_buffer_selection()
		return
	workbench_buffer_placement_requested.emit(_selected_buffer_index, origin, _selected_buffer_rotation)


func _on_workbench_undo_pressed() -> void:
	if workbench_undo_button.disabled:
		return
	workbench_undo_requested.emit()


func _on_workbench_combination_begin_pressed(combo_id: StringName, source_a_instance: int, source_b_instance: int) -> void:
	if combo_id == &"" or source_a_instance <= 0 or source_b_instance <= 0:
		return
	workbench_combination_begin_requested.emit(combo_id, source_a_instance, source_b_instance)


func _on_workbench_combination_cancel_pressed() -> void:
	if _pending_combination.is_empty():
		return
	workbench_combination_cancel_requested.emit()


func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.free()


func _on_result_continue_pressed() -> void:
	result_continue_requested.emit()


func _on_shop_offer_pressed(index: int) -> void:
	shop_buy_requested.emit(index)


func _on_shop_sell_pressed(item_id: StringName) -> void:
	shop_sell_requested.emit(item_id)


func _on_shop_reroll_pressed() -> void:
	shop_reroll_requested.emit()


func _on_shop_continue_pressed() -> void:
	shop_continue_requested.emit()


func _on_fate_pressed(fate_id: StringName) -> void:
	fate_selected_requested.emit(fate_id)


func _on_workbench_route_pressed(school_id: StringName) -> void:
	workbench_route_selected_requested.emit(school_id)


func _on_workbench_commit_pressed() -> void:
	if workbench_commit_button.disabled:
		return
	workbench_commit_requested.emit()


func _on_preview_start_pressed() -> void:
	preview_start_requested.emit()


func _on_restart_pressed() -> void:
	restart_requested.emit()
