# CURRENT_CONFIRMED_DECISIONS

> 현재 승인된 제품/설계 결정을 기록하는 프로젝트 정본이다.
> 오래된 Roadmap/AGENTS 설명과 충돌하면 **최신 사용자 승인과 이 문서의 최신 항목**을 우선하고, 이후 관련 문서를 동기화한다.
> 구현 완료 상태를 뜻하지 않는다. 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`가 소유한다.

Last updated: 2026-08-10
Project baseline observed before this document branch: `main@7ef8eeaec1e5e4bad65a7bf00061274b60641e6a`

## MVP-4 — Backpack / Combination Basics

Status: `DESIGN_IN_PROGRESS / IMPLEMENTATION_NOT_STARTED`

### Board and usable-space model

- 전체 배치 보드는 `6 x 6 = 36 cells` 고정이다.
- 시작 사용 가능 공간은 기본 닌자 가방이 제공하는 `4 x 3 = 12 cells`이다.
- 가방을 구매/배치해 사용 가능 공간을 늘린다.
- 새 가방은 기존 사용 가능 공간과 상하좌우 변으로 최소 1칸 이상 연결되어야 한다.
- 사용 가능 공간 전체는 항상 하나의 4-neighbor connected component를 유지한다.
- 가방끼리는 겹칠 수 없다.
- 아이템은 가방이 제공하는 활성 셀 위에만 배치할 수 있다.
- 가방 레이어와 아이템 레이어는 분리한다.

### Movement and rotation

- 가방과 아이템 모두 90도 단위 회전 가능하다.
- 비정사각형 직사각형 아이템은 회전으로 `1x2 ↔ 2x1`, `1x3 ↔ 3x1`, `2x3 ↔ 3x2` 등이 된다.
- 일반 아이템은 MVP-4에서 직사각형 중심으로 유지한다.
- 가방은 일부 L/T형 비정형 형태를 허용한다.
- 방향키는 현재 모든 가방+배치 아이템의 상대 배치를 유지한 채 전체 묶음을 1칸 이동한다.
- 전체 이동/회전 결과가 보드 밖, 충돌, 비활성 셀, 연결성 파괴를 만들면 전체 조작을 취소한다.
- 휴식 구간에서만 백팩 편집/회전을 허용한다.

### Item size and effect budget

Recommended MVP-4 budget table:

| occupied cells | base effect budget |
|---:|---:|
| 1 | 1.0 |
| 2 | 2.1 |
| 3 | 3.3 |
| 4 | 4.6 |
| 6 | 7.2 |

- 큰 아이템은 배치가 어렵지만 칸당 기본 효율이 조금 높다.
- 크기와 모양은 분리한다. 같은 면적이면 기본 예산은 같고 공간적 가치가 달라진다.
- 조합 결과물은 원본 둘을 실제 백팩에 배치/인접시키는 비용을 지불하므로 일반 크기 예산 상한의 예외가 될 수 있다.
- 현재 조합 결과 예산은 원본 합계 대비 약 `+12%` 프리미엄을 권장값으로 둔다.

### Adjacency and special-bag overlap

- 아이템-아이템 인접은 상하좌우 변 공유만 인정한다. 대각선은 제외한다.
- 같은 아이템 쌍의 같은 시너지는 접촉 변 개수와 관계없이 1회만 계산한다.
- 서로 다른 이웃과의 관계는 각각 계산한다.
- 특수 가방은 아이템이 그 가방 영역에 **1칸만 걸쳐도** 효과를 1회 적용한다.
- 하나의 아이템이 서로 다른 여러 특수 가방에 걸치면 각 가방 효과를 모두 적용한다.
- 같은 종류 특수 가방도 서로 다른 인스턴스면 중첩 가능하다.
- 특수 가방 효과는 아이템 본체보다 작은 보조 예산(대략 0.4~0.6)을 기본 가이드로 둔다.

### Backpack editing UX

- 기본 편집 모드에서 아이템/가방 모두 드래그 가능하다.
- 가방 하나를 집으면 그 가방과 최소 1칸 겹친 아이템을 같이 이동 후보로 든다.
- 해당 아이템이 다른 가방에도 걸쳐 있어도 다른 가방까지 연쇄 이동시키지 않는다.
- 배치 작업은 `Ctrl+Z / Ctrl+Y` Undo/Redo를 제공한다.
- Undo/Redo 대상: 이동, 회전, 배치, 백팩↔작업 버퍼 이동.
- Undo/Redo 제외: 구매, 판매, 버리기, 상자 개봉, 보스 보상 선택, 리롤, 조합 확정, 운명 선택.
- 복잡한 배치 판단은 미리보기로 유효/무효, 인접/특수 가방/조합 가능성을 놓기 전에 보여주는 방향을 사용한다.

### Temporary storage / work buffer

- 임시 보관함은 `6 slots` 카드형 저장이다. 아이템 크기는 슬롯 수에 영향을 주지 않는다.
- 보스 보상, 상자, 상점 구매품이 여기로 들어간다.
- 이미 백팩에 있던 아이템도 휴식 중 잠시 빼서 작업 버퍼로 사용할 수 있다.
- 버퍼에 있는 아이템은 전투 효과, 인접 효과, 특수 가방 효과, 조합 자격이 모두 비활성이다.
- 다음 전투 확정 전에 버퍼는 반드시 `0 items`여야 한다.
- 영구 Storage로 사용하지 않는다.

### Acquisition pillars

아이템 획득은 세 축으로 구성한다.

1. **Boss reward = quality / choice**
   - 각 5분 구간 보스 격파 후 `3 options → choose 1`.
   - 일반 아이템 풀 기반이지만 고가치/조합 핵심재료 가중치를 높인다.
   - 현재 유파와 직접 관련된 후보를 최소 1개 보장한다.
   - 선택 전 REST 진입 불가.

2. **Shop = control / economy**
   - 일반 아이템 후보 `3` + 가방 전용 후보 `1`.
   - 가방은 상점 전용 획득이다.
   - 구매품은 즉시 전투 modifier가 되지 않고 작업 버퍼로 들어간 뒤 유효 배치돼야 활성화된다.
   - 리롤 비용은 기존 `5G → 10G → 15G`를 유지한다.
   - 휴식당 가방 최대 1개 구매를 권장 규칙으로 사용한다.

3. **Chest = quantity / randomness**
   - 전투 중 상자는 즉시 열지 않고 토큰으로 획득한다.
   - REST에서 상자 1개를 열면 랜덤 아이템 2개를 모두 작업 버퍼로 획득한다.
   - 버퍼 빈칸이 2개 미만이면 개봉 불가.
   - 미개봉 상자를 다음 구간으로 이월하지 않는다.

### Combat timing for reward cadence

- 각 5분 전투 세그먼트에서 **약 3분대에 엘리트/중간보스 1명**을 등장시킨다.
- 해당 엘리트를 실제로 처치하면 상자 토큰 1개를 획득한다.
- **5분대에 세그먼트 보스**가 등장한다.
- 엘리트 등장 보장과 상자 획득 보장은 구분한다: 엘리트를 잡지 못하면 상자는 없다.
- 이 결정은 기존 문서의 `5/10/15분 중간보스` 표현을 실질적으로 재정의한다. 다음 문서 동기화 시 `3분대 엘리트 + 5분 보스` 용어로 정리한다.

### Rest flow

Approved high-level flow:

```text
COMBAT
→ BOSS
→ RESULT
→ BOSS_REWARD (3 choose 1, forced)
→ REST WORKBENCH
   ├─ chest
   ├─ shop
   ├─ backpack
   ├─ 6-slot work buffer
   └─ combination
