# Runtime Battlefield Floor — Adversarial Review

> Date: 2026-08-30 KST
> Scope: the user-locked continuous floor tile only. Sparse props and contact
> shadows are explicitly excluded until their separate batch approval.

## Approved boundary

- Replace the direct fixed battlefield background binding with a repeating,
  player-camera-compatible floor surface.
- Preserve the old backdrop source for provenance and rollback.
- Keep all combat, route, reward, input, player, enemy, HUD, and visual-effect
  owners unchanged.
- Do not turn the generated sparse-prop atlas or contact-shadow candidate into
  a repository or runtime asset before a user batch `LOCK`.

## Five full-scope adversarial loops

| Loop | Attack | Validated finding and correction | Evidence/result |
| --- | --- | --- | --- |
| 1 | Could the new image be missing, wrong, or untracked? | Added the repository-local PNG plus SHA-256/provenance and an exact resource-path assertion. | Focused `test_main_scene.gd`: 11/11 tests, 118 assertions passed. |
| 2 | Could a fixed Sprite2D leave a moving player on a finite image? | Replaced the direct backdrop Sprite2D with `Parallax2D`, `repeat_size = (1254, 1254)`, and one child tile. | A pre-change headless harness failed because `BattlefieldBackdrop` was not `Parallax2D`; the post-change harness passed. |
| 3 | Could the visual cover gameplay or change game rules? | Retained `z_index = -10`, placed only the tile under the backdrop, and added an assertion that it stays behind the player. | Scene/test source inspection and focused test passed. |
| 4 | Could the legacy moonlit backdrop be accidentally deleted or silently rewritten? | Kept its source and historical manifest receipt; document the consumer change explicitly instead of rewriting its merge record. | `moonlit_battlefield_backdrop_v1.png` remains present; only the `Main` binding changed. |
| 5 | Could unapproved prop/shadow art enter runtime through this change? | Kept both candidates outside the repository, manifest, and scene tree. | Git/scene inspection: no prop or shadow consumer exists in this branch. |

## Machine evidence and ceiling

- Godot 4.7.1 console import/parse plus the focused pre/post harness: pass.
- Focused `tests/integration/test_main_scene.gd`: 11/11 tests, 118 assertions:
  pass.
- Existing focused `test_mvp3_four_school_modifiers.gd`: 5/5 tests, 87
  assertions: pass.
- At this floor-only review's original point, the full GUT run ended at 520/521
  under suite ordering and the same single failure reproduced on the exact
  `origin/main` baseline (`b0d310d1b7b8006524e7078fa1a9443430481e38`). Later
  diagnosis traced that fixture to a time-randomized workbench reward layout:
  the test assumed every offered item fitted the starting board. The repair
  fixes only the test fixture's existing circuit RNG to seed `1`; production
  `Main` still calls `randomize()`. The repaired fixture passed three
  consecutive runs, and the final full suite passed 523/523 tests with 5832
  assertions; there is no current full-suite blocker for this branch.
- Ninja Survival had no attached live Godot/Hera editor session. Live rendered
  continuity, input, Human Usability, Player Experience, and device/export are
  all **NOT_RUN**.

## Result and next safe work

The floor tile is `USER_LOCKED` and implemented only on the current isolated
branch. It is not merged. The user subsequently batch-locked the sparse-prop
atlas and contact-shadow candidate; their separate implementation does not
require regenerating this locked floor tile.
