# CURRENT_CONFIRMED_DECISIONS

> 현재 승인된 제품/설계 결정을 복원하는 프로젝트 원장이다.
> 상세 규칙 전문은 등록된 분야/기능 정본을 참조하며 이 파일에 중복 복제하지 않는다.
> 구현 완료 상태는 이 파일이 아니라 `docs/ACTIVE_CONTEXT.md`가 소유한다.

Last updated: 2026-08-11
Current project baseline observed for this update: `main@ac497904ad002974515c890dc55a4378f6e82680`

## MVP-4 — Backpack / Combination Basics

```yaml
status: DESIGN_APPROVED
implementation: NOT_STARTED
primary_decision_id: DEC-2026-08-11-001
secondary_decision_ids:
  - DEC-2026-08-11-002
written_spec: docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
written_spec_status: APPROVED_BY_USER_2026-08-11
traceability: docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md
implementation_plan: docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md
content_balance_data: docs/planning/2026-08-11-mvp4-content-balance-v1.md
benchmark_evidence: docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md
planning_integration: MERGED_PR_8_360e8652b51e8125c63b7a5cdc2288092bb8e096
production_gate: EXPLICIT_USER_DECLARATION_기획_완료_REQUIRED
```

### Decision — spatial board and bags

- 전체 배치 보드는 `6 x 6 = 36 cells` 고정이다.
- 기본 닌자 가방이 제공하는 시작 활성 영역은 `4 x 3 = 12 cells`이다.
- 새 가방을 구매/배치해 활성 셀을 확장한다.
- 새 가방은 현재 활성 영역과 직교 변으로 연결되어야 하며 전체 활성 셀은 항상 하나의 4-neighbor connected component다.
- 가방끼리는 겹칠 수 없다.
- 아이템은 활성 셀 위에만 놓인다.
- 가방 레이어와 아이템 레이어는 분리한다.
- 가방과 아이템은 모두 90도 단위 회전한다.
- 일반 MVP-4 아이템은 직사각형 footprint 중심이다.
- 일부 가방은 L/T형 비정형 footprint를 허용한다.

### Decision — movement and edit semantics

- 휴식 구간에서만 백팩 편집/회전을 허용한다.
- 개별 가방을 집어 이동할 때 그 가방 영역과 최소 1칸 겹쳐 있는 아이템은 함께 이동 후보가 된다.
- 그 아이템이 다른 가방에도 걸쳐 있더라도 **다른 가방까지 연쇄 이동시키지 않는다**.
- 전체 가방+배치 아이템의 상대 배치를 유지한 채 한 칸씩 옮기는 whole-layout translation을 제공한다.
- 전체 이동 결과 하나라도 보드 밖/충돌/비활성 셀/연결성 파괴를 만들면 전체 조작을 취소한다.
- Keyboard/gamepad의 방향 입력은 일반 상태에서 focus/선택 셀 탐색에 사용한다.
- **명시적이고 화면에 보이는 `전체 이동 모드`가 활성화된 동안에만** 방향키/D-pad가 whole-layout translation을 수행한다.
- 일반 탐색과 `전체 이동 모드`는 동시에 활성화되지 않는다.
- Touch는 명시적 `전체 이동` 액션 + 화면 방향 컨트롤로 같은 기능을 제공한다.
- 배치 편집은 Undo/Redo를 지원한다.
- Undo/Redo 포함: 이동, 회전, 배치, 백팩↔작업 버퍼 이동, 합법적인 whole-layout edit.
- Undo/Redo 제외: 구매, 판매, 버리기, 상자 개봉, 보스 보상 선택, 리롤, 조합 확정, 운명 선택.

### Decision — size/effect budget defaults

초기 조정값은 `RECOMMENDED_DEFAULT`이며 플레이테스트로 재튜닝할 수 있다.

| occupied cells | base effect budget |
|---:|---:|
| 1 | 1.0 |
| 2 | 2.1 |
| 3 | 3.3 |
| 4 | 4.6 |
| 6 | 7.2 |

- 큰 아이템은 배치가 어렵지만 칸당 기본 효율이 조금 높다.
- 같은 면적이면 기본 예산은 같고 모양이 공간적 가치를 만든다.
- 조합 결과는 두 원본을 실제 백팩에 배치·인접시키는 공간 비용을 이미 지불하므로 일반 크기 예산 상한의 예외가 될 수 있다.
- 조합 결과 초기 예산은 원본 합계 대비 약 `+12%` 프리미엄을 권장한다.
- 특수 가방 보조 효과는 대략 `0.4~0.6` 예산을 권장한다.

