extends Node2D
class_name MainController

@export var reward_orb_scene: PackedScene

var game_over: bool = false

@onready var game_state: GameState = $GameState
@onready var combat_ddd: CombatDDDTracker = $CombatDDD
@onready var player: PlayerController = $Player
@onready var auto_attack: AutoAttackController = $Player/AutoAttack
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var school_host: SchoolRuntimeHost = $SchoolRuntimeHost
@onready var school_selection: SchoolSelectionUI = $SchoolSelectionUI
@onready var hud: HUDController = $HUD


func _ready() -> void:
	game_state.score_changed.connect(hud.set_score)
	combat_ddd.combo_changed.connect(hud.set_combo)
	combat_ddd.stylish_score_changed.connect(hud.set_stylish_score)
	combat_ddd.reward_count_changed.connect(hud.set_reward_count)
	combat_ddd.title_triggered.connect(hud.show_combo_title)
	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)
	wave_spawner.enemy_spawned.connect(_wire_enemy)
	school_selection.school_selected.connect(_on_school_selected)
	school_host.resource_changed.connect(hud.set_school_resource)
	school_host.ultimate_ready_changed.connect(hud.set_ultimate_ready)
	school_host.school_feedback.connect(hud.show_school_feedback)

	hud.set_health(player.health, player.max_health)
	hud.set_score(game_state.score, game_state.kill_count)
	hud.set_combo(combat_ddd.combo_count, combat_ddd.max_combo)
	hud.set_stylish_score(combat_ddd.stylish_score)
	hud.set_reward_count(combat_ddd.reward_count)
	hud.set_ultimate_ready(false)

	wave_spawner.configure(self, player)
	school_host.configure(player, self)

	for child in get_children():
		if child.is_in_group("enemies"):
			_wire_enemy(child)

	_set_combat_enabled(false)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	if game_over:
		get_tree().reload_current_scene()
		return
	if school_host.selected_school_id != &"":
		school_host.try_use_ultimate()


func _on_school_selected(school_id: StringName) -> void:
	if game_over:
		return
	if not school_host.select_school(school_id):
		return
	hud.set_school(school_host.selected_school_name)
	_set_combat_enabled(true)


func _set_combat_enabled(enabled: bool) -> void:
	var gameplay_mode := Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	player.process_mode = gameplay_mode
	auto_attack.process_mode = Node.PROCESS_MODE_DISABLED
	wave_spawner.set_spawning_enabled(enabled)
	wave_spawner.process_mode = gameplay_mode

	for child in get_children():
		if child.is_in_group("enemies"):
			child.process_mode = gameplay_mode


func _on_enemy_died(enemy: Node) -> void:
	if game_over:
		return

	var death_position := Vector2.ZERO
	if enemy is Node2D:
		death_position = (enemy as Node2D).global_position

	game_state.register_kill(100)
	combat_ddd.register_kill()
	school_host.forward_enemy_died(enemy)
	_spawn_reward_orb(death_position)


func _spawn_reward_orb(spawn_position: Vector2) -> void:
	if reward_orb_scene == null or not is_instance_valid(player):
		return

	var orb_node := reward_orb_scene.instantiate()
	if not orb_node is RewardOrb:
		orb_node.free()
		return

	add_child(orb_node)
	var orb := orb_node as RewardOrb
	orb.global_position = spawn_position
	orb.configure(player)
	orb.collected.connect(_on_reward_collected)


func _on_reward_collected(_orb: RewardOrb) -> void:
	if game_over:
		return
	combat_ddd.register_reward_collected()


func _wire_enemy(enemy: Node) -> void:
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	if enemy.has_signal("died"):
		var death_callback := Callable(self, "_on_enemy_died")
		if not enemy.is_connected("died", death_callback):
			enemy.connect("died", death_callback)


func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	wave_spawner.set_spawning_enabled(false)
	school_host.deactivate()
	_stop_gameplay()
	hud.show_game_over()


func _stop_gameplay() -> void:
	for child in get_children():
		if child == game_state or child == hud:
			continue
		child.process_mode = Node.PROCESS_MODE_DISABLED
