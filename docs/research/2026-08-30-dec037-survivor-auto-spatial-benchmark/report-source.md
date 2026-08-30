# DEC-037 사전 벤치마크 — 자동전투·서바이버·공간 백팩 역공학

```yaml
research_id: RES-2026-08-30-DEC037-SURVIVOR-AUTO-SPATIAL
status: RESEARCHED_NOT_PRODUCT_DECISION
requested_by: USER
observed_at: 2026-08-30_KST
scope: "DEC-037 구현 재개 전, 인접 장르 12종의 구조적 역공학"
authority_boundary: "EVIDENCE_AND_RECOMMENDATION_ONLY"
product_authority:
  - docs/CURRENT_CONFIRMED_DECISIONS.md
  - docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md
  - docs/ACTIVE_CONTEXT.md
implementation_authority:
  - scripts/player/player_controller.gd
  - scripts/backpack/backpack_state.gd
  - scripts/core/rest_commit_coordinator.gd
  - scripts/core/school_circuit_controller.gd
not_evidence_for:
  - Human_Usability
  - Player_Experience
  - device_export
  - runtime_balance
```

## 0. 결론 먼저

이번 조사는 현재 제품 방향을 교체할 근거를 찾지 못했다. 오히려 다음의 현재 방향이 자동전투 서바이버 장르와 공간 빌드 장르의 강점을 함께 취하는 조합임을 확인했다.

```text
직접 조작하는 한 명의 닌자
-> 자동 공격과 유파 효과
-> 이동 · 2회 충전 대시 · 위험 회피로 만드는 전투 기여
-> Elite / Trace / Boss라는 읽히는 Stage 관문
-> 전투 밖 REST Workbench의 3×3 시작 공간 · 회전 · 인접 · 조합 판단
-> 미리보기에는 전투력 0, Fate 때 백팩 + Fate + 다음 Stage를 원자적으로 확정
```

따라서 이번 조사 결과는 **새 시스템 추가 지시가 아니라**, 현재 DEC-037을 구현·검수할 때 지켜야 할 품질 기준이다.

- 자동 공격을 수동 스킬바로 되돌리지 않는다.
- 3×3 시작과 6×6 기술 상한을 혼동하지 않는다.
- Trace는 즉시 화력 보상이 아니라 진행 관문으로 유지한다.
- Ninja Soul을 즉시 영구 전투력으로 바꾸지 않는다.
- Workbench의 미리보기와 Fate 확정 경계를 흐리지 않는다.
- 다른 게임의 이름·캐릭터·미술·UI·수치·서사·아이템 조합을 복제하지 않는다.

이 문서는 사실과 프로젝트 적용 추론을 분리한다. `ADOPT`는 이미 승인된 구조를 강화하는 근거, `ADAPT`는 후속 작은 패키지에서만 검토할 표현 원칙, `TEST`는 실제 플레이 검증 전에는 확정하지 않는 가설, `REJECT`는 현 제품에서 배제할 참조 구조를 뜻한다.

## 1. 조사 질문과 보호 경계

### 조사 질문

> 자동공격형 닌자 서바이벌에서, 플레이어가 조작하는 대상과 전투 기여가 명확히 읽히면서도 3×3부터 커지는 공간 백팩·유파 조합·Trace·Fate가 단순한 장식이 되지 않게 하려면 무엇을 채택하고 무엇을 피해야 하는가?

### 이미 승인되어 이번 조사로 변경하지 않는 것

| 보호 경계 | 현재 제품 규칙 | 이번 조사에서의 취급 |
|---|---|---|
| 전투 주체 | 고정된 한 명의 닌자를 직접 움직인다. 공격과 유파 효과는 자동이다. | `ADOPT`의 전제 |
| HUD | 상단에는 대시 충전, 플레이 시간, Stage/Phase, 설정을 중심으로 보인다. 하단 수동 스킬바는 두지 않는다. | `ADOPT`의 전제 |
| 가방 | 기술 보드는 6×6, 플레이어 시작 사용 공간은 정확히 중앙 3×3이며 확장으로 넓어진다. | `ADOPT`의 전제 |
| 빌드 권위 | 아이템은 합법 배치·해결·Fate 원자 커밋 뒤에만 전투력에 반영된다. 미리보기는 전투력 0이다. | `ADOPT`의 전제 |
| Run 흐름 | 학교 전장 → Core → Elite → Trace → Boss → Result/Workbench → 다음 미방문 학교다. | `ADAPT`의 기준 |
| 영구재화 | Ninja Soul은 Run 밖에 남고 현재 정본의 정산/재도전 경계를 따른다. | 직접 전투 스탯화는 `REJECT` |

