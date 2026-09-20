# Adapter for the existing Workbench view. No combat or save authority here.
extends Node

signal departed(profile: Dictionary)

const ADAPTER = preload("res://scripts/ui/selected_rest_adapter.gd")
const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const SHOP = preload("res://scripts/core/shop_controller.gd")

var adapter
var view
var message_label: Label
var _actions: VBoxContainer
var _buttons: Dictionary = {}
var _charge: Dictionary = {}
var _connections: Array = []
var _message := "휴식 회복은 진입 시 1회 적용됩니다. 구매·강화는 즉시 저장되며 전투 효과는 출전 확정 후 반영됩니다."

func configure(rest_view, store, charge: Dictionary) -> Dictionary:
	if view != null: return {"ok": false, "reason": &"already_open"}
	adapter = ADAPTER.new()
	var result: Dictionary = adapter.open(store)
	if not result.ok: return result
	view = rest_view
	_charge = charge.duplicate(true)
	_actions = VBoxContainer.new()
	_actions.name = "SelectedCampActions"
	view.workbench_view.add_child(_actions)
	view.workbench_view.move_child(_actions, 1)
	message_label = Label.new()
	message_label.name = "SelectedCampMessage"
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	view.workbench_view.add_child(message_label)
	view.workbench_view.move_child(message_label, 1)
	_bind(view.workbench_route_selected_requested, func(id): adapter.choose_route(id); refresh())
	_bind(view.fate_selected_requested, func(id): adapter.choose_fate(id); refresh())
	_bind(view.workbench_boss_reward_selected, func(index): _buy_reserved("boss_reward", index))
	_bind(view.workbench_chest_open_requested, func(): _act("chest", ""))
	_bind(view.workbench_bag_purchase_requested, func(): _act("bag", str(adapter.snapshot().reward_state.shop.bag_id)))
	_bind(view.workbench_shop_buy_requested, func(index): _buy_reserved("shop_item", index))
	_bind(view.workbench_shop_sell_requested, func(id): _act("sell_item", str(id)))
	_bind(view.workbench_shop_reroll_requested, func(): _act("reroll", ""))
	_bind(view.workbench_bag_placement_requested, func(pos, rot): _edit("place_bag", [pos, rot]))
	_bind(view.workbench_buffer_placement_requested, func(index, pos, rot): _edit("place_buffer", [index, pos, rot]))
	_bind(view.workbench_existing_item_move_requested, func(id, pos, rot): _edit("move", [id, pos, rot]))
	_bind(view.workbench_undo_requested, func(): _edit("undo", []))
	_bind(view.workbench_combination_begin_requested, func(id, a, b): adapter.begin_combination(id, a, b); refresh())
	_bind(view.workbench_combination_cancel_requested, func(): adapter.cancel_combination(); refresh())
	_bind(view.workbench_combination_commit_requested, func(pos, rot): _result(adapter.commit_combination(pos, rot)))
	_bind(view.workbench_commit_requested, _depart)
	refresh()
	return {"ok": true}

func _bind(source: Signal, callback: Callable) -> void:
	source.connect(callback)
	_connections.append([source, callback])

func _exit_tree() -> void:
	for connection in _connections:
		if is_instance_valid(connection[0].get_object()) and connection[0].is_connected(connection[1]): connection[0].disconnect(connection[1])
	if is_instance_valid(_actions): _actions.queue_free()
	if is_instance_valid(message_label): message_label.queue_free()

func action_button(kind: String, id: String):
	return _buttons.get(kind + ":" + id)