### Decision — adjacency and special bags

- 아이템-아이템 인접은 상하좌우 변 공유만 인정하고 대각선은 제외한다.
- 같은 아이템 pair의 같은 시너지는 접촉 변 개수와 관계없이 한 번만 계산한다.
- 서로 다른 이웃과의 관계는 각각 계산한다.
- 특수 가방은 아이템이 해당 가방 영역에 **1칸만 걸쳐도** 효과를 한 번 적용한다.
- 한 아이템이 서로 다른 여러 특수 가방에 걸치면 각 가방 instance 효과를 각각 적용한다.

### Decision — six-slot REST work buffer

- 작업 버퍼는 `6 slots` 카드형 임시 저장이다. 아이템 크기는 슬롯 소모량을 바꾸지 않는다.
- 보스 보상, 상자, 상점 구매품이 작업 버퍼로 들어간다.
- 이미 백팩에 있던 아이템도 REST 중 잠시 버퍼로 옮길 수 있다.
- 버퍼 아이템은 전투 효과, 인접 효과, 특수 가방 효과, 조합 자격이 모두 비활성이다.
- Fate/다음 전투 확정 전에 버퍼는 반드시 `0 items`여야 한다.
- 영구 Storage로 사용하지 않는다.

### Decision — acquisition pillars

1. **Boss reward = quality / choice**
   - 각 5분 세그먼트 보스 격파 후 `3 options → choose 1`.
   - 일반 아이템 풀을 사용하되 **고가치 아이템과 조합 핵심재료의 후보 가중치를 높인다**.
   - 현재 유파와 직접 관련된 후보를 최소 1개 보장한다.
   - 선택 전 REST 진입 불가.

2. **Shop = control / economy**
   - 일반 아이템 후보 `3` + 가방 후보 `1`.
   - 가방은 상점 전용 획득이다.
   - 구매품은 즉시 전투 modifier가 되지 않고 Workbench로 들어간 뒤 유효 배치/commit되어야 활성화된다.
   - 리롤 비용은 `5G → 10G → 15G`를 유지한다.
   - 휴식당 가방 최대 1개 구매를 초기 권장값으로 둔다.

3. **Chest = quantity / randomness**
   - 전투 중 상자는 즉시 열지 않고 chest token으로 획득한다.
   - REST에서 token 1개를 열면 랜덤 아이템 2개를 모두 작업 버퍼로 받는다.
   - 버퍼 빈 슬롯이 2개 미만이면 개봉 불가이며 token을 소비하지 않는다.
   - 미개봉 chest는 다음 세그먼트로 이월하지 않는다.

### Decision — combat cadence

- 각 5분 전투 세그먼트에서 **약 3분대에 엘리트/중간보스 1명**을 등장시킨다.
- 실제로 처치했을 때만 chest token 1개를 획득한다.
- **약 5분대에 세그먼트 보스**가 등장한다.
- 과거 현재 문서의 `5/10/15분 중간보스` 표현은 `3분대 엘리트 + 5분 세그먼트 보스`로 대체된다.

### Decision — REST flow and commit boundary

```text
COMBAT
→ ~3 MIN ELITE
→ ~5 MIN SEGMENT BOSS
→ RESULT
→ BOSS_REWARD (3 choose 1, forced)
→ REST WORKBENCH
   ├─ chest
   ├─ shop
   ├─ backpack / bag expansion
   ├─ 6-slot work buffer
   └─ combination
→ FATE (commit boundary)
→ PREVIEW / COMPLETE
```

- 보스 보상만 REST 진입 전에 강제한다.
- REST 안에서는 chest/shop/backpack/combination 순서를 강제하지 않고 자유 왕복한다.
- Fate 진입 조건: boss reward 완료, 미개봉 chest 0, work buffer 0, pending bag 없음, 모든 배치 유효, bag 연결성 유효, pending combination 없음.
- Fate 선택은 해당 휴식의 최종 commit boundary다.

### Decision — combinations

