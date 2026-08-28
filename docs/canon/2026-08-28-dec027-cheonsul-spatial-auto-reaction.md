# DEC-027 — 천술류 공간 유도형 자동 반응

```yaml
decision_id: DEC_027
status: APPROVED_PRODUCT_INTENT_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec027-cheonsul-spatial-auto-reaction.md
implementation_reality: CURRENT_RUNTIME_REMAINS_AUTOMATIC_WET_SHOCK_TARGETING
human_player_evidence: NOT_RUN
```

## 1. 결정

천술류의 기본 자동전투를 유지한다. 다만 강한 연쇄 반응은 단순한 자동 타기팅 결과가 아니라, 플레이어가 이동으로 적을 모아 만든 **읽을 수 있는 공간 조건**에서 우선적으로 발생해야 한다.

플레이어의 대표 행동은 `안전한 이동선 선택 → 적 군집 형성 → 자동 상태 준비 → 공간 조건 안의 강한 반응 확인 → 궁극기 결산`이다.

## 2. 채택 및 기각

### 채택 — 공간 유도형 자동 반응

- `WET → SHOCK`의 자동전투 리듬은 보존한다.
- 플레이어는 개별 주문을 직접 조준하거나 순서를 누르지 않는다.
- 자동 `SHOCK`은 플레이어가 만든 공간 조건 안의 준비된 군집을 우선 대상으로 삼아, 그 조건을 읽을 수 있는 고가치 연쇄 결과를 낸다.
- 청색은 준비된 공간/상태, 호박·주황은 반응의 결과를 표현한다. 지속 단어 배지 대신 작은 상태 아이콘을 사용한다.

### 기각 — 직접 발동형 반응

별도 반응 버튼, 조준 reticle, 쿨다운 조작은 첫 Slice에서 도입하지 않는다. 수동 입력·터치·게임패드 조준 부담이 자동전투의 접근성과 범위를 과도하게 바꾼다.

### 기각 — 완전 자동 유지

현재처럼 시스템이 상태 적용, 반응 대상 선택, 연쇄 결과까지 모두 결정하는 상태를 최종 Player Promise로 채택하지 않는다. 이는 천술류를 일반적인 자동 화력으로 읽히게 할 위험이 있다.

## 3. 아직 결정하지 않은 구현 규칙

- 공간 조건의 정확한 형태: 짧은 고정 결계, 군집 밀도, 또는 다른 명시적 영역 규칙.
- 조건의 지속 시간, 반응 반경, 군집 임계값, 피해/궁극기 충전 수치.
- Core / Elite / Boss에서 조건을 강화·변주하는 정확한 방식.
- 실제 화면 크기에서의 아이콘, 청색 준비 신호, 호박·주황 반응 신호의 가독성과 접근성 안내.

이 값과 표현은 다음 제품 결정 및 Human Usability/Player Experience 검증 전까지 정본 값이 아니다.

## 4. 구현 및 검증 경계

- 현재 `CheonsulRuntime`은 1.8초 간격으로 `WET`/`SHOCK`을 교대 자동 발동하고, `SHOCK`은 기존 `WET` 적을 우선한다. 이것은 구현 사실이며 DEC-027이 이미 구현되었다는 증거가 아니다.
- 이번 결정은 T12~T16 machine-scope, Route/Trace/Workbench authority, 자동전투 기본 입력, 전투 수치에 변경을 가하지 않는다.
- 구현은 Phase 1 기획과 Visual Direction 후속 검토가 끝난 뒤 별도 GitHub Issue, Definition of Ready, TDD 및 Human Slice 검증 패키지로만 시작한다.
- Human 검증은 첫 30초 안에 플레이어가 “적을 모아 청색 준비를 만들고, 다음 반응을 크게 터뜨렸다”고 설명할 수 있는지, 안전선과 군집 기회를 실제로 교환하는지, 아이콘/텔레그래프가 위험을 가리지 않는지를 확인한다.

## 5. 재검토 조건

- 플레이어가 이동해도 반응의 대상·결과 차이를 인지하지 못한다.
- 공간 조건을 만들기 위해 이동하는 것이 생존 위험 또는 보상과 의미 있게 맞물리지 않는다.
- 자동전투의 가독성·접근성을 잃거나 다른 유파와 조작 언어가 불필요하게 분리된다.

## 6. Adversarial review — 5 whole-scope loops

1. **기능 목록으로만 이해했는가:** 반응 자동화 자체가 재미라는 주장을 기각했다. 공간 조건을 만든 이동과 고가치 연쇄 결과의 인과가 Player Promise의 필수 계약이다.
2. **자동전투 정체성을 훼손하는가:** 별도 조준·반응 버튼·쿨다운 체인을 기각했다. 이동, 적 군집, 기존 자동전투, 궁극기라는 현재 입력 문법을 유지한다.
3. **새 엔진을 발명하는가:** 기존 상태·타기팅·연쇄 시스템의 목표 우선순위와 표현을 조정하는 후속 범위로 제한했다. 새 유파 전용 엔진·자원 UI·공간 규칙을 승인하지 않는다.
4. **시각 문법과 충돌하는가:** 청색 준비/호박·주황 결과, 작은 상태 아이콘, 최근 피격 적 하나의 HP 표시 원칙을 유지한다. 보라/검정 천술 상태, 지속 텍스트 배지, 상시 HP 바를 기각한다.
5. **증거와 구현을 혼동하는가:** 현재 자동 타기팅 코드와 planning board를 각각 implementation fact와 reference-only visualization으로 분리했다. Human Usability, Player Experience, runtime render, device/export는 모두 `NOT_RUN`이다.