→ FATE (commit boundary)
→ PREVIEW / COMPLETE
```

- 보스 보상만 REST 진입 전에 강제한다.
- REST 안에서는 상자/상점/백팩/조합을 자유롭게 왕복한다.
- Fate 진입 전 검증: 보스 보상 처리, 미개봉 상자 0, 작업 버퍼 0, pending bag 없음, 모든 배치 유효, 가방 연결성 유효, 미완료 조합 transaction 없음.
- Fate 선택은 해당 휴식의 최종 커밋 경계다.

### Combination rules

- 조합은 자동 변환하지 않는다. 인접 배치 후 명시적 `조합` 액션으로 실행한다.
- 임시 보관함 안에서는 조합할 수 없다.
- 두 재료가 실제 백팩에 유효하게 배치되고 상하좌우로 인접해야 한다.
- `조합 미리보기 → 결과물 직접 배치 → 유효 배치 성공 시에만 원본 소비` 트랜잭션을 사용한다.
- 취소하면 원본은 유지된다.
- 완료된 조합은 배치 Undo/Redo 대상이 아니다.
- 조합 힌트는 단계적 공개한다: 미발견 힌트 → 재료 보유 시 강화된 힌트 → 실제 조합 가능 표시 → 최초 성공 후 레시피/결과 완전 공개.

Approved representative combinations:

- `수둔 + 은신술 → 물안개`
- `일본도 + 뇌둔 → 뇌명도`
- `폭탄 + 화둔 → 폭렬탄`

### Architecture direction

Confirmed architecture:

```text
ItemDefinition / BagDefinition
        ↓
