# 닌자의 신 — 구현 입력 명세

문서 ID: NS-IMPLEMENTATION-PACKET · 2026-09-11 · 최종 설계 승인 대기

## 준비 범위와 실행 경계

상세 규칙의 수치는 NS-DESIGN-RULES가 소유한다. 이 명세는 그 규칙을 기존 Godot 책임자에 연결하는 계약이다. 기존 main과 작업 브랜치의 차이를 지우지 않는다. 새 게임 기능은 이번 문서 작업으로 구현되지 않는다. 설계 승인 후 아래 P01부터 별도 exact-main 작업을 시작할 수 있으나 이미지의 알파·모션 검수가 실패한 상태로 최종 아트를 런타임에 넣지 않는다.

시각 후보의 상태는 자산 manifest가 소유한다. 새로운 자동 로드, 외부 서버, 유료 API, 다른 게임 엔진은 필요하지 않다. 기존 Scene/Resource 및 GUT를 재사용한다. 새 순서형 반응 엔진을 하나 더 만드는 대신 기존 천술의 상태 책임을 공유 효과 처리로 명시적으로 추출한다.

## 오의 호환성 명세 보강 — R-ULTIMATE

최신 변경: CheonsulRuntime은 전방 고정 방향/플레이어 추종 원점의 브레스 틱을 소유한다.
거리+내적 부채꼴 판정, 틱별 hit set, 대시 취소, 사망 정리를 검증한다. 렌더 파티클은
판정 권한이 아니다. 귀인화는 GuiinRuntime의 수명 토큰과 BasicWeaponController의
임시 검 profile로 분리한다. 원래 RunBuildState 장비 스냅샷을 교체하거나 저장하지 않는다.
CombatResolver의 원천 판정과 NinjutsuAutoController의 발동 차단이 같은 모드 토큰을
소비해야 이미 생성한 소환체/지속 피해가 제한을 우회하지 않는다. 별도 전역 manager 금지.

추가 인수 요구: 브레스 앞/뒤/±30°/거리320 경계, 이동·고정 방향,6틱, 같은 틱 재진입,
대시 즉시 취소, 일시정지. 귀인화는 근접4종×공격/보호 책 조합, 기존 투사체·소환체·독·
조합 피해 차단, 보호 유지, 원래 쿨다운/장비 단계 복구, 사망/장면 이탈 중복 정리를 시험한다.
임시검 전환은2026-09-12 사용자 진행 승인으로 채택했다. 이 시험 목록은 구현 완료 증거가 아니다.

아래 이전 패키지의 ‘호환성 명세가 남음’ 상태를 대체한다. 기본 충전·독립 효과는 상세 규칙에 명세했으며 실행 검증/최종 승인은 아직 남았다. 숫자는 상세 규칙만 소유한다.

- 기존 네 SchoolRuntime에서 평상시 내장 공격을 제거하고 선택 인법 소비처에만 둔다. 기존 Host/자원 신호는 재사용한다. 봉마 상시 식신/결계, 천술 원소 교대, 귀인 기본 맥동, 흑영 자동 다중 암영침이 제거 검증 대상이다.
- 자원/상한/비용/활성 지속과 발동 원자성은 각 runtime이 소유한다. 흑영은 살아 있는 적의 표식 합이 아니라 독립 준비 값을 소유한다. 표식은 책 효과로 남는다.
- 기본 충전은 전투 delta만, 보너스는 중복 제거한 CombatEvent만 소비한다. 천술 reaction-resolved는 자원 통지 전용 예외다. 보너스 내부주기는 벽시계가 아닌 전투 시간으로 잰다.
- UI 상태는 CHARGING / READY_NO_TARGET / READY / ACTIVE / BLOCKED. resource_changed는 수치, ultimate_ready_changed는 충전 도달을 알리되 실제 요청에서 대상·pause·생존을 재검사한다. UI 활성 상태를 권한으로 신뢰하지 않는다.
- schema2의 정확한 필드는 E의 checkpoint.ultimate_charge를 따른다. 진행 중 오의 객체·적 ID는 저장하지 않는다. 구형 저장 자동 변환 금지. 전투 중 실시간 저장으로 이 경계를 우회하지 않는지 검증한다.
- 인수 fixture는24정의에서 유파별 서로 다른2개를 열거해60행 생성한다. 각 행은 일반 적 단독/보스 단독 성공, 비선택 자동 효과0, 실패 비용0을 검증한다. 빈 맵·메뉴·보너스 중복·지속 정리·NaN 저장 검증을 추가한다. 문서 조합 산술은 GUT를 대신하지 않는다.
- 새 오의는 기존 밸런스 교체이므로 최종 Blueprint 승인 후 구현한다. VFX4종 duration/타격 마커/발 접점/적 전조 비가림 검수는 별도이며 현재 자산 준비 완료로 표시하지 않는다.

