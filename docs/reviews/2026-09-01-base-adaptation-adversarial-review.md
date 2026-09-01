# Ninja Survival · Base Adaptation Adversarial Review

Review mode: running-adversarial-review-and-refinement.
Scope: PROJECT_NATIVE_BASE_ADAPTATION_DOCUMENTATION_ONLY.
User approval: RECOMMENDED_THIN_ADAPTER_APPROVED_2026_09_01.
Project branch: codex/base-adaptation-contract-136.
Source main: 9855f9a5fa2e4297e3171a1b1903d3517719ad93.
Base observed main: 19355b7ef065a21d0f2b685c7d9be64a4a3970f8.
Full Base adapter: EXPECTED_NOT_INSTALLED.
Product runtime change: NONE.
Human, player, and device evidence: NOT_RUN.

## Scope, alternatives, and protected boundary

The package changes only the Base-observation ledger, documentation routing,
mutable-state pointer, one procedural contract, this review, and its plan.
Product decisions, Canon, Human/Master GDD, visual/asset manifests, Godot
scripts/scenes/data/tests, runtime behavior, PR #135, PR #49, and uncertain
Godot-generated material are protected without modification.

| Alternative | Decision | Reason |
|---|---|---|
| Copy all Base templates, registries, dashboards, and Skill routes | REJECT | It would duplicate operational surfaces and needs legacy adapter/registry baselines absent here. |
| One native, non-owning project contract mapped to existing owners | ADAPT | It provides a repeatable entry, phase, evidence, and cleanup route without replacing project truth. |
| Two-stage formal Base adapter onboarding | DEFER | It needs a dedicated bootstrap and a later fresh-main migration, not this documentation workstream. |

Official comparison inputs were the 2020 Scrum Guide and GitHub issue/dependency
documentation. They support small explicit work units and dependency visibility;
they do not justify a second project dashboard or task database.

Each loop below re-attacked all changed files and the full approved scope:
user intent, authority, Base fit, current/open PRs, runtime/asset
non-interference, cleanup safety, evidence limits, cost/permission exposure,
Git protection, rollback, alternatives, long-term maintenance, and completion.

## Loop 1 — authority and destructive-action attack

Input: uncommitted documentation candidate.

Validated finding BAWC-001, MUST_FIX: the phrase safe cleanup could be read as
allowing deletion despite the project deletion approval boundary. Correction:
continuation permits cleanup classification only and explicitly does not
authorize destructive removal.

Validated finding BAWC-002, SHOULD_FIX: ACTIVE_CONTEXT changed while
state_router_updated_at still named 2026-08-30. Correction: it now names
2026-09-01 KST only.

Regression check: no cleanup automation, deletion path, product rule, or
evidence claim was introduced. Better alternative result: full Base onboarding
remains unnecessary for this scope. Long-term fit: PASS. Clean exit: false.

## Loop 2 — duplicate owner and Base-adapter claim attack

Input: loop-1-corrected uncommitted candidate.

Attack covered duplicated product/GDD/asset/runtime ownership, false full
adapter validation, generated dashboard/registry scope creep, PR boundary,
permissions, cost, rollback, evidence limits, and the remaining full scope.
Validated findings: none.

Verification: the owner table routes every product fact to an existing owner;
PROJECT_BASE_ADAPTER_NOT_INSTALLED is explicit; and the Base validator returns
the expected missing-adapter failure rather than a false success. Better
alternative result: the project-native contract is the smallest owner with a
real consumer. Long-term fit: PASS. Clean exit: false.

## Loop 3 — phase, evidence, and player-claim attack

Input: loop-2-reattacked uncommitted candidate.

Attack covered phase mapping, runtime/asset non-interference, Human and device
claim inflation, Phase 3 consumer requirements, Phase 4 scope, cost,
permissions, Git/PR isolation, cleanup safety, alternative fit, and completion.
Validated findings: none.

