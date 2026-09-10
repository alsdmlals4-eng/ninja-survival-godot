# Manual ultimate input implementation plan

User approved continuation of the dated A+B screen blueprint. Execute inline in
the existing isolated current-task worktree; no unrelated PR or asset promotion.

Goal: connect existing school ultimates to one top-bar control and a dedicated
input action without changing charge/effect rules or automatic ordinary attacks.
Spec: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`, dated A+B section.
Architecture: runtime owns eligibility/effects; MainController guards combat
requests; HUD renders readiness and bounded feedback and emits an intent.
Tech stack: existing Godot 4.7.1 GDScript / GUT 9.7.1. No new runtime dependency.

## Acceptance and execution

- [x] Add real-main integration tests in `tests/integration/test_manual_ultimate_input.gd`:
  E/joypad Y/action requests reduce a ready Guiin resource to zero once; repeat
  key echo does not consume; paused/noncombat/dead requests preserve resource;
  charged Cheonsul without valid status targets rejects and preserves resource.
- [x] Run focused GUT before implementation and observe assertion failures.
- [x] Add `ultimate` InputMap action (E / joypad Y), `ultimate_requested` HUD
  intent and `UltimateButton` under `CombatTopBar/Row`. MainController handles
  non-echo unhandled input and button through `_on_ultimate_requested()`.
- [x] Add runtime-owned `ultimate_block_reason() -> StringName` to the existing
  school base/host and Cheonsul override for `no_target`. Do not infer target
  availability inside HUD or change ultimate damage/cost.
- [x] Wire readiness on selection and signals; update after rejection/success.
  Render charging/ready and short failure/success text in the same top control.
  Guard pause/settings, game-over/player death and `_combat_enabled` in Main.
- [x] Update existing top-bar contract assertions to include the single manual
  ultimate. Keep ordinary lower skill controls excluded.
- [x] Run focused and full GUT, import and headless smoke; inspect live rendered
  HUD at the actual viewport. Test key, pad-event, button and modal boundaries.
- [x] Review all changed behavior/canon/evidence five times under project rules.
- [ ] Commit/push exact revision, open current-task PR and inspect exact-head checks.

## Alternatives and feasibility

ADAPT InputMap plus `_unhandled_input`: lets UI consume gameplay input first.
REJECT polling Input every frame for ultimate: introduces held/repeat and modal
leak risks. REJECT HUD owning charge/target filters: duplicates domain legality.
Read official Godot InputEvent and BaseButton docs on 2026-09-10; code paths and
existing ultimate domain make this feasible without save changes or new autoloads.
Keep existing engine baseline after current official archive check; no upgrade.

Protected: katana/shuriken/ninjutsu auto timing, dash immunity, bag transactions,
Trace/Fate/route/economy, original artwork and PDF. Revert this package's commit
to roll back; no save migration or destructive cleanup is needed.
Live Hera status initially has no editor. Verify exact project/engine/session
before launching. Machine input is not physical controller/touch or Human PASS.

Evidence: docs/reviews/2026-09-10-manual-ultimate-review.md. Physical pad/touch
and live paused-input observation are not covered by the completed machine steps.
