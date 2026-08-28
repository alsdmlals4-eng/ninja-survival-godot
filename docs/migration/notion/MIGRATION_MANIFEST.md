# Notion migration manifest — 닌자의 신

```yaml
migration_id: NINZA_NOTION_TO_REPOSITORY_2026_08_28
scope: CURRENT_AND_PARTIAL_PROJECT_STRUCTURE_AND_WORK_PRODUCTS
source_mode: READ_ONLY
source_write_or_delete: PROHIBITED
snapshot_date: 2026-08-28 KST
temporary_notional_file_urls: REDACTED
active_owner_after_cutover: REPOSITORY
```

## What was migrated

| Source category | Read | Repository preservation | Active owner after migration |
| --- | ---: | --- | --- |
| Project hub/Home/6 domain pages/7 project leaf pages | 17 | `structure/*.notion.md` | GDD, canon, visual docs, evidence docs |
| CORE SYSTEM · Master current/partial rows | 8 | `core-system/*.notion.md` | `CURRENT_CONFIRMED_DECISIONS.md`, dated canon, GDD |
| ASSET LIBRARY · Master approved rows | 13 | `assets/*.notion.md` + local assets/manifests | repository binary + SHA/provenance manifest |
| Three Notion database schemas | 3 | `schemas/*.notion.md` | repository documents and data schemas |

The snapshots retain the original Notion page URL, ancestor path, properties and
page content. They are provenance/continuity records only: current product
decisions are still resolved using the repository authority order.

## Structure-to-owner map

| Former Notion surface | Preserved snapshot | Repository owner |
| --- | --- | --- |
| `00 · 프로젝트 허브` | `structure/3c01b237-eb1c-8141-93ae-c528c4f3c40c.notion.md` | `docs/DOCUMENTATION_MAP.md` |
| `닌자 서바이벌 · Home` | `structure/3c41b237-eb1c-81aa-a4e0-e208ba4fb15e.notion.md` | `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` |
| `01 · Direction · Planning` | `structure/3c51b237-eb1c-8105-b7ba-da42ab387b2a.notion.md` | `docs/CURRENT_CONFIRMED_DECISIONS.md`, `docs/canon/` |
| `02 · Combat · Schools · Backpack` / `핵심 시스템 · 상세` | `structure/3c51b237-eb1c-81a1-b20b-cd43555aacc3.notion.md`, `structure/3c11b237-eb1c-8152-8974-cfbd10c889c0.notion.md` | product canon, data, scenes, tests |
| `03 · World · Story · Content` / `세계관 · 핵심 스토리` | `structure/3c51b237-eb1c-81b7-89fb-ecca44caf95e.notion.md`, `structure/3c11b237-eb1c-8142-acf0-db0a7fe0a463.notion.md` | `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` |
| `04 · Visual · UX · Assets` / Visual Bible / UI Flow / Asset Library | `structure/3c51b237-eb1c-8197-853b-ed40c7c7dfb6.notion.md`, `structure/3c01b237-eb1c-8116-9028-c8c8c427e467.notion.md`, `structure/3c01b237-eb1c-81a2-b859-c8155c90ca75.notion.md`, `structure/3c01b237-eb1c-81e6-9d5b-c467b5ad2b1e.notion.md` | `docs/CURRENT_VISUAL_HANDOFF.md`, `docs/visual/`, `docs/assets/approved/`, `assets/` |
| `05 · Production · Validation` / Production Handoff | `structure/3c51b237-eb1c-8111-8160-eccc16740ff8.notion.md`, `structure/3c01b237-eb1c-81b4-a3f5-ec575f3c77b5.notion.md` | `docs/ACTIVE_CONTEXT.md`, `docs/planning/`, code/tests/workflows |
| `06 · Reference · Benchmark` / benchmark library | `structure/3c51b237-eb1c-818b-aeed-c379f4ee5f7f.notion.md`, `structure/3c01b237-eb1c-81c7-99f5-caf371107acb.notion.md` | GDD benchmark section and decision rationale |
| `프로젝트 전체 작업계획` / project registry page | `structure/3c01b237-eb1c-81d8-9e3a-cd5fcc605ec5.notion.md`, `structure/3c01b237-eb1c-814c-892d-dd3d07bfef54.notion.md` | `docs/ACTIVE_CONTEXT.md`, `MVP_ROADMAP.md`, GitHub Issues/PRs |

## Asset continuity audit

| Asset ID | Repository preservation | SHA-256 verification | Runtime status |
| --- | --- | --- | --- |
| `NINJA_PLAYER_BASE_01` | `docs/assets/approved/player-base-original/ninja_player_base_original.png` | exact source match | identity source only; not runtime-bound |
| `NINJA_PLAYER_RUNTIME_MOVE_01` | `docs/assets/approved/img-01-player-runtime-core/player_runtime_move_v2_alpha.png` | exact source match | approved source; no runtime binding |
| Player runtime Hit/Attack derivatives | `docs/assets/approved/img-01-player-runtime-core/` | local SHA recorded in current repository | approved source; no runtime binding |
| Generic yokai ×3 | `assets/runtime/visual-core/` | each Notion hash matches | `EnemyBasic` variant pool |
| Bongma familiar / talisman / Cheonsul boss / reward orb / moonlit backdrop / flame field | `assets/runtime/visual-core/` | each Notion hash matches | consumer and evidence in `docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md` |

All 13 approved ASSET LIBRARY records have a sanitized individual snapshot in
`assets/`. The local repository contains the approved binary or, for the
fixed-player identity, the now-migrated exact original source. No signed Notion
attachment URL is treated as a durable asset owner.

## Deliberately excluded legacy data

| Source | Count | Why it is excluded |
| --- | ---: | --- |
| 작업계획 · Master rows | 7 | T01–T15/old DEC-026 planning receipts are historical implementation history. Merged main, dated canon, tests and current context are stronger owners. |
| CORE SYSTEM · Master `최종 결과 · 닌자소울` | 1 | `DEFERRED` old record. The current user-approved Run-end Ninja Soul policy is owned by DEC-033/current decision docs instead. |

The database schemas themselves remain archived under `schemas/`, so their
former structure is recoverable without promoting historical rows to current
truth.

## Completion checks

- [x] Notion source was read without modification or deletion.
- [x] 17 project structural pages preserved.
- [x] 8 current/partial core-system records preserved.
- [x] 13 approved asset records preserved.
- [x] 3 database schemas preserved.
- [x] Temporary signed file URLs redacted rather than committed.
- [x] All approved asset hashes either match a repository source or the
  user-provided player-base original copied into the repository.
- [ ] Read back the committed remote branch and complete final cutover wording.

## Cutover rule

Until the final checked-in readback is complete, Notion is a **read-only
migration source**. After this manifest's completion check is closed, new
project work must use repository owners only; the preserved Notion snapshot
does not become a duplicate active canon.
