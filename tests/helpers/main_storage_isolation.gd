extends RefCounted
## Invoke before entering the tree. No production code or user profiles are changed.
## Finished fixture files are collected for user deletion review, not auto-deleted.

static func prepare(node: Node) -> void:
	if node.get_script() == null or node.get_script().resource_path != "res://scripts/core/main_controller.gd":
		return
	assert(not node.is_inside_tree(), "Main storage must be isolated before ready.")
	var directory := "user://gut_main_isolated_20260912"
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	assert(error == OK, "Cannot isolate Main fixture storage.")
	var prefix := directory.path_join("%d_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec(), node.get_instance_id()])
	# Existing fixtures explicitly exercise v1 compatibility. Selected acceptance
	# tests re-enable the new default after isolation, always with a private path.
	node.selected_rules_enabled = false
	node.profile_storage_path = prefix + "_profile.json"
	if node.wallet_storage_path == "user://ninja_soul_wallet_v1.json":
		node.wallet_storage_path = prefix + "_wallet.json"
	if node.resume_storage_path == "user://run_resume_v1.json":
		node.resume_storage_path = prefix + "_resume.json"