## A. 현재 구현 → 변경 지점

### 최신 장비 분리 수정 — 이전 패키지보다 우선

규칙 책임자는 R-EQUIPMENT/R-WEAPON-CONTENT/R-NINJUTSU/R-COMBINATION/R-TRACE/R-ULTIMATE다. 24인법·8무기·3조합·책에 의존하지 않는 오의가 검토용 명세로 준비됐다. 현재 코드는 바꾸지 않았다. 시작 유파 예외는 승인되어 해금/책 유지 + 장비 강화만 제공한다. 시작60쌍 실행 검증, 저장·여정 통합, 최종 자산·Blueprint 승인이 남아 전체 착수 게이트는 닫혀 있다.

RunBuildState가 런 소유 장비·3슬롯·장비별 강화 단계를 단일 확정 스냅샷으로 소유한다. BasicWeaponController는 확정 근접/투사 장비만 소비한다. BackpackState/Resolver는 인법서 두 개의 4칸 배치를 처리하고 장비의 가상 셀/인접을 계산하지 않는다. NinjutsuLoadoutState는 시작3택1×2와 해금/배치를 검사한다. TraditionAccessState는 전장 완료와 인법 해금/포기를 분리한다. 새 autoload나 두 번째 가방 시스템은 만들지 않는다.

필수 인수 시험: 서로 다른 시작 인법2개, 숨은 starter 없음, 전체4/외부1, 장비 슬롯3/점유0, 책4칸/여유5칸, 미장착·미확정 전투력0, 선택 장비만 강화, 교체 시 단계 복사 없음, 강화한 타 유파 후보 제외, 경로 완료 보존, 취소0소비/반복확인1회, 저장 실패 전부 원복. 아직 실행하지 않은 게임 시험이다.

| 현재 소비처 | 현재 상태 | 승인 뒤 변경 | 완료 증거 |
|---|---|---|---|
| `scripts/combat/basic_weapon_controller.gd` | 기본 자동무기 존재 | 근접4/투사4 정의·장비 슬롯 소비 | 경계·투사 수명·시전당 hit set·미장착0 |
| `scripts/player/player_controller.gd` | 이동·대시 기반 | 정지 대시·피격 보호·메뉴 입력 차단 | 0/1/2충전·동시 피해·중지 재개 시험 |
| `scripts/schools/ninjutsu_auto_controller.gd` | 보조 기술 공통 피해 | 24종 효과·상태·대시 종료 훅·분신 | 표 기반24종·재귀금지·정리·pause 시험 |
| `scripts/schools/cheonsul_runtime.gd` | 고정 원소 교대·반응 충전·상태 대상 오의 | 선택 책만 상태 생성, 기본 충전+반응 보너스, 무상태 오의 허용 | 역순 무반응·중복 자원 금지·무상태 단독 보스 |
| `scripts/core/ninjutsu_loadout_state.gd` | 시작유파 중심 | 시작2선택 + 배치 기반 혼합 검사 | 활성4/외부1/해금·배치, 시작60쌍 |
| `scripts/data/mvp4_catalog.gd` | 19아이템/5주머니/3조합 | 공간3ID 대체·책24 연결·3조합 교정 | 장비 비소모·원타/부가타 중복 없음 |
| `scripts/core/run_build_state.gd` | 확정 modifier·운명 집합 | 무기별 modifier와 활성 인법 참조 | preview=0·중복 운명 거부 |
| `scripts/core/run_resume_codec.gd` | schema 1 | schema 2 전체 유효성 검사 | 손상·미래버전·잘못된 배치 전부 실패 |
| `scripts/core/run_resume_store.gd` | tmp/previous 교체 | 하나의 회복 가능한 거래 파일로 통합 | 쓰기/이름변경/정리 실패 주입 |
| `scripts/core/ninja_soul_wallet.gd` | 잔액 직접 저장·소비 중심 | 원자적 거래의 wallet projection | 중복 지급·차감·클릭·재실행 무효 |
| `scenes/player/player.tscn` | Sprite2D 이동/피격 표현 | SpriteFrames+표현 상태, 본체 공격 없음 | 발 접점·속도·좌우·사망 확인 |
| `scenes/enemies/school_encounter_actor.tscn` | 패턴 actor 소비처 | 데이터 시간표+독립 적 외형 | 전조와 판정·회복 구간 동일 |
| `scenes/ui/title_screen.tscn`, `hud.tscn`, `rest_flow_ui.tscn` | 기존 UI 입력 경로 | 6메뉴·상단 HUD·통합 준비 | 마우스/키·패드/터치 왕복 |

