extends Node
class_name SchoolRuntimeHost

signal resource_changed(label: String, current: float, maximum: float)
signal ultimate_ready_changed(ready: bool)
signal school_feedback(text: String)
signal school_activated(school_id: StringName, school_name: String)

const SCHOOL_NAMES := {
	&"bongma": "봉마류",
	&"cheonsul": "천술류",
	&"guiin": "귀인류",
	&"heukyeong": "흑영류",
}

const SCHOOL_CHILDREN := {
	&"bongma": "Bongma",
	&"cheonsul": "Cheonsul",
	&"guiin": "Guiin",
	&"heukyeong": "Heukyeong",
}

var player: PlayerController
var world: Node2D
var selected_school_id: StringName = &""
var selected_school_name: String = ""
var active_runtime: SchoolRuntimeBase


func configure(new_player: PlayerController, new_world: Node2D) -> void:
	player = new_player
	world = new_world
	for child in get_children():
		if child is SchoolRuntimeBase:
			(child as SchoolRuntimeBase).configure(player, world)


func select_school(school_id: StringName) -> bool:
	if selected_school_id != &"":
		return false
	if not SCHOOL_NAMES.has(school_id):
		return false

	var runtime := _runtime_for(school_id)
	if runtime == null:
		return false

	for child in get_children():
		if child is SchoolRuntimeBase and child != runtime:
			(child as SchoolRuntimeBase).deactivate()

	runtime.configure(player, world)
	_connect_runtime(runtime)
	runtime.activate()
	active_runtime = runtime
	selected_school_id = school_id
	selected_school_name = SCHOOL_NAMES[school_id]
	school_activated.emit(selected_school_id, selected_school_name)
	return true


func forward_enemy_died(enemy: Node) -> void:
	if active_runtime == null or not active_runtime.active:
		return
	active_runtime.on_enemy_died(enemy)


func try_use_ultimate() -> bool:
	if active_runtime == null or not active_runtime.active:
		return false
	return active_runtime.try_use_ultimate()


func deactivate() -> void:
	if active_runtime == null:
		return
	active_runtime.deactivate()


func _runtime_for(school_id: StringName) -> SchoolRuntimeBase:
	var child_name: String = SCHOOL_CHILDREN.get(school_id, "")
	if child_name.is_empty():
		return null
	return get_node_or_null(NodePath(child_name)) as SchoolRuntimeBase


func _connect_runtime(runtime: SchoolRuntimeBase) -> void:
	var resource_callback := Callable(self, "_on_resource_changed")
	if not runtime.resource_changed.is_connected(resource_callback):
		runtime.resource_changed.connect(resource_callback)

	var ultimate_callback := Callable(self, "_on_ultimate_ready_changed")
	if not runtime.ultimate_ready_changed.is_connected(ultimate_callback):
		runtime.ultimate_ready_changed.connect(ultimate_callback)

	var feedback_callback := Callable(self, "_on_school_feedback")
	if not runtime.school_feedback.is_connected(feedback_callback):
		runtime.school_feedback.connect(feedback_callback)


func _on_resource_changed(label: String, current: float, maximum: float) -> void:
	resource_changed.emit(label, current, maximum)


func _on_ultimate_ready_changed(ready: bool) -> void:
	ultimate_ready_changed.emit(ready)


func _on_school_feedback(text: String) -> void:
	school_feedback.emit(text)
