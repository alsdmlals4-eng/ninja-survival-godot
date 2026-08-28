# 2026-08-29 Four-school Circuit Execution — Incident / Solution / Lesson

```yaml
classification: PROJECT_INCIDENT_SOLUTION_LESSON
status: CURRENT_TASK_UNMERGED
base_promotion: NO_BASE_PROMOTION
```

## Incident A — Workbench state existed without a complete player input path

### Evidence

`RestBackpackSession`, `CombinationResolver` and the atomic commit coordinator already owned legal layout, move/undo and first-tier combination rules. The current Workbench view initially exposed reward selection and buffer placement but did not show active/occupied board cells, move/undo or the explicit combination transaction.

### Solution

- Render a snapshot-derived 6×6 board with active cells and current item occupancy.
- Keep legality in `RestBackpackSession` / `BackpackResolver`; the UI emits only placement, move, undo and combination intents.
- Add explicit `CombinationResolver` preview → result-origin placement → cancel paths. A pending result blocks Workbench commit.

### Lesson

For spatial-build games, a domain-complete transaction is not a player-complete slice until the player can see the legal state, make the intended change and recover from a mistake without UI bypass ownership.

## Incident B — Retry could debit before restoring a malformed checkpoint

### Evidence

The initial retry flow spent the persistent Soul and consumed the one retry before sequential state restore calls. A focused integration test corrupted the build payload and reproduced a balance decrease with no restoration.

### Solution

`RunBuildState`, `RunRouteState`, `RunSettlementLedger` and `SchoolCircuitController` each expose non-mutating checkpoint preflight. `MainController` requires every preflight to pass before `NinjaSoulWallet.spend_for_retry()` or `RunCheckpoint.consume_retry()` is called.

### Lesson

Any persistent debit adjacent to a multi-owner restore needs an all-owner preflight boundary. “Each restore is individually validated” is insufficient if the debit occurs before the first failed restore.

## Incident C — Legacy normal-kill modifier conflicted with the fixed economy policy

### Evidence

The approved G rule is data-owned: normal 20% × 1G, Elite 5G, school Boss 10G. Older `RunModifierSet.normal_kill_gold_pct` still exists in catalog/modifier compatibility data, but the new policy correctly ignores it. Older tests instead expected a fractional carry payout.

### Solution

- Correct the regression tests to prove seeded `RunEconomyPolicy` payouts and source receipts.
- Add a regression assertion that the legacy modifier cannot override fixed normal/Elite/Boss policy rewards.
- Preserve the field rather than silently deleting or repurposing catalog data outside a dedicated product decision.

### Revisit condition

If economy-affecting backpack/Fate effects are desired again, define a new policy owner and player-facing explanation before changing `RunEconomyPolicy`. Do not revive a hidden fractional carry rule.

## Base promotion

`NO_BASE_PROMOTION`: the general transaction-preflight principle is already covered by Base atomicity/evidence rules. The Workbench layout and fixed G policy are specific to `닌자의 신`.