테이블의 경로는 현재 존재하는 파일이다. 새로운 `EffectDefinition` Resource와 `CombatEvent` 값은 기존 data/combat 계층에 추가하는 제안이며 별도 전역 manager가 아니다.

## B. 데이터 계약

| 레코드 | 필수 필드 / 불변식 |
|---|---|
| EffectDefinition | id, school_id, effect_kind, cooldown, target_policy, range, shape, damage, duration, status_id, boss_response, event_family. 수치 유한·음수 금지; 알려진 enum만 |
| CombatEvent | run_id, cast_id, event_sequence, source_actor_id, target_id, family, amount. sequence는 런 내 단조 증가; 동일 cast/target/family 중복 거부 |
| LoadoutSnapshot | starting_school, draft_picks[2], committed_ninjutsu_ids. picks 서로 다른2; 활성≤4; 외부≤1; 해금과 committed 배치에서 재산출해 일치 검사. fixed starter 없음 |
| EquipmentSnapshot | owned_instances, equipped_slots{melee,projectile,outfit}, upgrade_rank_by_instance, revision. 슬롯 적합성·고유 인스턴스 검사; rank 정수0..4; backpack 좌표 없음; 미장착 전투력0 |
| TraceDecision | run_id, cleared_school, decision, target_equipment_instance_id, expected_revision, transaction_id. absorb면 target 없음; equipment_upgrade면 현재 장착 대상 정확히1. 흔적당 확정1회; 해금과 포기 동시 불가 |

TraceDecision 검증은 시작 유파이면 강화만 허용하고 기존 open 상태와 보유 책을 보존한다. 타 유파 강화에서만 forfeited_ninjutsu_school_ids에 추가한다. open/forfeited 교집합은 비어 있어야 하고 시작 유파는 항상 open이다. cleared_school_ids/trace_decisions는 접근 권한과 별도 필드로 보존한다. 보상 풀은 인법 후보에만 해당 잠금을 적용하고 공용 조합 재료·경로 완료를 차단하지 않는다.

흔적 확정 거래와 출전 거래는 별도 revision을 갖되 동일 저장 책임자를 사용한다. 흔적 미리보기 취소는 0소비; 흔적 저장 확정 후 출전 취소는 해금/강화 선택을 환불하지 않는다. pending 출전 장비가 흔적 처리 이전 revision이면 다시 비교/검증한다. 저장 실패 시 접근 권한/포기/장비 단계/흔적 소비/처리 ID 전부 원복한다.

인수 사례: 4시작 유파 각각에서 시작 흔적 강화 후 책2개/해금 유지; 다른 유파3개 각각 흡수·강화 분기; 장착3슬롯 각각 대상 선택; 뒤로/취소/중복 transaction_id/손상 rank/옛 revision; 흡수한 유파를 재강화하려는 불법 입력; 네 전장 순서24개에서 완료 기록과 최종 진입 보존. 이 표는 구현할 시험이며 아직 게임 PASS가 아니다.
| 추가 레코드 | 필수 필드 / 불변식 |
|---|---|
| EncounterPattern | id, primitive, shape, target_policy, telegraph_duration, lock_duration, active_duration, recovery_duration, slot_cost. 경고/피해가 같은 shape 인스턴스 사용 |
| SpriteAtlasEntry | source_sha256, image_path, region, state, duration_ms, pivot, facing, consumer, approval_state, alpha_check. region 내부·양수·발 접점 확인 |
| CodexEntry | 기존 enemy/item/ninjutsu ID 참조, kind, role_text, acquisition_text, recipe_refs, counterplay, exceptions. UI 설명에 별도 수치 복제 금지 |