이 표의 제품 규칙은 외부 출처가 아니라 현재 프로젝트 정본에서 온다. 외부 사례는 이 규칙의 품질과 위험을 비교하기 위한 용도다.

## 2. 방법·증거 한계

1. 자동전투 생존, 이동/대시, 보스·목표 관문, 공간 인벤토리, 자동 전투 빌드, 경로 선택, 메타 진행을 축으로 나눴다.
2. 출시사·개발사의 공식 Steam 제품 페이지 또는 공식 웹사이트를 우선 읽었다. 접근일은 `2026-08-30 KST`다.
3. 제품 페이지가 말한 기능만 `관찰 사실`로 적었다. 해당 기능이 본 프로젝트에 적합하다는 문장은 `프로젝트 추론`이다.
4. 스토어 페이지는 설계 의도와 공개 기능에는 강하지만, 실제 드롭률·정확한 입력 반응·장기 밸런스·인간 UX를 증명하지 못한다. 이 한계는 아래 `TEST`로 남긴다.
5. 최소 10종 요구보다 넓게 12종을 상호 대조했다. 기존 [MVP-4 백팩/서바이버 조사](../2026-08-11-mvp4-backpack-survivors-benchmark.md)는 4×3 역사 기준의 콘텐츠·마찰 연구이고, 본 문서는 DEC-037의 **3×3 공개 경험·직접 이동·Stage/Phase**에 대한 별도 선행 조사다.

## 3. 12종 역공학 매트릭스

