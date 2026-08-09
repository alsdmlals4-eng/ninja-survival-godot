extends GutTest

const BASE_PATH := "res://scripts/schools/school_runtime_base.gd"
const HOST_PATH := "res://scripts/schools/school_runtime_host.gd"


func test_select_school_activates_exact_runtime_once() -> void:
	assert_true(ResourceLoader.exists(BASE_PATH), "SchoolRuntimeBase must exist")
	assert_true(ResourceLoader.exists(HOST_PATH), "SchoolRuntimeHost must exist")
	if not ResourceLoader.exists(BASE_PATH) or not ResourceLoader.exists(HOST_PATH):
		return

	var base_script = load(BASE_PATH)
	var host = load(HOST_PATH).new()
	add_child_autofree(host)
	for child_name in ["Bongma", "Cheonsul", "Guiin", "Heukyeong"]:
		var runtime = base_script.new()
		runtime.name = child_name
		host.add_child(runtime)

	assert_true(host.select_school(&"guiin"))
	assert_eq(host.selected_school_id, &"guiin")
	assert_eq(host.selected_school_name, "귀인류")
	assert_eq(host.active_runtime.name, "Guiin")
	assert_true(host.active_runtime.active)
	assert_false(host.select_school(&"bongma"))
	assert_eq(host.active_runtime.name, "Guiin")


func test_invalid_school_id_is_rejected_without_selection() -> void:
	assert_true(ResourceLoader.exists(HOST_PATH), "SchoolRuntimeHost must exist")
	if not ResourceLoader.exists(HOST_PATH):
		return

	var host = load(HOST_PATH).new()
	add_child_autofree(host)
	assert_false(host.select_school(&"unknown"))
	assert_eq(host.selected_school_id, &"")
	assert_null(host.active_runtime)


func test_deactivate_disables_selected_runtime() -> void:
	assert_true(ResourceLoader.exists(BASE_PATH), "SchoolRuntimeBase must exist")
	assert_true(ResourceLoader.exists(HOST_PATH), "SchoolRuntimeHost must exist")
	if not ResourceLoader.exists(BASE_PATH) or not ResourceLoader.exists(HOST_PATH):
		return

	var host = load(HOST_PATH).new()
	add_child_autofree(host)
	var runtime = load(BASE_PATH).new()
	runtime.name = "Bongma"
	host.add_child(runtime)

	assert_true(host.select_school(&"bongma"))
	assert_true(runtime.active)
	host.deactivate()
	assert_false(runtime.active)