물리 초당 delta를 전투 시간으로 사용하고 메뉴에서는 전투 시간을 멈춘다. wall-clock 날짜로 상태·패턴을 진행하지 않는다. 판정과 표현은 같은 사건을 관찰하되 피해 권한은 domain에만 있다. 죽은 적은 이후 사건의 유효 대상에서 즉시 제외하고 시체 그림은 잠시 남겨도 전투 대상이 아니다.

## C. 상태·피해 충돌표

| 입력 상황 | 단일 결과 | 회귀 시험 |
|---|---|---|
| 화상 중 젖음 | 두 상태 공존, 증기 없음 | 기존 천술 반응 훼손 금지 |
| 젖음 → 번개 | 두 토큰 소비, 주 대상10/추가 최대2명6 | 같은 cast/target 반응1회 |
| 번개 → 젖음 | 반응 없음, 각 만료 유지 | 같은 시각 sequence 역순 시험 |
| 뇌쇄 기본 피해 + 반응 | 기본12 뒤 반응; 젖음 1.25배는 없음 | 숨은 삼중 피해 금지 |
| 상태 지속 재부여 | 만료=max(기존,신규); 다음 tick 유지 | 계속 재부여해도 피해 정지/폭증 없음 |
| 반응·장비 부가 피해 | 다른 반응/명중 효과 재귀 생성 없음 | 두 뇌명도가 서로 재발동하지 않음 |
| 대시/입장/피격 보호 중 명중 | 피해0, 피격 보상·물안개 발동 없음 | 무적을 이용한 피격 효과 파밍 방지 |
| 독+화상 동시 틱 | 독/화상 각1회, 죽으면 후속 무효 | 처치·소울 자격 중복 금지 |
| 엘리트/보스 속박 | 둔화로 대체, 패턴 시계 계속 | 기절 잠금으로 보스 무력화 금지 |

피해 순서: 유효성 → 방어/무적 → 적용 범주별 가산 modifier → 피해량 0 이상 → HP 차감 → 실제 피격 사건 → 사망 1회. 회피가 있는 경우 한 명중 사건당 1회만 추첨한다. seed와 사건 순서를 시험 fixture에 기록한다. 무기·인법·반응·오의·장비의 범주를 섞어 두 번 곱하지 않는다.

## D. 획득·경제·운명

구슬/기록 소비처는 `scripts/combat/reward_orb.gd`와 `scripts/combat/combat_ddd_tracker.gd`다. 현재 구슬은 회수 수와 STYLE만 올리므로 신규 XP 레벨·수동 스킬 선택창을 구현하지 않는다. 결과 설명에서 경제 재화와 분리한다. 준비 회복은 거래에 healed_prepare_session_ids를 기록해 재진입/저장복구에 멱등 적용한다.

인법서24종은 해금된 미소유 후보에 한해40G, 시작 지급 두 책은 무료·판매0G다. 무기8/의복1과 공간 보조19종은 별도 풀이다. 공간19종 중 교체된3개는 R-COMBINATION 가격, 나머지16종과5가방은 기존 정의를 유지한다. 상점의 첫 제안은 구매 가능한 가장 저렴한 확장 주머니 우선; 전체 가방이 채워졌으면 확장 후보 보장은 해제한다. 미해금/포기 인법은 제외하되 전장 안정화로 열린 조합 재료는 별도 자격이다.

보상 lane은 빌드 연속성 / 새 전승 / 공용 지원 순으로 최대1개씩 후보를 가져온다. 비어 있는 lane은 다른 유효 lane에서 중복 ID 없이 보충한다. 유효 후보가 총1개면 1개만 표시. 무료 새로고침 반복으로 후보를 바꾸지 않으며 prepare_session_id와 seed로 보존한다. 상자 토큰 소비·후보 선택·수령은 하나의 준비 거래다. 수령 목적지는 공간 아이템이면 REST 버퍼, 실물 무기/의복이면 런 장비 목록이며 한 아이템을 양쪽에 중복 입고하지 않는다.

