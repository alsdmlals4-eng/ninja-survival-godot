# 닌자의 신 — 구현 입력 명세

문서 ID: NS-IMPLEMENTATION-PACKET · 2026-09-11 원안 · 승인 범위 연속 구현 중

실행 상태는 최신 사용자 지시와 CURRENT_CONFIRMED_DECISIONS/ACTIVE_CONTEXT를 따른다.
과거 원안의 승인 대기 표시는 현재 구현을 다시 중단시키는 게이트가 아니다.
미승인 이미지의 최종 확정 및 Human/출시 검증은 별도 상태로 유지한다.

## 준비 범위와 실행 경계

### 현재 실행 지도

2026-09-14 요청은 **남은 작업과 구현·설계 명세 준비**다. 이번 문서 작업은
게임 기능 추가·이미지 생성·기존 저장 전환을 실행하지 않는다.
최신 잔여 작업의 진입점은 [J. 잔여 구현 실행 명세](#j-잔여-구현-실행-명세--2026-09-14)다.
아래 2026-09-13 계획들은 구현 이력이며 J의 상태표로 재작업 여부를 판정한다.

### 2026-09-13 저장 선행 계획: 구형 잔액의 무손실 입력 검사

Goal: profile2 이관 입력인 v1 잔액을 손상/미래형 데이터와 구별한다.
Architecture: NinjaSoulWallet의 기존 읽기 책임에 순수 decode_legacy_balance를
추가하며 새 autoload/파일은 만들지 않는다. 기존 유효 파일은 그대로 읽는다.
Spec: 본 문서 E의 '유효한 정수 잔액만 이관, 손상 wallet 0초기화 금지'.
Files: scripts/core/ninja_soul_wallet.gd, tests/unit/test_ninja_soul_retry.gd.
Interfaces: decode_legacy_balance(parsed)->int, 실패=-1; configure 실패는 기존
storage_path/balance/configured를 보존한다. 파일이 없을 때만 초기 파일을 쓴다.
- [x] RED: `{balance:1.5}`, 문자열/불리언/미래schema/손상JSON을 거부하고 원본 보존.
- [x] 구현: 타입→유한성→정수성→JSON 안전 정밀도→범위를 확인한 뒤 int 변환.
- [x] GREEN: 유효 잔액과 기존 재도전 읽기, 재설정 실패 후 기존 경로로만 차감.
- [x] 전체 GUT100scripts/792tests/10524assertions, source diff 검사.
- [ ] 이 변경 head의 원격 readback/CI. profile2 원자 거래 완료로 보고하지 않는다.
공식 FileAccess flush/DirAccess rename 계약 ADAPT. 직접 덮어쓰기 REJECT,
두 파일 교차 정산 REJECT. 원자성은 별도 실패 주입 증거가 있어야 주장한다.
Sources: https://docs.godotengine.org/en/4.6/classes/class_fileaccess.html
and https://github.com/godotengine/godot/blob/master/core/io/dir_access.cpp .

### 2026-09-13 실행 계획: 선택형 빌드 묶음 교차 검사

기존 RestCommitCoordinator에 부작용 없는 선택형 묶음 검사를 둔다. 별도 상태
소유자 대신 BackpackState/EquipmentLoadoutState/TraditionAccessState/Loadout의
기존 복원 검사를 재사용한다. 가방 실제 배치→책 ID→해금 유파→활성 인법을
대조하고 시작 유파 불일치를 거부한다. StartLoadoutSession의 확정 결과에
접근 상태를 포함하고 이 검사에 통과한 결과만 제공한다. 문서상의 active ID나
UI 선택값만 신뢰하는 대안은 REJECT. 기본 Main/디스크 저장은 아직 변경하지 않는다.
검사:4유파 시작 묶음 JSON 왕복,없는 책 활성화/위조 해금/구형가방/불법 장비 거부.

### 2026-09-13 실행 계획: 흔적 선택의 인법 접근 분리

TraditionAccessState의 선택형 경로에서 전장 안정화(보조 재료)와 인법 해금(흡수)을
분리한다. 시작 유파 흔적은 강화만, 타 유파는 흡수/강화 중1회. 강화는 준비용
EquipmentLoadoutState 복사본의 장착 슬롯1개만+1, 예상revision이 다르면0변경.
동일 흔적 재확인·미안정화·미장착·상한·잘못된 선택을 거부한다. 기본 Main과
legacy initialize는 유지. 상위 profile2 거래는 접근상태와 준비 장비를 함께
후보 복제→검사→저장→채택하므로 이 도메인 성공을 저장 완료로 부르지 않는다.
선택형 획득 pool은19보조 ID매핑만 적용, 책 해금과 공용 재료 패키지는 별개.
검사: 시작 인법 유지, 흡수 자동지급 없음, 강화 타유파 미해금,중복/낡은revision
후 장비·접근상태 불변,원래 legacy package 회귀. 새 전역 manager 없음.

### 2026-09-13 실행 계획: 확정 장비 런 소유권

기존 RunBuildState가 EquipmentLoadoutState의 검증된 복사본만 보유하도록 연결한다.
`commit_equipment_snapshot`은 불법 슬롯/강화/타입이면0변경, `equipment_snapshot`은
외부 변경 불가 복사본. 닌자복 감소만 기존 RunModifierSet에 합산하고 무기 피해는
BasicWeaponController가 소비한다. 미장착 강화·편집 중 상태는0효과.
기존 schema1 소유수치/저장 키는 유지하고 Main은 profile2까지 계속 opt-in 경계.
검사:5%→강화8%→재적용8%(중복없음),외부복사편집/불법입력 보존,
실제 Player100피해95/92,무기 인술 보정0,기존 경제/운명 회귀.

### 2026-09-13 실행 계획: 조합 조건부 효과

R-COMBINATION 소비처를 BasicWeaponController/BasicProjectile의 실제 유효 명중으로
연결한다. 뇌명은 시전 첫 유효 명중에서 다른 적 최대2/120/6/내부1초,
폭렬은 투사 시전 첫 유효 명중 위치96/12/내부4초. 쌍쿠나이·관통·화약탄은
시전 공유 claim을 먼저 소비해 다중 발동/재귀를 막는다. 추가 피해는 별도
CombatResolver combination 문맥, 원타 장비/비전/인법 배율 재적용 없음.
물안개는 실제 HP손실 신호에서만1초+20%/내부3초; 기존 Player boon 소스에
연결하고 기본+8%는 가방 resolver가 계속 소유한다. pause/사망/해제는 정리.
TDD: 실제 명중/여러대상/내부주기/보호막만피해/해제/구형 경로 회귀.
신규 autoload/별도 공격 타이머 REJECT, 기존 owner의 시전·피해 사건 ADAPT.

### 2026-09-13 실행 계획: 선택형 공간 카탈로그와 무기 비전

- 범위: R-BAG/R-COMBINATION의19보조+3조합+24책(시작형 포함48정의).
  `selected_backpack_catalog.gd`가 기존 정의를 새로 구성하며 legacy 목록은 불변.
  BackpackState 선택형 경로와 CombinationResolver가 이 목록을 소비한다.
- 비교: 구형 목록 직접 변경 REJECT(저장 의미 변경), UI ID 치환 REJECT(검증 우회),
  명시적 선택형 카탈로그 ADAPT(기존 Resource/geometry/transaction 재사용).
- 공식 Resources 문서의 공유 데이터 특성 ADAPT: 매 구성별 독립 정의를 사용.
  https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
  Backpack Battles의 배치/조합 중심 성장 REFERENCE_ONLY; 레시피·아트 복제 없음.
  https://store.steampowered.com/app/2427700/Backpack_Battles/
- 먼저 실제 배치·JSON왕복·구형 무기 거부·새 레시피 atomic commit을 실패 테스트로
  고정하고 구현한다. 이후 비전 보정은 기존 RunModifierSet 저장 키를 바꾸지 않는
  별도 파생값으로 실제 무기 소비처에 연결. 미리보기/버퍼는 전투 효과0.
- 조합 결과의 조건부 부가타/물안개 피격 효과는 별도 다음 동작 시험이 필요하며,
  목록/조합 성공만으로 이 효과나 Main/profile2/전체 Run 완료를 주장하지 않는다.
- 비용0/새 autoload 없음. rollback은 해당 선택형 연결만 복귀, v1파일은 미수정.

### 2026-09-13 다음 실행: 봉마 비오의 처치 자원

R-ULTIMATE의 비오의 처치는 지속 피해/식신을 포함한다. 실제 BongmaRuntime은
normal/weapon/direct_injutsu만 허용해 선택한 독안개·화인 처치를 누락한다.
기존 CombatResolver의 소유 피해 문맥만 재사용하고 dot/clone/reaction 경로를
허용한다. unknown/빈 문맥/ultimate는 거부하고 사망 ID 중복·초당1회는 유지한다.
test_bongma_runtime에서 각 경로의 실제 사망 사건 RED→수정→전체 회귀 순서.
새 자원 관리자/적 직접 피해 감시는 만들지 않는다. 전체 Run 완료와는 별개다.

### 2026-09-13 다음 실행: 선택형 복원 경계

profile2 준비의 첫 단계로 인법 복원에 별도 명시 경로를 만든다. 원본 시작2선택,
현재 활성≤4/외부≤1/해금, 검증된 실제 가방 책 목록과 일치해야 한 번에 복원한다.
schema1의 기존 restore는 선택형 거부를 유지한다. 구형 저장 강제 변환/삭제 없음.
이 단계는 전체 profile2 파일 구현이 아니며, 이후 단일 지갑·checkpoint 거래가 소비한다.
정상 JSON 왕복과 불일치·중복·비해금·외부2개 실패/현재 상태 보존을 TDD로 검증한다.

### 2026-09-13 다음 실행: 전 시작쌍 전투 회귀

실측60쌍 시험31.685초에서 반복 정의 생성 소비처를 확인했다. 시전기마다24정의를
한 번 보유하고 시전 레코드의 변경 가능한 config만 복사하도록 최적화한다.
전역 가변 Resource 캐시는 만들지 않는다. 동일60쌍/기존 회귀로 변경 전후를 비교.

24개 효과 연결 뒤 유파별15쌍/총60쌍을 실제 Player/Enemy/Loadout/자동 시전기로
10초간 진행한다. 대시 종료, 혼합 효과, 해제/정리를 확인하며 보조만 고른 쌍에
숨은 공격을 지급하지 않는다. 기존 시작 배치60쌍 검사와 별개인 전투 스모크다.
이후 실제 Main 시작 UI/profile2와 연결. 이 시험만으로 오의60쌍·Human 검수 PASS는 아니다.

### 2026-09-13 다음 실행: 퇴마부륜

반경90/부적3개/2초/적당최대2회×5/재명중0.5초 계약을 실제 회전 접촉으로 구현.
기술 시험값: 초당180도 회전, 부적 판정 반경24, 최대0.025초 간격으로 시전 내
접촉을 검사하여 저프레임 터널링을 줄인다. 이 값은 최종 밸런스/아트 확정이 아니다.
부적별 타수가 아니라 시전 전체 적별2회이며 플레이어 중심으로 이동한다.
원판 전체 피해는 부적 접촉 의미를 잃어 REJECT, 새 projectile/autoload는 REJECT,
기존 시전/승인 임시 Sprite 소비 경로 ADAPT. 귀인화 중 수명/회전만 진행.

### 2026-09-13 다음 실행: 뇌보

실제 대시 종료·내부6초 주기로3초 대기. 다음 직접 공격 인법의 첫 유효 피해에
번개 토큰1회, 기본무기/독/화상/분신/반응은 소비하지 않는다. 반응 피해는 가능하지만
뇌보 추가 자원 통지는 금지. 직접 인법 피해 helper에 연결하여 null-resolver 시험
경로와 실제 CombatResolver 경로가 같은 소모 규칙을 갖는다. 해제/종료 정리.
시전 복제/전역 damage signal 가로채기 대신 현행 인법 owner 내부 공통 경계 ADAPT.

### 2026-09-13 다음 실행: 수맥 결박과 순서형 원소 반응

수맥:4초 주기, 고정 목표 반경96/2초 영역, 첫 진입8피해·젖음3초, 영역 내25%둔화.
같은 시전 재진입 피해 금지, 영역 이탈/만료 때 둔화만 제거하고 젖음은 남은 시간 유지.
젖음/번개 토큰을 선택형 시전기 단일 소유로 추가하며 인법 source별 남은 시간을
보존한다. 브레스는 provider 조회 재사용. 다음 뇌쇄·뇌보가 같은 토큰 함수를 소비.
뇌쇄: 젖음 우선·3초/연결140/최대3/각12. 젖음→번개만 두 토큰 소비 후10+주변2명6,
반응 종류 별도·재귀 금지·시작 천술 자원 보너스만 통지. 역순은 공존, 반응 없음.
공식 process/Timer 자료와 기존 천술 규칙을 재사용; 기존 origin-only 자동교대는 REJECT.
TDD: 영역 출입/만료/해제, 순서/토큰 소비/연쇄 상한/자원 중복 금지.

### 2026-09-13 다음 실행: 인법 이동 제어 공통 소비처

연결 순서: 봉인쇄(첫12/후속8·140·최대3·속박0.6), 진압인(예고0.2 후
고정 목표 반경100에16·속박0.4). 인법 시전기는 부여한 제어 source의 대상만
추적하여 해제/전장 종료 때 제거한다. 적 소유 시간 만료와 패턴은 독립 유지.
TDD로 체인 상한/재방문/지연/엘리트/해제 경계를 검증한다.

EnemyChaser가 일시 둔화/속박만 소유한다. 일반 속박 종료 뒤2초 보호,
엘리트 속박 대신20%/보스10% 둔화, 일반 둔화40% 상한. 원래 move_speed를
덮지 않고 최종 이동 계수에 적용하여 기존 천술/적 정의 변경과 충돌하지 않는다.
각 source의 해제를 지원한다. 가장 강한 둔화를 사용하고 반복 속박은 현재 속박을
늘리지 않는다(무한 갱신 방지). 패턴 시계와 독립적인 process에서 만료하며
SchoolEncounterActor의 telegraph/chase 조기 반환이 지속시간을 멈추지 않는다.
대안: 속도 직접 덮기 REJECT(복원 충돌), 패턴 시계 중단 REJECT(정본 위반),
기존 적 이동 소유자 확장 ADAPT. 저장/새 autoload 없음. 테스트로 권위/상한/만료 검증.

### 2026-09-13 다음 실행: 그림자분신

승인된7초 주기/고정 위치1체/2초 수명/0·0.7·1.4초 각6피해를 기존 시전 레코드로
구현한다. 분신은 매 타격에 자신의 위치 기준 최근접 유효 적을 고르며 장비/인법을
복제하지 않는다. 피해 종류 clone으로 직접 인법 명중 proc와 분리한다.
기존 시전 레코드 ADAPT; Player 복제/AI 캐릭터 생성은 충돌·도발·장비 복제 위험으로
REJECT; 별도 소환 매니저도 실제 필요 없어 REJECT. 기존 임시 효과만 사용하며 최종
캐릭터형 분신 아트는 미검증. 귀인화 중 수명과 타격 시각만 흐르고 공격하지 않는다.
검증: 고정 원점/최근접/3회 제한/죽은 적 제외/해제/귀인화 누락타 재생 금지.

### 2026-09-13 다음 실행: 화염 인장과 브레스 상태 조회

선택형 표의 화염 전용 계약을 구현: 최근접 적 중심90, 즉시6, 화상3초/초당2,
재사용1.8초. 구형 설명의 숨은 wet/shock 교대는 선택형 계약에서 실행하지 않는다.
독무의 시간 처리 함수를 재사용하되 상태 저장소/해제는 독과 분리한다.
천술 오의는 상태를 복사하거나 추가 피해를 재시전하지 않고 선택형 소유자에게
읽기만 요청한다(기존 흑영 표식 provider 방식 ADAPT). 기존 천술 단독 상태와
신규 인법 이중 갱신/새 global manager는 REJECT. 공식 Timer 근거는 위 독무 조사 재사용.
검증: 화상 갱신 틱 보존, 독 공존, 해제, 숨은 토큰 금지, 실제 브레스+2 소비처.
Main은 provider 연결만 변경하며 profile/기본 모드 전환은 하지 않는다.

### 2026-09-13 다음 실행: 독무 장막

후속 교정: R-ULTIMATE 대조에서 귀인화가 기존 식신까지 삭제하는 차이를 확인했다.
백귀 식신은 동일 노드/위치를 보존하고 공격 쿨다운만 동결한다. 독무는 정상 수명으로
만료하며 공격 금지 시간에 재노출/밀린 피해를 생성하지 않는다. 이미 발사한 투사체 취소는 유지.
식신 정체성 보존/공격 정지/복귀 잔여 쿨다운을 회귀 테스트한다.

승인 R-INJUTSU/R-ULTIMATE 수치 그대로 최근접 적 중심 반경96, 장막2초,
독3초/1초마다4피해/재사용5초를 연결한다. 재노출은 지속만 갱신하고 피해 시계는 유지한다.
기존 선택형 시전기 소유의 일시 상태를 사용(ADAPT); 적마다 Timer 추가와
시작 유파 전용 천술 상태 소유자 재사용은 취소/다유파 연결 비용 때문에 REJECT.
Godot Timer 공식 문서의 프레임/정지 제약을 참고하여 기존 delta 시계를 유지한다.
Halls of Torment 공식 소개는 군중 속 빌드 다양성의 REFERENCE_ONLY이며 수치를 복제하지 않는다.
저장 스키마/기본 Main 전환/새 최종 아트는 범위 밖. 기존 임시 효과를 소비한다.
TDD: 지연 피해, 갱신 주기, 범위/늦은 진입, 일시정지, 귀인화 무피해 경과,
해제/사망/스테이지 정리. 기존 장판/식신의 귀인화 수명 문제는 별도 회귀 대상이다.
현재 엔진4.7.1/기존 CombatResolver의 dot 분류로 실현 가능(FEASIBLE).
롤백은 해당 시전 분기/일시 상태 제거이며 사용자 저장 데이터는 변경하지 않는다.

### 2026-09-13 다음 실행: 사슬 처형

선택형 표식을 읽어 표식 우선→낮은 HP 비율→거리→안정 ID로 목표를 고른다.
일반 적은 HP15% 이하일 때 남은 HP만큼 피해, 그 외14피해; 엘리트/보스는17.5피해(기존 정수 반올림 사용).
처치 확인 후 이전 대상 위치140 안에서 최대2후속, 대상별1회. 처치 실패/무효 대상에서는 중단.
이미 존재하는 시전 레코드/CombatResolver를 재사용하며 오의 처형과 합치지 않는다.
테스트: 일반 저HP, 엘리트/보스 즉사 금지, 후속 최대/범위/실제 처치 조건, pause/해제 경계.

### 2026-09-13 후속 검토: 선택형 전투 상한

R-COMBINATION의 이동1.6배/전체 피해감소60%를 현재 조합 소비처와 대조한다.
기존 profile/기본 Main을 묵시 전환하지 않도록 선택형 Loadout 계약일 때만 새 계산을 적용한다.
Player가 최종 수치 계산, 시전기가 계약 활성 여부만 연결한다. 저장 필드는 추가하지 않는다.
계획: 이동50%+귀일보15%, 피해감소 장비50%+인법10%의 실패 테스트 →
선택형 합산/상한 처리 → 기존 legacy 계산 보존 회귀. 별도 상한 manager/저장 필드 신설은 기각.

### 2026-09-13 다음 실행: 백귀식신 선택형 소비처

기존 BongmaFamiliar 장면/추종을 재사용하고 책 소유/주기/해제는 선택형 시전기가 소유한다.
식신 자체 자동 공격 처리는 끄고 기존 attack_once를 0.7초 주기로 호출해 이중 공격을 막는다.
추종 최대180, 탐색320, 피해8. 기존 scene 외형은 대체 자산이며 신규 승인으로 간주하지 않는다.
주기는 기존 ID별 잔여시간을 써서 재장착 악용을 막고 귀인화/사망/준비/해제 시 식신을 정리한다.
대안: 기존 유파 무료 식신 부활은 책 소유를 무시해 기각; 별도 식신 구현은 중복으로 기각.
테스트는 실제 Player/Enemy/식신 노드, 장착/주기/추종/해제/재장착을 확인한다.

### 2026-09-13 다음 실행: 암영침·추영표

소유: 기존 NinjutsuAutoController의 선택형 시전/해제 수명에 표식과 단일 투사체를 둔다.
표식은 피해가 아닌 타깃 우선순위이며 암영침 소유 해제/죽음/새 전장에 정리한다.
대안: 기존 HeukyeongRuntime.apply_needle_hit 재사용은 숨은 치명타/누적폭발 때문에 기각;
별도 전역 상태 autoload는 필요 없으므로 기각; 선택형 소비처 안의 제한된 표식 상태를 채택.
TDD: 실제 이동 전 피해0, 첫 교차만 피해, 표식8초/갱신/해제, 표식 목표 우선,
발사 후 유도 없음, 인술 피해 구분, 긴 프레임에서도 수명 범위 밖 피해0.
기존 선분 연구를 재사용하며 선분-원 최초 교차 시점으로 가장 먼저 닿은 적을 결정한다.
이미지/기본 Main 전환/새 저장은 제외하며 최종 VFX 검수는 남긴다.

### 2026-09-13 다음 실행: 풍주 이동 판정

후속 전환 점검: 최종 재앙도 새 전장이므로 성공한 최종 준비 확정 뒤 인법 시전기의
전장 주기를 초기화한다. 기존 4전장→최종보스 Main 통합 테스트에 잔여 주기 유입을
먼저 재현하고 기존 configure 경로만 사용한다. 실패한 준비 확정에는 적용하지 않는다.

승인된 풍주 표의 주기3/속도600/길이360/폭48/수명0.6/피해14를 기존 선택형 시전기에 연결한다.
순서: 지연 명중·긴 프레임·중복 명중·수명·해제 실패 테스트 → 이동 구간 판정 → 전체 회귀.
BasicProjectile 재사용은 장비 피해/첫 명중 소멸 규칙이 달라 기각, 새 전역 투사체 관리자는 불필요해 기각.
기존 시전 레코드의 고정 방향과 이전/현재 이동 거리를 사용하는 방식을 채택한다.
Godot Geometry2D 선분 계산을 조사했으며 이 사각 폭의 풍주는 종축 구간/횡축 폭으로 직접 판정한다.
Source: https://docs.godotengine.org/en/stable/classes/class_geometry2d.html
움직이는 적의 프레임 사이 전체 궤적까지 복원하는 연속 충돌은 포함하지 않는다. 새 이미지 승격도 하지 않는다.

### 2026-09-13 연속 개선: 보호·이동 소비처 및 전투 전환

승인 범위: R-NINJUTSU의 철혈호체/빙막/귀일보/연막보법을 먼저 연결하고,
그 결과를 재사용해 수호결계/결계보법과 기존 유파 무료 공격 분리를 이어서 구현한다.
실제 소비처는 PlayerController, NinjutsuAutoController, SchoolRuntimeBase/Host, Main이다.
새 전역 시스템/의존성/저장 필드/기획 의미/이미지 승격은 추가하지 않는다.

- [x] 실패 테스트 후 피해감소→보호막, 무적 중 보호막 보존, 실제 대시 종료 신호를 연결.
- [x] 귀일보 이동+15%/1.2초, 연막보법 감소15%/1초, 철혈호체 근접110/10%, 빙막12/3초.
- [x] 발밑 수호결계120/2초/20%, 대시 도착점 결계보법90/1.5초/10%; 둘은 큰 값만 적용.
- [x] 시전기 소유 시간/조건과 플레이어 최종 효과 계산 분리; 장비 갱신은 임시 효과를 보존.
- [x] 해제/사망/준비 진입 정리 및 새 Stage 주기 초기화의 실제 Main 호출을 연결.
- [x] 모든 유파가 선택형 Loadout을 참조하여 무료 기본 공격을 차단하되 자원 충전을 유지.
- [x] 전체97scripts/731tests/9673assertions 및 실제 물리 대시 종료/process 지속시간 검증.
- [ ] 나머지14종 인법, 태그 피해, 시작 준비 Main 전환, 장비/경제/profile2 연결.
- [ ] 새 보호 VFX·표시 검수, 정상 속도 전체 런, 전체 범위5회 검토 및 Human/device 검증.

ADAPT Halls of Torment의 능력/장비 조합, Brotato의 자동 공격+특성 빌드.
우리 해석: 공격 이외의 선택도 거리·대시 타이밍을 통해 생존 결과를 바꿔야 한다.
Sources: https://store.steampowered.com/app/2218750/Halls_of_Torment/ ; https://store.steampowered.com/app/1942280/Brotato/
기술 근거: https://docs.godotengine.org/en/stable/tutorials/misc/pausing_games.html
신호는 pause 중에도 호출될 수 있어 dash-end handler에 pause/처리 가능 상태를 별도 검사한다.
대안 비교: Player에 제한된 transient source map(채택), RunModifierSet 저장 필드에 혼합(수명/저장 권한 혼동으로 기각),
별도 전역 buff manager(현 소비처에 불필요한 복잡성으로 기각). 비용 추가0, 기존 저장 유지.

### 2026-09-13 선택형 인법 전투 연결 — 진행 중

후속 실행 범위: 귀혈파 경로를 잔영 쇄도/수라진/나찰연각까지 확장하고,
책 해제·귀인화·재구성·피해 콜백 중 취소를 함께 검사한다. 기존 Main에는
Guiin Loadout 바인딩만 추가하여 선택형일 때 내장 무료 피해를 막고 자원 충전은 유지한다.
Main의 기본 시작 선택/저장 전환은 이번 변경에 포함하지 않는다.

- [x] 잔영: 길이320/폭56/0.35초, 적당16 피해1회, 본체 이동 없음.
- [x] 수라진: 고정 시전 위치에서 0/0.5초에8 피해, 총2회.
- [x] 나찰연각: 고정 방향100도/반경100, 0/0.12/0.24초에5 피해, 총3회.
- [x] 실제 Loadout 변경 신호로 예약 공격과 시각 효과 정리, 재귀 시전 차단.
- [x] Guiin 선택형 무료 공격 억제와 자원 충전 유지, 기존 경로 회귀 검사.
- [x] 실제 엔진 process + 실제 Player/Enemy로 나찰연각3타 및 해제 검증.
- [ ] 나머지20종 효과, 태그 증가 최종 연결, Main의 Stage 전환 호출 연결.

추가 benchmark ADAPT: Halls of Torment의 다양한 능력/아이템 시너지 지향
(https://store.steampowered.com/app/2218750/Halls_of_Torment/).
이는 서로 다른 공격 판정/시간 특성을 유지할 근거이지 수치 복제 근거가 아니다.
기술 비교: 기존 시전기의 명시적 delta 상태(채택), 효과마다 독립 Timer(취소 소유권 분산으로 미채택),
새 전역 이벤트 시스템(현재 세 효과에 과설계로 미채택).
공식 Godot pause 문서에 따라 수동 호출에도 일시정지 가드를 둔다:
https://docs.godotengine.org/en/stable/tutorials/misc/pausing_games.html

사용자 승인 개선 루프: 유사 게임 조사 → 기존 명세 구체화 → 실제 소비처 구현 → 회귀/실행 검증 → 교정.
첫 제한 단위는 기존 NinjutsuAutoController의 selectable-v2 전용 경로와 귀혈파다.
기존 generic 시전 경로는 유지하고, 미구현 새 책은 generic 공격으로 대체하지 않는다.

- [x] 실제 Loadout의 선택/확정/해제/재장착으로 실패 테스트를 먼저 재현한다.
- [x] 카탈로그의 0.9초/80범위/10피해를 소비하고 최초 주기, 무대상 재탐색, 해제 중 대기시간 보존을 연결한다.
- [ ] 나머지 공격 인법의 시간별 효과/상태/투사체 및 생존·이동 소비처를 연결한다.
- [ ] 기존 유파 내장 공격과 새 책의 중복을 차단하고 실제 Main/장비/저장 profile2를 함께 통합한다.
- [ ] 신규 경로 실제 렌더·입력, 5회 전체 범위 적대적 검토, 정상 속도 런 검증을 수행한다.

Benchmark ADAPT: Brotato의 자동 공격 및 빌드 선택, Vampire Survivors의 군중 처치와 성장 선택.
우리 설계 해석: 공격의 범위·주기로 선택 가치를 만들되 6무기/짧은 웨이브 구조는 이식하지 않는다.
공식 제품 설명만 비교했으며 타 게임 코드를 역공학했다고 주장하지 않는다.
Sources: https://store.steampowered.com/app/1942280/Brotato/ ; https://store.steampowered.com/app/1794680/Vampire_Survivors/
Feasibility: 기존 Godot Node/카탈로그/Loadout 소비처 재사용, 새 의존성·비용·저장 변경 없음.
Rollback: 전용 경로 및 해당 테스트만 되돌리며 기본 Main 경로는 변경하지 않는다.
제한: 근접 태그 보너스 최종 연결, 새 Stage 재사용 시 타이머 리셋 계약, 신규 효과 미술, Human 검증 미완료.

### 2026-09-13 승인된 시작 빌드 연결 계획

Goal: 실제 3×3 공간과 시작 인법 두 권, 외부 장비 세 슬롯을 하나의 검증된 시작 입력으로 만든다.
Architecture: 기존 BackpackState/Resolver와 NinjutsuLoadoutState를 재사용한다.
새 시작 세션은 선택과 배치를 임시로 보유하고, 확정 시에만 읽기 전용 스냅샷을 제공한다.
Tech stack: Godot 4.7.1 / GDScript / GUT. Spec: 상세 규칙 R-LOADOUT/R-EQUIPMENT/R-NINJUTSU.
새 저장 profile2 및 실제 인법 효과가 준비되기 전에는 기본 Main 시작 경로를 교체하지 않는다.

- [x] Book geometry: `scripts/data/ninjutsu_book_catalog.gd`에서 24개 인법에 무료 시작/유상 책 ID를 매핑한다. 둘 다 1×2이며 판매가는 각각 0/20G. 기존 경제 목록을 변경하지 않는다.
- [x] `BackpackState`에 명시적 선택형 카탈로그 모드를 추가한다. 복사/JSON 왕복 시 모드를 유지하며 schema1 codec은 새 모드를 거부한다. 기존 모드의 지오메트리/저장은 유지한다.
- [x] `scripts/core/start_loadout_session.gd`에서 시작3택1×2, 취소/재선택, 배치 이동/회전, 실제 배치에서 추출한 ID로만 최종 확정을 연결한다. 장비는 EquipmentLoadoutState의 별도 스냅샷이다.
- [x] GUT에서 중복/가방 밖/충돌/미선택/복사 오염/확정 후 편집/JSON 모드 손실을 검사한다. 핵심 신규 경로의 RED→GREEN 뒤 전체60쌍의 실제 네 칸 배치와 단일 확정을 확인했다.
- [x] 독립 시작 준비 UI 소비처에서 선택/배치/장비 표시를 검사한다. Main 전투·새 저장 연결과 혼동하지 않도록 준비 검증 화면임을 표시한다.
- [x] 전체 회귀707tests, 실제 화면 검증, 5회 제한 범위 자체 검토 후 증거를 기존 review/Active Context에 기록하고 task branch를 동기화했다. 전체 게임/독립 검토/병합 완료는 아니다.

구현 코드 head: `01ab502b9f13ca3ac067215b5de3930d4fe9baf3`.
다음 계획: 선택한 인법의 실제 효과와 기존 내장 공격 제거를 한 묶음으로 검증한 후
장비/준비 확정/profile2를 연결한다. 그 전에는 Main을 전환하지 않는다.

Research: ADAPT Godot JSON primitive encoding and explicit value copies
(https://docs.godotengine.org/en/latest/tutorials/io/saving_games.html,
https://docs.godotengine.org/en/stable/classes/class_dictionary.html).
REJECT adding books to the legacy shop pool globally; REJECT a second geometry engine.
ADOPT an explicit catalog mode in the existing spatial owner, preventing silent old-save interpretation.
Feasibility: existing geometry/resolver/draft/gear owners suffice; no new autoload, paid service or art dependency.
Rollback: legacy defaults unchanged; reject new mode at schema1 boundary, preserve user files.
Correction: current `MVP4Catalog.build_bags()` already defines 3×3. Previous status claiming geometry itself was absent was stale; new draft/book integration is the missing work.

2026-09-12 최신 지시: 남은 구현을 통합 검증까지 진행한다. 아래의 과거 문서 작업
한정/구현 착수 대기 문장은 이번 진행 승인을 막지 않는다. 다만 새 이미지 최종 승인,
실제 사용자 플레이 평가, 파괴적 저장 이관과 보호된 main 경계는 유지한다.
현재 구현은 브레스·기본무기/대시 교정과 네 전장→최종 준비→재앙 보스→완료 화면 연결까지다.
장비/인법/저장/최종 정산 등 전체 P패키지 완료가 아니다. 현재 실행 상태·증거는 Active Context를 따른다.

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

### 2026-09-12 구현 재개 — 첫 단위: 천술 브레스

최신 사용자가 남은 구현 확인과 진행을 요청했다. 승인된 브레스 논리부터 현재 작업
브랜치에서 실행한다. 전체 Blueprint/아트 승인을 소급하지 않는다. 기존 main b5c2dd61과
현재 Draft147의 수동 오의 입력 차이를 확인했고 타 PR135/49는 수정하지 않는다.

파일: `scripts/schools/cheonsul_runtime.gd`, `scripts/player/player_controller.gd`,
`tests/unit/test_cheonsul_runtime.gd`, 관련 `tests/integration/test_manual_ultimate_input.gd`.
기존 Host→runtime 요청을 유지하고 runtime이 방향/6틱/취소를 소유한다.

- [x] RED/GREEN: 무상태 전방/뒤쪽,6틱,대시 취소,일시정지 거부, 이동 원점과 방향 고정을 검증했다.
- [x] 경계 교정: 큰 delta에서 상태 만료 후에도 보너스가 남는 실패를 재현하고 틱별 시간 진행으로 교정했다.
- [x] 회귀: 기존 오의 피해/상태 유지 기대 교정. Godot4.7.1/GUT9.7.1 전체623/623,6860assertions.
- [x] 메인 headless smoke:120프레임 종료코드0. 실제 화면/입력/Human 검증은 아니다.
- [x] 자동무기 방향 fallback, 가시 대상 정책, 사망/각도/거리/pause/이탈 경계 보강.
- [x] Main 상단 버튼→Host→브레스→대시 취소 통합 시험 포함, 전체629/629(91스크립트),6896assertions.
- [x] 전용 VFX: 표시된 색/표현 승인, Aseprite4프레임 접점 정렬, PNG+JSON, runtime연결 및 고립된 실제GPU렌더 확인. 전체 전장 가독성/Human은 미검증.
- [x] R-INPUT 일부: 정지 대시/재입력·pause 거부, 일본도120도 군중 판정, 수리검480탐색. 전체637/637,6936assertions.
- [ ] 최종5회 전체 검토/정확한commit 검증/PR push. 이번 증분은 로컬 미커밋이며 완료 gate가 열려 있다.

오의 신규 전용 그림은 이 단위에서 만들지 않는다. 기존 자동 원소/반응 충전의 자유선택
전환, 임시검 모드, 장비3슬롯,24책,profile2는 각각 남은 구현이며 브레스 완료에 포함하지 않는다.

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

설계 검토와 PDF 생성은 문서 증거다. 과거 승인 전 구현 금지는 최신 승인 범위 밖 변경에 적용하며, 현재 실행 범위는 최신 사용자 요청을 따른다. 자산은 GENERATED_CANDIDATE / REWORK / REVIEWED를 구분한다. 실제 runtime, 사람의 재미·가독성, Android/패드 실기기, 라이선스·출시 최종 심사는 별도 gate다.

롤백은 패키지별 변경과 데이터 계약 버전을 함께 되돌리며 이미 생성된 profile2를 구형 codec으로 억지 해석하지 않는다. 구형 파일 보존, 새 테스트 경로, feature/package 단위 통합으로 복구 범위를 작게 만든다. main 직접 push·강제 push·기존 Draft 임의 merge는 하지 않는다.

전체 구현 입력의 최종 판정은 자산 검사·문서 교차검사·5회 전체 검토 결과와 함께 보고한다. 이미지 준비가 실패한 경우 승인만 받으면 모든 아트를 바로 적용할 수 있다고 주장하지 않는다. 대신 논리 P01~P05 착수 가능성과 아트 P06의 실제 blocker를 분리한다.

## J. 잔여 구현 실행 명세 — 2026-09-14

### J0. 범위·근거·완료의 의미

**Goal:** 기존 신규 도메인을 재사용하여 기본 새 게임에서 네 전장·최종전·정산·이어하기까지
최신 규칙으로 연결하고, 실제 조작·화면·저장·성능의 검증 증거를 만든다.
**Architecture:** 기존 Main은 조립/진입, 각 도메인은 합법성, UI는 표시/의도,
RunResumeStore는 디스크, RunResumeCodec은 직렬화/교차 검증을 소유한다.
새 전역 manager, 두 번째 전투/가방/경제 시스템은 만들지 않는다.
**Tech Stack:** Godot4.x/GDScript/GUT, JSON, 기존 PNG/Resource/Scene; 추가 유료 의존성0.
**Spec:** 본 문서 A~I 및 `NINJA_SURVIVAL_DETAILED_RULES.md` R-*.
**Execution:** 후속 구현은 이 문서의 패키지 순서와 TDD로 수행한다. 한 번에 전체를 갈아엎지 않는다.

검토 기준 코드: 작업 브랜치 `c3604867a09a8eb0b03280a50d81b7db9d1b8854`.
관찰한 completed main: `b5c2dd61cd589ebd218d1b4da3f016fb94a02126`.
이는 2026-09-14 관찰값이며 다음 실행에서는 다시 fetch/readback한다.
PR147은 해당 작업의 Draft, PR135/49는 read-only. main에 새 규칙이 병합됐다고 말하지 않는다.
위 코드 head의 GitHub GUT/Windows internal artifact SUCCESS를 조회했다.
이전 로컬 전체792tests/10524assertions, isolated MATERIAL_RUNTIME_PASS는 기존 증거이며
이번 명세 작업에서 게임 테스트/전체 런/사람 검증을 새로 실행한 것은 아니다.

| 영역 | 현재 구현 현실 | 남은 종류 |
|---|---|---|
| 4유파·2회 시작 선택·3×3·시작 책2권 | StartLoadoutSession과 UI/배치/교차 검사 존재 | 기본 Main 연결·선택 지원품·저장 |
| 8무기·닌자복·24인법 | 카탈로그/장비 상태/개별 효과와 테스트 존재 | 전체 획득 흐름·태그 계산·런타임 조합 행렬 |
| 보조19·조합3 | selected catalog/실제 명중 조합/닌자복 소비 존재 | 상점·도감의 legacy 필터 교체 |
| 흔적 흡수/강화 | 선택형 access/gear 후보와 복원 검증 존재 | 준비 UI·영구 거래·출전 거래 구분 |
| 저장 | v1 재개 저장/지갑과 손상 입력 보호 존재 | 단일 profile2 및 경제/복구 거래 |
| 전장·최종 보스 | circuit·actors·final_calamity 존재 | 새 규칙 적합성 및 기본 전체 런 검증 |
| 신규 그림체 | 브레스 외형 승인·일부 runtime 증거 | 플레이어/적/무기/인법/UI 상태군 LOCK와 통합 |

**재구현 금지:** 24인법·8무기·3조합을 모두 미구현으로 세지 않는다.
기능 존재, 선택형 기본 경로 적용, 자동 검증, 실제 화면 검증을 별도 상태로 기록한다.

### J1. 패키지 지도와 순서

| ID | 플레이어 결과 | 선행/BLOCKS | 현재 판정 | 기존 P단계 |
|---|---|---|---|---|
| R01 | 재화와 진행을 함께 안전하게 저장/복구 | 없음, R02/R03/R05를 차단 | 설계 지정·구현 필요 | P04 |
| R02 | 흔적·장비·가방·인법·운명·다음 전장을 준비 화면에서 확정 | R01 | 부분 구현 연결 | P03/P04 |
| R03 | 새 게임부터 새로운 규칙으로 실제 전투 시작 | R01/R02 | 기본 진입 경로 전환 필요 | P01/P05 |
| R04 | 상점·상자·보상·조합에서 실제 빌드 성장 | R02, R03으로 전투 확인 | 기존 거래에 새 목록/장비 연결 | P03 |
| R05 | 종료 정산·각성·재도전·도감·설정 완결 | R01/R03/R04 | 기존 화면/ledger 확장 | P04/P06 |
| R06 | 네 유파 전장과 최종 보스의 공정한 패턴 | R03, R04/R05로 전체 런 확인 | 기존 배우/패턴 재검토 | P05/P07 |
| R07 | 무기·인법·오의·조합 수치/사건 일관성 | R03/R04 | 소비자 교차 검증·검증된 결함만 수정 | P02/P05 |
| R08 | 일관된 플레이어·적·VFX·UI/음향 | 상태 명세는 즉시, 적용은 R03/R06/R07+LOCK | 자산 준비/승인/연결 필요 | P06 |
| R09 | 마우스·키보드·패드·터치 완주/군중 성능 | R03~R08 | 자동·실기기 검증 필요 | P08 |
| R10 | 테스트 가능한 배포 후보·정본/PDF/정리 | R01~R09의 필요 증거 | 통합 검수·배포 후보 준비 | P08 |

권장 기본 순서: R01 → R02 → R03 → R04 → R05 → R06 → R07 → R08 → R09 → R10.
R06/R07의 독립 fixture와 R08의 상태 브리프는 저장 구현 중에도 조사할 수 있지만,
같은 Main/codec/scene를 동시에 수정하는 작업은 순차 처리한다. 아트 LOCK 대기는
저장/경제/전투 논리 검증 전체를 막지 않는다. 일정·완료율은 실측 없이 숫자로 만들지 않는다.

### R01. 단일 프로필·저장 복구

2026-09-20 후속: `publish_recovery_candidate(role, observed)`를 기존 store에 추가했다.
현재 조회한 canonical/previous/temporary 전체와 SHA256이 일치해야 한다. 모든 원본
(손상본 포함)을 같은 프로필 경로의 `.recovery/<고유 기록>/`에 바이트 그대로 보관하고
선택·해시·목록을 inventory.json에 남긴 뒤 선택본을 stage/readback한다. 다시 목록을
대조한 후 원래 파일은 같은 보관 폴더로 옮기고 정본을 교체한다. 실패하면 이동한
원본을 역순 복귀하며 복귀 실패도 원본 보관 경로를 반환한다. 자동 최신 tmp 채택,
원본 삭제, 게임 보상/재화 계산, 새로운 저장 포맷은 추가하지 않는다.
보존본과 displaced 원본의 중복은 실패 복구를 위한 의도된 보존이며 자동 정리하지 않는다.
호출 중 재진입 거래는 거부한다. 다중 프로세스 writer/OS 전원 차단 내구성은 미검증이다.
복구 화면과 사용자 확인 입력은 R03 Main 전환에서 이 API를 소비한다.
첫 파일 이동 전에 `.recovery-required` 표식 디렉터리를 만들고 정본 readback과
표식 제거가 모두 성공해야 복구 완료로 반환한다. 시작 후 실패는 rollback 성공 여부와
무관하게 표식을 남기므로 재시작 후에도 load/신규 거래/구형 지갑 이관이 차단된다.
현재 후보를 다시 조회해 명시 선택하면 재시도할 수 있다. 원본이 archive에만 남은
경우 `publication_incomplete`와 `recovery_archive_root`를 제공하며 자동 새 프로필 생성은
금지한다. archive-only 원본 수동 복귀/안내는 R03 복구 UX의 미완료 경로다.
표식 제거 실패는 `ok=false, recovery_required, publication_applied=true`로 구분한다.
예상치 못한 표식 파일/내용은 덮어쓰거나 재귀 삭제하지 않는다. 이 표식은 저장 포맷이나
두 번째 저장 관리자가 아니라 같은 store의 미완료 복구 상태다.
검증: 전용 gut 임시 디렉터리에서 3역할 선택, 손상본 보존, 낡은 목록,
보관/임시 쓰기 실패, 보관 중 원본 변경, 이동/되돌림/최종 readback 실패를 검사한다.
독립 검토 1회차에서 previous만 있던 상태의 게시+rollback 동시 실패가 재시작 뒤
missing으로 오인되는 P1을 확인했다. 전용 회귀 RED1개 → 교정 후 집중12/12,
319단언 PASS. 재시작 차단, 명시 재시도, 표식 제거 실패와 예상치 못한 파일 보존 포함.
공식 API 확인: [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html),
[DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html).
기존 store 확장 ADAPT, 최신 후보 자동 승격 및 두 번째 저장 관리자 REJECT.
새 재미 규칙은 없으며, 중단 후 빌드/재화가 바뀌지 않는 신뢰성 가설을 기계 검사한다.
HUMAN/FUN 결과는 별개 NOT_RUN이다.

현재 범위: departure/preparation 값 저장, 임시 I/O 실패 보호, 읽기 전용 복구 후보
조회·선택 재검증, 구형 잔액 비파괴 이관 API, receipt가 있는 재도전 자격 보존까지
구현했다. Main은 아직 기존 진입이며 복구 확정/원본 보관 UI, 재도전 업무 거래와
R02 연동은 남아 있다. 아래 숫자는 당시 검증 이력으로 현재 완료 범위를 대체하지 않는다.

추가 장애 검증: old→previous / tmp→main / 실패 후 rollback / readback 실패 뒤
새 파일 격리·원본 복원 실패를 주입했다. promote와 rollback이 동시에 실패하면
원본.previous와 새 후보.tmp를 모두 보존한다. 전체102scripts/805tests/11529assertions
PASS(exit0), `ninja-profile-rename-full-gut-20260914.log`. OS 전원차단·실제 디스크
고장·다중 프로세스 writer까지 검증했다는 뜻은 아니다. tmp open/write/flush 전체
실패 조합과 복구 선택 UI는 당시 잔여였다. 임시 I/O 후속 증거는 아래 보강 절 참조.

2026-09-14 후속 구현: `decode_selected_checkpoint()`와 실제 profile store를 연결해
출전 경계의 non-null active_run을 저장/재읽기한다. 경로 파생 배열 불일치, 미해결
흔적, 가방/보관함 ID 중복, 잠긴 유파 책, 선택하지 않은 무료 시작 책, 허위 배치
수정치, 출전 유파/자원 불일치를 거부한다. 네 전장24순서의 출전/최종 경계 검사와
디스크 재시도 검사를 포함해102scripts/803tests/11496assertions PASS(exit0).
JSON 정수/실수 표현 차이가 동일 거래를 충돌로 오인하는 실패를 재현·교정했다.
이 증거 당시 Main/preparation/재도전/복구/이관이 잔여였다. 현재 구현 범위는 이 절
첫 요약과 Active Context를 따른다. 정상속도 완주와 전체5회 적대검토는 여전히 미완료다.

앞선 2026-09-14 구현 증거: envelope/명시적 profile store/거래 digest와 재시도/기본 I/O
실패 보호를 구현했다. GUT101scripts/798tests/10592assertions PASS. active_run이
null인 프로필만 허용했던 초기 단계이며, 이후 위 departure/preparation 구현으로
확장했다. 초기 제한을 현재 동작으로 해석하지 않는다.

**문제/가치:** 현재 wallet_v1과 resume_v1은 별도 파일이다. 개별 파일 보호가 있어도
소울 차감과 체크포인트 이동 전체의 원자성은 보장하지 못한다.
**수정 파일:** `scripts/core/run_resume_codec.gd`, `scripts/core/run_resume_store.gd`,
`scripts/core/ninja_soul_wallet.gd`, `scripts/core/run_checkpoint.gd`.
**시험:** 기존 `tests/unit/test_run_resume_codec.gd`, `test_run_resume_store.gd`,
`test_ninja_soul_retry.gd` 확장; 교차 거래는 신규 `tests/unit/test_profile_v2_transaction.gd`.

다음은 R01의 기본 API다. 복구 조회/선택과 이관 API는 아래 관련 절에 명시한다:

```gdscript
# RunResumeCodec: 실패는 {ok:false, reason:StringName}, 성공은 정규화 profile 복사본.
func decode_profile_v2(payload: Dictionary) -> Dictionary
func decode_selected_checkpoint(payload: Dictionary) -> Dictionary
# RunResumeStore: configure_profile() 이후만 허용, v1 경로와 구분.
func configure_profile(path: String) -> bool
func load_profile() -> Dictionary
func transact_profile(candidate: Dictionary, expected_revision: int, transaction_id: String) -> Dictionary
```

E의 root/meta/active_run을 유지한다. active_run의 `checkpoint`는 **마지막 출전 확정**
빌드다. 별도 파일 없이 같은 active_run 안에 `preparation`을 선택 필드로 둔다:

```text
preparation = null | {
  prepare_session_id, phase: 'preparing', revision,
  access, equipment, spatial_session, loadout, gold, reward_state,
  pending_fate, provisional_school, healing_applied,
  fate_state? // candidate_ids, pending_fate, rng_seed, rng_state
}
```

이 필드는 준비 거래를 저장하기 위한 기술 명세다. 수치/아이템 정의는 저장에 복제하지 않는다.
2026-09-14 실제 owner 연결에 따른 기술 보강: spatial_session은 backpack/buffer/
pending_bag/preserve_buffer의 한 묶음이다. 구매 후 미배치 가방을 누락하지 않고,
드래그 미리보기·조합 진행 상태는 저장하지 않는다. loadout은 준비 시점의 인법
배치 검증에 사용한다. 별도 준비 route를 중복 저장하지 않고 마지막 checkpoint
경로에서 해당 전장 하나를 완료한 결과와 provisional_school로 계산한다.
2026-09-14 FateController의 준비 값 보존 연결: 선택 후보·예약 ID·해당 owner의 RNG
seed/state를 fate_state에 저장한다. 후보는 아직 획득하지 않은 운명으로 중복 없이
현재 남은 수와 일치해야 하며, pending_fate는 owner 예약과 일치해야 한다. 복원은
시그널/전투 효과/재추첨을 발생시키지 않는다. 이미 적용한 운명은 준비 snapshot으로
내보내지 않는다. 이전12필드 준비본은 pending_fate가 빈 경우에만 호환 허용한다.
Fate RNG는 현재 Main에서 보상 RNG와 독립이므로 각 owner 값을 따로 보존한다.
동일 데이터의 두 정본을 새로 만들지 않으며 출전 거래/Main 적용은 후속 연결이다.

reward_state는 RestRewardController의 version1 값(snapshot)이다. 보스 후보·수령
여부·상자·상점 후보/레인·가방 구매 제한·재추첨 단계 및 공용 RNG seed/state를
보존한다. RNG는 JSON 정밀도 손실을 피하기 위해 정규 64비트 정수 문자열이며
복원 순서는 seed 다음 state다. 엔진 변경 간 동일 추첨 결과까지 보장하지 않는다.
근거: https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html
재추첨으로 복원 REJECT, RNG 없는 선택지 보존만 REJECT(다음 추첨 변화), 기존
owner 값+공유 RNG 보존 ADAPT. 기존/선택형 카탈로그는 실제 가방 계약으로 분리한다.

access/equipment는 확인된 흔적·구매 소유 상태, backpack/buffer는 그 준비의 기준 상태다.
드래그 중 임시 좌표/미확정 운명은 메모리 후보이며 확정된 준비 기준과 구분한다.
checkpoint와 preparation의 서로 다른 시점 데이터를 임의 합성해 전투하지 않는다.
보스 후 준비 생성 자체를 저장해 이어하기가 직전 보스를 다시 처치해 보상을 복제하지 않게 한다.

checkpoint의 저장 owner 매핑은 다음과 같다. UI bundle은 검사용 투영이며 동일 사실을
여러 JSON 필드의 권위자로 중복 저장하지 않는다.

| 키 | 책임/검사 |
|---|---|
| build | RunBuildState의 gold/소유/선택운명/확정 장비. equipment의 출전 정본은 이 안에만 둔다 |
| route | RunRouteState 완료 순서/현재/다음 경로. 완료 중복·5번째 전장 거부 |
| circuit | phase/전장/상자·보상 진행. route와 단계 일치 |
| backpack, buffer | persistent instance records, 전체 ID유일/다음ID, buffer≤6 |
| loadout | origin/draft_picks/active/pending, 실제 책과 access로 검증 |
| access | starting/stabilized/trace_decisions/unlocked, route 완료와 교차 검사 |
| prepare_session_id, rules_version | 안정적 준비 ID와 알려진 content/rules 계약 |
| ultimate_charge | 시작 유파의 충전만. 활성 모드 없음 |

현재 출전 codec의 circuit은 `{phase: "core" | "final_boss", active_school_id}`만
저장한다. 일반 출전은 route.active_school_id와 같고, 최종 출전은 네 전장 완료 후
빈 학교 ID를 쓴다. 진행 중 전투 장면을 복원하는 구조가 아니다. build는 기존7필드
snapshot을 유지하되 legacy owned_items는 비어 있어야 하며 공간 수정치는 현재
배치로 재계산해 일치 검사한다. 일반 출전의 eligible_boss_ids는 완료 전장 집합과
일치한다. 재도전은 retry:run_id receipt(또는 저장 중인 동일 거래 ID)가 있어야 하며,
기존 완료 전장을 모두 보존하고 현재 전장의 기존 보스 자격만 추가로 보존할 수 있다.
무관한 미방문 전장 자격은 거부한다. 실제 비용/실패 화면 업무 진입은 R05 후속 연결이다.

E의 active_ninjutsu_ids/selected_fates는 각각 loadout.active_spell_ids/build 선택운명의
**의미명**으로 해석한다. 독립적인 두 번째 권위 배열을 추가하지 않는다. codec의
검사용 bundle.equipment는 checkpoint.build에서 투영한다. preparation 장비는 아직
출전하지 않은 별도 시점의 소유/편집 기준이며 checkpoint 장비와 값이 달라도 합법이다.
준비 중 구매·흔적 거래는 드래그 중인 좌표를 몰래 확정하지 않는다. 현재 confirmed
preparation을 clone하고 해당 거래 필드만 변경한 뒤 저장한다.

검증 순서: root/형/버전 → ID/정수/유한수 → route/circuit 상태 → 가방/버퍼 →
gear/access → 배치에서 active 인법 재산출 → 수정치 재산출 → 자원/경제 거래 일관성.
`RestCommitCoordinator.validate_selected_build_bundle()`를 재사용하되 이것만으로
route/gold/buffer/정산까지 검증됐다고 보지 않는다. 슬롯3·무기8+복1·인법4/타유파1,
인스턴스 중복(가방/버퍼 전체), starting_school 일치, 알려지지 않은 필수 버전 거부.
오의 자원 상한은 봉마120/천술3/귀인100/흑영3, 유한수0..상한. 활성 오의·투사체·
피해영역이 남은 경계 저장은 거부한다. 모드 토큰/Node ID는 직렬화하지 않는다.

거래 결과: `{ok, reason, revision, already_applied, warning}`. expected_revision이
다르면 파일/메모리0변경. 같은 transaction_id+동일 요청은 재적용 없이 기존 결과,
같은 ID+다른 payload는 `transaction_conflict`. transaction ID만 저장하지 말고
정규화 요청 digest/결과 revision을 receipt에 보존한다. 소울은 JSON 정확 정수 범위 내.

준비 거래 ID 제안: `prepare:<run>:<stage>`, `trace:<run>:<school>`,
`purchase:<prepare>:<offer>:<request>`, `depart:<prepare>`. 요청 ID는 클릭 프레임마다
새로 만들지 않고 동일 요청 재시도에 유지한다. 성공한 출전 뒤 새로운 출전은 새로운
prepare_session_id에서만 가능하다. heal 적용은 prepare 생성 receipt와 원자적으로 기록한다.

```text
validate candidate → write tmp → flush/close → decode tmp
→ main→previous → tmp→main → decode exact main
→ adopt memory → publish signals
```

실패 주입 지점: tmp open/write/flush/readback, old rename, promote rename, final
readback, rollback rename, previous cleanup. 성공 전 메모리/전투는 변경하지 않는다.
정본 readback 성공 뒤 cleanup 실패는 성공+warning; 실패로 재시도해서 이중 지급 금지.
main/previous/tmp가 남으면 유효성/revision/receipt를 비교하며 손상 원본 보존.
tmp만 더 새롭다는 이유로 미확정 거래를 자동 확정하지 않는다. 모호하면 복구 화면에서
정본 후보·잃을 진행을 보여주고 플레이는 닫는다. 파일시스템 crash-proof는 주장하지 않는다.

2026-09-14 구현: `inspect_profile_recovery()`는 정본/이전본/임시본 각각의 존재,
유효성, revision, 읽은 바이트의 SHA256을 반환하는 읽기 전용 점검이다. 자동 승격이나
삭제는 하지 않는다. 복구 후보 선택·동시 변경 해시 비교·Main 복구 화면은 남아 있다.
기존 store 확장 ADAPT, 최신 tmp 자동 채택 REJECT(미확정 거래), 별도 저장 관리자
추가 REJECT(책임 중복). 준비 reward.segment와 마지막 출발 stage_index도 교차 검증한다.
근거: Godot FileAccess/get_buffer/get_error 및 HashingContext 공식 계약;
https://docs.godotengine.org/en/stable/classes/class_hashingcontext.html
실제 시험용 파일의 손상·누락·유효 후보 보존과 교차 스테이지 거부를 검사하며,
실제 정전 내구성이나 플레이어 복구 화면 검증으로 확대하지 않는다.

v1 런 자동 변환 REJECT. 유효 v1 잔액만 첫 profile 생성 시 source SHA256과
`migrate:wallet-v1:<sha>` receipt로1회 이관. 이미 profile이 있으면 v1 재수입 금지.
손상 wallet은0초기화 금지, 미래 버전 거부, 원본 삭제/덮어쓰기 금지.

2026-09-14 구현: `RunResumeStore.import_legacy_wallet(source_path)`가 기존 잔액
검증기와 profile 거래를 재사용한다. 읽은 원본 바이트 SHA256을 이관 receipt에 기록하고
첫 profile만 생성한다. 정본이나 복구 후보가 하나라도 있으면 재수입을 거부한다.
실패 주입은 gut 전용 파일로만 수행한다. Main 진입 연결은 후속 R03이며 기존 런의
자동 변환은 여전히 제외한다. 원본 직접 수정 REJECT, 별도 이관 저장소 REJECT,
기존 엄격한 검증기+단일 거래 재사용 ADAPT. 사용자 파일은 이번 시험에 사용하지 않았다.

인수 예: 초기 소울2 → retry 거래 → 소울1/소비flag/checkpoint 예약이 함께 저장;
동일 ID 재시도는 소울1. rename 실패면 기존 소울2/이전 체크포인트 유지.
테스트는 주입된 gut 전용 경로만 사용. 정상 사용자 경로로 실패 주입 금지.
**완료:** JSON 왕복+모든 실패 지점+재시작 readback이 통과한 뒤에만 R02가 소비한다.

R01 2026-09-14 보강: 임시 파일 open/store/flush/readback 실패를 실제 시험 전용
파일과 최소 I/O 경계로 주입한다. store_string 반환값을 먼저 검사하며 핸들을 명시적으로
닫고 실패 원인을 분리한다. 원본·호출자 요청·잔액은 유지하고 남은 후보는 자동 덮어쓰지
않는다. 집중9/9, 전체806/806 자동검사 통과. 전원 차단·실기기 증거는 아니다.
대안: 기존 최종 get_error만 확인 REJECT(쓰기 실패 단계 분리/검증 부족),
별도 저장 프레임워크 REJECT(책임 중복), 기존 store의 좁은 I/O 경계 ADAPT.
공식 근거: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
(store_string 성공값, flush/get_error, close 수명). JSON/Resource 저장 형식 교체는 하지 않는다.

준비 보상 상태의 실제 owner 조사: RestRewardController의 chest/boss pending/options,
ShopController의 offer/lane/bag-purchased/reroll과 공유 RNG를 보존해야 한다.
begin_rest 재호출은 후보 재추첨·구매 제한 초기화를 일으키므로 복원 경로로 쓰지 않는다.
이 조사만으로 preparation codec 또는 selected reward runtime이 구현됐다고 보지 않는다.

### R02. 준비 단계와 두 확정 거래

**수정:** `scripts/core/rest_commit_coordinator.gd`, `school_circuit_controller.gd`,
`tradition_access_state.gd`, `equipment_loadout_state.gd`, `run_build_state.gd`,
`scripts/backpack/rest_backpack_session.gd`, `scripts/ui/rest_flow_ui.gd`,
`scenes/ui/rest_flow_ui.tscn`. 테스트: 기존 rest coordinator/session/circuit 및
`tests/integration/test_mvp3_rest_flow_ui.gd`에 selected 경로 추가.

한 준비 화면 안에 보상/상점/가방/캐릭터장비/흔적/다음 전장/운명 패널을 둔다.
확정 전후 수치와 저장 상태를 표시한다. UI는 domain 반환 사유를 표시할 뿐
장비 강화·가격·해금·geometry를 직접 계산하지 않는다.

| 행동 | 디스크/소유 상태 | 전투 상태 | 취소/실패 |
|---|---|---|---|
| 흔적 대상 미리보기 | 변경0 | 변경0 | 이전 선택 화면 |
| 흔적 최종 확인 | access+장비 단계를 준비 거래로 함께 저장 | 기존 출전 빌드 유지 | 저장 실패시 둘 다0변경 |
| 배치/장착/운명/경로 편집 | 메모리 후보 | 변경0 | 마지막 준비 확정 기준으로 복귀 |
| 출전 확정 | 최종 배치+gear+인법+Fate+route+checkpoint 함께 저장 | readback 후1회 반영 | 전체 후보 보존, 전투 진입 금지 |

신규 제안 `prepare_selected_departure(request: Dictionary)->Dictionary`는 live owner를
변경하지 않고 clone의 합법성/복원 가능성을 검증하여 profile candidate를 만든다.
`commit_selected_departure(request: Dictionary)->Dictionary`는 R01 거래 성공 이후에만
검증된 복사본을 채택한다. 채택 중 외부 signal 재진입은 막고 모든 owner 채택 후
UI/전투 signal을 한 번 공개한다. v1 `commit_pending()`를 selected 모드에 억지 사용 금지.
in-progress guard, session_id/revision 검사, 연타 idempotence가 필수다.

흔적 시작유파는 강화만/인법 유지, 타유파 흡수는 후보 해금만/자동 지급0.
어느 선택도 전장 완료/최종전 조건은 동일. 강화 후 출전 편집 취소로 흔적을 복원하지 않는다.
장비 변경/판매 뒤 trace record의 과거 instance를 현재 장착품으로 대체 해석하지 않는다.
준비 회복은 prepare_session_id당1회; 재입장/로드로 반복되지 않는다.
최종 준비에는 다섯 번째 전장 선택을 요구하지 않는다. 운명 후보가 부족하면
남은 후보만 노출하며 이미 가진 것을 복제하거나 진행을 막지 않는다.

**검증 예:** 강화 확인→장비 미리보기 취소→재개: 강화 소유 기록 유지, 미확정 장착 원복.
출전 중 I/O실패→route/Fate/장비/HP 그대로; 다시 같은 요청→한 번만 출전.
버퍼6개 보존/미배치 효과0/슬롯 미장착/조합 미완료/네 전장 완료/잘못된 revision을 시험한다.

### R03. 기본 새 게임·이어하기 연결

**수정:** `scripts/core/main_controller.gd`, `start_loadout_session.gd`,
`scripts/ui/title_screen.gd`, `scenes/ui/title_screen.tscn`, 기존 시작 선택 UI.
**시험:** `tests/integration/test_title_start_gate.gd`, `test_start_loadout_ui.gd`,
`test_main_title_resume_flow.gd`, `test_school_circuit_main_runtime.gd`.

기존 Main의 `activate_starter` 경로를 새 게임 selected 경로에서 제거하고
StartLoadoutSession의 검증된 bundle을 소비한다. legacy fixture/codec은 별도 호환 경로.
화면: 새 게임 확인 → 시작 유파 →3택1 두 번→시작 가방/장비 확인→첫 전장 선택→출전.
시작 유파와 첫 전장은 독립. 최초 일반 공격은 무기2+선택 인법2, 총4패턴이다.
이전 문서의 ‘3자동 공격’ 표현은 예전 starter1 기준이며 새 구현을 지시하지 않는다.
일반 공격은 자동, 직접 입력은 이동/무적대시/수동 오의/메뉴다. 하단 인법 버튼 없음.

새 런 생성은 profile 거래로 기존 미정산 포기 정산+new run_id를 묶는다. 확인 취소는
기존 런0변경. 이어하기는 preparation이 있으면 준비 화면, 아니면 마지막 출전 경계로
복귀하며 임시 효과 정리→장비/가방/경로→학교 runtime 활성화→오의 자원→입력 해제 순서.
전투 입력은 전체 복원과 readback 후 연다. 키를 누른 채 복귀해 대시/오의가 즉시
발동하지 않도록 released-input 경계를 둔다. 시간만 경과한 전투를 자동 복원하지 않는다.

**완료:** 4시작 유파×4첫 전장=16경로, 유파별15시작쌍=60구성의 기계 검사;
기본 제목 화면에서 실제 입력으로 최소1개 완전 전장→준비→다음 전장 증거.
도메인60쌍 통과를 기본 Main60쌍 완료로 승격하지 않는다.

### R04. 보상·상점·장비·조합의 획득 연결

**수정:** `scripts/core/rest_reward_controller.gd`, `shop_controller.gd`,
`school_circuit_controller.gd`, `scripts/data/selected_backpack_catalog.gd`,
`equipment_catalog.gd`, `ninjutsu_book_catalog.gd`, 준비 UI.
**시험:** 기존 reward adversarial/session/selected catalog 테스트 및 준비 UI 통합.

현재 `_eligible_lanes/_filtered_pool`은 실제 가방 계약에 따라 legacy/selected 지원품
목록을 고른다. selected 대체 교본 누락은 교정했다. 혼합 종류 획득 연결은 남아 있으며,
selected 경로는
보조19/해금 인법24/장비9/가방을 명시적 종류로 구분하고 그 종류의 owner로 전달한다.
`offer={offer_id, kind, definition_id, acquisition_price, lane_id, revision}` 제안.
kind는 support/book/equipment/bag; string prefix 추측으로 거래 종류를 정하지 않는다.
기존 lane-first/seed/dedupe 재사용, UI 전용 복제 카탈로그 금지.

인법은 보유 가방+버퍼의 canonical spell ID 전체에서 중복 제외; start/일반 book
외형 ID가 달라도 같은 인법이다. 장비는 보유9종 범위에서 중복 제외. 신규 장비는
외부 목록, 책/재료는6칸 버퍼→실제 배치. 결과를 못 받을 때 골드/토큰 소비0.
상점 첫 준비 확장 가방 후보 보장, 잔액 부족은 비용을 표시하며 구매 없이 출전 가능.
이미 선택한 흔적 결과에 맞춰 인법 pool 갱신; 보스 처치만으로 인법 자동 해금 금지.
조합은 기존3레시피와 원자 배치, 실패하면 재료2개 보존. 아이템0~2개만 남는 후보군도
중복으로3장을 채우지 않는다. 최초 지급품 판매0, 구매품50%내림, 마지막 장비 판매 금지.

**완료 예:** 타유파 강화 후 그 유파 책0개/공통 재료 허용; 흡수 후 책이 후보에
등장하되 무조건 지급 아님. 버퍼 가득참·중복 클릭·낡은 상점revision·장비 판매/재구매
·조합 취소·4번째 준비에서 돈/품목/효과가 일치한다.

### R05. 정산·각성·재도전·도감·설정

**수정:** `scripts/core/run_settlement_ledger.gd`, `ninja_soul_wallet.gd`,
`run_checkpoint.gd`, `main_controller.gd`, `scripts/ui/title_screen.gd`,
`codex_presentation.gd` 및 기존 설정/결과 화면 consumer.
**시험:** `test_ninja_soul_retry.gd`, `test_title_actions.gd`,
`test_codex_presentation.gd`, R01 transaction test.

정산 초기 규칙: distinct 유파 보스수+최종승리2, 보스0이고 elite qualified면 위로1.
기록용 STYLE/구슬/생존 시간으로 추가 소울을 만들지 않는다. 한 run_id 정산1회.
retry1소울·런당1회·종료 정산 아님; checkpoint 과거 자격과 현재 자격의 합집합으로
중복 보스 지급을 막는다. settle/retry/unlock은 R01 동일 파일 거래에만 쓴다.
각성3소울로 시작 지원 선택 해금, 체술/호신/인법단련 중1개 실제 가방 점유/판매0.
2권과 지원품을 실제3×3에 배치할 수 없는 조합은 confirm에서 설명하고 출전을 막으며
미리보기 자동배치는 geometry를 재사용한다. 무료 기본조작 잠금/무한 스탯트리 금지.

도감 현재 selectable 제외 필터를 selected 카탈로그 경로로 교체한다. 적/24인법/
장비9/보조19/가방/조합3을 분리한다. 물의 재료와 수맥 기술은 서로 다른 설명이다.
장비에 ‘가방 배치’를 표시하지 않는다. ID·가격·크기·효과는 실제 카탈로그에서 읽고
UI문자열에 수치를 중복 정의하지 않는다. 조합 부가타의 재귀 금지/보스 제어 예외 명시.
설정은 음량/효과강도/흔들림/전체화면/입력 안내의 실제 consumer와 저장 실패 안내.
효과 최소에서도 적 피해 경계는 유지한다. 기존 버튼 존재를 consumer 구현 완료로 보지 않는다.

**완료:** 재시작 후 정산/각성 이중 지급·이중 차감0, 손상 저장 이어하기 비활성 사유,
새 게임 취소 보존, 여섯 메인 버튼의 실제 이동/뒤로/초점 반환 증거.

### R06. 전장·군중·엘리트·보스·최종전 적합성

**수정:** `scripts/data/encounter_catalog.gd`, `stage_encounter_profile.gd`,
`scripts/core/stage_encounter_state.gd`, 기존 WaveSpawner,
`scripts/enemies/school_encounter_actor.gd`, `encounter_pattern_controller.gd`,
`final_calamity.gd`, `scenes/enemies/school_encounter_actor.tscn`, `final_calamity.tscn`.
**시험:** 기존 encounter actor/catalog/stage/wave/final tests; 신규
`tests/integration/test_full_route_matrix.gd`는 전체 연결 증거 담당.

일반3역할은 접촉 추격만; 초반부터 부적/피해 장판 금지. 4유파×(일반3+엘리트1+보스1)
20개 역할의 existing ID를 유지하고 R-ENCOUNTER의 행동표와 비교해 필요한 차이만 수정.
엘리트2패턴 순차, 보스 첫2패턴을 보여준 뒤3번째. 기존 ID의 role 변경으로 저장 의미
바꾸지 않는다. 봉마 보스는 이동진술사+식신, 엘리트는 별도 요괴 수호자 외형.

스폰 floor는 살아있는 일반+예약=10 이상 목표,0.8초 예고,화면밖/최소거리,
매프레임 중복 예약0. 강적 단계에서 예약 취소/일반 스폰 권한 중지, 기존 군중 유지.
일반 적 최대수 하드캡/노후 자동삭제 금지. 100/300/600/1000은 성능 표본일 뿐 상한 아님.

패턴은 WINDUP→LOCKED→ACTIVE→RECOVERY→CHASE. 전조와 피해는 같은 geometry.
Stage1/2 슬롯1,3/4/최종2; 전조~최후 hazard/소환체 종료까지 점유. pause는 전부
동결이지 hazard 삭제가 아니다. 사망/씬전환은 슬롯/자식 projectile/소환체 정리.
보행 탈출 가능 경로를 반경 여유를 더한 hazard 합집합에서 찾고 실패시 대기.
방사16×거리4 후보/선분 sweep은 보수적 초기 검사이며 안전 증명으로 과장하지 않는다.
고정구간=max(0.65, 경로길이/현재속도+0.15), 총전조≥고정+0.2를 시작 전에 결정.

최종 재앙은 이미 존재한다. 새로 만들기보다 네 완료순서/HP4구간/패턴 종료 후 전환,
큰 피해로 구간 건너뛰기, 첫테마 기회+0.2가 **런당 테마1회**인지 검사한다.
현재 controller는 첫 패턴 사용 후 `_opening_telegraph_bonus=0`으로 소비한다.
따라서 반복 가산 버그로 추정해 수정하지 말고 테마 전환/저장 복원에도 런당1회가
유지되는지 회귀 검사한다. 최종 승리가 정산 거래로 이어지는 것까지 포함.
**완료:** 24전장 방문 순열과4시작 유파의96경로 기계 행렬+대표 실제 완주.
HP/시간을 조작한 fixture는 정상속도 플레이와 구분하며 재미 검증 대신 쓰지 않는다.

### R07. 전투 수식·사건·오의 호환성

**수정:** `scripts/combat/basic_weapon_controller.gd`, `projectile.gd`, 기존
`scripts/combat/combat_resolver.gd`, `scripts/core/ninjutsu_loadout_state.gd`, 각 school runtime/host.
기존 combat/weapon/
selected support/ultimate 테스트를 확장하고 같은 효과의 두 번째 실행기를 만들지 않는다.

R-WEAPON-CONTENT의 `base × (1+태그합+0.15×rank+무기보조합)`을 원타당 한 번,
최종 반올림도 한 번. 무기8×rank0..4×보조없음/있음 경계. 인술/오의/조합 부가타에
무기 강화가 섞이지 않도록 피해 문맥을 유지한다. 현 구현이 단계별로 반올림하는지
소수 결과 fixture로 검증하고 실제 차이가 있으면 수정한다.
젖음→번개만 반응, 역순0, 동일 시전 target hit-set, 독/화상 갱신은 틱시계 유지.
분신/지속/조합/반응/오의의 추가 발동·자원 통지 자격을 R-ULTIMATE대로 분리.
이동/생존 인법만 고른 시작도 기본 충전으로 오의 사용 가능해야 한다.
브레스 방향 고정/6틱/대시 취소, 귀인화 임시검만/원래8무기 복원, death/pause/
remove/reapply/save boundary 뒤 잔류 보정0을 actual process로 확인한다.

**완료:** 60시작쌍, 타유파1개 허용/2개거부,4개상한,책 제거/재배치,
변신 중 장착변경 차단, 투사체 비행 중 소유자 교체/사망, 재진입 콜백이 기존 공격에
새 효과를 소급 적용하지 않는 시험. 개별효과 PASS와 완주 빌드 PASS 분리.

### R08. 자산·모션·VFX·음향·화면

**Owner:** `docs/CURRENT_VISUAL_HANDOFF.md`, 기존 visual manifest/candidate README,
PlayerVisualController와 실제 actor/weapon/ninjutsu/UI consumer. 필요 상태 먼저 명세,
image model 후보→Aseprite 적합 작업→검수→LOCK→manifest→Godot 연결 순서.
새 그림체/프레임을 코드 도형으로 대신하지 않는다. 설명용 그림만으로 인게임 완료 금지.

| 상태군 | 제작/재사용 입력 | 연결 인수 조건 |
|---|---|---|
| 플레이어 | 대기·이동·대시·피격·사망, 멋진 애니 닌자 | 발pivot·48~64px초기크기·이동중 공격모션 없음 |
| 일반12역할 | 이동·생성예고·피격·사망 | 동일 카메라/접지, 색만 아닌 실루엣 |
| 엘리트4/보스4/최종 | 준비·고정·발동·회복+이동/피격/사망 | 패턴 event가 재생 구동, 보스는 일반 확대 금지 |
| 무기8/인법24/조합3/오의4 | 발동·이동/유지·명중·종료 필요한 가족 | 피해 geometry/수명과 표현 일치, 과밀해도 적 전조 우선 |
| 바닥/소품 | 반복 바닥, 나무/등잔 개별 | 바닥 이음새/카메라 이동, 랜드마크 고정 구움 없음 |
| UI/로고/메달/아이콘 | 정상·선택·비활성·오류, 작은4조각메달 | 제목 ‘닌’높이, 하단 인법바/삭제 문구 재도입 금지 |
| 음향 | 피격·경고·대시·오의·구매·확정/실패 | 실제 사건1회, 동시 발음 예산, 권리/출처 기록 |

24인법마다 무조건 별도 대형 시트를 만들지 않고 실제 공유 가능한 primitive family를
구분하되 상태를 생략하지 않는다. 메타데이터: source/hash/approval/consumer/state/
frame rect/pivot/duration/facing/import/filter/scale. 실제 alpha·halo·셀간 오염·좌우
반전·cancel/end 정리 검사. 승인된 브레스 외형은 재승인 요청 없이 재사용 가능하지만
player/적 새 후보의 최종 LOCK를 대신하지 않는다. 미승인 가족은 logic-ready와 별도.
**완료:** 단독 투명 이미지가 아니라 동일 바닥/플레이어/적/전조가 있는 화면에서
대표4유파/최종전 캡처 검수. 음향/라이선스/사람 가독성 증거도 개별 표기.

### R09. 입력·성능·실기기

**수정:** 실제 Control/입력 owner, 기존 wave/actor/spatial query와 테스트 helper.
기본 조작 경로: 마우스 drag/rotate, 키보드·패드 pick→move→rotate→place→cancel,
터치 pick→cell→rotate→place. 장비비교/흔적선택/상점/출전/뒤로도 모두 접근 가능.
확인창 닫을 때 초점 복귀; 게임 입력과 ui_accept 공유로 오의/구매 이중발동 금지.
1280×720, 긴 한글,125/150%배율,효과 최소,흔들림 끔,패드 연결 해제 시험.

성능: 100/300/600/1000 누적 적과 완주 세션에서 CPU/GPU frame time p50/p95/p99,
메모리/Node/Collision/잔류 Timer/발사체 수를 측정한다. 목표기기·해상도·engine·build
함께 기록. 목표기기 확정 전 특정 FPS PASS를 선언하지 않는다. 병목 측정→공간 조회
→갱신 분산→pool/render batching 순서; MultiMesh로 AI/충돌까지 해결됐다고 주장 금지.
**완료:** 자동 input event는 패드/터치 실기기 PASS가 아니다. 연결 장치 없으면
`DEVICE_NOT_RUN`을 남기고 가능한 desktop 경로는 계속 검증한다.

### R10. 통합·정본·블루프린트·정리·전달

**수정:** 기존 tests/tools/CI, `docs/ACTIVE_CONTEXT.md`, 본 명세, Human Blueprint,
`tools/export_replanned_blueprint_pdf.py` 및 실제 승인 asset manifest.
새 추적 대시보드/외부 Notion 정본 생성 금지. 구현 결과와 Human PDF는 서로 다른 owner.
기존 Human 내용을 삭제한 와이어프레임 축약본 대신 현재 규칙+전체 플로우+데이터표+
SWOT 강화/완화계획+승인 이미지+wireframe+atlas/상태군을 통합한다. PDF는 render 후
페이지 잘림/이미지 누락/목차/참조/실제 다운로드 경로를 확인한다. PDF 요청은 후속
산출물 단계이며 이번 명세 준비가 PDF 재생성 완료를 뜻하지 않는다.

검증 순서: focused RED/GREEN → full GUT → parse/import → actual runtime/input
→ 96경로 기계 matrix → 대표 정상속도 완주 → 현행 작업 계약의 공유 전체 검토 → exact-head CI
→ 허용된 protected PR merge → new-main readback → 동일 build 사용자 전달.
각 전체 검토는 승인 범위의 기능/흐름/저장/입력/아트/성능/문서/보호범위를 재공격한다.
2026-09-20 승인된 같은 계약 2회 예산을 적용하며, 기존 유효 검토 이력은 재사용한다.
과거 5회 기록은 역사 증거다. Human/출시 승인 자동 추정 금지.

삭제 후보는 실제 consumer0·고유자료0·Git복구·용량을 확인한 것만
`C:/Users/user/Documents/GitHub/Ninza/DELETE_REVIEW/ninja-survival-godot/<date>/`
아래 manifest와 함께 모은다. 사용자 직접 삭제. 승인근거/사용중소스/dirty worktree/
미확인 산출물은 이동하지 않는다. Base 승격은 반복 공용 문제의 후보만 기록하고
프로젝트 고유 규칙을 공용 규칙으로 즉시 편입하지 않는다.

### J2. 실행·인수 템플릿과 공통 fixture

각 R패키지는 아래1~6을 따르고 기존 테스트 책임 파일을 확장한다.
1. 해당 R-*·현재 owner·정확 main/PR/head를 재읽고 구현 범위를 기록한다.
2. 아래 같은 상태 비교를 실제 GUT fixture로 작성하고 예상 실패를 확인한다.
3. owner에 최소 구현, UI에서 규칙 계산/별도 저장 쓰기 금지.
4. focused→전체→해당 runtime 증거, 실패 원인 교정 후 다시검사.
5. 관련 현재상태/정본/검증근거 갱신, 새 이미지 LOCK은 별도.
6. exact-head 검토/CI/readback 후 다음 의존 패키지에 넘긴다.

```gdscript
# 후속 시험의 의사코드. API는 R01/R02에서 구현한 뒤 실제 fixture에 바인딩한다.
var before = owners_snapshot()
inject_failure("promote_rename")
var result = commit_selected_departure(request)
assert_false(result.ok)
assert_eq(owners_snapshot(), before)
assert_false(combat_input_enabled())
# 같은 transaction_id를 복구 후 재시도해도 비용/흔적/보상 적용 횟수는1.
```

순수 fixture→고정 seed 전장→기본 Main 사용자 경로 순으로 확대한다.
공유 저장소의 기본 user:// 파일, 다른 프로젝트 Editor/PID, 다른 PR은 시험 대상이 아니다.
기준 금액/HP/규칙 수치는 Detailed Rules/definition에서 가져오고 문서와 테스트에
서로 다른 매직넘버를 만들지 않는다. 밸런스 값은 초기값/측정값/승인값을 구분한다.

### J3. 조사·대안·현실성 및 명세 검토 기록

2026-09-14 출전 저장 후속 조사: Godot 공식 Saving games의 명시적 지속 데이터와
JSON/복잡한 객체 복원의 한계를 재확인했다. 전체 Scene/Node 그래프 저장은 REJECT,
기존 wallet/resume 두 파일에 새 필드만 추가하는 방식은 REJECT, 기존 codec/store와
도메인 검증기를 조합하는 단일 프로필은 ADAPT. 새 DB/SaaS/유료 도구는 필요 없다.
[Brotato 공식 설명](https://store.steampowered.com/app/1942280/Brotato/)의 자동 공격과
전투 사이 상점은 전투/정비 분리의 REFERENCE_ONLY, Backpack Battles의 구매/배치
의존 빌드는 ADAPT한다. 두 게임의 내부 저장 구현을 조사했다고 주장하지 않으며
우리 거래 구조가 보편적 최적해라는 성능 주장도 하지 않는다. 현재 판단 근거는
기존 owner 재사용·실패 복구·재현 테스트·추가 운영비0이며 메모리/디스크 실측은 별도다.

2026-09-14 프로젝트 current/native Base 계약과 Base remote d830c0f를 확인했다.
Base MASTER_IMPLEMENTATION_PLAN의 패키지/의존/롤백/증거 구조만 ADAPT.
템플릿의 ci-gate/자동merge/리뷰 역할 제한은 이 프로젝트 계약으로 교체하지 않는다.
Base2회 대비 프로젝트5회 검토 드리프트는 기존 명시 채택을 유지한다.

| 대안 | 판정 | 이유/비용/재검토 |
|---|---|---|
| 기존 코드 전면 재작성 | REJECT | domain/test/ID와 save 증거 상실, 현재 공백은 연결 중심 |
| 구형 Main에 UI만 덧씌우기 | REJECT | 숨은 starter/legacy reward/두파일 경제가 남음 |
| 기존 owner에 selected 계약 추가→검증→Main 전환 | ADAPT | 복구 범위 작음, dual mode는 전환 완료 후 소비자0 확인하여 정리 |
| 매 프레임 실시간 저장 | REJECT | 투사체/오의 중간 상태 재현 부담, 승인된 경계 저장과 다름 |
| 단일 profile의 검증된 준비/출전 거래 | ADAPT | 신규 SaaS/DB 없이 FileAccess/기존 store 재사용; 장애 주입 필요 |

1차 자료: [Godot Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html),
[FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html),
[UI focus](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html),
[Backpack Battles 공식 판매 페이지](https://store.steampowered.com/app/2427700/Backpack_Battles/).
JSON 저장/명시적 UI초점 ADAPT; 인벤토리 배치가 전투 결과를 만드는 사례 REFERENCE_ONLY.
PvP구조·세부레시피·가격·그림체는 복사하지 않는다. 이번 조사는 기존 방향의 연결
판단을 위한 targeted refresh이며 새로운10게임 전체 벤치마킹 완료가 아니다.

**발견·교정:** legacy상점필터→R04, selectable제외도감→R05,
기본activate_starter→R03, 흔적/출전 두확정의 저장 공백→R01/R02,
기존 최종보스 재작성 중복→R06 검증/수정으로 축소, 시작3공격 표현→4패턴으로 정정.
소스의 잠재 수식 문제는 재현 전 버그 확정이 아닌 검증 항목이다. 최종패턴 가산은
실제 owner의1회 소비를 확인해 신규 수정 대신 회귀 항목으로 교정했다.
**한계:** 이 문서는 남은 작업의 설계·실행 입력이다. 자산 최종 LOCK·전체 게임 완성·
96경로 통과·실기기·전체5회 구현 검토·출시를 PASS로 선언하지 않는다.
