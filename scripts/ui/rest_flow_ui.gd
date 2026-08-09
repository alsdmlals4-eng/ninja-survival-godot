extends CanvasLayer
class_name RestFlowUI

signal result_continue_requested
signal shop_buy_requested(index: int)
signal shop_sell_requested(item_id: StringName)
signal shop_reroll_requested
signal shop_continue_requested
signal fate_selected_requested(fate_id: StringName)
signal preview_start_requested
signal restart_requested

@onready var panel: Control = $Panel
@onready var result_view: Control = $Panel/Margin/Content/ResultView
@onready var shop_view: Control = $Panel/Margin/Content/ShopView
@onready var fate_view: Control = $Panel/Margin/Content/FateView
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
@onready var preview_summary_label: Label = $Panel/Margin/Content/PreviewView/SummaryLabel
@onready var preview_start_button: Button = $Panel/Margin/Content/PreviewView/StartButton
@onready var complete_summary_label: Label = $Panel/Margin/Content/CompleteView/SummaryLabel
@onready var complete_restart_button: Button = $Panel/Margin/Content/CompleteView/RestartButton


func _ready() -> void:
	result_continue_button.pressed.connect(_on_result_continue_pressed)
	shop_reroll_button.pressed.connect(_on_shop_reroll_pressed)
	shop_continue_button.pressed.connect(_on_shop_continue_pressed)
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
	return [result_view, shop_view, fate_view, preview_view, complete_view]


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


func _on_preview_start_pressed() -> void:
	preview_start_requested.emit()


func _on_restart_pressed() -> void:
	restart_requested.emit()