- 조합은 자동 변환하지 않고 명시적 `조합` 액션을 요구한다.
- 버퍼 안에서는 조합할 수 없다.
- 두 재료가 실제 백팩에 유효 배치되고 직교 인접해야 한다.
- `조합 미리보기 → 결과물 직접 배치 → 유효 배치 성공 시 원본 atomic consume + 결과 생성` 순서를 사용한다.
- 취소/실패 시 원본은 유지한다.
- 완료 조합은 배치 Undo/Redo 대상이 아니다.
- 힌트는 `미발견 → 관련 재료 보유 → 실제 조합 가능 → 최초 성공 후 완전 공개` 순으로 점진 공개한다.

대표 1차 조합:

- `수둔 + 은신술 → 물안개`
- `일본도 + 뇌둔 → 뇌명도`
- `폭탄 + 화둔 → 폭렬탄`

### Decision — Persistent Workbench — DEC-2026-08-11-001

사용자 승인: **A안 — 통합 Persistent Workbench**.

- REST의 중심은 `6x6` 백팩 보드를 지속 노출하는 Workbench다.
- chest, shop, backpack, work buffer, combination은 별도 선형 화면으로 강제하지 않는다.
- Windows: 중앙 백팩 + 주변 rail/panel.
- Android: 중앙 백팩을 유지하고 주변 기능을 bottom sheet / 짧은 tab으로 재배치한다.
- UI는 `BackpackState`, 경제, 조합, Fate 규칙을 재계산하지 않고 domain snapshot을 표시하며 사용자 intent만 signal/event로 반환한다.
- Mouse: drag/drop + click selection.
- Keyboard/gamepad: 예측 가능한 focus/선택 셀 탐색, 선택/집기/배치, 별도 회전/취소; whole-layout은 명시적 mode에서만 수행한다.
- Touch: tap-select → tap-place가 완전한 기본 경로이며 drag는 보조다.
- 핵심 기능을 long-press, precision drag, hover에만 의존시키지 않는다.
- 회전, 전체 이동, Undo, Redo, 조합, 취소는 화면상 명시 컨트롤을 제공한다.
- modal/bottom-sheet 종료 후 직전 의미 있는 focus로 복귀한다.
- 유효/무효, focus, 시너지, 조합 가능 상태는 색 하나에만 의존하지 않고 outline/icon/text를 병행한다.
- Android interactive target은 약 `48dp x 48dp` 이상을 초기 접근성 기준으로 사용한다.

### Decision — transaction and determinism

- 이동/회전/전체 이동은 preview validation 후 commit하며 실패하면 canonical state를 변경하지 않는다.
- 상자/구매/보스보상/조합/Fate transaction은 prerequisites를 확인한 뒤 한 번만 mutation한다.
- 빠른 반복 입력으로 transaction이 중복 실행되지 않도록 action-level guard를 둔다.
- 실패 메시지는 `무엇이 실패했는지 + 이유 + 다음 행동`을 제공한다.
- Shop/boss/chest 후보 RNG는 seed/injection 가능해야 한다.
- `BackpackResolver`의 점유/충돌/연결성/인접/특수 bag/combo 자격 계산은 UI와 분리된 deterministic rule layer다.

### Decision — architecture

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

- `BackpackState`: 6x6 보드와 배치 instance/좌표/회전의 runtime source of truth.
- `BackpackResolver`: occupancy, collision, active cells, connectivity, adjacency, special-bag overlap, combo eligibility, active effects 계산.
- `RestBackpackSession`: work buffer, preview, edit history, whole-layout mode, combination preview 등 REST 편집 상태.
- `BuildPreviewSnapshot`: REST 중 예상 효과를 보여주는 derived snapshot.
- `RunBuildState`: GOLD, selected school, Fate, **committed backpack modifier snapshot** 조합 책임.
- 기존 `owned_items: Dictionary` count model은 MVP-4의 공간 source of truth 또는 최종 modifier authority가 아니다.
- REST 편집 중 실제 combat runtime modifier를 계속 흔들지 않고 Fate/next-combat commit 시 동기화한다.

### Decision — planned MVP-4 content direction

- 기본 획득 가능 아이템: `19종` 권장 구성.
- 조합 전용 결과물: `3종`.
- 구매 가능 가방: `5종` 권장 구성(일반 4 + 특수 1).
- 기존 MVP-3 8개 아이템은 폐기하지 않고 footprint/effect-budget 체계에 맞춰 재규격한다.
- 신규 핵심 후보: 일본도, 수리검, 폭탄, 수둔, 뇌둔, 화둔, 은신술, 독침술, 결계술, 대형 소환진, 금기의 부적.
- 첫 특수 비정형 가방은 `L형 4칸 인법 주머니`를 권장하며, 1칸 이상 겹친 인법 item에 작은 보조 효과를 준다.
- 별도 희귀도/등급 시스템은 MVP-4에 추가하지 않는다.
- 정확한 초기 footprint/id/bag cell 기본값은 승인 Spec을 보존하는 범위에서 implementation plan의 `RECOMMENDED_DEFAULT`를 사용하며 플레이테스트로 조정 가능하다.