func refresh() -> void:
	if adapter.snapshot().is_empty(): return
	var focused_key := ""
	var focus = view.get_viewport().gui_get_focus_owner()
	for key in _buttons:
		if _buttons[key] == focus: focused_key = key
	var context := _context()
	var fate_ids: Array[StringName] = []
	for id in adapter.snapshot().get("fate_state", {}).get("candidate_ids", []): fate_ids.append(StringName(id))
	view.show_workbench(adapter.route.get_route_snapshot(), fate_ids, FATES.build_fates(),
		StringName(adapter.pending_fate), adapter.readiness(_charge), context)
	_render_actions()
	message_label.text = _message
	if not focused_key.is_empty(): _restore_action_focus.call_deferred(focused_key)
	else: _focus_pending_action.call_deferred()
	_ensure_focus_visible_after_layout()

func _ensure_focus_visible_after_layout() -> void:
	# Containers recalculate after newly-created actions enter the tree. Following
	# focus in the same frame uses stale rectangles (even with follow_focus=true).
	await get_tree().process_frame
	if not is_instance_valid(view) or not view.workbench_view.is_visible_in_tree(): return
	var target = view.get_viewport().gui_get_focus_owner()
	if is_instance_valid(target) and view.workbench_view.is_ancestor_of(target):
		view.get_node("Panel/Margin").ensure_control_visible(target)

func _focus_pending_action() -> void:
	for key in _buttons:
		if (key.begins_with("reload:") or key.begins_with("trace:")) and not _buttons[key].disabled:
			_restore_action_focus(key)
			return
	if adapter.snapshot().get("reward_state", {}).get("boss_pending", false) and view.workbench_boss_reward_choices.get_child_count() > 0:
		view.workbench_boss_reward_choices.get_child(0).grab_focus()
	elif not view.workbench_chest_open_button.disabled:
		view.workbench_chest_open_button.grab_focus()
	elif view.workbench_route_cards.get_child_count() > 0:
		view.workbench_route_cards.get_child(0).grab_focus()
	else: view.workbench_commit_button.grab_focus()

func _restore_action_focus(key: String) -> void:
	var target = _buttons.get(key)
	if is_instance_valid(target) and not target.disabled and target.is_visible_in_tree(): target.grab_focus()
	else: _focus_pending_action()

func _label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_actions.add_child(label)

func _button(kind: String, id: String, text: String, disabled := false) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 44
	button.disabled = disabled or adapter.reload_required or not adapter.pending_combination.is_empty()
	if kind == "reload": button.disabled = false
	button.pressed.connect(_act.bind(kind, id))
	_actions.add_child(button)
	_buttons[kind + ":" + id] = button

