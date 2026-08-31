# DEC-042 · title actions, Continue, Awakening, and Codex adversarial review

> Review mode: `attack → validate-critique → refine-approved-findings → regression-recheck → decision-report`
> Scope: approved title actions, checkpoint-only Continue, player-facing
> Awakening wording, and read-only Codex; no new title image, economy, or
> meta-progression system.
> Input branch: `codex/dec037-runtime-migration-135`, post-main readback worktree
> Main readback before mutation: `9855f9a5fa2e4297e3171a1b1903d3517719ad93`
> User authority: approved DEC-042 recommendation, including `닌자소울 → 각성`
> player copy and Codex as enemy/ninjutsu/equipment explanation rather than a
> progress journal, 2026-09-01 KST.

## Approved boundary and protected strengths

- Retain the user-locked title backdrop, wordmark, and separate four-piece
  medal unchanged; this package does not generate, replace, or alter image
  source bytes.
- Add exactly the player-requested title actions: New Game, Continue,
  Awakening, Codex, guide, settings, and quit.
- Continue begins only from the atomic Workbench boundary, reconstructs a fresh
  Core-pressure Stage at `PLAY 00:00`, and refuses corrupt/unknown persistence
  without deleting it.
- Keep `NinjaSoulWallet` and its legacy file identity as the only permanent
  balance/debit owner; only player-facing wording becomes `각성`.
- Codex is factual/read-only, catalog-derived, and has no discovery, unlock,
  extra save, or combat-authority path.
- This review does not claim live visual render, Human Usability, Player
  Experience, full input-device observation, device/export, or release PASS.

## Viable approaches considered

| Alternative | Result | Decision |
| --- | --- | --- |
| Save arbitrary live combat state, enemies, projectiles, elapsed time, and temporary Workbench UI | Much broader migration surface and fragile state restoration; contradicts the approved Workbench boundary | `REJECT` |
| Store only a Boolean that a run exists, then reconstruct rewards from UI state | Cannot prove build/route/loadout integrity or safely reject corruption | `REJECT` |
| Validate a primitive Workbench checkpoint at the domain boundary and recreate fresh Core pressure | Preserves the meaningful committed choice while avoiding invalid mid-combat restoration | `ADOPT` |
| Create a separate “Awakening” wallet/save system | Breaks approved compatibility and duplicates permanent-currency authority | `REJECT` |
| Derive a text-native read-only Codex from current catalogs | Keeps explanations current without manufacturing an unlock system | `ADOPT` |

## Full-scope improvement loops

| Loop | Full-scope attack and validated result | Applied correction / regression evidence | Better alternative and long-term fit | Exit state |
| --- | --- | --- | --- | --- |
| 1 | Attacked persistence shape, object leakage, unknown schema/item handling, partial restoration, corrupt record deletion, and route/backpack/loadout reconstruction. Codec and store tests proved JSON primitives only, unknown content rejection, and retained corrupt records. | Added/kept strict codec/store gates; focused resume codec/store and circuit tests passed. | A raw `JSON.stringify` of runtime objects would be shorter but loses validation and type boundaries. | No partial checkpoint leaked. |
| 2 | Attacked the one-retry rule across application relaunch. A valid finding showed `retry_consumed` was present in the in-memory checkpoint but absent from durable resume payloads, so reopening Continue could reset it. | Added a red codec test, persisted/restored `retry_consumed`, reconstructed the local retry checkpoint after Continue, and passed focused retry/Continue tests. | Treating a restarted process as a new retry allowance violates the existing once-per-checkpoint rule. | `MUST_FIX_FIXED`. |
| 3 | Attacked the two-file retry handoff: a resume write failure after wallet spend could debit the player before the consumed state was durable. | Retry state now saves before the wallet debit; a failed resume write restores the in-memory retry state. If the wallet debit fails, the consumed state is rolled back and re-saved. Focused retry and circuit tests passed `17/17`, `229` assertions. | Moving wallet ownership into UI or resume storage would violate the protected wallet owner. A full cross-file journal is not justified without a demonstrated disk-failure product requirement. | `MUST_FIX_FIXED`; rare dual-storage I/O failure remains an explicit future hardening boundary. |
| 4 | Attacked title entry regression and shared local user data: old title tests started from whichever default resume file happened to exist, while the new correct New Game rule prompts when a record exists. | Tests now use only their own `user://gut…` temporary record and remove only that exact test path before configuring it. Title-to-Stage and four-school tests passed `15/15`, `186` assertions; no user record is deleted. | Removing the confirmation would satisfy old tests but violate approved data-loss protection. | `CONFLICT_FIXED`. |
| 5 | Re-attacked the whole package: title consumer ownership, locked visual reuse, action labels, New Game confirmation, corrupt Continue handling, Core-at-zero resume, retry balance compatibility, Codex facts, horde/dash/school circuit regression, main parse/smoke, branch safety, and evidence ceiling. | Focused title/resume/retry regression passed `25/25`, `296` assertions. Full GUT passed `604/604`, `6784` assertions. Godot `4.7.1` headless main-scene smoke exited cleanly. | Existing project-local codec/store/presenter patterns fit better than adding an autoload, paid dependency, plugin, or Base duplicate. | Machine-scope clean. |

## Findings and decisions

- `MUST_FIX_FIXED` — retry consumption is now durable across Continue/relaunch.
- `MUST_FIX_FIXED` — retry transitions save consumed resume state before the
  existing wallet debit and roll the checkpoint state back on either pre-play
  failure path.
- `CONFLICT_FIXED` — title regression tests explicitly isolate their own
  temporary persistence record instead of depending on a shared user record.
- `REJECTED_CRITIQUE` — no new `각성` wallet, no Codex unlock system, no live
  combat persistence, no duplicate Base plugin/skill, and no replacement art.
- `ALLOWED_LEGACY` — technical `NinjaSoulWallet` identifiers and
  `user://ninja_soul_wallet_v1.json` remain compatibility data; player UI says
  `각성`.
- `BLOCKED_UNVERIFIED` — live visual layout/readability, Human Usability,
  Player Experience, touch/gamepad visual behavior, device/export, and
  release status are `NOT_RUN`. Headless smoke and GUT do not promote them.

## Completion-candidate rescan

The approved machine-scope list is empty after the five whole-scope loops:
source ownership, persistence validation, retry consistency, title navigation,
Codex data source, regression coverage, and headless main startup all have
current evidence. The remaining next gate is a human live-screen pass on the
exact PR head: title density/medal scale, Korean readability, Continue error
copy, keyboard/gamepad/touch focus return, and first resumed Core pressure.

## CLEAN_REVIEW_EXIT

`CLEAN_REVIEW_EXIT_MACHINE_SCOPE`: no remaining machine-scope blocker or
approved-scope regression is known. A later merge still requires exact-head CI
and a post-merge main readback. Human visual/device/release claims remain
explicitly `NOT_RUN` until observed.