| # | 비교 게임 · 1차 출처 | 관찰 사실 | 구조적으로 읽은 강점/위험 | 닌자의 신 처리 |
|---:|---|---|---|---|
| 1 | [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | 시간 생존·로그라이트를 표방하며, 매 Run의 금으로 다음 생존자 업그레이드를 산다고 설명한다. 마우스·키보드·컨트롤러·터치를 지원한다. | 짧은 입력 문법에서도 생존 위치와 성장 선택을 반복시키는 대표 구조다. 단순한 단일 타이머가 정체성이 되기 쉽다. | 이동 기여와 접근성 문법은 `ADOPT`; 20~30분 단일 생존 타이머/고딕 표면은 `REJECT`. |
| 2 | [Brotato](https://store.steampowered.com/app/1942280/Brotato/) | 무기가 기본적으로 자동 발사되고, 20~90초 웨이브·웨이브 사이 상점·재료/경험치 수집을 명시한다. | 자동 공격에서도 위치와 짧은 보상 판단을 분리한다. 그러나 고정 웨이브 상점이 리듬을 지배할 수 있다. | 전투 중 자동 공격과 전투 밖 판단 분리는 `ADOPT`; 매 웨이브 강제 상점은 `REJECT`. |
| 3 | [Halls of Torment](https://store.steampowered.com/app/2218750/Halls_of_Torment/) | 캐릭터·특성·능력·아이템으로 Run 빌드를 만들고, 고유 패턴 보스, 30분 Run, 이후 Run에 영향을 주는 아이템/해금 요소를 제시한다. | 보스의 고유 패턴과 빌드 조합의 결합은 강점이다. 긴 타이머와 복수 클래스는 이 게임의 비용이다. | 보스 텔레그래프와 빌드 읽기성은 `ADAPT`; 30분 타이머/클래스 대량 확장은 `REJECT`. |
| 4 | [Deep Rock Galactic: Survivor](https://store.steampowered.com/app/2321470/Deep_Rock_Galactic_Survivor/) | 혼자 움직이고 채굴하며 자동 사격하는 서바이버라이크로, 절차형 동굴·웨이브·목표·탈출을 제시한다. | 자동 사격은 직접 이동, 위치 선정, 목표 우선순위와 공존할 수 있다. 채굴·추출은 게임의 별도 목적 계층이다. | 자동전투+직접 이동의 역할 분리는 `ADOPT`; 채굴/탈출/절차형 동굴은 `REJECT`. |
| 5 | [Death Must Die](https://store.steampowered.com/app/2334730/Death_Must_Die/) | 축복·시너지·무작위 고유 아이템과, 강한 보상에 적의 위험 증가가 맞물리는 선택을 소개한다. | 좋은 보상은 위험 또는 기회비용과 연결될 때 더 읽힌다. 개별 신/축복 서사는 이 제품의 고유 표면이다. | Boss/Workbench 보상의 기회비용 언어는 `ADAPT`; 신/축복/유물 서사와 정확한 대시 수치는 `REJECT`. |
| 6 | [Soulstone Survivors](https://store.steampowered.com/app/2066020/Soulstone_Survivors/) | 350개 이상 스킬, 무기·스킬트리·대형 보스를 전면에 둔다. | 콘텐츠 폭은 반복성의 한 방법이지만, 초기 가독성과 밸런스/제작 비용을 급격히 키운다. | 보스 다양성의 필요성만 `REFERENCE`; 대량 스킬 카탈로그는 `REJECT`. |
| 7 | [God of Weapons](https://store.steampowered.com/app/2342950/God_Of_Weapons/) | 자동 무기, 회피·전리품, 제한된 인벤토리에 무기/장신구를 맞추는 전략적 정리를 핵심으로 소개한다. | 자동전투와 제한 공간은 서로 잘 맞지만, 공간이 단순 정리 업무가 되면 실패한다. | 제한 공간을 판단으로 만드는 원칙은 `ADOPT`; 아이템·UI 표현 복제는 `REJECT`. |
| 8 | [Backpack Hero](https://store.steampowered.com/app/1970580/Backpack_Hero/) | 소지품 자체보다 가방 안의 배치가 성능에 영향을 준다고 설명하며, 아이템 시너지·서로 다른 플레이스타일을 제시한다. | 배치는 보상 소비가 아니라 빌드 언어여야 한다. 과도한 아이템 수는 초반 독해 비용을 만든다. | 회전·인접·조합의 읽기성을 `ADOPT`; 방대한 아이템 풀과 마을 재건은 `REJECT`. |
| 9 | [Backpack Battles](https://store.steampowered.com/app/2427700/Backpack_Battles/) | 아이템 구매/제작/배치 뒤 자동 전투하며, 모양·크기·가격·희귀도와 조합을 명시한다. | 준비 단계의 배치 판단과 전투 결과를 분리해 피드백을 선명하게 만든다. PvP 카운터는 별도 문제다. | Workbench의 명확한 배치-결과 연결은 `ADAPT`; PvP/상대 카운터 메타는 `REJECT`. |
| 10 | [Megaloot](https://store.steampowered.com/app/2440380/Megaloot/) | 인벤토리 로그라이크 빌드와, 아이템을 버리면 전설적 힘을 얻는 변환을 전면에 둔다. | 보상 처분을 즉시 능력치로 바꾸면 가방의 공간 기회비용이 약해질 수 있다. | 공간 빌드 관찰은 `REFERENCE`; 폐기→즉시 전투력 환산은 `REJECT`. |
| 11 | [Rogue: Genesia](https://store.steampowered.com/app/2067920/Rogue_Genesia/) | 강적 경로와 상점 휴식 경로 중 하나를 고르게 하며, 300+ 패시브·50+ 무기를 제시한다. | 다음 경로를 위험/보상/휴식의 언어로 예고하면 선택이 읽힌다. 과잉 업그레이드는 방향성을 희석할 수 있다. | Workbench의 다음 학교 예고를 철학/위험/접근 패키지로 읽게 하는 원칙은 `ADAPT`; 노드월드와 대량 풀은 `REJECT`. |
| 12 | [Scarlet Tower](https://store.steampowered.com/app/2181720/Scarlet_Tower/) | 낮/밤, 밤 전용 상인·유물, 날씨 이벤트, 다수 무기/패시브와 보스를 소개한다. | 시간대가 콘텐츠 가용성과 긴장을 바꾸는 방식은 풍부하지만, 여러 축이 겹치면 핵심 Stage 리듬을 흐릴 수 있다. | 시간대에 따른 긴장 변화는 `REFERENCE`; 낮밤/날씨/상인 계층은 `REJECT`. |

### 비교 해석의 주의

- 위 12개 중 일부는 순수 서바이버라이크가 아니라 공간 인벤토리·자동 전투·로그라이트 선택 축을 제공하는 인접 장르다. 그래서 표면 장르가 아니라 **플레이어가 언제 무엇을 판단하는가**만 역공학했다.
- 공식 페이지의 “많은 무기/스킬” 수치는 해당 게임의 마케팅 사실이지, 이 프로젝트의 콘텐츠 목표가 아니다.
- “대시 2회”는 외부 공통 표준이 아니다. 현재 DEC-037 수치를 유지하되, 실제 Boss/Elite 텔레그래프에 충분한 대응 창이 있는지 직접 시험해야 한다.

## 4. 비교 결과를 현재 제품에 번역한 규칙

### 4.1 ADOPT — 현재 승인 구조를 구현·검수에서 강화

1. **자동공격 + 명확한 이동 기여**
   플레이어가 조작하는 것은 항상 화면의 한 닌자다. 공격은 자동으로 발생하되, 생존 결과에는 위치, 적과의 거리, 위험 우선순위, 대시 충전 사용이 실질적으로 영향을 줘야 한다. 따라서 상단 HUD의 `DASH / PLAY / STAGE · PHASE / 설정`은 유지한다.

2. **전투와 Workbench를 분리한다.**
   가방 회전·인접·조합·경로/Fate 결정은 전투 중이 아니라 Result/REST에서 집중한다. 자동전투일수록 이 짧은 결단 창의 원인과 결과가 선명해야 한다.

3. **3×3은 튜토리얼 문구가 아니라 실제 압력이다.**
   첫 1~2개 보상부터 회전/인접/확장 중 하나를 판단하게 하되, 시작부터 6×6 전체를 사용하게 하지 않는다. 보드는 6×6 기술 경계를 유지하되 플레이어가 읽는 첫 공간은 정확히 3×3이다.

4. **Trace와 전투 보상을 분리한다.**
   Trace는 Elite 이후 Boss로 가는 비소멸 진행 관문·유파 접근의 근거이고, 오브/아이템/골드 같은 즉시 화력 보상으로 바꾸지 않는다.

5. **Fate 이전의 미리보기는 권위를 갖지 않는다.**
   Workbench에서 보여 주는 배치·다음 학교·Fate 후보는 결정을 돕지만, `BackpackState → BackpackResolver → RestBackpackSession/CombinationResolver → RunBuildState → combat`의 커밋 경계를 우회하지 않는다.

6. **Ninja Soul은 공간 판단을 덮지 않는다.**
   현재 정본의 Run 종료 정산 및 1회 재도전 비용 경계를 유지한다. 나중에 영구 사용처를 넓힐 필요가 생겨도, 즉시 영구 공격력보다는 접근·선택 폭·정보/연습 편의가 공간 빌드의 의미를 보존한다.

### 4.2 ADAPT — 후속 작은 표현 패키지에서만 검토할 원칙

| 대상 | 적용 원칙 | 이번 작업에서 하지 않는 일 |
|---|---|---|
| Stage/Phase | `signature → Core 압력 → Elite → Trace → Boss → Workbench`를 단일 타이머가 아니라 관문과 긴장의 교대로 읽히게 한다. | 새 웨이브 시스템, 외부 게임의 보스/패턴 복사 |
| 대시 | 대시는 단순 이동 가속이 아니라 텔레그래프된 위험에 쓰는 회피 예산으로 보이게 한다. | 대시 횟수·시간·무적·충돌 규칙의 무근거 변경 |
| Workbench 미리보기 | 커밋 전 화면은 `활성 칸`, `인접/조합 변화`, `Fate가 고를 다음 학교`, `미리보기 전투력 0`을 읽게 한다. | 현재 트랜잭션/도메인 권위의 UI 이전 |
| 다음 학교 | 경로 카드는 현재/다음 학교의 위험 처리 철학·접근 패키지를 예고하되, Fate 전에는 확정 결과처럼 보이지 않게 한다. | 노드월드/절차형 지도/새 경로 도메인 추가 |
| 전장 배경 | 무한하게 이어지는 바닥 위에 희소한 등잔·나무·비석을 독립 소품으로 두고, 접지 그림자·이동 정지감을 구분한다. | 다른 게임의 배경/소품/색·구도를 복제하거나 충돌 규칙 변경 |

### 4.3 TEST — 구현 후 실제 증거가 있어야만 결정할 가설

| 가설 | 관찰 방법 | 통과로 오해하면 안 되는 것 |
|---|---|---|
| 자동 공격 중에도 플레이어가 “내가 조작하는 닌자”를 즉시 알아본다. | 처음 보는 플레이어가 이동·대시·자동공격의 주체를 설명할 수 있는지 관찰한다. | HUD 단위 테스트, 정적 스크린샷 |
| 2회 대시는 Elite/Boss 텔레그래프에 대응할 충분한 회피 예산이다. | 위험 패턴에서 대시를 아끼거나 하나를 사용해 회피하는 선택이 실제로 생기는지 런타임 관찰한다. | 충전 수치/쿨다운 자동 테스트 |
| 3×3 시작이 첫 가방 선택의 기회비용을 만들되, “정리만 하느라” 멈추게 하지는 않는다. | 첫 두 보상과 첫 Workbench의 사고 시간·실수 원인을 기록한다. | 보드 경계 단위 테스트 |
| Trace가 보스 관문·유파 접근으로 이해되고, 즉시 화력 보상으로 오해되지 않는다. | Elite→Trace→Boss→Workbench 설명을 플레이어가 자신의 말로 재현하는지 관찰한다. | 라이프사이클 도메인 테스트 |
| Fate 전 미리보기와 커밋 후 전투 권위의 차이를 이해한다. | 같은 화면에서 “아직 확정되지 않은 것”과 “이미 전투력에 반영된 것”을 구분하게 한다. | 원자 커밋 단위 테스트 |
| Ninja Soul이 실패를 줄이는 편의/장기 선택으로 읽히며, 가방 판단을 무효화하지 않는다. | 재도전/정산 화면을 본 뒤 영구재화의 효과를 물어본다. | wallet 파일 저장 테스트 |

### 4.4 REJECT — 현재 패키지에서 의도적으로 하지 않을 것

- 수동 공격/하단 스킬바/조준 빌드로 자동전투의 책임을 UI에 되돌리는 것.
- 3×3 공개 규칙을 6×6 전체 시작으로 바꾸거나, 반대로 6×6 기술/확장 구조를 폐기하는 것.
- PvP 카운터빌드, 채굴·추출, 절차형 노드월드, 낮밤·날씨 경제, 복수 주인공/신 서사, 대규모 스킬·아이템 카탈로그.
- 아이템 폐기·Trace·Ninja Soul을 즉시 공짜 전투력으로 환산해 공간 판단과 Boss 관문의 의미를 없애는 것.
- Fate 이전의 미리보기 결과를 전투에 반영하거나, UI가 도메인 소유권을 가져가는 것.
- 타 게임의 고유 명칭·미술·아이콘·HUD 레이아웃·수치·드롭률·보스 동작을 복제하는 것.

## 5. 현재 Godot 구조에 대한 구현 적합성 판정

| 확인 항목 | 현재 구현 근거 | 적합성 판정 | 이유 / 롤백 경계 |
|---|---|---|---|
| 직접 이동·대시 | `PlayerController`는 `CharacterBody2D`에서 입력 벡터를 읽고 `move_and_slide()`로 이동하며, 2회 충전·0.20초·3배 속도·1.5초 재충전을 가진다. | `FEASIBLE` | 새 조작 엔진이 필요 없다. 수치·충돌 감각은 Human/runtime 검증 전 `TEST`다. |
| 상단 자동전투 HUD | `HUDController`와 `StagePhasePresentation`이 별도 표현 경계를 갖고, DEC-037은 하단 수동 스킬바를 제외한다. | `FEASIBLE` | 표현만 바꾸더라도 전투/유파 권위를 HUD로 옮기지 않는다. |
| 3×3에서 6×6 확장 | `BackpackState`의 보드 상한은 `6×6`이고, 시작 가방의 활성 칸으로 실제 배치 가능 영역을 판정한다. | `FEASIBLE` | 현재 데이터/검증 경계를 통해 회전·인접·활성 칸을 유지한다. |
| 미리보기와 원자 커밋 | `RestCommitCoordinator`가 session·Fate·route 검증을 통과한 뒤 백팩 modifier, route, Fate를 한 번에 확정한다. | `FEASIBLE` | 새로운 저장/메타 시스템을 만들지 않고, 중간 UI 표현은 후보 상태를 유지한다. |
| Ninja Soul | `NinjaSoulWallet`은 지속 저장과 재도전 비용을 분리한다. 정산의 더 넓은 의미는 해당 canon/ledger가 소유한다. | `FEASIBLE_WITH_SCOPE_GUARD` | 새로운 영구 스탯 트리를 추가하지 않는다. 영구 사용처 확대는 별도 제품 결정이 필요하다. |
| Stage 관문 | `SchoolCircuitController`, `StageEncounterState`, `StageFlowController`, `CheonsulVerticalSliceController`가 이미 학교/Stage/전투 흐름의 소비처를 제공한다. | `FEASIBLE_WITH_RUNTIME_TEST` | 관문 가독성과 보스 공정성은 코드 존재만으로 증명되지 않는다. |

### Godot 문서 대조

현재 `CharacterBody2D`의 top-down 이동 방식은 Godot의 [2D movement overview](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html) 및 [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) 문서가 안내하는 `Input.get_vector()` + `move_and_slide()` 흐름과 호환된다. HUD/선택 화면의 일시정지 처리도 [process mode / pausing 문서](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html)의 노드 처리 모드 경계 안에서 구현 가능하다. 이는 **엔진 적합성** 근거일 뿐 실제 조작감·접근성·렌더 품질 검증은 아니다.

## 6. 증거 갭 매트릭스와 다음 안전 작업

| 주장 | 현재 증거 | 빠진 증거 | 다음 안전 작업 | 현재 상태 |
|---|---|---|---|---|
| 자동전투와 직접 이동의 조합은 장르적으로 타당하다. | 12종의 1차 제품 설명 + 현재 입력/대시 코드 | 이 게임에서의 인간 가독성·재미 | 첫 플레이 Human observation | `RESEARCHED`, Human `NOT_RUN` |
| 3×3 시작이 실제 공간 판단을 만든다. | DEC-037 + `BackpackState` 구조 + 공간 빌드 비교 | 첫 두 보상에서의 실제 선택/피로 | focused runtime + 관찰 테스트 | `SPECIFIED`, UX `NOT_RUN` |
| Trace/Fate 경계는 좋은 장기 선택을 만든다. | canon + 트랜잭션 구조 + 인접 장르의 선택 분리 | 플레이어의 원인-결과 이해 | Result/Workbench 이해도 테스트 | `IMPLEMENTED_PARTIAL`, Human `NOT_RUN` |
| 2회 대시가 공정한 위험 대응 예산이다. | 현재 수치/입력 구현 | Boss/Elite 패턴별 대응 시간, 피격 체감 | 대표 패턴별 런타임 검증 | `IMPLEMENTED`, balance `NOT_RUN` |
| Ninja Soul이 공간 빌드를 지배하지 않는다. | 현재 retry wallet 경계 + canon 정산 규칙 | 장기 메타 해금이 도입됐을 때의 경제 영향 | 별도 메타 제품 결정과 실험 | `SCOPE_GUARDED`, no expansion |

다음 구현 패키지에서의 순서는 다음처럼 제한한다.

```text
현재 DEC-037 구현 소비처와 테스트 재확인
-> 자동 공격 / 이동 / 대시 / Stage·Phase 화면의 기계 검증
-> Workbench 미리보기와 Fate 커밋 경계 회귀 검증
-> 이후 별도 Human/Player 관찰 gate
```

이 보고서는 위 순서에 **새 기능을 추가하지 않는다**. 특히 대시 수치, 영구재화 사용처, Stage 타이밍, 보상 가중치 변경은 관찰 근거 없이 수행하지 않는다.

## 7. 적대적 전체 범위 재검토 — 5회

아래 검토는 이 보고서가 제품 결정을 몰래 바꾸거나, 외부 게임을 표면적으로 복사하거나, 코드 존재를 UX 증거로 과장하지 않는지 다시 공격한 결과다. 각 발견은 현재 정본·소스·출처 범위를 다시 대조한 뒤에만 반영했다.

| 회차 | 전체 범위 공격 | 확인 결과 | 교정 / 유지 |
|---:|---|---|---|
| 1 | “장르 벤치마크”가 수동 스킬·새 웨이브·노드월드 같은 범위 확장으로 변질되는가? | 현 DEC-037의 직접 이동 + 자동공격 + Stage/Phase와 충돌한다. | `REJECT`에 수동 스킬바·새 웨이브·노드월드를 명시하고, 보고서를 근거 문서로 한정했다. |
| 2 | Trace·Ninja Soul·보상 구조가 외부 게임의 즉시 성장 문법 때문에 기존 권위를 잃는가? | Trace의 비전투 진행성과 Fate 원자 경계, Ninja Soul의 현재 정산/재도전 경계가 보호되어야 한다. | 즉시 화력 환산을 `REJECT`, 영구 사용처 확대를 별도 제품 결정으로 분리했다. |
| 3 | UI 표현 권고가 `BackpackState`·resolver·commit coordinator의 권한을 UI로 옮기는가? | 미리보기는 설명일 뿐, 커밋 전 전투 권위를 가지면 안 된다. | `ADOPT`와 적합성 표에 후보/커밋 경계를 다시 명시했다. |
| 4 | 비교 대상의 미술·캐릭터·보스·수치·서사를 그대로 가져오는가? | 출처들은 기능의 존재만 지지하며, 고유 표면을 복사할 권한이나 필요는 없다. | 모든 적용을 구조/가독성/결정 시간으로 제한하고 표면 복제를 `REJECT`했다. |
| 5 | 공식 스토어 설명과 코드 존재를 Human/Player 또는 밸런스 PASS로 과장하는가? | 제품 페이지는 구현 기능, 코드는 기계적 가능성까지만 지지한다. | 증거 갭에 Human/Player·device·balance를 모두 `NOT_RUN`으로 유지했다. |

다섯 회차 모두 새 MUST_FIX를 남기지 않았다. 이는 보고서의 범위·근거·문서 정합성 검토 결과일 뿐, 런타임·플레이어 경험·디바이스 검증의 PASS가 아니다.

## 8. 외부 출처 원장

모든 링크는 공식 개발사/배급사 Steam 제품 페이지 또는 공식 엔진 문서다. 각 출처는 해당 게임의 공개 기능을 확인하는 데만 사용했고, 본 프로젝트의 설계 결론은 본 문서의 해석이다.

1. [Vampire Survivors — poncle / Steam](https://store.steampowered.com/app/1794680/Vampire_Survivors/)
2. [Brotato — Blobfish / Steam](https://store.steampowered.com/app/1942280/Brotato/)
3. [Halls of Torment — Chasing Carrots / Steam](https://store.steampowered.com/app/2218750/Halls_of_Torment/)
4. [Deep Rock Galactic: Survivor — Funday Games / Steam](https://store.steampowered.com/app/2321470/Deep_Rock_Galactic_Survivor/)
5. [Death Must Die — Realm Archive / Steam](https://store.steampowered.com/app/2334730/Death_Must_Die/)
6. [Soulstone Survivors — Game Smithing / Steam](https://store.steampowered.com/app/2066020/Soulstone_Survivors/)
7. [God of Weapons — Imagine Games / Steam](https://store.steampowered.com/app/2342950/God_Of_Weapons/)
8. [Backpack Hero — Jaspel / Steam](https://store.steampowered.com/app/1970580/Backpack_Hero/)
9. [Backpack Battles — PlayWithFurcifer / Steam](https://store.steampowered.com/app/2427700/Backpack_Battles/)
10. [Megaloot — axilirate / Steam](https://store.steampowered.com/app/2440380/Megaloot/)
11. [Rogue: Genesia — Ouadi Huard / Steam](https://store.steampowered.com/app/2067920/Rogue_Genesia/)
12. [Scarlet Tower — Pyxeralia / Steam](https://store.steampowered.com/app/2181720/Scarlet_Tower/)
13. [Godot 2D movement documentation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
14. [Godot CharacterBody2D documentation](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
15. [Godot pausing and process modes documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html)

## 9. 기록 상태

```yaml
research_complete: true
games_compared: 12
current_product_direction_replaced: false
new_product_decision_created: false
new_runtime_feature_authorized: false
runtime_modified_by_this_research: false
machine_validation_by_this_research: NOT_RUN
human_validation_by_this_research: NOT_RUN
recommended_follow_up: "DEC-037 기존 구현 범위의 기계 검증 후, 별도 Human/Player 관찰 gate"
```