ItemInstance / BagInstance
        ↓
BackpackState
        ↓
BackpackResolver
        ↓
active placement effects
        ↓
RunBuildState + Fate
        ↓
RunModifierSet
```

- `BackpackState`: 6x6 보드, 배치된 아이템/가방 인스턴스, 좌표, 회전의 런타임 source of truth.
- `BackpackResolver`: 점유 셀, 충돌, 활성 셀, 연결성, 인접 그래프, 특수 가방 겹침, 조합 가능성, 활성 효과 계산 전담.
- `RestBackpackSession`: 휴식 작업 버퍼, 드래그/회전 미리보기, 전체 이동, Undo/Redo, 조합 미리보기 같은 편집 상태 전담.
- `RunBuildState`: GOLD, 유파, Fate, 최종 전투 modifier 조합 책임 유지.
- 기존 `owned_items: Dictionary`의 개수 기반 모델은 MVP-4의 백팩 source of truth가 아니다.
- REST 중에는 실제 Player/Combat runtime modifier를 계속 흔들지 않고 `BuildPreviewSnapshot` 성격의 계산 결과만 보여주며, Fate/다음 전투 확정 시 실제 runtime에 동기화하는 방향을 사용한다.

### Planned MVP-4 content pool (approved design direction)

- 기본 획득 가능 아이템: `19종` 권장 구성.
- 조합 전용 결과물: `3종`.
- 구매 가능 가방: `5종` 권장 구성(일반 4 + 특수 1).
- 기존 MVP-3 아이템 8종은 폐기하지 않고 크기/예산 체계에 맞춰 재규격한다.
- 신규 핵심 후보: 일본도, 수리검, 폭탄, 수둔, 뇌둔, 화둔, 은신술, 독침술, 결계술, 대형 소환진, 금기의 부적.
- MVP-4 첫 특수 비정형 가방은 `L형 4칸 인법 주머니`를 권장하며, 1칸 이상 겹친 인법 아이템에 작은 보조 효과를 주는 방식이다.
- 별도 희귀도 시스템은 MVP-4에서 만들지 않는다. 크기/효과예산/획득처 가중치에 집중한다.

### Known scope change from older repository docs

The current repository documents still contain older MVP exclusions such as:

- item rotation excluded
- complex backpack shapes excluded
- 5/10/15 minute `midboss` terminology

Those statements are **superseded for MVP-4 by the approved decisions above**. The next documentation synchronization pass must reconcile `AGENTS.md` and `MVP_ROADMAP.md` instead of silently reverting the approved design.

## Still NOT approved / not complete

- 상세 휴식 작업대 UI layout / visual hierarchy / accessibility interaction spec.
- 최종 MVP-4 error handling, test matrix, human QA checklist, completion gate.
- 전체 설계 문서의 최종 작성/커밋 및 사용자 written-spec review.
- implementation plan.
- any MVP-4 production code.

## Approval boundary

- 위 항목들은 현재 대화에서 사용자에게 순차적으로 승인받은 MVP-4 설계 결정이다.
- 새 핵심 플레이 규칙, 새로운 경제 축, 새로운 획득처, 새 조합 계층, 범위 확대는 별도 사용자 결정이 필요하다.
- 설계 완료 전 구현 금지.
- 설계 문서 작성 후 사용자 written-spec review를 통과해야 implementation plan으로 넘어간다.
