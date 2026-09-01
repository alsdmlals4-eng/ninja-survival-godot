extends GutTest

const TITLE_SCREEN := "res://scenes/ui/title_screen.tscn"
const TITLE_BACKDROP := "res://assets/runtime/ui/title_screen_moonlit_ninja_v2.png"
const TITLE_BACKDROP_SHA256 := "86f86da33986499bfd98aa003ba52ac65105136197d4530aa3335c9b8f2e030c"
const TITLE_MEDAL := "res://assets/runtime/ui/title_four_traditions_medal_v2.png"
const TITLE_MEDAL_SHA256 := "26520188d71f9565fef0263062dcbab6ce23f4998371f55af765c034257c61cc"
const TITLE_LOGO := "res://assets/runtime/ui/title_logo_ninja_god_v1.png"
const TITLE_LOGO_SHA256 := "c946ae4b08fd77f1e36bc25b22d0d41fdd5060fc80e98faeb9e6f2d2ac9a7a5b"
const TITLE_MANIFEST := "res://docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md"
const TITLE_MANIFEST_ID := "NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02"
const TITLE_MEDAL_MANIFEST_ID := "NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02"
const TITLE_LOGO_MANIFEST_ID := "NINJA_RUNTIME_TITLE_LOGO_NINJA_GOD_01"


func test_title_screen_exposes_separate_locked_graphic_logo_medal_backdrop_and_start_intent() -> void:
	assert_true(ResourceLoader.exists(TITLE_SCREEN), "The locked title-screen scene must exist.")
	if not ResourceLoader.exists(TITLE_SCREEN):
		return

	var title := (load(TITLE_SCREEN) as PackedScene).instantiate()
	add_child_autofree(title)
	await get_tree().process_frame

	assert_true(title.visible)
	assert_true(title.has_signal(&"start_requested"))
	var backdrop := title.get_node_or_null("Backdrop") as TextureRect
	var title_logo := title.get_node_or_null("LogoLockup/TitleLogo") as TextureRect
	var title_medal := title.get_node_or_null("TitleMedal") as TextureRect
	var start_button := title.get_node_or_null("LogoLockup/MenuButtons/StartButton") as Button
	assert_not_null(backdrop)
	assert_not_null(title_logo)
	assert_not_null(title_medal, "The four-traditions medal must be an independently positioned title asset, not baked into the backdrop.")
	assert_not_null(start_button)
	if backdrop == null or title_logo == null or title_medal == null or start_button == null:
		return

	assert_not_null(backdrop.texture)
	if backdrop.texture != null:
		assert_eq(backdrop.texture.resource_path, TITLE_BACKDROP)
		assert_eq(backdrop.texture.get_size(), Vector2(1672, 941))
	assert_eq(FileAccess.get_sha256(TITLE_BACKDROP).to_lower(), TITLE_BACKDROP_SHA256)
	var manifest_text := FileAccess.get_file_as_string(TITLE_MANIFEST)
	assert_true(manifest_text.contains(TITLE_MANIFEST_ID))
	assert_true(manifest_text.contains(TITLE_BACKDROP_SHA256))
	assert_true(manifest_text.contains("`assets/runtime/ui/title_screen_moonlit_ninja_v2.png`"))
	assert_true(manifest_text.contains("`TitleScreen/Backdrop`"))
	assert_true(manifest_text.contains("USER_LOCKED"))
	assert_true(ResourceLoader.exists(TITLE_MEDAL), "The locked four-traditions medal source must be separately loadable.")
	assert_not_null(title_medal.texture)
	if title_medal.texture != null:
		assert_eq(title_medal.texture.resource_path, TITLE_MEDAL)
		assert_eq(title_medal.texture.get_size(), Vector2(1254, 1254))
	assert_eq(title_medal.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_eq(title_medal.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(FileAccess.get_sha256(TITLE_MEDAL).to_lower(), TITLE_MEDAL_SHA256)
	assert_true(manifest_text.contains(TITLE_MEDAL_MANIFEST_ID))
	assert_true(manifest_text.contains(TITLE_MEDAL_SHA256))
	assert_true(manifest_text.contains("`assets/runtime/ui/title_four_traditions_medal_v2.png`"))
	assert_true(manifest_text.contains("`TitleScreen/TitleMedal`"))
	assert_true(ResourceLoader.exists(TITLE_LOGO), "The user-locked title logo source must exist.")
	assert_not_null(title_logo.texture)
	if title_logo.texture != null:
		assert_eq(title_logo.texture.resource_path, TITLE_LOGO)
		assert_eq(title_logo.texture.get_size(), Vector2(1672, 941))
	assert_eq(title_logo.stretch_mode, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_eq(title_logo.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(FileAccess.get_sha256(TITLE_LOGO).to_lower(), TITLE_LOGO_SHA256)
	assert_true(manifest_text.contains(TITLE_LOGO_MANIFEST_ID))
	assert_true(manifest_text.contains(TITLE_LOGO_SHA256))
	assert_true(manifest_text.contains("`assets/runtime/ui/title_logo_ninja_god_v1.png`"))
	assert_null(title.get_node_or_null("LogoLockup/TitleLabel"), "The actual title must be the locked world-building logo, not a plain fallback label.")
	assert_null(title.get_node_or_null("LogoLockup/PromiseLabel"), "The redundant title promise must not compete with the world-building logo.")
	assert_not_null(title.get_node_or_null("LogoLockup/MenuButtons/GuideButton"))
	assert_not_null(title.get_node_or_null("LogoLockup/MenuButtons/SettingsButton"))
	assert_eq(get_viewport().gui_get_focus_owner(), start_button)
	watch_signals(title)
	start_button.pressed.emit()
	assert_signal_emitted(title, "start_requested")
