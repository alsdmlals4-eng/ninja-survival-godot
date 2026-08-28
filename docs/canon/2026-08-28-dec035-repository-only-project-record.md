# DEC-035 — Repository-only project record after Notion migration

```yaml
decision_id: DEC-035
status: APPROVED_WORKFLOW_AND_DOCUMENTATION_SCOPE
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec035-repository-only-project-record.md
implementation_reality: NO_GODOT_BEHAVIOR_CHANGE
human_player_evidence: NOT_APPLICABLE
migration_manifest: docs/migration/notion/MIGRATION_MANIFEST.md
```

## Decision

`닌자의 신` moves from Notion to a repository-only active record **without
dropping its existing Notion structure or current work products**. The
repository is the single active owner for the human-readable GDD, Flow, Visual
Bible, structured product canon, asset provenance, implementation contract,
code/data/Scene/Resource, tests and evidence receipts.

The Notion source was used read-only for the migration. Its current structure,
current/partial system records, approved asset records and data-source schemas
are preserved under `docs/migration/notion/`. Existing Notion pages and
attachments remain intact and are not edited or deleted.

After the migration completion check, Notion is
`HISTORICAL_REFERENCE_ONLY`: new project work must not create, modify, upload,
attach or rely on it as an active gate. A migration snapshot is continuity
evidence, not a second active canon.

**Completion receipt:** PR #118 was squash-merged to `main` at
`8ae3dd1c8bea48908117ad4133ce00654a048b3f`. Its exact remote main readback
confirmed the migration manifest and the fixed-player source SHA-256.

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

Migrated Notion asset records preserve provenance and prior approval context,
but do not by themselves satisfy a new asset gate. The migration additionally
put the fixed-player original source into the repository after exact SHA-256
verification; all current approved assets are mapped in the migration manifest.

## Scope and supersession

- Supersedes active Notion source/read/write/attachment/readback steps only
  **after** the migration manifest completion check closes.
- Does not supersede current product, visual grammar, approval level,
  single-character identity, asset consumer or evidence boundaries.
- Does not start Godot production, asset batch generation or Human validation.
- A legacy Notion record that was intentionally excluded is not revived by this
  decision; current truth stays in approved repository Decision/Canon/code.

## Incident / Solution / Lesson

- **Incident:** current structure, visual approval context and asset receipts
  were split between the repository and an external Notion surface. Immediate
  retirement would risk losing project work or page structure.
- **Solution:** capture the current Notion surface read-only, preserve its
  structural snapshots and schemas, map each owner to a repository document,
  validate each approved asset binary/hash, then cut active ownership to the
  repository.
- **Lesson:** external-owner retirement is a migration, not a flag flip. The
  cutover needs coverage, provenance and exclusion evidence before the old
  surface can become historical only.

## Base promotion

`NO_BASE_PROMOTION`: this project-specific Notion structure, asset set and
repository layout are not reusable Base configuration. The general principle is
already covered by Base source-owner/evidence rules.
