extends "res://tests/support/selected_profile_fixture.gd"

const SCREEN_PATH = "res://scripts/ui/selected_rest_screen.gd"
const REST_VIEW = preload("res://scenes/ui/rest_flow_ui.tscn")

func test_real_buttons_unlock_books_buy_equip_and_forge_without_live_combat_changes() -> void:
	var fixture := _fixture()
	assert_true(ResourceLoader.exists(SCREEN_PATH), "Selected rest needs visible actions, not API-only completion")
	if not ResourceLoader.exists(SCREEN_PATH): return
	var view = add_child_autofree(REST_VIEW.instantiate())
	# Headless DisplayServer defaults to 64x64; use the actual QA layout size.
	view.panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	view.panel.size = Vector2(1152, 760)
	var screen = add_child_autofree(load(SCREEN_PATH).new())
	assert_true(screen.configure(view, fixture.store, {"school_id": "bongma", "resource_amount": 0}).ok)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(view.panel.visible)
	assert_eq(view.get_viewport().gui_get_focus_owner(), screen.action_button("trace", "absorb"), "Entry must show the unresolved trace before route choices")
	await get_tree().process_frame
	var scroll_rect: Rect2 = view.get_node("Panel/Margin").get_global_rect()
	var action_rect: Rect2 = screen.action_button("trace", "absorb").get_global_rect()
	assert_true(scroll_rect.encloses(action_rect), "Focused trace must be inside viewport: %s / action %s" % [scroll_rect, action_rect])
	assert_true(view.workbench_commit_button.disabled)
	assert_eq(screen.action_button("book", "cheonsul_flame_mark"), null)
	var absorb = screen.action_button("trace", "absorb")
	assert_not_null(absorb)
	absorb.pressed.emit()
	assert_true(fixture.store.load_profile().profile.active_run.preparation.access.trace_decisions.has("cheonsul"))
	var book = screen.action_button("book", "cheonsul_flame_mark")
	assert_not_null(book)
	book.pressed.emit()
	assert_eq(screen.adapter.spatial.buffer.size(), 1)
	screen.action_button("equipment", "kunai").pressed.emit()
	screen.action_button("equip", "kunai").pressed.emit()
	assert_eq(screen.adapter.snapshot().equipment.equipped_slots.projectile, "gear_kunai")
	var gold := int(screen.adapter.snapshot().gold)
	screen.action_button("forge", "projectile").pressed.emit()
	assert_eq(int(screen.adapter.snapshot().gold), gold - 20)
	assert_true(screen.message_label.text.contains("강화"))
	assert_eq(fixture.store.load_profile().profile.active_run.checkpoint, fixture.profile.active_run.checkpoint)
	assert_true(view.get_node("Panel/Margin").follow_focus)
	await get_tree().process_frame

func test_origin_enhance_only_and_save_error_keeps_screen_open_for_retry() -> void:
	var fixture := _fixture(&"bongma", &"bongma")
	assert_true(ResourceLoader.exists(SCREEN_PATH))
	if not ResourceLoader.exists(SCREEN_PATH): return
	var view = add_child_autofree(REST_VIEW.instantiate())
	var screen = add_child_autofree(load(SCREEN_PATH).new())
	assert_true(screen.configure(view, fixture.store, {"school_id": "bongma", "resource_amount": 0}).ok)
	assert_eq(screen.action_button("trace", "absorb"), null)
	fixture.store.fail_open = true
	screen.action_button("trace", "melee").pressed.emit()
	assert_true(view.panel.visible)
	assert_true(screen.message_label.text.contains("실패"))
	assert_true(screen.adapter.snapshot().access.trace_decisions.is_empty())
	fixture.store.fail_open = false
	screen.action_button("trace", "melee").pressed.emit()
	assert_true(screen.adapter.snapshot().access.trace_decisions.has("bongma"))
	assert_eq(screen.action_button("trace", "melee"), null)
	await get_tree().process_frame
