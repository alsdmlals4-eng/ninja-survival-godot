extends GutTest

const BASE_PATH := "res://scripts/schools/school_runtime_base.gd"
const HOST_PATH := "res://scripts/schools/school_runtime_host.gd"
const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const RESOLVER_PATH := "res://scripts/combat/combat_resolver.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


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


func test_runtime_base_exposes_run_system_and_modifier_hooks() -> void:
	var runtime = load(BASE_PATH).new()
	add_child_autofree(runtime)
	assert_true(runtime.has_method("configure_run_systems"))
	assert_true(runtime.has_method("apply_run_modifiers"))
	assert_true(_has_property(runtime, &"combat_resolver"))
	assert_true(_has_property(runtime, &"contribution_tracker"))
	assert_true(_has_property(runtime, &"run_modifiers"))


func test_host_forwards_run_systems_and_modifiers_to_all_runtimes() -> void:
	if not ResourceLoader.exists(RESOLVER_PATH):
		return
	var base_script = load(BASE_PATH)
	var host = load(HOST_PATH).new()
	add_child_autofree(host)
	var runtimes: Array = []
	for child_name in ["Bongma", "Cheonsul", "Guiin", "Heukyeong"]:
		var runtime = base_script.new()
		runtime.name = child_name
		host.add_child(runtime)
		runtimes.append(runtime)

	var tracker = load(TRACKER_PATH).new()
	add_child_autofree(tracker)
	var resolver = load(RESOLVER_PATH).new()
	add_child_autofree(resolver)
	resolver.configure(tracker)
	host.configure_run_systems(resolver, tracker)

	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.25
	host.apply_run_modifiers(modifiers)
	modifiers.school_damage_pct = 9.0

	for runtime in runtimes:
		assert_eq(runtime.combat_resolver, resolver)
		assert_eq(runtime.contribution_tracker, tracker)
		assert_almost_eq(runtime.run_modifiers.school_damage_pct, 0.25, 0.001)


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
