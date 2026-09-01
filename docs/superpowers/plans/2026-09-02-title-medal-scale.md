# Title Medal Secondary-Scale Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the user-locked four-traditions medal as a separate title asset, while reducing its rendered footprint to a secondary symbol approximately the height of the `닌` glyph in the `닌자의 신` wordmark.

**Architecture:** `TitleScreen/TitleMedal` keeps the existing transparent PNG, aspect-preserving stretch mode, and ignored pointer input. Only the authored anchor rectangle changes; the focused title integration test locks a small viewport-relative geometry contract, and visual handoff/blueprint documents record that this is a layout change rather than an asset replacement.

**Tech Stack:** Godot 4.7.1, GDScript, `.tscn` anchors, GUT, repository visual provenance records.

**Spec:** `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`, `docs/CURRENT_VISUAL_HANDOFF.md`, and the current user-approved instruction: reduce the title medal to the approximate size of the `닌` wordmark glyph.

## Global Constraints

- Preserve `NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02`, its file bytes, SHA-256, approval state, and independent `TitleScreen/TitleMedal` consumer.
- Keep `TitleMedal.mouse_filter = IGNORE` and `STRETCH_KEEP_ASPECT_CENTERED` so title input/focus ownership cannot regress.
- Do not change title actions, Continue/Awakening/Codex semantics, Stage entry, save data, combat, or any unowned/open PR.
- The title visual change must stay zero-cost and use the current Godot 4.7.1/GUT workflow.
- Machine, runtime-render, Human Usability, Player Experience, and device/export evidence remain separately reported.

---

### Task 1: Lock the smaller secondary-medal geometry with a failing GUT test

**Files:**
- Modify: `tests/integration/test_title_screen.gd:10-88`
- Test: `tests/integration/test_title_screen.gd`

**Interfaces:**
- Consumes: instantiated `res://scenes/ui/title_screen.tscn`, `TitleScreen/TitleMedal`, and `LogoLockup`.
- Produces: a focused layout contract limiting the medal rectangle to `<= 0.060` viewport width and `<= 0.130` viewport height, positioned beside the wordmark rather than replacing it.

- [x] **Step 1: Write the failing test**

```gdscript
const MAX_TITLE_MEDAL_VIEWPORT_WIDTH := 0.060
const MAX_TITLE_MEDAL_VIEWPORT_HEIGHT := 0.130

var title_lockup := title.get_node_or_null("LogoLockup") as Control
assert_not_null(title_lockup)
if title_lockup != null:
    var medal_width := title_medal.anchor_right - title_medal.anchor_left
    var medal_height := title_medal.anchor_bottom - title_medal.anchor_top
    var lockup_width := title_lockup.anchor_right - title_lockup.anchor_left
    assert_true(medal_width <= MAX_TITLE_MEDAL_VIEWPORT_WIDTH)
    assert_true(medal_height <= MAX_TITLE_MEDAL_VIEWPORT_HEIGHT)
    assert_true(medal_width < lockup_width * 0.25)
    assert_true(title_medal.anchor_left >= 0.28)
```

- [x] **Step 2: Run the focused test to verify it fails on current geometry**

```powershell
& $godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_screen.gd -gexit
```

Expected: `FAIL`, because the existing `0.090`-wide by `0.200`-high authored rectangle exceeds the new secondary-scale ceiling.

- [x] **Step 3: Do not change production files until the failure names the old rectangle**

Confirm the failure is caused by medal-size expectations rather than missing resources, parser errors, or title lifecycle setup.

---

### Task 2: Reduce the authored rectangle without changing the approved medal asset

**Files:**
- Modify: `scenes/ui/title_screen.tscn:65-76`
- Modify: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`
- Modify: `docs/CURRENT_VISUAL_HANDOFF.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Create: `docs/reviews/2026-09-02-title-medal-secondary-scale-adversarial-review.md`

**Interfaces:**
- Consumes: Task 1’s smaller-geometry GUT contract and the existing user-locked separate PNG asset.
- Produces: an aspect-preserved approximately `0.055` viewport-width × `0.120` viewport-height medal rectangle, immediately beside the wordmark, plus current-owner evidence that no source image bytes changed.

- [x] **Step 1: Apply the minimal scene change**

```ini
[node name="TitleMedal" type="TextureRect" parent="."]
anchor_left = 0.29
anchor_top = 0.35
anchor_right = 0.345
anchor_bottom = 0.47
```

- [x] **Step 2: Record the approved visual intent in its existing owners**

Add one compact decision/handoff/blueprint note that the medal is a secondary four-fragment title symbol, scaled to the approximate height of the `닌` glyph. Explicitly preserve the existing asset ID, SHA-256, consumer, and `NOT_RUN` Human/runtime boundaries.

- [x] **Step 3: Run the focused test to verify it passes**

```powershell
& $godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_screen.gd -gexit
```

Expected: `PASS`; the scene still exposes the same asset, input behavior, title focus, and start intent while satisfying the smaller geometry contract.

- [x] **Step 4: Write the five whole-scope adversarial loops**

Attack source-byte drift, input interception/focus, logo hierarchy regression, stale docs, test/verification overclaim, rollback, and unrelated runtime impact. Correct only validated findings and record the evidence ceiling.

---

### Task 3: Verify the exact branch and prepare the reviewable result

**Files:**
- Verify: `scenes/ui/title_screen.tscn`, `tests/integration/test_title_screen.gd`, current documentation owners.
- Record only verified results in existing current-state documents; do not create a fake runtime or Human PASS.

**Interfaces:**
- Consumes: green focused test, exact pinned Godot executable, and clean branch state.
- Produces: import/parse/smoke/full-GUT evidence, an actual title-screen preview if a Ninja Survival live session can be safely attached, and a PR-ready branch.

- [x] **Step 1: Run exact Godot import and parse checks**

```powershell
& $godot --headless --path . --import
& $godot --headless --path . --editor --quit
```

- [x] **Step 2: Run main-scene smoke and full regression**

```powershell
& $godot --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 300
& $godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

- [x] **Step 3: Use only a confirmed Ninja Survival live-editor session for visual proof**

Run `hera status`/`hera instances`; never mutate or capture an unrelated project. If no Ninja Survival session is attached, retain `RUNTIME_RENDER_NOT_RUN` and present the machine-verified source change with that limitation.

- [x] **Step 4: Commit, push, open a focused PR, and validate its exact head**

```powershell
git add scenes/ui/title_screen.tscn tests/integration/test_title_screen.gd docs/CURRENT_CONFIRMED_DECISIONS.md docs/CURRENT_VISUAL_HANDOFF.md docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/ACTIVE_CONTEXT.md docs/reviews/2026-09-02-title-medal-secondary-scale-adversarial-review.md docs/superpowers/plans/2026-09-02-title-medal-scale.md
git commit -m "fix: reduce title medal visual weight"
git push -u origin codex/title-medal-scale-141
```

Create one new PR from this branch; do not modify the user-owned PR #135 or any unrelated open branch. Report exact head CI and merge/readback status separately from Human/player/device acceptance.

Completed as PR [#141](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/141): exact head
`b196c40ece2c55ee66831e84151ba4d026706240` passed both required GitHub
checks, then squash-merged to `main` at
`d0e49d0685803849e9013f482f7452830abbf5d4`. Remote main readback found the
same tree as the exact PR head.