func _render_actions() -> void:
	_buttons.clear()
	for child in _actions.get_children():
		_actions.remove_child(child)
		child.queue_free()
	var prep: Dictionary = adapter.snapshot()
	var profile: Dictionary = adapter.profile_snapshot()
	var school: String = profile.active_run.checkpoint.route.active_school_id
	var school_name: String = view.WORKBENCH_SCHOOL_DETAILS[StringName(school)].name
	if adapter.reload_required:
		_label("저장 상태를 다시 확인해야 합니다. 추가 구매·출전을 잠시 막았습니다.")
		_button("reload", "", "저장된 휴식 상태 다시 읽기")
	if not prep.access.trace_decisions.has(school):
		_label("%s 흔적 — 아래 중 한 번만 선택" % school_name)
		if school != str(profile.active_run.starting_school):
			_button("trace", "absorb", "유파 흡수 · %s 인법서 구매 자격 해금 (인술 즉시 지급 아님)" % school_name)
		else: _label("시작 유파는 이미 해금되어 있습니다. 시작 인법은 유지하고 장비에 힘을 더합니다.")
		for slot in GEAR.SLOTS:
			var id: String = prep.equipment.equipped_slots[slot]
			var gear_name: String = GEAR.CATALOG.definition(StringName(prep.equipment.owned_instances[id].definition_id)).name
			_button("trace", slot, "유파 강화 · %s에 %s 추가 (해당 유파 인술 추가 해금 없음)" % [gear_name, GEAR.GROWTH.power(StringName(school), StringName(slot)).name])
	else: _label("%s 흔적 선택 완료 · %s" % [school_name, "흡수" if prep.access.trace_decisions[school].choice == "absorb" else "장비에 유파의 힘 부여"])
	_label("장비 — 가방 칸을 사용하지 않습니다 / 모닥불 수치 강화는 유파 강화와 별개")
	var gear = GEAR.new()
	gear.restore_snapshot(prep.equipment)
	for slot in GEAR.SLOTS:
		var id: String = prep.equipment.equipped_slots[slot]
		var definition: Dictionary = GEAR.CATALOG.definition(StringName(prep.equipment.owned_instances[id].definition_id))
		var rank := int(prep.equipment.upgrade_rank_by_instance[id])
		var quote: Dictionary = gear.forge_quote(StringName(slot))
		_label("장착: %s +%d" % [definition.name, rank])
		if quote.ok:
			_button("forge", slot, "수치 강화 · %s +%d → +%d · %d엽전 / 성공 %d%% · 실패 시 장비·등급 유지" % [definition.name, rank, quote.next_rank, quote.cost, quote.chance_percent], prep.gold < quote.cost)
	for id in GEAR.CATALOG.DEFINITIONS:
		var definition: Dictionary = GEAR.CATALOG.definition(StringName(id))
		if prep.equipment.owned_instances.has("gear_" + id):
			if prep.equipment.equipped_slots[definition.slot] != "gear_" + id: _button("equip", id, "%s 장착 · 출전 시 반영" % definition.name)
		else: _button("equipment", id, "장비 구매 · %s / %d엽전" % [definition.name, definition.price], prep.gold < definition.price)
	_label("인법서 상점 — 해금된 유파만 판매 / 구입 후 가방에 배치해야 발동")
	var owned_spells: Array = []
	var spatial: Dictionary = adapter.spatial.persistent_preparation_snapshot()
	for item in spatial.backpack.items + spatial.buffer: owned_spells.append(BOOKS.spell_id(StringName(item.definition_id)))
	for id in BOOKS.NINJUTSU.build_definitions():
		var definition = BOOKS.NINJUTSU.definition_for_id(id)
		if not prep.access.unlocked_ninjutsu_school_ids.has(str(definition.school_id)) or owned_spells.has(id): continue
		var price := int(BOOKS.build_items()[BOOKS.book_id(id)].base_price)
		_button("book", str(id), "%s 구매 · %d엽전" % [definition.display_name, price], prep.gold < price or spatial.buffer.size() >= 6)
	if prep.has("vitals"):
		_label("체력 %d / %d · 비상약 %d / 1" % [prep.vitals.health, prep.vitals.max_health, prep.vitals.emergency_potions])
		for kind in ["potion", "emergency"]:
			var data: Dictionary = GEAR.GROWTH.CONSUMABLES[kind]
			var unavailable: bool = prep.vitals.health >= prep.vitals.max_health if kind == "potion" else prep.vitals.emergency_potions >= data.capacity
			_button(kind, "", "%s · 체력 %d 회복 / %d엽전" % ["즉시 회복약" if kind == "potion" else "비상약 비축", data.healing, data.cost], unavailable or prep.gold < data.cost)

func _buy_reserved(kind: String, index: int) -> void:
	var rewards: Dictionary = adapter.snapshot().reward_state
	var ids: Array = rewards.boss_ids if kind == "boss_reward" else rewards.shop.offer_ids
	if index >= 0 and index < ids.size(): _act(kind, str(ids[index]))

func _act(kind: String, id: String) -> void:
	match kind:
		"reload": _result(adapter.reload())
		"trace": _result(adapter.trace("absorb", "") if id == "absorb" else adapter.trace("enhance", id))
		"forge": _result(adapter.forge(id))
		_: _result(adapter.purchase(kind, id))

func _edit(kind: String, args: Array) -> void:
	_message = "배치 변경 — 출전 확정 또는 구매 시 함께 저장됩니다." if adapter.edit(kind, args) else "배치할 수 없습니다. 빈 칸·회전·가방 범위를 확인하세요."
	refresh()

