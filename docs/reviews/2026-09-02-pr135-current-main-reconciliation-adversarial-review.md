# PR #135 Current-Main Reconciliation — Adversarial Review

> **Review state:** `LOCAL_CANDIDATE_CLEAN_PR_CI_MERGE_AND_MAIN_READBACK_PENDING`
> **Scope:** A fresh branch from completed `origin/main`
> `7b94efa90ec8c577edf0317163c4cf6b30a32531` absorbing selected deltas from
> the user-approved but read-only source head
> `d65a712d441d3ca854ee8ae2edff468bb4974983`.
> **Exclusions:** Human Usability, Player Experience, keyboard/gamepad/touch
> end-to-end play, device/export, balance, and release acceptance.

## Evidence boundary

The candidate passed Godot 4.7.1 import and main-scene smoke; focused GUT
`55/55` tests with `585` assertions; and full GUT `605/605` tests with
`6,789` assertions. A fresh Ninja Survival editor session rendered the title
and Stage selector, read the declared input map, and exposed the initial
horde tree without source diagnostics. These are local machine and scoped
runtime facts only; they do not establish CI, a merge, Human usability, or
balance.

## Five full-scope attack loops

| Loop | Whole-scope attack | Validation and result | Correction / regression result |
| --- | --- | --- | --- |
| 1 | Could the source merge erase the merged Blueprint, contract, or mutable router authority? | The only direct conflict was `docs/ACTIVE_CONTEXT.md`; `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` and `docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md` remain present. | Kept current-main router content, then added a reconciliation overlay only. TDD surface test was RED on exact main and GREEN after the selected source consumers existed. |
| 2 | Could the automatic-combat package make normal Core enemies spam opening projectiles, talismans, or floor zones? | Focused horde, actor, encounter, weapon, Dash, and loadout suites pass. The Core contract stays pursuit/contact only; Elite/Boss retain telegraphed pattern owners. | No source repair was validated as necessary. `21/21` focused combat/encounter tests (`231` assertions) pass. |
| 3 | Could title actions, checkpoint/Continue, Awakening naming, Codex scope, or top-only HUD duplicate state authority or reintroduce manual skills? | Title/HUD/persistence/Codex/asset suites pass. `MainController` remains transition/checkpoint owner; `TitleScreen` is presentation; the wallet remains internally compatible. | No source repair was validated as necessary. `33/33` focused title/HUD tests (`349` assertions) pass. |
| 4 | Could runtime evidence be polluted by a stale editor configuration instead of the reconciled source? | An editor opened before the source input map was loaded reported missing movement/Dash actions. The source file had the actions; the stale session was stopped, project settings re-read in a fresh session, and the fresh runtime had no source errors. | Environmental correction only: restart from the exact candidate. Fresh title/Stage render, input-map readback, and initial `Player`/`WaveSpawner`/ten-enemy horde tree observation succeeded. No code claim is based on the stale session. |
| 5 | Could provenance/docs overclaim full bespoke art, completed merge, or Human validation; or could task-only artifacts leak into the repository? | Eight adopted PNG hashes match their manifest values. The three user-locked Bongma actor binaries are genuine consumers, but the full four-school data roster does not have a complete individually locked actor-art set. Temporary editor/test addons and generated import files were removed from the candidate. | Added current-main evidence overlays to the decision ledger, visual handoff, visual manifest, DEC-037, and Master GDD. GitHub CI, merge/readback, Human/device/balance remain explicit pending states. A task-only GUT archive outside the repository could not be deleted under the host policy and is reported separately; it is not tracked or consumed by the project. |

## Better-alternative recheck

- **Rejected:** rewriting/rebasing the original PR #135. It would mutate the
  user-approved source and require unsafe history handling.
- **Adopted:** a new current-main branch with source lineage declared in the
  receipt, plan, ledger, and PR body. It preserves the existing Blueprint and
  singular Workbench/Fate/route owners.
- **Deferred:** generating an unbounded batch of four-school art to hide the
  partial bespoke-asset gap. It expands the approved reconciliation scope and
  would need separate candidates, consumers, review, and runtime validation.

## Clean exit condition for this review

No local P0/P1 issue remains in the approved reconciliation scope. The
remaining required gates are protected-PR exact-head CI, merge, post-merge
main readback, and the explicitly separate Human/player/device/balance
validation. Any change after this review requires re-running the affected
machine checks and this whole-scope review.
