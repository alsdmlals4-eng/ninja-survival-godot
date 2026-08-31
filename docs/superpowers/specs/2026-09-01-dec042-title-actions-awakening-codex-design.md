# DEC-042 Title Actions, Awakening, and Codex — Design Specification

**Status:** User-approved product direction; implementation specification review pending
**Date:** 2026-09-01 KST
**Owners:** `MainController` owns Run/persistence transitions. `TitleScreen` owns presentation/intents. Existing catalog and domain classes own all Codex facts.

## Purpose and approved scope

The title becomes the complete player-facing front door while preserving the locked `닌자의 신` wordmark and its separately placed four-traditions medal. No raster art is created or changed.

The approved menu order is:

1. **새 게임**
2. **이어하기**
3. **각성**
4. **도감**
5. **조작 방법**
6. **설정**
7. **종료**

The user changed the player-facing permanent-resource name from `닌자소울` to **각성**. Existing `NinjaSoulWallet` and `user://ninja_soul_wallet_v1.json` remain legacy technical identifiers, so existing balance/save data continues to work. This package does not alter resource amount, source, or retry cost.

`도감` is a read-only reference surface for actual **적 / 인법서 / 장비** definitions. It is not a Run-flow record, route journal, discovery gate, or a new progression/save system.

## Current facts and problem

The current `TitleScreen` exposes only `시작하기`, `조작 방법`, and `설정`. `시작하기` opens the Stage selector with combat disabled. `MainController` already owns an in-memory `RunCheckpoint`, captured only after successful Workbench/Fate/route commit. It includes committed build, route, Boss ledger, and backpack state, but cannot cross restarts because it contains GDScript objects rather than primitive file data.

The existing wallet is the only persistent debit owner. The current Game Over copy still says `닌자소울`.

## Alternatives and decision

| Approach | Decision | Reason |
| --- | --- | --- |
| Frame-exact mid-combat save (units, projectiles, timers, hazards, incomplete Workbench edits) | **REJECT** | Duplicates combat/transaction ownership and risks restoring invalid partial state. |
| Current in-memory retry only | **REJECT** | Does not provide the approved restart-safe `이어하기` action. |
| Durable checkpoint only after atomic Workbench commit | **ADOPT** | Reuses the existing safe commit boundary and starts a clean Stage encounter from committed data. |
| Title-owned wallet, catalog, or route state | **REJECT** | Creates duplicate authority and data drift. |
| Thin project-owned resume store/presenter that reads existing domains | **ADOPT** | Preserves `TitleScreen` as a view and existing catalog/domain owners as truth. |

Godot documents `FileAccess` for persistent `user://` game data and `Control` focus navigation for keyboard/controller UI. The implementation uses those capabilities without treating source/API research as runtime, Human-UX, or device proof.

## Player behavior

### 새 게임

`새 게임` keeps the existing flow: hide the title, open the existing Stage selector, and keep combat disabled until an explicit Stage choice.

If a valid resumable checkpoint exists, it first displays a local confirmation:

> 새 게임을 시작하면 현재 이어하기 기록이 삭제됩니다. 계속하시겠습니까?

Only confirmation clears the record and sends the existing Stage-selection intent. Cancellation returns focus to `새 게임` and preserves the record.

### 이어하기

`이어하기` is enabled only for a schema-valid and domain-valid saved checkpoint. It asks `MainController` to restore. The title remains visible until all validation/reconstruction succeeds.

The durable checkpoint is written **only after** the existing Workbench commit succeeds, `_capture_run_checkpoint()` has captured the committed state, and the next active Stage has started. It is never written during normal combat, enemy/projectile/hazard activity, pending Workbench/Fate/route edits, Game Over, or before a valid committed checkpoint exists.

Cold resume begins the saved active Stage at its fresh Core-pressure state and `00:00`, reconstructing committed build, route, ledger, backpack, and active Ninjutsu loadout. It intentionally does not serialize transient battlefield nodes. It is a safe checkpoint continuation, not a frame-perfect replay.

Malformed JSON, unsupported schema, unknown/duplicate current IDs, invalid relationships, or failed reconstruction keeps the title open, disables Continue, preserves the source file for diagnosis, and displays:

> 이어하기 기록을 확인할 수 없습니다.

### 각성

`각성` opens a local read-only panel showing `NinjaSoulWallet.balance()` as **보유 각성** and explaining:

> 각성 1을 사용하면 유효한 워크벤치 기록에서 현재 스테이지에 한 번 재도전할 수 있습니다.

It adds no shop, grant, second data store, or spend action. Game Over and retry button copy change to `각성`; the wallet class/path/debit logic remain unchanged.

### 도감

`도감` opens a local panel with **적 / 인법서 / 장비** tabs. The first tab receives focus. Each tab has a scrollable list and selected-entry description. It shows no discovery/progression/Run-flow state.

| Tab | Source of truth | Player information |
| --- | --- | --- |
| 적 | `EncounterCatalog`, `EncounterActorDefinition` | display name, tradition/Stage identity, Core/Elite/Boss role, contact pressure or telegraphed pattern description |
| 인법서 | `NinjutsuCatalog`, `NinjutsuDefinition` | display name, tradition, acquisition lane, actual attack primitive description |
| 장비 | `MVP4Catalog` item/bag/combination definitions | display name, type, footprint/bag shape, static/spatial/backpack role description |

