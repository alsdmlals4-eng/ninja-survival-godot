# CURRENT_CONFIRMED_DECISIONS

> 현재 승인된 제품/설계 결정을 기록하는 프로젝트 정본이다.
> 오래된 Roadmap/AGENTS 설명과 충돌하면 **최신 사용자 승인과 이 문서의 최신 항목**을 우선하고, 이후 관련 문서를 동기화한다.
> 구현 완료 상태를 뜻하지 않는다. 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`가 소유한다.

Last updated: 2026-08-11
Current project baseline observed for this update: `main@9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1`

## MVP-4 — Backpack / Combination Basics

Status: `DESIGN_COMPLETE_PENDING_WRITTEN_SPEC_REVIEW / IMPLEMENTATION_NOT_STARTED`

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
- 전체 가방+배치 아이템의 상대 배치를 유지한 채 전체 묶음을 1칸 이동하는 `전체 이동` 조작을 제공한다.
- 키보드/게임패드에서는 **명시적 `전체 이동 모드`가 활성화된 동안** 방향키/D-pad가 전체 묶음을 1칸 이동한다. 일반 Workbench 상태의 방향 입력은 focus/선택 셀 탐색에 사용한다.
- Touch에서는 `전체 이동` 액션을 선택한 뒤 화면 방향 버튼 또는 동등한 명시 조작으로 같은 기능을 제공한다.
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
- 복잡한 배치 판단은 미리보기로 유효/무효, 인접/특수 가방/조합 가능성을 놓기 전에 보여준다.

### Rest Workbench UI / input / feedback — DEC-2026-08-11-001

사용자 승인: **A안 — 통합 Persistent Workbench**.

- REST의 중심 화면은 `6x6` 백팩 보드를 지속 노출하는 통합형 작업대다.
- 상자, 상점, 백팩, 6-slot 작업 버퍼, 조합은 별도 선형 화면으로 강제하지 않고 같은 REST 작업대 안에서 자유 왕복한다.
- Windows 기본 레이아웃은 중앙 백팩 + 주변 rail/panel 구조를 사용한다.
- Android 기본 레이아웃은 동일한 정보·행동 계약을 유지하되 백팩을 중심에 두고 주변 기능을 bottom sheet / 짧은 tab으로 재배치한다.
- UI는 `BackpackState`나 조합/경제 규칙을 재계산하지 않는다. 표시 snapshot을 받고 사용자 의도만 signal/event로 반환한다.

#### Input paths

- Mouse: drag/drop + click selection.
- Keyboard/gamepad 기본 상태: 방향 입력으로 예측 가능한 focus/선택 셀 탐색 → 선택/집기 → 셀 이동 → 배치, 별도 회전 액션, 취소 액션을 제공한다.
- Keyboard/gamepad `전체 이동 모드`: 화면에 모드 상태를 명확히 표시하고, 모드가 활성화된 동안만 방향키/D-pad가 전체 가방+아이템 layout을 1칸 이동한다. 취소/완료 시 일반 focus 탐색으로 즉시 복귀한다.
- Touch: tap-select → tap-place를 완전한 기본 경로로 제공하고 drag는 보조 경로로 둔다. `전체 이동`은 명시 액션 + 화면 방향 컨트롤로 수행한다.
- 핵심 기능을 long-press, 정밀 drag, hover에만 의존시키지 않는다.
- 회전, 전체 이동, Undo, Redo, 조합, 취소는 화면상 명시 버튼을 제공하며 PC shortcut은 추가 경로로 둔다.
- focus 이동은 명시적 neighbor를 우선해 예측 가능하게 유지하고 modal/bottom-sheet 종료 뒤 직전 의미 있는 focus로 복귀한다.
- `전체 이동 모드`와 일반 focus 탐색은 동시에 활성화되지 않는다. 모드 표시가 보이지 않는 상태에서 방향 입력이 layout을 이동시키지 않는다.

#### Information hierarchy

1. 항상 보임: 백팩 보드, 사용 가능/비활성 셀, 작업 버퍼 사용량, GOLD, 미개봉 상자 수, REST 완료 조건 요약.
2. 선택 시 보임: 아이템/가방 이름, 크기/회전, 현재 효과, 활성 시너지, 특수 가방 영향, 조합 힌트 단계.
3. 이동/회전 중 보임: 예상 footprint, 유효/무효, 새 인접 관계, 특수 가방 overlap, 조합 가능성, preview modifier 변화.
4. 확정 전 보임: 판매/버리기/조합 확정/운명 선택 같은 비-Undo 행동의 결과와 취소 경계.

#### Feedback contract

- 유효 배치: 형태/outline + 짧은 긍정 아이콘/문구.
- 무효 배치: 원인 셀 강조 + `보드 밖 / 비활성 셀 / 충돌 / 연결성 파괴` 중 구체 원인 표시.
- 인접 시너지: 두 대상과 접촉 edge를 연결해 어떤 관계가 생기는지 표시.
- 특수 가방 효과: 적용되는 bag region과 대상 item을 함께 표시.
- 조합 가능: 재료 쌍을 강조하고 `조합 가능` 액션을 노출하되 자동 변환하지 않는다.
- `전체 이동 모드`: mode label/icon/border로 현재 방향 입력의 의미가 바뀌었음을 명확히 표시한다.
- 색상만으로 상태를 전달하지 않고 outline/icon/text를 함께 사용한다.
- 자주 반복되는 이동/hover 피드백은 낮은 강도로 유지하고, 확정/실패/조합 성공만 더 강한 피드백을 사용한다.

#### Progressive combination hints

- 미발견: 결과명/정확한 레시피를 숨기고 가능성만 약하게 암시한다.
- 관련 재료 보유: 관련 후보임을 강화한다.
- 실제 유효 인접 상태: `조합 가능`을 명확히 표시한다.
- 최초 성공 후: 레시피와 결과를 완전 공개한다.
- 힌트는 현재 선택/배치 문맥에서 보여주며 전체 조합표를 처음부터 상시 노출하지 않는다.

#### Fate commit checklist

Fate 진입 버튼은 아래를 상시 요약하고, 미충족 항목이 있으면 비활성 상태와 함께 원인/바로가기 행동을 제공한다.

- boss reward 처리 완료
- 미개봉 chest `0`
- work buffer `0 items`
- pending bag 없음
- 모든 item/bag placement 유효
- bag 연결성 유효
- 미완료 combination transaction 없음

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
- 과거 `5/10/15분 중간보스` 표현은 `3분대 엘리트 + 5분 세그먼트 보스`로 대체됐다.

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

### Transaction / invalid-state handling

- 이동/회전/전체 이동은 preview validation을 먼저 수행하고 실패하면 canonical state를 변경하지 않는다.
- 조합은 preview result placement가 유효해질 때까지 원본을 소비하지 않는다. 최종 성공 시 단일 atomic transaction으로 원본 소비 + 결과 배치를 수행한다.
- 상자 개봉은 work buffer 빈 슬롯이 `2` 미만이면 실행 전 차단한다.
- 구매는 GOLD/offer/구매 제한/work buffer 수용 가능성을 확인한 뒤 실행한다. 실패 시 GOLD와 offer 상태를 부분 변경하지 않는다.
- Fate 진입은 commit checklist 전체가 통과해야 한다.
- UI 애니메이션/중복 입력/빠른 반복 입력 때문에 transaction이 두 번 실행되지 않도록 action-level guard를 둔다.
- 실패 메시지는 `무엇이 실패했는지 + 왜 + 가능한 다음 행동`을 제공한다.

### Determinism / testability

- 상점 offer, boss reward, chest reward처럼 무작위 후보를 만드는 컴포넌트는 주입 가능한 RNG 또는 seed를 사용해 deterministic test가 가능해야 한다.
- `BackpackResolver`의 점유, 충돌, 연결성, 인접, 특수 가방 overlap, 조합 자격 계산은 UI/Scene과 분리된 deterministic rule layer로 유지한다.
- `RestBackpackSession` Undo/Redo와 preview는 동일 입력에서 동일 결과를 만들어야 한다.
- `전체 이동 모드` 진입/해제, 일반 focus 탐색과 방향 입력의 배타성, 모드 중 전체 이동 atomicity를 deterministic input/session test로 검증한다.
- UI test는 규칙 정답을 재구현하지 않고 resolver/session snapshot과 signal/event 경계를 검증한다.

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
- `RestBackpackSession`: 휴식 작업 버퍼, 드래그/회전 미리보기, 전체 이동 모드, 전체 이동, Undo/Redo, 조합 미리보기 같은 편집 상태 전담.
- `RunBuildState`: GOLD, 유파, Fate, 최종 전투 modifier 조합 책임 유지.
- 기존 `owned_items: Dictionary`의 개수 기반 모델은 MVP-4의 백팩 source of truth가 아니다.
- REST 중에는 실제 Player/Combat runtime modifier를 계속 흔들지 않고 `BuildPreviewSnapshot` 성격의 계산 결과만 보여주며, Fate/다음 전투 확정 시 실제 runtime에 동기화한다.

### Planned MVP-4 content pool (approved design direction)

- 기본 획득 가능 아이템: `19종` 권장 구성.
- 조합 전용 결과물: `3종`.
- 구매 가능 가방: `5종` 권장 구성(일반 4 + 특수 1).
- 기존 MVP-3 아이템 8종은 폐기하지 않고 크기/예산 체계에 맞춰 재규격한다.
- 신규 핵심 후보: 일본도, 수리검, 폭탄, 수둔, 뇌둔, 화둔, 은신술, 독침술, 결계술, 대형 소환진, 금기의 부적.
- MVP-4 첫 특수 비정형 가방은 `L형 4칸 인법 주머니`를 권장하며, 1칸 이상 겹친 인법 아이템에 작은 보조 효과를 주는 방식이다.
- 별도 희귀도 시스템은 MVP-4에서 만들지 않는다. 크기/효과예산/획득처 가중치에 집중한다.

### Test / human QA completion contract

Automated contract coverage must include at minimum:

- footprint rotation and board boundary checks
- bag connectivity and invalid disconnect rejection
- item/bag collision and active-cell checks
- whole-layout translation success/failure atomicity
- normal focus navigation vs `전체 이동 모드` directional-input exclusivity
- orthogonal-only adjacency and one-effect-per-pair rule
- one-cell special-bag overlap and multi-bag stacking
- work-buffer activation exclusion and zero-before-combat gate
- Undo/Redo included vs excluded transaction boundaries
- boss/shop/chest reward intake constraints
- explicit combination eligibility, preview, cancel, atomic success
- seeded deterministic reward generation
- Fate commit checklist failures and success
- duplicate-input transaction guard

Human QA must separately validate:

- Windows mouse+keyboard path
- Windows gamepad focus path, including visible `전체 이동 모드` transition
- Android touch path on a real device, including touch `전체 이동` control
- smallest supported layout and long Korean text
- valid/invalid placement comprehension without relying on color alone
- first-time recipe hint comprehension without exposing the full recipe too early
- REST duration/fatigue and whether the workbench feels like next-combat design rather than inventory chores
- return focus after panel/modal close

Human/run evidence remains `NOT_RUN` until the later implementation build exists.

### Known synchronization state

- PR #5 already synchronized current `AGENTS.md`, `MVP_ROADMAP.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, handoff snapshot, and documentation map with the approved rotation/shape/timing direction.
- Project Google Sheets still contains stale pre-PR-#5 wording in multiple tabs. A write attempt on 2026-08-11 returned Google Sheets `403 PERMISSION_DENIED`; Sheet synchronization is therefore `GITHUB_UPDATE_PENDING_SHEET / BLOCKED_USER_ACTION` and must not be reported as `SYNCED`.
- PR #6 was closed unmerged as superseded by Draft PR #7, which absorbs its `ACTIVE_CONTEXT` correction and advances the design state.

## Remaining gate

- Canonical MVP-4 written design spec must remain synchronized with this decision source.
- The written spec must pass placeholder / contradiction / scope / ambiguity self-review and exact-head adversarial review.
- User written-spec review is required by the active Superpowers brainstorming overlay.
- `writing-plans` and any MVP-4 production code remain blocked until that written-spec review closes.

## Approval boundary

- Sections 1–5 are prior approved product rules.
- `DEC-2026-08-11-001` approves the integrated Persistent Workbench direction.
- Input/accessibility/error/test details above, including explicit `전체 이동 모드`, are in-scope technical/UX safety defaults applied under `[연속작업] 진행해`; they preserve the already-approved whole-layout translation behavior while preventing ambiguous directional input.
- 새 핵심 플레이 규칙, 새로운 경제 축, 새로운 획득처, 새 조합 계층, 또는 MVP 범위 확대는 별도 사용자 결정이 필요하다.
- written-spec review 전 구현 금지.