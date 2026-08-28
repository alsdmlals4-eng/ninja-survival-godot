# DEC-035 — Repository-only project record and Notion retirement

```yaml
decision_id: DEC-035
status: APPROVED_WORKFLOW_AND_DOCUMENTATION_SCOPE
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec035-repository-only-project-record.md
implementation_reality: NO_GODOT_OR_ASSET_BEHAVIOR_CHANGE
human_player_evidence: NOT_APPLICABLE
```

## Decision

`닌자의 신` no longer uses Notion as an active project tool or owner. The
repository is the single active source for the human-readable GDD, Flow,
Visual Bible, structured product canon, asset provenance, implementation
contract, code/data/Scene/Resource, tests, and evidence receipts.

Existing Notion pages and attachments remain intact, but are
`HISTORICAL_REFERENCE_ONLY`. Current and future work must not read, search,
write, upload, attach, or wait for Notion destination readback.

## Repository asset gate

```text
fresh canon + actual consumer
-> text brief
-> generate one candidate
-> user LOCK / REVISE / REJECT
-> only LOCK: repository source + SHA-256/provenance manifest
-> actual consumer integration
-> applicable import/runtime/Human evidence
```

An old Notion attachment is historical provenance only. It neither blocks nor
satisfies a new asset gate. No existing Notion data is deleted or migrated
solely for this decision.

## Scope and supersession

- Supersedes active Notion source/read/write/attachment/readback steps in
  project workflow documents and `AGENTS.md`.
- Does **not** supersede the current product, visual grammar, approval level,
  single-character identity, asset consumer, or evidence boundaries.
- Does **not** start Godot production, asset batch generation, or Human
  validation.
- If a needed fact exists only in historical Notion and has no repository
  equivalent, classify it `UNKNOWN_UNVERIFIED`; do not silently revive Notion.

## Incident / Solution / Lesson

- **Incident:** human-facing current truth, visual approval, and asset
  receipts were split between repository and an external Notion surface.
  Continuing to require that surface would create a stale/unavailable
  dependency after the user's retirement decision.
- **Solution:** use the repository Master GDD, current decision ledger,
  visual handoff, manifest/provenance, and production evidence as the only
  active record. Historical Notion references remain non-operative receipts.
- **Lesson:** a project documentation owner must be executable by the current
  workflow. When an external owner is retired, its current rules need an
  explicit repository replacement rather than a silent omission.

## Base promotion

`NO_BASE_PROMOTION`: retiring a specific external documentation owner and
choosing repository-only asset provenance is a project/user workflow decision.
The general source-owner migration principle is already covered by Base
fresh-read and evidence-ownership rules.
