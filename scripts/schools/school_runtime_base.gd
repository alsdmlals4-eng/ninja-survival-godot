extends Node
class_name SchoolRuntimeBase

signal resource_changed(label: String, current: float, maximum: float)
signal ultimate_ready_changed(ready: bool)
signal school_feedback(text: String)
signal player_action_resolved

var player: PlayerController
var world: Node2D
var active: bool = false
var combat_resolver: CombatResolver
var contribution_tracker: CombatContributionTracker
var run_modifiers := RunModifierSet.new()


func configure(new_player: PlayerController, new_world: Node2D) -> void:
	player = new_player
	world = new_world


func configure_run_systems(
	resolver: CombatResolver,
	tracker: CombatContributionTracker
) -> void:
	combat_resolver = resolver
	contribution_tracker = tracker


func apply_run_modifiers(modifiers: RunModifierSet) -> void:
	run_modifiers = modifiers.copy_values() if modifiers != null else RunModifierSet.new()


func activate() -> void:
	active = true
	process_mode = Node.PROCESS_MODE_INHERIT


func deactivate() -> void:
	active = false
	process_mode = Node.PROCESS_MODE_DISABLED


func on_enemy_died(_enemy: Node) -> void:
	pass


func try_use_ultimate() -> bool:
	return false


func is_ultimate_ready() -> bool:
	return false


func emit_player_action_resolved() -> void:
	if active:
		player_action_resolved.emit()
