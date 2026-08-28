# 네 유파 Circuit 실행 — 적대적 검토

```yaml
scope: ISSUE_126 + NINJA_FOUR_SCHOOL_CIRCUIT_V1
base_main: e53b41cf5c7e138735df90c2b654e62acb4d50d8
review_status: CLEAN_FOR_MACHINE_SCOPE_PENDING_STATUS_ICON_ASSET_LOCK
human_player_evidence: NOT_RUN
loops_completed: 5
```

## Evidence boundary

- CURRENT: approved contract/decisions, the current-task code and Scene/Resource state, focused GUT, full GUT, Godot headless editor parse and five-second main-scene smoke.
- EXTERNAL: the existing contract's official Godot Resource/RNG documentation and its benchmark dispositions remain applicable; no new market claim is made by this implementation review.
- NOT evidence: historical Notion, older visual boards, a generated status atlas, Human Usability, Player Experience, device/export or a real player session.

## Five whole-state loops

| loop | full-scope attack | validated finding | correction / disposition | recheck |
| --- | --- | --- | --- | --- |
| 1 | Can one school-neutral lifecycle actually carry all four school identities without a Cheonsul-only back door? | Yes: old MVP2 test controls still required `cheonsul_slice`. | Move the debug Cheonsul test targets onto the current `school_circuit_role` path without changing canonical progression or rewards. | Four-school controller + current Main integration tests. |
| 2 | Can the Workbench claim player control while its board/combination state is invisible or UI-owned? | Yes: active/occupied cells, move/undo and combination output placement were absent from the presentation path. | Snapshot-derived board, move/undo and explicit `CombinationResolver` intent path added; commit remains blocked while a combination is pending. | Workbench UI, Main intent and controller transaction tests. |
| 3 | Can a failed retry corrupt a persistent balance or consume the one retry? | Yes: wallet debit happened before sequential restore failure. | Add non-mutating all-owner checkpoint preflight before debit/consume. | Corrupted-payload integration regression plus wallet/checkpoint tests. |
| 4 | Can old reward assumptions or a legacy modifier override the approved fixed G policy? | Yes: old tests still asserted normal 1G every kill and 25G Boss; `normal_kill_gold_pct` remained in compatibility data. | Assert policy resource receipts and prove the legacy modifier is inert; preserve the field pending a separate catalog decision. | Economy policy and build-state GUT. |
| 5 | Could the package overclaim visual or player evidence after code passes? | Yes: `EnemyEffectBadge` still renders text and the only atlas is `GENERATED_EXPLORATION`. | Record status-icon runtime completion as `PARTIAL`; do not promote or integrate an unlocked image. Keep hit-only HP as machine implementation only. | Documentation readback + exact-head machine checks. |

## Clean machine-scope findings

- The four-school circuit, Trace pickup, Workbench transactional inputs (including combination), fixed G policy and one retry checkpoint all have focused source/transaction/integration evidence.
- Final Binding, final calamity, true Run-end Soul credit and player validation were not absorbed into this package.
- The explicit unresolved item is narrow: a user `LOCK`/revision of a status-icon asset candidate is required before replacing legacy text badges. This is not disguised as an implementation pass.

## Exact current-task machine receipt

```text
Godot 4.7.1 headless editor parse: PASS
Godot 4.7.1 five-second main smoke: PASS
Full GUT: 521/521 tests, 5769 assertions: PASS
```

## Revisit conditions

- Lock or revise the generated status atlas, then perform asset provenance, target-resolution composite and icon/help-path validation before runtime asset integration.
- Run the deferred Human/Player gate before a player-facing milestone; machine evidence remains insufficient for first-session readability, fairness or fun.
