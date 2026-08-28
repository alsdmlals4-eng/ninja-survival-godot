# 네 유파 Circuit 구현계약 — 적대적 검토

```yaml
scope: DEC036 + NINJA_FOUR_SCHOOL_CIRCUIT_V1 + Phase2_DoR
assessed_main: 50fbf203ec3f71af1633a5b6cc74e7167c0604c8
review_status: CLEAN_FOR_SOURCE_PR_THEN_PDF_PUBLICATION
human_player_evidence: DEFERRED_NOT_RUN
loops_completed: 5
```

## Evidence used

- CURRENT: `AGENTS.md`, `ACTIVE_CONTEXT.md`, `CURRENT_CONFIRMED_DECISIONS.md`, DEC-014~036, Master GDD, screen coverage, actual `scripts/`, `scenes/`, `tests/`, workflow, GitHub open-pr/issue readback.
- EXTERNAL REFERENCE: current official/primary pages for [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/), [Brotato](https://store.steampowered.com/app/1942280/Brotato/), [Backpack Battles](https://store.steampowered.com/app/2427700/Backpack_Battles/), [Hades II](https://www.supergiantgames.com/games/hades-ii/), and [Godot Control](https://docs.godotengine.org/en/stable/classes/class_control.html).
- NOT USED AS CURRENT TRUTH: historical Notion records, old branches, closed PR WIP, the draft PR #49, old image candidates.

## Five whole-state loops

| loop | attack | validated finding | correction / disposition |
| --- | --- | --- | --- |
| 1 | Could the contract claim four schools while retaining Cheonsul-only runtime? | Yes; existing adapter is Cheonsul-specific. | Require one school-neutral circuit owner and data-composition tests; do not claim implementation. |
| 2 | Could Trace, Workbench or UI silently own a rule it must not? | Yes; current Trace is `R`/button recovery and current UI only renders pending reward. | Define Trace pickup owner and coordinator-only atomic commit; UI remains intents/snapshots. |
| 3 | Does “human QA is unnecessary” accidentally become a UX PASS? | Yes; historical issue wording could mislead. | DEC-036 defers sequencing only; every package keeps `NOT_RUN`. |
| 4 | Could retry/Soul scope cause duplicate settlement or premature final content? | Yes; wallet/ledger did not exist, and fourth Boss is not true Run end. | Separate wallet debit, eligibility ledger and checkpoint; prohibit Soul credit before final package. |
| 5 | Could icon/HP/UI work drift from the approved visual grammar or turn a board into a runtime asset? | Yes; text badge is actual code and the visual board is reference-only. | Add semantic presenters, keep blue/amber Cheonsul and purple/black Heukyeong boundaries, no generated board/asset promotion. |

## Additional adversarial findings

```yaml
finding_id: INC_126_01
class: STALE_TRACKING
evidence: Issue_62 describes T13 although PR_63 is merged; Issue_68 remains Cheonsul-only despite DEC-029; Issue_93's screen audit owner exists on main.
disposition: RECONCILE_IN_THIS_PACKAGE
impact: prevents an obsolete checklist from blocking or duplicating the new contract.

finding_id: INC_126_02
class: EVIDENCE_LIMIT
evidence: no current local Godot executable was discoverable from the planning worktree; existing CI/workflow documents still define import/smoke/GUT checks.
disposition: NOT_A_CONTRACT_BLOCKER
impact: this documentation package cannot claim a new local runtime test; future implementation must fresh-resolve the approved exact engine before authoring.
```

## Clean exit conditions

- No new product direction was invented: all user-facing system rules come from DEC-027~035 or the user's 2026-08-29 Human-QA deferment.
- Three materially different reference patterns were considered: time survival, auto-fire shop cadence, spatial backpack buildcraft. The contract adapts their general lesson and rejects their expressive surfaces.
- The four-school scope uses one controller/data chassis, not four engines.
- Final Binding, final calamity, Soul credit, player evidence, device/export, and production asset batches remain outside the package.
- The Human GDD changed, so its PDF manifest is deliberately `STALE_PENDING_MAIN_SOURCE_PUBLICATION` until the required second publication PR records the completed-main source commit. The implementation-contract approval request starts only after that publication package returns to `CURRENT`.
