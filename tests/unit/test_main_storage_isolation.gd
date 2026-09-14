extends GutTest


func test_main_fixture_isolates_defaults_before_ready_without_overriding_explicit_paths() -> void:
	var helper_path := "res://tests/helpers/main_storage_isolation.gd"
	assert_true(ResourceLoader.exists(helper_path))
	if not ResourceLoader.exists(helper_path):
		return
	var helper = load(helper_path)
	var main = load("res://scenes/main/main_scene.tscn").instantiate()
	var other = load("res://scenes/main/main_scene.tscn").instantiate()
	helper.prepare(main)
	helper.prepare(other)
	assert_ne(main.wallet_storage_path, other.wallet_storage_path)
	assert_ne(main.resume_storage_path, other.resume_storage_path)
	assert_true(main.wallet_storage_path.begins_with("user://gut_main_isolated_20260912/"))
	assert_false(FileAccess.file_exists(main.wallet_storage_path), "Preparation must not launch Main or write its wallet.")
	main.resume_storage_path = "user://explicit_fixture_resume.json"
	helper.prepare(main)
	assert_eq(main.resume_storage_path, "user://explicit_fixture_resume.json")
	main.free()
	other.free()
