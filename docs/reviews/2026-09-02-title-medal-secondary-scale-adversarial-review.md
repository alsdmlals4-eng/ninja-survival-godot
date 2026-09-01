# DEC-043 — Title Medal Secondary-Scale Adversarial Review

```yaml
review_id: DEC043_TITLE_MEDAL_SECONDARY_SCALE
scope: TitleScreen/TitleMedal layout only
baseline: origin/main caa8abb5ac3f29df4045362aec3b2013b4577bdc
branch: codex/title-medal-scale-141
user_direction: keep the four-traditions medal separate but reduce it to approximately the 닌 wordmark glyph height
asset_mutation: NONE
cost: ZERO_INCREMENTAL
external_feasibility: ADOPT_GODOT_CONTROL_ANCHORS
machine_evidence: FOCUSED_GUT_RED_THEN_GREEN_IMPORT_EDITOR_PARSE_MAIN_SMOKE_FULL_GUT_PASS
runtime_render_human_player_device: NOT_RUN
```

## Scope and feasibility decision

The current title already owns a separate transparent, user-locked
`NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02` through
`TitleScreen/TitleMedal`. Replacing the bitmap, baking it into the backdrop, or
adding a new title system would broaden the user request and risk undoing
existing provenance/input protections. The selected solution changes only the
`TextureRect` anchor box from `0.090 × 0.200` to `0.055 × 0.120`, retains
aspect-preserving stretch and ignored pointer input, and makes a screen-size
relative geometry contract executable in the focused title test.

The official Godot [Size and anchors documentation](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html)
confirms that Control anchor values are relative to the parent/viewport and
that independent horizontal/vertical anchors define a responsive rectangle.
`ADOPT`: a narrow, bounded anchor rectangle is simpler and safer than a new
asset or a fixed-pixel layout, while retaining the current `TextureRect` owner.

## Five whole-scope loops

| Loop | Full-scope attack | Validated finding | Correction / regression result | Better alternative and disposition |
| --- | --- | --- | --- | --- |
| 1 | Source bytes, alpha, separate consumer, and rollback lineage could change while only apparent size is requested. | The requested change does not need a source-image mutation. | Preserved the same medal path, SHA-256 check, independent node, aspect mode, and ignored pointer input; focused test covers each. | `REJECT` a resized PNG: it would create avoidable provenance/version work and lose runtime tuning. |
| 2 | A smaller rectangle could still dominate the logo or become an unrelated left-side panel. | The old `0.090 × 0.200` rectangle fails all three new secondary-scale conditions. | Wrote the GUT assertions first; RED result was `0/1`, `45/48`. The exact `0.055 × 0.120` rectangle then passed `1/1`, `48` assertions. | `REJECT` fixed pixels: the official anchor model better preserves a responsive layout. |
| 3 | Overlay changes can capture mouse input, steal initial focus, or change the New Game start gate. | The existing scene already owns pointer-ignore and start/focus behavior; they remain the relevant regression surface. | Focused test retained `MOUSE_FILTER_IGNORE`, initial Start focus, separate asset checks, and `start_requested` emission. | `REJECT` folding the medal into the wordmark: it removes the separately adjustable symbol the user specifically requested. |
| 4 | A clean focused test could hide import/parser/Main regressions or title asset load errors. | The scene change has no script/asset substitution but must survive Godot loading. | Godot 4.7.1 import, headless editor parse, and 300-frame Main smoke each exited `0`; full GUT passed `605/605`, `6,794` assertions. | `REJECT` treating static diff as sufficient: engine loading is a required machine boundary. |
| 5 | Documentation could imply a new visual asset or claim human visual approval from a generated review board and headless checks. | The user approved the hierarchy direction, not a new bitmap or Human/device pass. | Decision ledger, visual handoff, Blueprint, and Active Context state this as a layout-only change; runtime-render/Human/player/device remain `NOT_RUN`. | `ADAPT` the review board only as a comparison aid; it is not a runtime source or evidence class. |

## Clean exit and remaining boundary

No valid blocker or `MUST_FIX` remains in the approved layout-only scope. One
local-environment finding was validated during cleanup: the generated `.import`
metadata is required for Godot to load the locked PNGs as `Texture2D`; removing
it reproduced `92` unrelated resource-load/test failures, and `--import`
followed by the full GUT suite restored `605/605` passing tests. Therefore the
generated import/UID metadata and the temporary GUT junction remain local,
untracked test dependencies only; they are explicitly excluded from staging and
will be removed by disposal of this isolated worktree rather than copied into
the repository.

Exact PR-head CI (`gut` and `Windows internal build artifact`) passed for
`b196c40ece2c55ee66831e84151ba4d026706240`; PR #141 was then squash-merged
to `main` at `d0e49d0685803849e9013f482f7452830abbf5d4`. Remote main readback
confirmed the `TitleMedal` anchors and an empty tree delta from the exact PR
head. Attached Ninja Survival live render, Human Usability, Player Experience,
and device/export validation remain separate `NOT_RUN` gates.
