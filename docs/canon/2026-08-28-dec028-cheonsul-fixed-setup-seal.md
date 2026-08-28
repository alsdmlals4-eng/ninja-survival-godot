# DEC-028 — 천술류 고정 청색 준비 결계

```yaml
decision_id: DEC_028
status: APPROVED_PRODUCT_INTENT_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
depends_on: DEC_027
owner: docs/canon/2026-08-28-dec028-cheonsul-fixed-setup-seal.md
implementation_reality: NO_PLAYER_OWNED_SETUP_SEAL_IMPLEMENTED
human_player_evidence: NOT_RUN
```

## 1. 결정

천술류의 읽을 수 있는 공간 조건은 **짧게 남는 고정 청색 준비 결계**다. 자동 `WET` 시전은 그 시전 지점에 결계를 남기고, 플레이어는 이동으로 적을 결계 안으로 유도한다. 다음 자동 `SHOCK`은 결계 안의 준비된 `WET` 군집을 우선 대상으로 삼아 호박·주황의 고가치 연쇄 반응을 낸다.

## 2. Player Promise

`안전선 선택 → 청색 결계에 적 유도 → WET 준비 확인 → 자동 SHOCK 연쇄 → 궁극기 결산`.

플레이어의 성공은 직접 주문을 누른 사실이 아니라, 위험한 적 군집을 짧은 고정 결계 안에 만들고 그 결과를 눈으로 확인한 사실에서 온다.

## 3. 채택 이유

- 기존 `telegraphed_zone`의 **보이는 경계 + 종료 cue** 언어와 시전 지점의 `FlameFieldVisual` 소비처를 후속 구현에서 제한적으로 `ADAPT`할 수 있다.
- 군집 수치만 숨겨 판단하게 하는 방식보다 반응의 원인·범위·만료를 읽기 쉽다.
- 플레이어 추종 오라보다 유도 경로와 위험 회피를 유지하며, 귀인류의 근접 체류 정체성과 겹치지 않는다.

## 4. 보호 규칙

- 결계는 플레이어에게 피해를 주는 적 장판과 혼동되지 않아야 한다. 청색 준비, 상태 아이콘, 명확한 경계/만료 cue로 구분한다.
- 결계는 자동전투의 보조 조건이며, 별도 조준·반응 버튼·새 자원 UI·유파 전용 조작을 만들지 않는다.
- 일반 `WET → SHOCK` 자동전투가 전부 무효화되는 구조를 만들지 않는다. 결계는 **고가치 군집 연쇄의 우선 조건**이다.
- 정확한 지속 시간, 반경, 군집 임계값, 피해/충전 보정은 이 결정에서 고정하지 않는다.
- 작은 아이콘, 피격 직후 적 하나만 보이는 HP 바, 청색 + 호박/주황 천술 색 문법을 유지한다.

## 5. 구현·검증 경계

- 현재 `CheonsulRuntime.FLAME_RADIUS = 90.0` 및 `FIELD_VISUAL_DURATION = 0.60`의 `FlameFieldVisual`은 기존 화염 시각 효과다. 이를 DEC-028의 청색 준비 결계로 자동 승격하거나 수치를 재사용했다고 주장하지 않는다.
- 현재 자동 `SHOCK`의 `WET` 우선 타기팅은 결계 안 군집 우선 규칙을 구현하지 않는다.
- 구현은 Phase 1의 나머지 제품 결정을 마친 뒤, 단일 구현계약의 Godot Scene/Node/Resource/data/테스트 범위로만 시작한다.
- Human Slice는 플레이어가 첫 30초 안에 결계의 목적·만료·고가치 반응 조건을 말할 수 있는지, 적 장판과 혼동하지 않는지, 적 유도를 위해 실제로 위험과 보상을 교환하는지를 관찰한다.

## 6. Revisit conditions

- 청색 결계가 적 위험 장판으로 반복 오인된다.
- 결계가 보이지만 적 유도와 연쇄 결과의 차이가 체감되지 않는다.
- 결계가 화면을 과밀하게 하거나 위험 텔레그래프를 가린다.
- 플레이어 추종 오라 또는 단순 군집 조건이 Human evidence에서 훨씬 더 명확하게 판명된다.

## 7. 적대적 검토 — 전체 범위 5회

1. **Player authorship:** 고정 결계가 이동·유도의 원인과 반응 결과를 연결하지만, 첫 30초 안에 그 관계를 말할 수 있는지는 아직 `NOT_RUN` Human Slice로 검증해야 한다.
2. **Auto-combat integrity:** 결계는 자동 시전의 결과와 다음 자동 `SHOCK`의 우선순위만 바꾸며, 직접 조준·반응 입력·자원을 추가하지 않는다.
3. **Four-school differentiation:** 짧게 만료되는 준비 구역은 봉마류의 지속 거점이나 귀인류의 추종 근접 오라가 아니다. 적을 통과시켜 유도할 때만 천술류의 이득이 생긴다.
4. **Visual/readability:** 플레이어 소유 청색 결계, 적의 위험 텔레그래프, 청색 `WET`/호박·주황 연쇄, 아이콘 상태, 피격 적 하나의 HP 공개가 서로 다른 의미를 지녀야 한다. 실제 크기·혼동 여부는 `NOT_RUN`이다.
5. **Scope/evidence:** 기존 `telegraphed_zone`과 `FlameFieldVisual`은 후속 구현 참고로만 `ADAPT`한다. 수치·Scene·runtime·asset·Human/Player PASS를 이 문서가 주장하지 않으며, 남은 Phase 1 결정 뒤 단일 구현계약에서 재검증한다.
