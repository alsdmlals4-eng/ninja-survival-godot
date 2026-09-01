# 도감은 별도 해금 데이터가 아니라 현재 정본 카탈로그를 읽어 설명용 항목으로 만든다.
extends GutTest

const CODEX_PRESENTATION_PATH := "res://scripts/ui/codex_presentation.gd"


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