### Decision — Hybrid spatial item dependency — DEC-2026-08-11-002

사용자 승인: **A안 — 하이브리드 공간 의존형**.

- 19개 기본 획득 아이템은 모두 혼자 배치해도 의미 있는 standalone effect를 가진다.
- strong-spatial item은 전체의 약 40%로 제한하며 **초기 tuning 범위는 7~9종**으로 둔다. 첫 authoring default는 `8종 strong-spatial + 11종 simple/one-condition`이다.
- `8종`은 초기 수치 기본값이지 불변 코어가 아니다. 7~9 범위 안의 조정은 A안의 핵심 방향을 유지하는 tuning으로 처리할 수 있다.
- 조합 핵심재료는 완성 조합을 만들기 전에도 정상적인 선택지로 기능한다.
- 3개 조합 결과는 단순한 원본 합계 `+12%` 복제가 아니라 여러 기존 modifier 축을 묶은 **기억나는 asymmetric power spike**로 만든다.
- 태그는 내부 계산에만 쓰지 않고 boss/shop weighting, combo hint, Workbench UI가 공유하는 player-readable build vocabulary로 사용한다.
- 공간 깊이를 얻기 위해 조작 난이도를 올리지 않는다. bag/item layer, explicit Undo/Redo, focus/touch parity를 유지한다.
- 상점/백팩/조합 의사결정은 전투 중에 삽입하지 않고 승인된 boss 이후 REST Workbench에 남긴다.
- exact 초기 수치·가격·가중치와 첫 8종 roster는 `docs/planning/2026-08-11-mvp4-content-balance-v1.md`의 `RECOMMENDED_DEFAULT`로 관리한다.
- 외부 벤치마크의 기능을 그대로 복사하지 않으며 근거와 ADAPT/AVOID 판정은 `docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md`가 기록한다.
- rarity, 새 획득 축, 2차/3차 조합, 전투 중 인벤토리 편집은 이 Decision으로 추가하지 않는다.

## Approval and execution boundary

- 위 MVP-4 제품/설계 방향과 `DEC-2026-08-11-001`, `DEC-2026-08-11-002`는 사용자 승인 상태다.
- L2 written spec은 2026-08-11 사용자 승인으로 `APPROVED`다.
- L3 traceability와 Superpowers implementation plan은 PR #8로 `main@360e8652...`에 통합됐다.
- **Godot/Codex production BUILD는 사용자가 프로젝트 계약의 전환 문구 `기획 완료`를 명시적으로 선언하기 전까지 시작하지 않는다.**
- 새 핵심 플레이 규칙, 새로운 경제 축, 새로운 획득처, 새 조합 계층, 기존 보호 범위 폐기는 별도 `USER_DECISION_REQUIRED`다.
- exact UI spacing/theme, 초기 balance tuning, 내부 파일 분할처럼 승인된 결과를 바꾸지 않는 사항은 `RECOMMENDED_DEFAULT`로 조정할 수 있다.

## Synchronization state

```yaml
project_main_planning_checkpoint: ac497904ad002974515c890dc55a4378f6e82680
mvp4_design_pr_7: MERGED_CLOSED
mvp4_planning_pr_8: MERGED_CLOSED
mvp4_planning_post_merge_gut: PASS_RUN_31437135591
mvp4_hybrid_content_decision: DEC_2026_08_11_002_APPROVED_PENDING_CURRENT_PLANNING_PR
project_sheet_read: READ_OK_2026_08_11
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403_RECONFIRMED_2026_08_11
```

Google Sheet는 2026-08-11 재조회에 성공했지만, 동일 세션의 write 재시도도 `403 PERMISSION_DENIED`였다. 과거 회전 후단개방/5·10·15분 표현과 일부 후속 조합 후보의 MVP-4 범위 표기가 남아 있으므로 writer 권한이 해결되기 전까지 `SYNCED`로 보고하지 않는다.
