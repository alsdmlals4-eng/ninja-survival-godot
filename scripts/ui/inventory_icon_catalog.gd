extends RefCounted
## Presentation mapping only. The scene supplies a reviewed atlas; no candidate
## directory is ever searched or loaded automatically by production.
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const KEYS := [&"katana", &"shuriken", &"ninja_suit", &"bag", &"bongma", &"cheonsul", &"guiin", &"heukyeong"]

static func icon(atlas: Texture2D, id: StringName) -> Texture2D:
	if atlas == null: return null
	var key := id
	var spell := BOOKS.spell_id(id)
	if spell == &"" and BOOKS.NINJUTSU.definition_for_id(id) != null: spell = id
	if spell != &"": key = BOOKS.NINJUTSU.definition_for_id(spell).school_id
	var index := KEYS.find(key)
	if index < 0: return null
	# Eight objects have explicit, inset source rectangles. No pixel editing.
	var rects := [Rect2(36, 116, 276, 444), Rect2(320, 195, 297, 320),
		Rect2(635, 195, 294, 357), Rect2(935, 184, 309, 350),
		Rect2(26, 729, 276, 347), Rect2(333, 728, 279, 346),
		Rect2(635, 729, 290, 345), Rect2(947, 729, 285, 347)]
	var region: Rect2 = rects[index]
	var ratio := Vector2(atlas.get_size()) / 1254.0
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = Rect2(region.position * ratio, region.size * ratio)
	return result
