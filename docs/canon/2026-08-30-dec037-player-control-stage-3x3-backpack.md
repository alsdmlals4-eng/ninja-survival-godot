# DEC-037 — 한 명의 조작 닌자, Stage/Phase, 3×3 시작 가방

```yaml
decision_id: DEC-037
status: APPROVED_BY_USER_2026-08-30_KST
owner: PRODUCT_CANON
supersedes_for_player_facing_surfaces:
  - legacy school terminology
  - 6x6 board presented as the starting backpack
runtime_migration_status: IMPLEMENTED_MACHINE_VERIFIED_UNMERGED_2026-08-30_KST
runtime_evidence_code_head: e9275abbe0a954313f468224bd0ceff21d27a57c
runtime_machine_evidence: GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_FOCUSED_GUT_23_OF_23_197_ASSERTS_1772_FULL_GUT_71_OF_71_555_ASSERTS_6030_PASS
scoped_live_runtime_observation: GODOT_4_7_1_SCOPED_STAGE_SELECTION_TOP_HUD_KEYBOARD_MOVEMENT_DASH_RECHARGE_AND_GAME_OVER_RENDER_OBSERVED_2026-08-30_KST
scoped_runtime_balance_signal: IDLE_GAME_OVER_AROUND_PLAY_00_04_TO_00_05_AND_SIMPLE_STRAIGHT_MOVEMENT_PLUS_ONE_DASH_GAME_OVER_AT_PLAY_00_14_OBSERVED_NOT_A_BALANCE_VERDICT
human_player_touch_gamepad_device_export_balance: NOT_RUN
```

## 결정

1. 플레이어는 Run 전체에서 **한 명의 고정 닌자**를 직접 이동한다. 전투의 기본 직접 행동은 이동이며, 자동 공격/전승 반응은 닌자의 위치와 확정된 빌드가 만든 자동 결과다.
2. 플레이어에게 보이는 다음 목적지는 **스테이지**다. 한 스테이지 안의 기존 `Stage 1..4` 진행 축은 **페이즈 1..4**로 표시한다. 내부 legacy `school` 식별자와 클래스명은 별도 migration 전까지 호환 목적으로 유지할 수 있다.
3. Run 시작의 실제 사용 가능 가방은 **정확히 3×3**이다. 획득한 가방의 배치로 사용 가능 공간을 확장하며, 기술적 최대 외곽은 기존 6×6 안에 둔다. 플레이어 화면은 6×6 전체를 시작 가방처럼 표시하지 않는다.

## 보호 규칙

- 아이템/가방 90도 회전, 직교 인접, special-bag one-cell-or-more overlap, six-slot REST buffer, 명시적 first-tier combination, preview combat power 0, committed modifier snapshot의 단일 combat authority를 유지한다.
- Workbench의 final backpack snapshot + pending Fate + provisional next Stage는 all-or-none commit을 유지한다.
- UI는 snapshot을 렌더하고 intent만 낸다. 공간 legality, economy, route, Fate, transaction authority를 가져오지 않는다.
- 한 명의 닌자 정체성과 trace-layer visual rule을 유지한다. Stage는 서로 다른 주인공/코스튬 선택지가 아니다.

## 이행 경계

이 결정은 사람용 Blueprint/기술 명세와 별도 fresh-main implementation package로 이행했다. 코드 기준 `e9275abbe0a954313f468224bd0ceff21d27a57c`에서 Godot 4.7.1 import, editor parse, main-scene smoke, 변경 범위 GUT 23 scripts/197 tests/1,772 assertions, full GUT 71 scripts/555 tests/6,030 assertions이 통과했다. 이 결과는 자동화·기계 검증 범위만 뜻하며, live observation 또는 Human/Player/device evidence가 아니다.

- `BackpackState` 시작 bag/cell, catalog item footprint, resolver/session/UI, save/rollback, GUT regression
- Stage/Phase 공개 UI, help, route/result copy 및 legacy identifier migration
- 전투에서 조작 닌자와 자동 행동의 경계가 보이는 HUD/input/feedback
- pointer, keyboard/gamepad, touch의 전투/Workbench 핵심 경로

## 증거 경계

문서와 PDF의 변경은 `DOCUMENTED`/publication evidence다. 위의 3×3 runtime과 UI 용어 이행은 `MACHINE_VERIFIED`이고, Godot 4.7.1 scoped live observation에서 Stage 선택, top-only HUD, keyboard 이동, DASH 충전 소모·회복, Game Over render를 실제로 관찰했다. 정지 시 약 `PLAY 00:04–00:05`, 단순 직선 이동+한 번의 대시 시 `PLAY 00:14`의 Game Over도 관찰했으나, 이는 접촉 압박의 후속 balance 검증 신호일 뿐 balance 판정이 아니다. Human Usability, Player Experience, touch/gamepad/device/export, balance와 release도 계속 `NOT_RUN`이며 기계 또는 scoped live 검증으로 승격하지 않는다.
