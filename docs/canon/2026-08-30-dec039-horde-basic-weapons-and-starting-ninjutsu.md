# DEC-039 — 군중 압박과 기본 무기 2종, 시작 인법

```yaml
decision_id: DEC-039
status: USER_APPROVED_2026-08-30_KST
amendment: USER_APPROVED_NO_NORMAL_ENEMY_MAXIMUM_2026-08-31_KST
owner: PRODUCT_CANON
depends_on:
  - DEC-026_SHARED_ATTACK_PRIMITIVES_AND_SCHOOL_COMPOSITIONS
  - DEC-037_ONE_FIXED_NINJA_DIRECT_MOVEMENT
runtime_status: IMPLEMENTED_MACHINE_VERIFIED_UNMERGED
approved_runtime_asset:
  id: NINJA_RUNTIME_BASIC_WEAPON_EFFECTS_01
  source: assets/runtime/visual-core/basic_weapon_effects_v1.png
  sha256: 728aff2ed85e233a0adcc195406a9a101b0933da8990078cced1af59c9eaf58a
  status: USER_LOCKED_IMPLEMENTED_UNMERGED
machine_evidence: GODOT_4_7_1_EDITOR_IMPORT_PARSE_MAIN_SMOKE_FULL_GUT_555_OF_555_6131_ASSERTS_PASS
scoped_desktop_runtime_before_uncapped_amendment: STAGE_SELECTION_TOP_HUD_RANDOM_HORDE_APPROACH_AND_GAME_OVER_RENDER_OBSERVED_2026_08_31_KST
uncapped_horde_scoped_desktop_runtime: NOT_RUN_AFTER_2026_08_31_AMENDMENT
human_player_device_balance: NOT_RUN
```

## 결정

선택한 스테이지의 전투 시작 시 플레이어는 조작 가능한 고정 닌자 한 명이며, 즉시 다음 **세 자동 공격 패턴**을 함께 가진다.

1. **일본도** — 가까운 적군을 베는 근접 자동공격. 플레이어 몸체는 공격 포즈로 바뀌지 않고, 일본도 베기 이펙트만 목표 방향에서 짧게 나타난다.
2. **수리검** — 가까운 유효 목표를 향해 날아가는 원거리 자동 투사체. 기존 범용 부적 투사체는 기본 무기로 쓰지 않는다.
3. **선택 유파의 시작 인법** — 봉마류·천술류·귀인류·흑영류 중 선택한 하나의 이미 존재하는 자동 유파 런타임이다. 유파 기술은 이후 인법서 획득으로 확장되는 축이며, 기본 무기와 섞거나 대체하지 않는다.

플레이어 캐릭터의 런타임 표정/자세는 이동과 피격만 표시한다. 유파 런타임의 기존 `player_action_resolved` 신호는 전투/텔레메트리 호환을 위해 남길 수 있으나, 더 이상 플레이어 공격 스프라이트를 재생하는 consumer가 아니다.

## 군중 압박 규칙

- 기존의 동·남·서·북 네 방향 순환 생성은 폐기한다.
- 일반 적은 플레이어로부터 `minimum_spawn_distance` 이상, `maximum_spawn_distance` 이하인 **원형 고리**에서 매 생성마다 난수 각도와 난수 거리로 등장한다.
- 선택 완료 후 일반 적은 즉시 **최소 10마리**까지 채워진다. 사망·정리로 수가 줄어도 일반 스폰이 허용된 동안에는 이 최저 수를 회복한다.
- **일반 적 최대 수는 두지 않는다.** 최소 수를 채운 뒤에도 `1초마다 3마리`의 보충 웨이브가 계속 누적된다. 단, Elite·Trace·Boss·Workbench·Result·Game Over의 기존 스폰 권한 gate가 일반 스폰을 중지한다.
- Elite, Trace, Boss, Workbench, Result, Game Over의 기존 `WaveSpawner.set_spawning_enabled(false)` 권한은 유지한다. 별도 WaveSystem을 만들지 않는다.
- 적은 기존 `EnemyChaser` 이동/접촉 피해와 `MainController._wire_enemy()`의 target/kill/reward wiring을 그대로 사용한다. 생성 위치만 바꾸며 적의 이동 규칙을 우회하지 않는다.

## 전투 권한과 확장 경계

```text
WaveSpawner
  -> normal EnemyChaser only
  -> random annular spawn + minimum active maintenance

BasicWeaponController
  -> katana direct close-range resolution
  -> shuriken projectile emission
  -> effect-only visuals
  -> CombatResolver basic-weapon boundary

SchoolRuntimeHost
  -> exactly one selected-school starter ninjutsu
  -> existing school-owned cadence/field/mark/familiar behavior
```

- `CombatResolver`가 기본 무기 피해도 기록한다. 현 `RunModifierSet`에는 일반 기본무기 전용 수치가 없으므로, 이 패키지에서 기본무기 피해는 existing school-only modifier를 임의로 적용하지 않는다. 훗날 명시적으로 승인된 기본무기 modifier가 생기면 같은 resolver 경계에 추가한다.
- 유파별 인법서의 획득 소스, 인벤토리/슬롯, 희귀도, 선택 화면, 조합과 등급은 이번 패키지에 새로 발명하지 않는다. 기존 19개 acquisition 아이템·Backpack·Workbench 권한을 훼손하지 않는 별도 progression package가 이를 맡는다.
- 기본무기 일본도/수리검은 시작부터 공통으로 가진다. 유파는 네 개의 새 플레이어 본체나 무기 스킨이 아니다.

## 시각 자산 경계

`NINJA_RUNTIME_BASIC_WEAPON_EFFECTS_01`은 한 장의 투명 RGBA 아틀라스다.

- 좌측 영역: 일본도 베기 이펙트
- 우측 영역: 수리검 투사체 이펙트
- 실사용자는 `BasicWeaponController`의 짧은 베기 Sprite와 `ShurikenProjectile/Visual`이다.
- 기존 승인 `player_runtime_attack_v2_alpha.png`와 `talisman_projectile_v1.png`는 삭제하지 않는다. 전자는 historical approved source로 보존하고 runtime consumer만 제거하며, 후자는 새 기본 수리검 consumer로 전용하지 않는다.

## 검증 및 증거 경계

기계 검증은 무작위 고리 거리 범위, 최소 10마리 복원, 최대치 없이 누적되는 보충 웨이브, 스폰 차단, 일본도/수리검/선택 유파 인법의 동시 활성, resolver 기록, 투사체/베기 이미지 consumer, 플레이어 공격 포즈 제거를 다룬다. 현재 scoped desktop 관찰은 스테이지 선택, 상단 HUD, 여러 방향의 군중 접근, Game Over 표현만 확인했다. 짧은 무기 이펙트 개별 프레임의 사람이 읽는 품질과, 무입력/짧은 이동에서 약 3초 내 사망한 압박 값은 separate balance/Player gate에서 재검토한다. 이는 수치가 재미있다거나 실제 사람이 군중을 읽고 대시를 사용하기 좋다는 증거가 아니다. Human Usability, Player Experience, touch/gamepad/device/export, balance 및 release는 `NOT_RUN`으로 남는다.