func _result(result: Dictionary) -> void:
	if result.ok and result.get("departed", false):
		view.hide_all()
		departed.emit(result.profile)
		return
	if not result.ok:
		_message = "처리 실패 · %s. 저장 재확인이 필요한 경우 다시 읽기를 선택하세요." % str(result.get("reason", "unknown"))
	elif result.get("outcome", {}).has("succeeded"):
		_message = "수치 강화 성공!" if result.outcome.succeeded else "수치 강화 실패 — 엽전만 소모되고 기존 장비·등급·유파 힘은 유지됩니다."
	else: _message = "반영 완료. 전투 능력은 출전 확정 후 적용됩니다."
	refresh()

func _depart() -> void:
	var result: Dictionary = adapter.depart(_charge)
	if not result.ok: _result(result); return
	view.hide_all()
	departed.emit(result.profile)

func _context() -> Dictionary:
	var prep: Dictionary = adapter.snapshot()
	var session = adapter.spatial
	var items: Dictionary = ADAPTER.ITEMS.build_items()
	var bags: Dictionary = ADAPTER.BAGS.build_bags()
	var rewards: Dictionary = prep.reward_state
	var labels: Array = []
	for id in rewards.boss_ids: labels.append(items[StringName(id)].display_name)
	var buffer: Array = []
	for item in session.buffer:
		buffer.append({"instance_id": item.instance_id, "definition_id": item.definition_id,
			"display_name": items[item.definition_id].display_name, "rotation_quarters": item.rotation_quarters,
			"sell_price": items[item.definition_id].sell_price()})
	var offers: Array = []
	for id in rewards.shop.offer_ids:
		var definition = items.get(StringName(id))
		offers.append({"definition_id": id, "display_name": definition.display_name if definition != null else "판매 완료", "price": definition.base_price if definition != null else 0})
	var bag_offer: Dictionary = {}
	if not rewards.shop.bag_bought and bags.has(StringName(rewards.shop.bag_id)):
		var definition = bags[StringName(rewards.shop.bag_id)]
		bag_offer = {"definition_id": definition.id, "display_name": definition.display_name, "price": definition.base_price}
	var pending_bag: Dictionary = {}
	if session.pending_bag != null:
		var bag = session.pending_bag
		pending_bag = {"instance_id": bag.instance_id, "definition_id": bag.definition_id,
			"display_name": bags[bag.definition_id].display_name, "rotation_quarters": bag.rotation_quarters}
	var active: Array = session.state.get_active_cells().keys()
	var board_items: Array = []
	for item in session.state.items.values():
		var cells: Array = []
		for offset in items[item.definition_id].footprint(item.rotation_quarters): cells.append(item.origin + offset)
		board_items.append({"instance_id": item.instance_id, "definition_id": item.definition_id,
			"display_name": items[item.definition_id].display_name, "origin": item.origin,
			"rotation_quarters": item.rotation_quarters, "cells": cells})
	var combinations: Array = adapter.combination_options()
	for option in combinations: option.display_name = items[option.result_item].display_name
	var pending: Dictionary = adapter.pending_combination.duplicate(true)
	if not pending.is_empty(): pending.display_name = items[pending.result_item].display_name
	var shop = SHOP.new()
	shop._reroll_index = int(rewards.shop.reroll_index)
	var reroll_cost: int = shop.get_reroll_cost()
	shop.free()
	return {"external_focus_owner": true, "allow_final_fate_skip": true, "boss_reward_pending": rewards.boss_pending, "boss_reward_labels": labels, "chest_count": int(rewards.chests),
		"buffer": buffer, "gold": int(prep.gold), "shop_offers": offers, "shop_reroll_cost": reroll_cost,
		"bag_offer": bag_offer, "pending_bag": pending_bag, "backpack_board": {"active_cells": active, "items": board_items},
		"can_undo": not session._undo_stack.is_empty(), "combination_options": combinations, "pending_combination": pending}