Verification: all five phase names and their re-open rules are present; Phase 3
requires an actual consumer; E0 through E6 remain separate; and the narrowed
status-value scan reports NO_OVERCLAIM_STATUS_VALUES. Better alternative:
separate evidence classes are safer than one completion status. Long-term fit:
PASS. Clean exit: false.

## Loop 4 — routing, freshness, and PR-isolation attack

Input: loop-3-reattacked uncommitted candidate.

Attack covered documentation discoverability, Base/project revision freshness,
PR collision, authority duplication, adapter boundary, runtime/asset
non-interference, cleanup, evidence, cost, rollback, and long-term fit.
Validated findings: none.

Verification: DOCUMENTATION_MAP routes L1+ proposal/mutation to the contract;
fresh fetch confirms Base origin/main is 19355b7 and project origin/main is
9855f9a; and this branch merge-base equals 9855f9a with no product PR paths
changed. Better alternative: separate governance worktree/PR is stronger than
folding this scope into product work. Long-term fit: PASS. Clean exit: false.

## Loop 5 — cleanup, rollback, and completion-candidate attack

Input: loop-4-reattacked uncommitted candidate.

Attack covered removal-by-name/date risk, unknown generated material, adapter
absence classification, path containment, rollback, evidence ceiling, PR
protection, cost/permissions, alternatives, and completion conditions.
Validated findings: none.

Verification: removal requires references/consumers zero, reread,
Git-recoverable change, and post-removal readback; UNKNOWN_UNVERIFIED is
preserved; the Base validator exits 1 only because
skills/PROJECT_BASE_ADAPTER.json is absent and is EXPECTED_NOT_INSTALLED; and
git diff --check is clean. Better alternative: a full adapter bootstrap is a
future package, not a complement required here. Long-term fit: PASS.
Clean exit: true.

## Loop 6 — exact-static-readback re-attack

Input: loop-5 candidate after the final contract/static readback.

Attack covered the final changed-path boundary, contract markers, external
discoverability pointers, evidence-status overclaim, diff whitespace,
full-adapter-validator interpretation, protected PR boundaries, runtime claim
inflation, rollback, and whether the static result itself introduced a product
claim. Validated findings: none.

Verification: the exact changed set is the six approved documentation paths;
contract markers and three discovery routes pass; no full-adapter or
Human/player/device `PASS` status value exists; `git diff --check` passes; and
the Base validator fails only with the expected absent
`skills/PROJECT_BASE_ADAPTER.json` message. No Godot source, scene, data,
asset, test, generated file, PR #135, or PR #49 path is present. Better
alternative: retained thin adaptation remains lower-risk than premature full
adapter onboarding. Long-term fit: PASS. Clean exit: true.

## Correction and regression summary

| Finding | Decision | Correction | Regression result |
|---|---|---|---|
| BAWC-001 continuation cleanup ambiguity | MUST_FIX | Continuation permits classification only; destructive removal remains explicit-user-only. | No deletion path exists. |
| BAWC-002 stale state-router date | SHOULD_FIX | state_router_updated_at now records 2026-09-01 KST. | Product resume/evidence claims are untouched. |
| Broad Human text scan matched valid negation | REJECTED_CRITIQUE | Static check narrowed to actual status-value claims. | NO_OVERCLAIM_STATUS_VALUES. |

## Final decision

Approved-scope implementation remaining work: 0.
Implementation correction rescan: complete.
Post-completion adversarial review: six full loops complete.
Final state: CLEAN_REVIEW_EXIT_CANDIDATE.
Contract/static evidence: E1_STATIC_PASS on the pre-commit exact candidate.
Automated runtime evidence: NOT_RUN_NOT_APPLICABLE_TO_DOCUMENTATION_SCOPE.
Human/player/device/export evidence: NOT_RUN.
Rollback: revert the one documentation-only commit; no product data, asset,
save, or runtime migration is involved.

Remaining delivery work is commit, push, PR creation/CI review, then
post-merge main readback. No Base promotion, full adapter installation,
cleanup deletion, or gameplay implementation is implied.
