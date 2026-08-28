# DEC-031 — 기본 Run 종료 + GOLD 1회 긴급 학교 재도전

```yaml
decision_id: DEC_031
status: APPROVED_PRODUCT_SCOPE_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec031-gold-one-time-emergency-school-retry.md
implementation_reality: FULL_RUN_SCENE_RELOAD_ONLY
human_player_evidence: NOT_RUN
```

## 1. 결정

기본 패배 규칙은 **B안: Run 전체 종료**다. 현재와 마찬가지로 긴급 재도전을 사용하지 않으면 사망은 이 Run의 progress를 끝내고 새 Run으로 돌아간다.

다만 한 Run에 한 번만, 플레이어는 현재 승인된 Run 재화인 **`GOLD`**를 지불해 직전 성공 Workbench checkpoint에서 **같은 활성 학교**를 다시 시작할 수 있다.

```text
player death
-> retry unused + valid committed Workbench checkpoint + checkpoint GOLD >= retry cost?
   -> player explicitly spends GOLD
   -> retry_used = true
   -> restore last committed build/Fate/route checkpoint
   -> restart the same active school at 0:00
otherwise
   -> Run ends -> new Run
```

정확한 GOLD 비용은 Human/Player balance validation 전까지 `TUNE_NOT_LOCKED`다. 새 영구 재화, 부활 토큰, 자동 부활, 재도전 횟수 추가는 승인하지 않는다.

## 2. checkpoint와 손실 규칙

긴급 재도전은 마지막 **성공 atomic Workbench commit**에서만 생긴다. 이 checkpoint는 이미 commit된 Backpack, Fate, route/clear order, Run GOLD를 하나의 restoration boundary로 보관한다.

- retry cost는 failed-school 동안 새로 얻은 GOLD가 아니라 checkpoint GOLD에서 차감한다. 실패한 학교의 임시 GOLD/ORB/Chest token/Trace/미확정 Boss reward는 모두 잃는다.
- checkpoint GOLD가 retry cost보다 적거나, 첫 학교처럼 성공 Workbench checkpoint가 없으면 긴급 재도전은 제공되지 않고 기본 Run 종료가 적용된다.
- 재도전은 같은 활성 학교의 `0:00`부터 시작한다. 다른 미방문 학교로 우회하거나, Elite/Trace/Boss 상태를 보존하거나, 보상을 중복 획득할 수 없다.
- retry를 한 번 쓴 뒤 다음 패배는 항상 Run 전체 종료다. 이후 Workbench commit이 생겨도 같은 Run에서 재도전권은 재충전되지 않는다.

## 3. Player Promise와 trade-off

기본적으로는 생존 실패가 Build·route 선택의 긴장을 유지한다. 그러나 이미 확보한 학교를 다시 반복하도록 강제하지 않고, 한 번의 비싼 회복 기회로 현재 학교의 위험/telegraph/Boss 학습을 다시 시도하게 한다.

대신 재도전은 값싼 무한 학습권이 아니다. 비용은 이미 확정된 GOLD를 줄이고, 한 번뿐이며, 실패한 학교에서 얻은 모든 임시 성과를 버린다.

## 4. 보호 규칙

- `RunRetryCheckpoint`는 UI가 아닌 domain owner다. 기존 `RestCommitCoordinator`의 Backpack + Fate + route atomicity를 우회하거나 복사하지 않는다.
- checkpoint 생성은 Workbench commit이 성공한 뒤 한 번만 일어난다. 실패/취소/pending reward/workbench invalid 상태에는 checkpoint를 갱신하지 않는다.
- retry spend와 snapshot restore는 all-or-none이다. insufficient GOLD, already-used retry, checkpoint 없음, active-school 불일치 중 하나라도 있으면 상태를 바꾸지 않는다.
- 기본 Run 종료는 삭제하지 않는다. 긴급 retry CTA를 선택하지 않거나 자격이 없으면 현재 Game Over -> new Run 흐름을 따른다.
- `GOLD`는 Run 재화다. Ninja Soul, 새 저장/메타 통화, 유료 통화, 별도 복구 token으로 대체하지 않는다.

## 5. Definition of Ready 영향

Phase 2 implementation contract는 다음을 포함해야 한다.

1. checkpoint data contract와 `RestCommitCoordinator`/`RunBuildState`/`RunRouteState` 소유 경계.
2. retry cost의 tune range와 checkpoint GOLD 부족·first-school·Boss/Trace/Workbench 각 death state의 rule table.
3. Game Over UI의 기본 새 Run CTA와 조건부 1회 `GOLD` 재도전 CTA의 한국어·mouse/keyboard-gamepad/touch path.
4. no-duplication regression: GOLD, Boss reward, chest token, Trace, Fate, route clear order, retry-used flag.
5. machine/runtime/Human/Player/device evidence를 분리한 validation matrix.

## 6. Evidence-based benchmark disposition

- **REFERENCE / Hades:** escape attempts end but permanent progression and story make another attempt meaningful. 이 프로젝트는 현재 해당 persistent package를 이번 scope에 넣지 않으므로 전체 초기화만을 그대로 채택하지 않는다. [Official Steam page](https://store.steampowered.com/app/1145360?l=english)
- **REFERENCE / Vampire Survivors:** death ends the time-survival attempt while earned gold supports later survivors. 이 프로젝트는 Run GOLD와 planned Ninja Soul를 동일시하지 않는다. [Official page](https://poncle.games/vampire-survivors)
- **ADAPT / Dead Cells accessibility:** 기본 permadeath와 별개로 biome 시작점 재개 Assist Mode를 둔다. 이를 난이도 설정으로 복사하지 않고, one-time·GOLD-gated·same-school retry로 제한해 route/Build 긴장을 보존한다. [Official core rule](https://deadcells.com/) · [Official Assist Mode notes](https://deadcells.com/patchnotes/29)

## 7. 적대적 검토 — 전체 범위 5회

1. **무한 farm:** failed school의 GOLD·reward·Trace를 restore하지 않고, checkpoint GOLD에서만 비용을 내게 해 실패 반복으로 재화를 만들 수 없게 했다.
2. **route 우회:** same active school restart만 허용한다. 미방문 학교 변경·clear-order 변경은 retry 중 불가다.
3. **Workbench 권한:** checkpoint는 성공 atomic commit 후에만 갱신한다. UI preview/pending reward가 build authority가 되는 경로를 금지했다.
4. **첫 학교 공정성:** checkpoint가 없으므로 기본 Run 종료가 적용된다. 시작 GOLD나 공짜 revive를 발명하지 않는다.
5. **증거 과장:** 현재 코드는 scene reload만 구현한다. 이 결정을 구현/테스트/Human PASS로 주장하지 않는다.
