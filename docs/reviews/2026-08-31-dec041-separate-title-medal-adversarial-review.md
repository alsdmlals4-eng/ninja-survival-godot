# DEC-041 · 분리 타이틀 메달 적대적 검토

> Review mode: `attack → validate-critique → refine-approved-findings → regression-recheck → decision-report`
> Scope: user-locked v2 medal-free title background and separate four-traditions medal
> Input branch: `codex/dec037-runtime-migration-135`, pre-commit worktree on `c16e783849fd79186a977c14c0c6ee0e4f81c3fa`
> Main readback before mutation: `9855f9a5fa2e4297e3171a1b1903d3517719ad93`
> User authority: `좋아 메달도 따로 만들어서 배치해` followed by `승인`, 2026-08-31 KST

## Approved boundary and protected strengths

- Replace the title's baked-medal presentation with a medal-free v2 backdrop
  plus one independent transparent v2 medal beside the already locked title
  logo.
- Preserve the fixed ninja, moon, temple silhouettes, dark painterly ink
  language, title-to-Stage gate, guide/settings behavior, automatic combat
  boundary, and all save/domain owners.
- Keep the v1 baked-medal key art as provenance and rollback source; do not
  delete or overwrite it.
- This review does not claim runtime render, Human Usability, Player
  Experience, touch/gamepad, device, or export validation.

## Three viable alternatives

| Alternative | Result | Decision |
| --- | --- | --- |
| Keep v1 key art and its baked medal | Lowest implementation cost, but cannot independently size or position the medal | `REJECT` |
| Overlay the new transparent medal over the baked v1 medal | Keeps the backdrop bytes, but creates an unavoidable double ring/halo after the requested size reduction | `REJECT` |
| Medal-free v2 backdrop plus separate RGBA v2 medal `TextureRect` | Gives independent placement while retaining the approved visual identity and a reversible v1 rollback source | `ADOPT` |

## Full-scope improvement loops

| Loop | Full-scope attack and validated result | Applied correction / regression evidence | Better alternative and long-term fit | Exit state |
| --- | --- | --- | --- | --- |
| 1 | Attacked candidate eligibility, visual identity, alpha, consumer specificity, scope, cost, and rollback. The medal is a 1254×1254 RGBA source with transparent corner samples; the backdrop is 1672×941 RGB and changes only the baked-medal field. | Registered two versioned files without overwriting v1; SHA-256 receipts are `265201…61cc` and `86f86d…030c`. | Reusing v1 as an opaque backdrop cannot meet separate placement; no provider, plugin, or paid tool is needed. | Candidate lock eligible. |
| 2 | Attacked direct-consumer and stale-reference drift: a new `TitleMedal` could exist while the backdrop still referenced the baked source, or the manifest could claim v1 was current. | Bound `TitleScreen/Backdrop` to v2 and `TitleScreen/TitleMedal` to the new transparent v2 source. Updated current decisions, active context, visual handoff, and manifest; targeted freshness search finds v1 only as historical provenance/rollback. | A shader or opaque cover would add a fragile visual masking layer; replacing the backdrop consumer is clearer and reversible. | `CONFLICT_FIXED`. |
| 3 | Attacked title interaction regression: a new overlay could intercept pointer input, alter start focus, or reveal combat from the title. | `TitleMedal.mouse_filter = IGNORE`; focused title/start tests passed `3/3`, `68` assertions. Existing start still opens only the Stage selector, while guide/settings remain local panels. | Folding the medal into the logo would remove independent tuning and violate the requested separation. | No interaction regression found. |
| 4 | Attacked import and source-integrity failure: copied PNGs can exist on disk while Godot cannot load them, or an asset could hash-drift after copy. The first focused test exposed missing Godot import metadata. | Performed one headless Godot editor import; both `.import` receipts appeared. Re-ran focused tests green and re-read exact SHA-256 values. | Treating file presence as a load proof was rejected; import plus real `TextureRect` resource loading is the required boundary. | `COMPLEMENT_GAP_FIXED`. |
| 5 | Re-attacked the whole approved scope: title composition ownership, old-asset rollback, exact manifest data, normal Stage entry, horde/dash/weapons/backpack domains, Base reuse, branch/PR safety, cost, and evidence ceiling. | Godot 4.7.1 editor parse and 300-frame main-scene smoke passed; full GUT passed `586/586`, `6587` assertions. No user-owned tracked change was replaced and no new save/autoload/plugin/tool was added. | Existing Base BCP-043/049 candidate-first visual contract already owns this common workflow; creating a duplicate Base skill/module would be duplication rather than promotion. | Machine-scope clean candidate. |

## Findings and decisions

- `MUST_FIX` — none remain.
- `SHOULD_FIX` — none remain within the approved implementation boundary.
- `CONFLICT_FIXED` — current consumer and active visual authority now describe
  the v2 split rather than the former baked-medal composition.
- `COMPLEMENT_GAP_FIXED` — Godot import metadata was absent after binary copy;
  a single editor import restored actual Texture2D loadability before green
  validation.
- `REJECTED_CRITIQUE` — do not generate a duplicate Base tool, plugin, or
  skill: Base BCP-043 and BCP-049 already define the reusable image candidate
  and final-lock boundary.
- `ALLOWED_LEGACY` — v1 baked-medal title art is retained only for provenance
  and rollback, with no direct current consumer.
- `BLOCKED_UNVERIFIED` — live render, Human/Player Experience, device/export,
  and complete touch/gamepad visual observation remain unrun because no exact
  Ninja Survival Hera editor session is attached. These are reported as
  `NOT_RUN`, not a failed or passed visual result.

## Completion-candidate rescan

The machine-scope work list is empty after source, manifest, scene, test,
Godot-import, parse, smoke, and full-suite readback. The only remaining gate is
separate human/runtime visual observation of the exact project revision. It is
not silently promoted by the automated evidence above.

## CLEAN_REVIEW_EXIT

`CLEAN_REVIEW_EXIT_MACHINE_SCOPE`: five complete loops re-attacked the full
approved change and found no remaining machine-scope blocker, stale active
consumer, duplicate Base work, or regression. A later merge requires exact-head
CI/review and post-merge main readback; live visual/Human/device evidence stays
explicitly `NOT_RUN` until actually observed.
