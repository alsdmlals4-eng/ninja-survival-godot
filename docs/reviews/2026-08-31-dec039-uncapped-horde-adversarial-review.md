# DEC-039 무제한 일반 군중 adversarial review

```yaml
review_scope: DEC-039 amendment - remove normal-enemy maximum cap
review_state: FIVE_WHOLE_SCOPE_LOOPS_COMPLETE
base_commit: PRE_UNCAPPED_DEC039_LOCAL_COMMIT
implementation_head: SAME_UNMERGED_DEC039_DELIVERY_COMMIT_AFTER_AMEND
machine_evidence: GODOT_4_7_1_EDITOR_IMPORT_PARSE_MAIN_SMOKE_FULL_GUT_555_OF_555_6131_ASSERTS_PASS
scoped_runtime_after_amendment: NOT_RUN
human_player_device_balance: NOT_RUN
```

## Loop 1 — hidden maximum-cap reentry attack

**Attack.** Search source, scene exports, and test contracts for a renamed or
indirect `max_active_enemies` ceiling after the user removed the cap.

**Evidence.** `WaveSpawner` no longer exports or validates a maximum count;
`main_scene.tscn` has no such authored field; `test_script_contracts.gd`
asserts the property is absent.

**Disposition.** `CLEAN` — no normal-enemy numeric capacity remains.

## Loop 2 — timed accumulation attack

**Attack.** Start from more than the 10-enemy floor and verify that a scheduled
batch still gets silently clamped by current population.

**Evidence.** `test_spawn_wave_has_no_normal_enemy_cap` starts with 11 normal
enemies and proves two calls add `3 + 3`, ending at 17. `_spawn_count()` loops
over the requested count directly; it contains no active-count capacity math.

**Disposition.** `CLEAN` — every allowed timed wave adds its authored batch.

## Loop 3 — floor and lifecycle ownership attack

**Attack.** Try to turn uncapped accumulation into a second spawn owner or
allow it to bypass Elite, Trace, Boss, Workbench, Result, or Game Over gates.

**Evidence.** `ensure_minimum_active()` still supplies only a missing floor;
`WaveSpawner` is still the sole normal spawner; all creation paths require
`_spawning_enabled`. Existing integration coverage confirms Game Over disables
the spawner and stage lifecycle tests keep permission authority outside it.

**Disposition.** `CLEAN` — removing the cap did not change encounter ownership.

## Loop 4 — product wording and false-safety attack

**Attack.** Look for current canon/spec/plan wording that still promises an
18-enemy ceiling, or reinterpret an uncapped count as a performance or balance
pass.

**Evidence.** DEC-039 canon, current decisions, Master GDD, spec, and plan now
state no normal-enemy maximum cap. They explicitly retain lifecycle stops and
mark performance, survival curve, Human, Player, device, and balance evidence
as unrun.

**Disposition.** `CLEAN` — the user decision is represented without a false
release or performance claim.

## Loop 5 — exact regression/evidence-boundary attack

**Attack.** Parse the exact modified project, smoke the main scene, and run the
whole regression suite; then attempt to promote that result to post-amendment
human runtime evidence.

**Evidence.** Godot 4.7.1 editor parse and headless main-scene smoke pass.
Full GUT passes `555/555` tests and `6131` assertions. No desktop observation
was run after this cap-removal amendment.

**Disposition.** `MACHINE_CLEAN / RUNTIME_NOT_RUN_AFTER_AMENDMENT`. The next
gate must observe uncapped horde performance and player survival/readability;
machine success is not a balance or Human Usability pass.

## Clean exit

No current code/canon/scene/test ownership blocker remains for removing the
normal-enemy cap. The retained risk is deliberately uncapped runtime load and
the player survival curve, both deferred to the next actual player/runtime
validation gate.