판매는 원래 구매 정의 가격의 50% 내림, 시작 각성 지급품은 0골드다. 조합 결과는 재료 가격 합의 50%를 판매 기준으로 사용하고 조합 비용은 0. 장비의 위치만 바꿔 판매가가 바뀌지 않는다. 출전 후 장착 변경은 불가하며 준비에 재진입했을 때만 판매한다. 취소로 상자/골드를 복제할 수 없다.

운명은 기존 5종 중 아직 선택하지 않은 것만 선택한다. 서로 다른 운명은 런 동안 누적, 같은 ID는 중복 불가. 매 출전 확정에서 신규 선택 최대1개; 4전장 뒤 마지막 결속에는 남은 선택 또는 건너뛰기 허용. 빈 운명 선택 때문에 마지막 보스 진입이 막히지 않는다. 운명 이득/손해는 기존 modifier 가산 규칙을 유지하고 NS-DESIGN-RULES의 이동·회피·피해감소 상한을 마지막에 적용한다.

## E. schema 2와 영구 거래

### 오의·장비 복원 경계 — 2026-09-12 보강

현재 `scripts/core/main_controller.gd`의 `_capture_run_checkpoint()`와
`RunResumeCodec`는 확정 build/route/circuit/loadout 저장을 소유하며 실행 중 오의는
직렬화하지 않는다. 이 책임을 재사용한다. 아래는 새 schema2 구현 계약이며 코드 변경 아님.

- 임시 귀인검은 장비 인스턴스가 아니다. 소유 장비/3슬롯/강화 단계는 원래 스냅샷 그대로
  저장한다. `guiin_sword`를 구매품·가방 아이템·소유 장비 목록에 추가하지 않는다.
- 준비/출전의 확정 거래 경계에서만 `ultimate_charge`를 저장한다. 시작 유파 runtime의
  자원을 읽고, 모든 오의·일반 투사체·피해 영역이 정리된 상태인지 확인한 다음 후보를
  검증한다. 새 런 최초 자원은0. 전투 도중 메뉴/종료는 마지막 확정 경계로 재개한다는
  안내를 표시하며 현재 전투 상태 일부를 그 스냅샷에 섞어 넣지 않는다.
- 브레스 방향·틱 번호·잔여 지속, 귀인검 모드 토큰·공격 차단 플래그, 적/소환체 인스턴스
  ID는 저장하지 않는다. 경계 저장에 활성 모드가 남으면 저장을 실패 처리하고 기존 파일
  유지·재시도 안내를 제공한다. 활성 상태를 조용히 빼고 성공했다고 보고하지 않는다.
- 복원은 전체 decode/검증 → 현재 임시 효과 정리 → 원래 장비·가방·경로 복원 → 시작
  유파 runtime 활성화 → 저장 자원 적용 순서다. activate의 초기화로 복원 자원이0이
  되거나, 과거 모드 토큰이 남아 투사/인법이 계속 막히면 실패다. 전체 복원 성공 전에는
  전투 입력·피해 처리를 열지 않는다.
- 재도전/강제 종료 복구는 checkpoint에 기록된 자원만 복원한다. 저장 이후 전투 중 쓴
  비용/얻은 자원을 추가 합산하거나 환불하지 않는다. 현재 잔액과 과거 경계 잔액을 섞지 않는다.

추가 인수 요구: 근접4종×강화0..4의 장비 동일성, 자원0/상한, 음수/상한초과/NaN/다른
school_id 거부, 활성 모드 저장 거부, activate 뒤 자원 readback, 반복 복원 후 공격 차단
잔류0·임시검 소유 아이템0. 문서 검사와 실제 게임 저장/실패주입 시험을 구분한다.

별도 신규 autoload 없이 기존 저장 책임자를 확장한다. 새 `user://ninja_profile_v2.json` **한 파일**에 지갑·정산 ID·현재 checkpoint를 넣어 두 파일 사이 소울 복제를 막는다. 기존 wallet API는 이 profile의 읽기/거래 facade가 된다. 전체 저장 실패면 메모리 잔액과 checkpoint도 바꾸지 않는다.