`CodexPresentation` derives ordered primitive view dictionaries from those current definitions. It must not invent combat values, lore, availability, or behavior not present in the current source. It cannot mutate combat, route, build, catalog, or persistence.

### Existing panels and exit

`조작 방법` and the current non-persistent fullscreen `설정` panel remain. `종료` opens a local confirmation; only confirmation emits an intent and `MainController` calls `get_tree().quit()`.

Only one title modal may be visible. Its backdrop blocks underlying pointer input. Closing/cancelling restores focus to the action that opened it.

## Ownership and interfaces

### `TitleScreen`: presentation only

`TitleScreen` renders the approved title assets, menu, and local panels. It emits only high-level intents:

```gdscript
signal new_game_requested
signal continue_requested
signal exit_confirmed
```

It exposes presentation setters only:

```gdscript
func set_continue_available(available: bool, reason: String = "") -> void
func set_awakening_balance(balance: int) -> void
func set_codex_entries(entries_by_category: Dictionary) -> void
```

It must never write a file, spend Awakening, select a Stage, mutate a Run, or instantiate combat content.

### `MainController`: Run transition and availability

`MainController` creates/configures one non-autoload `RunResumeStore`; provides Continue availability, Awakening balance, and Codex presentation to the title; clears a resume only after confirmed New Game; restores before hiding the title; and performs quit on confirmed exit. Failed restore cannot leave combat enabled, the title hidden, or a partial `school_circuit` alive.

### `RunResumeStore` plus codec: durable representation boundary

`RunResumeStore` is a project-owned `RefCounted` helper supplied by `MainController`, not an autoload/second Run owner. It stores schema-versioned primitive-only data at `user://ninja_run_resume_v1.json`, with `user://ninja_run_resume_v1.backup.json` as last-known-valid fallback.

Write sequence:

1. Encode the authoritative in-memory checkpoint into JSON-safe primitives.
2. Validate the payload before replacing an existing canonical record.
3. Write/flush a temporary file.
4. Parse and validate the temporary-file readback.
5. Preserve a valid primary as backup.
6. Replace the primary only after the preceding checks.

Read sequence tries primary then valid backup and returns explicit `VALID`, `MISSING`, or `INVALID`. Invalid data is never silently deleted.

The codec alone converts primitive data to/from the current checkpoint contracts, including:

- `RunBuildState` primitive fields, committed `RunModifierSet`, and economy receipts;
- `RunRouteState` snapshot;
- `RunSettlementLedger` eligible Boss IDs;
- `SchoolCircuitController` active Stage and committed `BackpackState` bags/items/instance IDs/rotations; and
- `NinjutsuLoadoutState` origin, active, and pending spell IDs.

Decode checks ID existence/uniqueness, item/bag placement, route/fate/modifier invariants, and final domain restoration before applying. It serializes no `Object`/`Resource`, enemy/projectile/hazard/UI state, clock, or pending Workbench operation.

## UI and input contract

The menu stays in the existing left safe area below the logo/medal lockup. `새 게임` is default focus; `이어하기` is immediately below and visibly disabled with a reason when unavailable. Decorative title assets remain pointer-ignored.

Every menu/modal action has explicit keyboard/controller focus neighbours in menu order. A modal focuses its first action; close/cancel restores origin focus. Codex list/detail supports pointer and keyboard/controller focus.

## Automated acceptance evidence

The implementation is TDD: each behavioral test must be observed failing before its production code is added.

1. Title action/menu surface, modal exclusivity, focus restoration, and unavailable Continue presentation.
2. New Game overwrite confirmation, existing Stage selector handoff, and disabled combat gate.
3. Player-facing `각성` title/Game Over copy while legacy wallet identity/path remains compatible.
4. Codex categories derived from actual catalogues and unable to mutate source/build/route data.
5. Missing/valid/corrupt/unsupported resume records, backup fallback, primitive-only payload, and no invalid-data deletion.
6. Cold resume of a committed checkpoint into a fresh active Stage; invalid data leaves title/combat state safe.
7. Focused GUT, full GUT, editor parse/import, and headless main-scene smoke.

Automated evidence remains separate from runtime render/input, Human Usability, Player Experience, device/export, balance, and release evidence.

## Scope safeguards and feasibility

- Preserve approved title assets and exact current consumers; generate no image.
- Preserve wallet class, balance, debit behavior, and legacy file path.
- Preserve Workbench atomicity; pending transactions have no durable-resume eligibility.
- Preserve the existing New Game Stage-selection/combat-enable gate.
- Preserve corrupt save sources for diagnosis.
- The new title actions/store/codec are independently removable without changing wallet, route, combat, or current in-memory `RunCheckpoint` contracts.

The repository already contains a post-commit checkpoint capture point, domain validators, a Stage-start owner, a persistent wallet, catalog data owners, title panel patterns, and GUT tests. Required work is limited to serialization/reconstruction through existing boundaries, UI presentation, and tests. It has zero incremental cost and no external service dependency.

There is no exact Ninja live-editor session for this package at specification time. Any eventual parser/import/smoke/GUT result must not be presented as live-render, Human, Player Experience, device/export, or release validation.
