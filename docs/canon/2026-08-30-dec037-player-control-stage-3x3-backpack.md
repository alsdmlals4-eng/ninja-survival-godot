# DEC-037 — 한 명의 조작 닌자, Stage/Phase, 3×3 시작 가방

```yaml
decision_id: DEC-037
status: APPROVED_BY_USER_2026-08-30_KST
owner: PRODUCT_CANON
supersedes_for_player_facing_surfaces:
  - legacy school terminology
  - 6x6 board presented as the starting backpack
runtime_migration_status: DEFERRED_UNTIL_HUMAN_BLUEPRINT_FINAL_REVIEW
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

이 결정을 사람용 Blueprint/기술 명세에 먼저 반영한다. 실제 Godot 이행은 사용자 final PDF review 후 별도 fresh-main package에서 다음을 같이 다룬다.

- `BackpackState` 시작 bag/cell, catalog item footprint, resolver/session/UI, save/rollback, GUT regression
- Stage/Phase 공개 UI, help, route/result copy 및 legacy identifier migration
- 전투에서 조작 닌자와 자동 행동의 경계가 보이는 HUD/input/feedback
- pointer, keyboard/gamepad, touch의 전투/Workbench 핵심 경로

## 증거 경계

이 문서와 PDF의 변경은 `DOCUMENTED`/publication evidence다. 3×3 runtime, UI 용어 이행, Human Usability, Player Experience, touch/gamepad/device/export는 `NOT_RUN`이며 문서 발행으로 승격하지 않는다.