| 저장 영역 | 필드 / 정책 |
|---|---|
| 루트 | schema_version=2, revision, content_contract=ns-replan-20260911 |
| meta | soul_balance 정수≥0, unlocked_support_choice, settled_run_ids, applied_transaction_ids |
| active_run | null 또는 run_id, starting_school, eligible_boss_ids 집합, elite_qualified, retry_consumed, checkpoint |
| checkpoint | 기존 build/route/circuit/backpack/buffer + active_ninjutsu_ids + prepare_session_id + selected_fates + rules_version + ultimate_charge |
| checkpoint.ultimate_charge | school_id는 active_run.starting_school과 동일, resource_amount는 유한한 수이며 해당 유파0..상한. 상한/비용은 저장값 대신 R-ULTIMATE 정의로 검사 |
| 무결성 | 알려진 ID·형·범위 검사, snapshot에서 modifier/활성 인법 재산출; 저장된 계산값 맹신 금지 |

쓰기 순서: 후보 snapshot 검증 → tmp 쓰기/flush → 다시 읽어 decode → 기존 파일을 previous로 이동 → tmp를 정본 경로로 이동 → 정본 decode readback → 메모리 갱신. previous 정리 실패는 거래 실패로 되돌리지 않고 **정리 경고**로 구분한다. 다음 시작에서 revision/transaction_id로 정본을 판정한다. 파일이 손상되면 previous 유효성 검사와 복구 확인을 제공하고 원본을 보존한다. 파일 시스템 수준 crash-proof 보장은 실제 실패 주입 전에는 주장하지 않는다.

정산 거래 ID는 `settle:run_id`, 재도전은 `retry:run_id`, 각성은 `unlock:support-choice-v1`. 같은 ID는 결과를 다시 보여주기만 하고 재지급/차감하지 않는다. 재도전은 소울1 차감·retry_consumed=true·checkpoint 복원 예약을 **같이** 기록한다. 새 게임은 확인 뒤 미정산 포기를 정산하고 새 run_id를 한 거래로 만든다. 강제 종료 뒤에는 마지막 확정 지점에서 재개한다.

schema1의 진행 중 런은 아이템 의미가 달라져 자동 변환을 **REJECT**한다. 구형 파일을 덮어쓰거나 삭제하지 않고 구형 런 유지 불가 이유를 설명한 뒤 새 런을 선택하게 한다. 기존 wallet의 유효한 정수 잔액만 profile2 생성 시 한 번 이관하고 원본 해시/이관 거래 ID를 기록한다. 미래 버전은 읽기 실패; 손상 wallet은 0으로 초기화하지 않는다. 테스트 전용 경로로 모든 이행을 검증한다.

## F. 화면·입력·실패 계약

| 화면 | 마우스 | 키보드/패드 | 터치 | 실패·복귀 |
|---|---|---|---|---|
| 메인 | 6버튼 클릭 | 방향/Tab 초점, Enter/A 확인 | 큰 버튼 탭 | 이어하기 실패 이유, 파괴적 새 게임 재확인 |
| 시작 선택 | 유파/전장 카드 별도 | 두 그룹 간 이동 | 카드 탭 후 시작 | 처음 초점 복원, 선택이 곧 출전 아님 |
| 전투 | 상단 오의/설정 | WASD/스틱, Space/B 대시, E/Y 오의 | 좌 이동패드, 우 대시/오의 | 메뉴가 열리면 held 입력 초기화 |
| 준비 가방 | 드래그/회전 버튼 | pick→방향→R/회전 버튼→place, B 취소 | 탭 pick→셀 탭 place, 회전 | 불법 배치 빨간 윤곽+이유, 원위치 복귀 |
| 캐릭터 장비 | 슬롯→목록→비교→교체 | 순차 초점·확인·B 취소 | 슬롯 탭→목록 탭→확인 | 교체는 미리보기, 출전 전 원복 가능 |
| 흔적 강화 | 강화→장비1개→확인 | 단계별 초점·뒤로 | 카드 탭→대상 탭→확인 | 해금 포기 경고, 취소0소비, 저장 실패 전부 원복 |
| 보상/운명 | 카드 선택 | 순차 초점·확인 | 탭→선택 표시 | 선택≠거래 확정, 중복 클릭 무효 |
| 도감/각성 | 목록/상세 | 목록→본문→뒤로 | 스크롤/뒤로 | 각성 부족 비용 표시, 읽기 중 게임 입력 없음 |
| 설정 | 슬라이더/토글 | 좌우/확인/뒤로 | 드래그/탭 | 저장 실패 경고, 이전 화면/초점 복귀 |

