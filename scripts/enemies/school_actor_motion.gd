extends Sprite2D

## Presentation only: authored idle/walk/prepare/release cells. Never owns
## pattern timing, collision, damage or death lifetime.
const ROWS := {
	"bongma": ["seal_chaser", "shikigami_handler", "barrier_carrier", "mobile_array_caster", "hundred_demon_array_master"],
	"cheonsul": ["fire_mark_caster", "water_vein_caster", "lightning_chain_caster", "five_element_tuner", "heavenly_change_taoist"],
	"guiin": ["surge_fighter", "pressure_monk", "ghost_blood_chaser", "melee_chaos_captain", "ghost_general"],
	"heukyeong": ["shuriken_scout", "poison_shadow_assassin", "dark_mark_pursuer", "shadow_chief", "night_executioner"],
}
var _row := 0
var _walk_time := 0.0

func configure_actor(definition) -> bool:
	var ids: Array = ROWS.get(str(definition.school_id), [])
	_row = ids.find(str(definition.actor_id))
	if _row < 0: return false
	texture = load("res://assets/runtime/encounters/sheets/%s.png" % definition.school_id)
	region_enabled = true
	region_filter_clip_enabled = true
	var factor := 0.32 if definition.role == &"core" else (0.45 if definition.role == &"elite" else 0.60)
	scale = Vector2.ONE * factor
	position = Vector2(0, 24.0 - 91.6 * factor)
	region_rect = Rect2(0, _row * 229, 229, 229)
	set_meta(&"provisional_existing_art", false)
	set_meta(&"appearance_approval", "RUNTIME_REVIEW_REQUESTED_NOT_FINAL_LOCK")
	return true

func _process(delta: float) -> void:
	var actor = get_parent()
	if not actor is SchoolEncounterActor or actor.definition == null: return
	var column := 0
	if actor.velocity.length_squared() > 1.0:
		_walk_time = fmod(_walk_time + maxf(delta, 0.0), 0.36)
		column = 1 + int(_walk_time >= 0.18)
		if absf(actor.velocity.x) > 1.0: flip_h = actor.velocity.x < 0.0
	match actor.pattern_state():
		&"telegraph", &"windup", &"locked": column = 3
		&"execute": column = 4
		&"recovery": column = 0
	region_rect.position.x = column * 229
