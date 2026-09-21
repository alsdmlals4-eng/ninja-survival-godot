# 도감은 별도 해금 데이터가 아니라 현재 정본 카탈로그를 읽어 설명용 항목으로 만든다.
extends GutTest

const CODEX_PRESENTATION_PATH := "res://scripts/ui/codex_presentation.gd"

func test_selected_codex_separates_twenty_four_books_nine_equipment_and_support() -> void:
	var presenter = load(CODEX_PRESENTATION_PATH).new()
	assert_true(presenter.has_method("build_selected_sections"))
	if not presenter.has_method("build_selected_sections"): return
	var sections: Array = presenter.build_selected_sections()
	assert_eq(_section_entries(sections, &"ninjutsu").size(), 24)
	assert_eq(_section_entries(sections, &"equipment").size(), 9)
	assert_eq(_section_entries(sections, &"support").size(), 19)
	assert_eq(_section_entries(sections, &"combinations").size(), 3)
	var katana := _entry_by_id(_section_entries(sections, &"equipment"), &"katana")
	assert_true(katana.detail.contains("별도 장비 슬롯"))
	assert_false(katana.detail.contains("가방 안에 배치"))
	var book := _entry_by_id(_section_entries(sections, &"ninjutsu"), &"cheonsul_ice_veil")
	assert_true(book.detail.contains("해금"))
	assert_true(book.detail.contains("보호막"))
	assert_false(book.detail.contains("보스 인법서"))
	var combo := _entry_by_id(_section_entries(sections, &"combinations"), &"thunder_blade")
	assert_true(combo.detail.contains("근접 비전"))
	assert_false(combo.detail.contains("일본도"))
	for entry in _section_entries(sections, &"support"):
		assert_false(entry.detail.contains("_"), "No internal modifier names: " + entry.title)
	var emblem := _entry_by_id(_section_entries(sections, &"support"), &"school_emblem")
	assert_true(emblem.detail.contains("봉마"))
	assert_false(emblem.detail.contains("조합 재료"))


func test_codex_derives_enemy_ninjutsu_and_equipment_sections_from_current_catalogs() -> void:
	assert_true(ResourceLoader.exists(CODEX_PRESENTATION_PATH), "Codex presentation is required.")
	if not ResourceLoader.exists(CODEX_PRESENTATION_PATH):
		return
	var presenter = load(CODEX_PRESENTATION_PATH).new()
	var sections: Array = presenter.build_sections()
	assert_eq(sections.map(func(section): return section.get("section_id")), [&"enemies", &"ninjutsu", &"equipment", &"bags", &"combinations"])
	assert_eq(_section_entries(sections, &"enemies").size(), 20)
	assert_eq(_section_entries(sections, &"ninjutsu").size(), 12)
	assert_eq(_section_entries(sections, &"equipment").size(), 22)
	assert_eq(_section_entries(sections, &"bags").size(), 6)
	assert_eq(_section_entries(sections, &"combinations").size(), 3)


func test_codex_entries_explain_actual_role_lane_or_placement_without_unlock_state() -> void:
	assert_true(ResourceLoader.exists(CODEX_PRESENTATION_PATH), "Codex presentation is required.")
	if not ResourceLoader.exists(CODEX_PRESENTATION_PATH):
		return
	var presenter = load(CODEX_PRESENTATION_PATH).new()
	var sections: Array = presenter.build_sections()
	var boss_entry := _entry_by_id(_section_entries(sections, &"enemies"), &"hundred_demon_array_master")
	assert_eq(boss_entry.get("role"), &"boss")
	assert_true(String(boss_entry.get("detail", "")).contains("전조"))

	var starter_entry := _entry_by_id(_section_entries(sections, &"ninjutsu"), &"cheonsul_flame_mark")
	assert_eq(starter_entry.get("acquisition_lane"), &"starter")
	assert_true(String(starter_entry.get("detail", "")).contains("시작"))

	var item_entry := _entry_by_id(_section_entries(sections, &"equipment"), &"katana")
	assert_true(String(item_entry.get("detail", "")).contains("가방"))
	assert_false(item_entry.has("is_unlocked"), "Codex must not create a separate discovery/unlock system.")


func _section_entries(sections: Array, section_id: StringName) -> Array:
	for section in sections:
		if StringName(section.get("section_id", &"")) == section_id:
			return Array(section.get("entries", []))
	return []


func _entry_by_id(entries: Array, entry_id: StringName) -> Dictionary:
	for entry in entries:
		if StringName(entry.get("entry_id", &"")) == entry_id:
			return entry
	return {}