설정의 첫 범위는 음량, 효과 강도, 화면 흔들림, 전체화면, 입력 안내다. 키 재매핑은 기존 기능 여부 확인 후 별도 착수 범위로 남기며 없는 기능을 버튼으로 속이지 않는다. 효과 강도 최소에서도 적 경고 경계와 상태 단서는 유지한다. 긴 한국어·125/150% 배율·1280×720에서 잘림을 검사한다.

## G. 아틀라스·모션·성능 제작 계약

적의 기존 encounter ID는 보존하고 그림의 새 역할을 매핑한다. 봉마의 `mobile_array_caster`는 기존 엘리트 ID로 유지하되 새 외형은 수호 요괴 엘리트, `hundred_demon_array_master`는 보스 ID를 유지하고 이동진술사·식신 사용 보스로 표시한다. 이름 때문에 두 ID의 등급·보상·저장 의미를 뒤바꾸지 않는다. 네 유파의 5행과 기존 ID 매핑은 후보 manifest의 logical_id가 소유한다.

최종전 제작 입력: 방문 완료 순서의 유파 테마를 HP 100~75 / 75~50 / 50~25 / 25~0% 구간에 순서대로 배치한다. 구간 전환은 현재 패턴 종료 후 적용하며 HP를 인위적으로 잠그지 않는다. 큰 피해로 여러 구간을 건너뛰면 현재 HP 구간으로 한 번만 전환한다. 각 테마 첫 패턴은 전승 지원 문양/힌트와 고정 구간 +0.2초의 읽기 기회, 런당 테마당 1회. 직접 피해·새 오의 지급 없음. 이후에는 해당 유파의 이미 배운 세 기술 중 합법 후보를 쓰고 다른 테마의 큰 위협을 동시에 4개 펼치지 않는다.

안전 경로 검사는 최대2개 패턴 도형을 플레이어 반경으로 팽창시킨 뒤 근처 후보 지점과 경로를 검사하는 보수적 판정으로 시작한다. 후보는 위험 도형 밖의 방사 방향 16개×거리4단계, 선분을 캐릭터 충돌 크기로 sweep하고 고정 구간 안 이동 가능한 것만 채택한다. 샘플링은 경로를 못 찾을 수 있으므로 실패는 공격 대기이지 안전 증명으로 간주하지 않는다. 움직이는 위협은 발동 구간의 예측 도형 합집합으로 검사한다. 벽/화면 경계/둔화/두 위협의 틈 사례를 fixture에 넣고 실제 캐릭터로 재검증한다.

인게임은 키아트보다 간결한 형태, 어두운 바닥에서 구분되는 외곽, 작은 발 그림자를 사용한다. 후보 생성은 스타일 제안이며 알파/셀 검사 실패는 REWORK다. 캐릭터 높이 비교 기준은 플레이어48~64px, 일반40~64px, 엘리트80~100px, 보스100~128px의 1280×720 화면이다. 이는 실제 카메라 캡처 후 조정할 초기값이지 원본 이미지를 임의 확대해 적 등급을 만드는 규칙이 아니다.

| 상태 | 첫 타이밍 계약 | 게임 연결 |
|---|---|---|
| 이동 | 플레이어4프레임×100ms, 적2프레임×140ms 반복 | 실제 속도 비율로 재생, 정지시 idle |
| 대시 | 1자세×실제 dash duration | 끝나면 move/idle, 공격 프레임 없음 |
| 피격 | 1자세80ms 후 복귀 | 보스 패턴 준비 상태를 덮지 않고 overlay 가능 |
| 일반 사망 | 1자세250ms 뒤 fade150ms | 판정 즉시 제거, 보상 한번 |
| 플레이어 사망 | 4프레임×120ms, 마지막 유지 | 입력/무기 정지와 동일 사건 |
| 강적 준비/발동/회복 | 준비/발동 자세를 실제 패턴 구간에 유지, 회복 idle로 연결 | frame timer가 공격 시점을 새로 만들지 않음 |

6포즈 적 시트가 6프레임 자연스러운 달리기라는 뜻은 아니다. 초기 이동2접점의 미끄러짐이 확인되면 사이 프레임을 추가 제작한다. 발 pivot과 머리 크기 변동은 전 프레임 1px 급으로 강제 수치 보장하지 않고 실제 표시 크기에서 검수한다. Aseprite 자동 선택은 등크기 프레임·타이밍·PNG/JSON 검수가 필요한 시트에 적용; 키아트/바닥은 불필요한 픽셀화 없이 원본 PNG 유지다.

최적화 선택은 단순 node pool → 공간 조회/업데이트 분산 → 렌더 묶음 비교 순서. 일반 몹 하드캡은 추가하지 않는다. 강공격 예산과 개체 수 예산은 별개. 100/300/600/1000 및 누적 런에서 frame time p50/p95/max와 메모리를 측정한다. 목표 장비가 확정되지 않았으므로 60fps 보장·최소사양 확정은 NOT_RUN이다.

## H. 착수 순서와 인수 시험

각 패키지는 fresh main/중첩 PR 확인 → 실패하는 시험 → 최소 구현 → focused/full GUT → 필요한 실제 화면/입력 검증 → 정본 갱신 → exact-head CI·보호된 전달 순서다. 아래는 아직 실행하지 않은 계획이다.

| 순서 | 작업 / 선행 | 핵심 인수 fixture |
|---|---|---|
| P01 | 데이터 계약·상태 충돌 / 최종 설계 승인 | 인법24(기존12 보존),무기8/의복1,공간19 매핑,5가방,3조합 |
| P02 | 자동무기·보호 / P01 | 슬롯당1공격・범위・빈 슬롯0,대시0/1/2,동시10명 접촉1피해 |
| P03 | 혼합·가방 / P01 | 시작2/활성4/외부1,책4칸,버퍼6,무기 비소모 조합・취소・원자성 |
| P04 | profile2·메타 / P03 | 정상/손상/v1/vfuture,중복정산/재도전,쓰기 단계별 실패,메모리-디스크 일치 |
| P05 | 천술 대표 전장 / P02~P04 | 30초정체성,180엘리트,흔적,경고/보스,준비→다음; 강공격동시1 |
| P06 | UI/대표 자산 / 자산LOCK·P05 | 6메뉴와3입력경로,상단HUD,전조/VFX읽기,발접점/모션·게임캡처 |
| P07 | 네 유파·최종전 / P05~P06 | 시작4×방문24=96 도메인 조건,최종 지원/2위협 이하,서로다른 적 외형 |
| P08 | 회귀·최적화·사람 검수 / P07 | 2빌드 비교,군중 표본,전체런 대표,한글/접근성/실기기 |

기능별 proposed test 파일은 기존 `tests/`의 같은 책임 파일을 먼저 확장한다. 없을 때만 `test_effect_contract.gd`, `test_profile_v2_transaction.gd`, `test_full_route_matrix.gd`를 추가한다. 표의 시험 이름은 새 파일이 이미 존재한다는 뜻이 아니다. 코드 식별자·경로를 현 main과 재확인한 뒤 생성한다.

## I. 완료 수준·롤백·잔여 위험

설계 검토와 PDF 생성은 문서 증거다. 승인 전 게임 변경은 하지 않는다. 자산은 GENERATED_CANDIDATE / REWORK / REVIEWED를 구분한다. 실제 runtime, 사람의 재미·가독성, Android/패드 실기기, 라이선스·출시 최종 심사는 별도 gate다.

롤백은 패키지별 변경과 데이터 계약 버전을 함께 되돌리며 이미 생성된 profile2를 구형 codec으로 억지 해석하지 않는다. 구형 파일 보존, 새 테스트 경로, feature/package 단위 통합으로 복구 범위를 작게 만든다. main 직접 push·강제 push·기존 Draft 임의 merge는 하지 않는다.

전체 구현 입력의 최종 판정은 자산 검사·문서 교차검사·5회 전체 검토 결과와 함께 보고한다. 이미지 준비가 실패한 경우 승인만 받으면 모든 아트를 바로 적용할 수 있다고 주장하지 않는다. 대신 논리 P01~P05 착수 가능성과 아트 P06의 실제 blocker를 분리한다.
