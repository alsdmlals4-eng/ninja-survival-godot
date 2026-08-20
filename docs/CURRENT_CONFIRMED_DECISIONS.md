# CURRENT_CONFIRMED_DECISIONS

> 현재 승인된 제품/설계 결정을 복원하는 프로젝트 원장이다.
> 상세 규칙 전문은 등록된 분야/기능 정본을 참조하며 이 파일에 중복 복제하지 않는다.
> 구현 완료 상태는 이 파일이 아니라 `docs/ACTIVE_CONTEXT.md`가 소유한다.

Last updated: 2026-08-20
Current project baseline observed for this planning checkpoint: `main@a78cd84bac1a1d7e9b4fa5809622a28de859528e`

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
- 이 문구의 최신 시간 의미는 아래 `DEC-2026-08-20-013`이 우선한다: 보스는 세그먼트 내부 4분대에 진입해 5분대 결산을 목표로 하며, 5:00은 hard fail이 아니다.

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
project_main_planning_checkpoint: 619cde1efb0a8d35485d810b29a4efa361fb2b19
mvp4_design_pr_7: MERGED_CLOSED
mvp4_planning_pr_8: MERGED_CLOSED
mvp4_planning_post_merge_gut: PASS_RUN_31437135591
mvp4_hybrid_content_decision: INTEGRATED_PR_12_619cde1efb0a8d35485d810b29a4efa361fb2b19
mvp4_hybrid_content_post_merge_gut: PASS_RUN_31449866658
project_sheet_read: READ_OK_2026_08_11
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403_RECONFIRMED_2026_08_11
```

Google Sheet는 2026-08-11 재조회에 성공했지만, 동일 세션의 write 재시도도 `403 PERMISSION_DENIED`였다. 과거 회전 후단개방/5·10·15분 표현과 일부 후속 조합 후보의 MVP-4 범위 표기가 남아 있으므로 writer 권한이 해결되기 전까지 `SYNCED`로 보고하지 않는다.

---

## 2026-08-20 World / Run Core Planning Checkpoint

```yaml
status: APPROVED_PLANNING_ACTIVE
implementation: NOT_STARTED_BY_THIS_CHECKPOINT
planning_branch: docs/world-core-planning-20260820
main_observed_before_planning: a78cd84bac1a1d7e9b4fa5809622a28de859528e
production_gate: EXPLICIT_USER_DECLARATION_기획_완료_REQUIRED
notion_world_owner: 09 · 세계관 · 핵심 스토리
notion_system_owner: 08 · 핵심 시스템 · 상세
```

이 checkpoint는 기존 MVP-0~3 integrated runtime과 승인된 MVP-4 백팩/Workbench 결정 위에 **세계관·플레이어 판타지·4유파 장기 정체성·첫 공세·런 cadence**를 추가한다. 제품 코드/Scene/Resource/runtime 변경 권한은 부여하지 않는다.

### DEC-2026-08-20-003 · 「닌자의 신」 전설

- 옛 전설에는 **천하가 난세에 빠질 때 「닌자의 신」이 나타나 혼란을 평정한다**는 이야기가 전해진다.
- 플레이어는 태어날 때부터 선택된 구원자/예언의 혈통이 아니다.
- 실제 생존·성장·빌드·평정의 업적 끝에 후대가 새로운 「닌자의 신」이라 부를 만한 전설이 된다.
- 감정선: `살아남는다 → 강해진다 → 자기 방식을 만든다 → 난세를 평정한다 → 전설이 된다`.

### DEC-2026-08-20-004 · 인간의 전란 → 금기 → 요괴/잠식

- 현재 난세의 출발은 인간 군벌/닌자 세력의 전쟁이다.
- 승리를 위한 금지 인법·주술·봉인된 힘의 남용이 봉인/영적 경계를 무너뜨린다.
- 요괴·원혼·잠식이 확산되고 인간은 이를 막거나 이용하려 다시 더 큰 금기에 손대는 악순환이 발생한다.
- 특정 유파 하나나 단일 흑막 한 명을 난세 전체의 원인으로 고정하지 않는다.

### DEC-2026-08-20-005 / 006 · 20분 4구간을 무너진 지부 생존/반격으로 재해석

- `약 20분 / 4×5분` 전투 골격은 유지한다.
- 과거 `4개 독립 권역 순례` 해석은 폐기한다.
- 시작점은 이미 무너지고 고립된 닌자 지부이며 첫 목표는 **적의 공세에서 살아남아 마지막 거점을 버티는 것**이다.
- 4구간 의미: `즉각 생존 → 주변 전선 유지 → 반격/공세 근원 접근 → 최종 공세`.
- 「닌자의 신」 전설은 플레이어를 지명하는 예언이 아니라 절망 속에서 스스로 붙잡는 희망/기준이다.

### DEC-2026-08-20-007 · 패배 = 전투불능/후퇴

- HP 0/Run 실패를 확정 사망으로 해석하지 않는다.
- 패배는 `전투불능/후퇴 또는 구조 → 지부 재정비 → 재도전`이다.
- 시간 회귀, 부활 비술, 세대교체를 현재 기본 코어로 추가하지 않는다.

### DEC-2026-08-20-008 · 닌자소울 = 전승의 불씨 / 수평 메타 성장

- 닌자소울은 문자 그대로의 영혼 추출물이 아니라 **의지·기량·깨달음·전승이 남긴 불씨**다.
- 사용처는 지부 전승 복구와 인법/장비/가방/시작 변형/힌트/도감/편의/도전 조건 등의 수평적 가능성 확장이다.
- 핵심 원칙: **`Run의 힘은 Run에서 만든다. Meta는 정답을 강하게 만드는 것이 아니라 더 많은 닌자 방식을 열어 준다.`**
- 반복 구매형 공격력/체력 인플레이션은 주 성장축으로 두지 않는다.

### DEC-2026-08-20-009 · 4유파 공동 변방 전선 지부

- 무너진 지부는 특정 한 유파의 전용 본거지가 아니라 **네 유파가 위험 지역을 공동 감시하기 위해 운영하던 변방 전선 지부**다.
- 폐허에는 네 유파의 전승/도구/기록 흔적이 모두 남아 있다.
- 닌자소울을 사용한 지부 복구는 잃어버린 네 유파의 전승을 다시 이어 붙이는 메타 표현이다.
- 유파 선택마다 지부 기능/동선을 4벌로 복제하지 않는다.

### DEC-2026-08-20-010 · 4유파 = 서로 다른 위험 처리 철학

| 유파 | 장기 제품 정체성 | 얕은 고유 앵커 |
|---|---|---|
| 봉마류 | **지속 장악** · 소환/결계로 공간을 준비하고 대신 싸우게 하며 버틴다 | 영력 |
| 천술류 | **반응 연쇄** · 상태를 만들고 원소 반응으로 전장을 바꾼다 | 오행반응/오행순환 |
| 귀인류 | **근접 지속** · 위험한 근접을 유지할수록 강해진다 | 귀혈 |
| 흑영류 | **우선 처형** · 위험한 대상을 골라 먼저 제거한다 | 암영표식 |

- 공통 전투/백팩/Workbench/Fate 프레임은 공유한다.
- 새 유파별 전용 조작/대규모 UI/공간 알고리즘을 만들지 않는다.
- 봉마 현재 고정 봉인진, 귀인 HP 50% 광전사, 흑영 가까운 적 우선은 현행 MVP-2 구현 증거이며 제품 정체성에 맞는지 후속 플레이테스트 조정 후보로 둔다.

### DEC-2026-08-20-011 · 첫 5분 시그니처 경험

```text
시작 즉시 유파 시그니처
→ 30초 안에 고유 앵커 첫 증명
→ 약 3분 Elite에서 위험 처리 철학 시험
→ 약 5분대 Boss에서 오의/핵심 루프 결산
→ 보스 보상 3개 중 1개 (최소 1개 유파 관련)
→ Workbench에서 다음 공세 설계
```

- 첫 Vertical Slice에는 별도 전투 중 드래프트나 시작 인법 2~3개 추가 선택을 필수화하지 않는다.

### DEC-2026-08-20-012 · 공통 위협 3역할 + 유파 잔흔 보스

- 일반 적 최소 문법은 `Swarm / Priority Threat / Anchor` 공통 3역할을 우선한다.
- 약 3분 엘리트는 공통 `공세 선봉대장` 역할이며 증원 + 명확한 예고 공격을 사용한다.
- 제1 공세 5분대 보스는 **공통 보스 골격 1개 + 선택 유파의 잠식 잔흔 키트 4개** 구조다.
- 봉마 잔흔: 잠식 식신 + 짧은 봉인진.
- 천술 잔흔: 원소 상태 영역 + 반응.
- 귀인 잔흔: 근접 연속 압박 + 귀혈 잔흔.
- 흑영 잔흔: 표식 축적 + 예고 처형.
- 같은 유파 보스는 플레이어 기술을 무효화하는 상성 하드카운터가 아니라 **유파 철학이 잠식되어 왜곡된 거울상**이다.
- 특정 유파 전체를 악역으로 고정하지 않는다.

### DEC-2026-08-20-013 · 4×5분 active combat + soft overtime

- `약 5분`은 일반전 종료 시각이 아니라 **해당 공세 보스까지 포함한 결산 목표 시간대**다.
- 초기 튜닝 기준: 약 3:00 Elite, 약 4:30 Boss 진입, 5:00~5:30대 Boss 처치 목표.
- `5:00`은 hard fail이 아니다. 보스가 살아 있으면 soft overtime으로 계속 싸운다.
- overtime은 잠식 고조로 압박을 높일 수 있으나 회피 가능성을 제거하지 않는다.
- `약 20분`은 **4개 세그먼트의 active combat target**이다.
- RESULT / Workbench / Fate 판단 시간은 active combat clock에서 제외한다.
- 현행 `StageFlowController`의 `300초 후 BOSS + 3세그먼트`는 구현 전 migration 대상으로 명시하며, 최신 제품 결정 권위가 아니다.

### 2026-08-20 checkpoint protection

- 현재 제품 코드·Scene·Resource·runtime은 이 checkpoint로 수정하지 않는다.
- 기존 MVP-0~3 integrated evidence와 MVP-4 approved backpack/workbench product decisions를 보호한다.
- 사용자가 **`기획 완료`**를 명시하기 전 Godot/Codex production BUILD로 전환하지 않는다.
- 오늘 상세 planning owners:
  - `docs/planning/2026-08-20-world-story-core.md`
  - `docs/planning/2026-08-20-world-story-core-continuation.md`
  - `docs/planning/2026-08-20-four-schools-signature-planning.md`
  - `docs/planning/2026-08-20-first-assault-encounter-planning.md`
  - `docs/planning/2026-08-20-dec012-school-trace-boss-amendment.md`
  - `docs/planning/2026-08-20-run-cadence-planning.md`

### Next pending planning decision

`DEC-PENDING-WORLD-014`: 제1 공세의 선택 유파 거울상 이후, 제2~4 공세의 보스가 어떻게 확대되어 DEC-004의 `인간 전란 → 금기 → 요괴/잠식 → 복합 난세`를 전투 콘텐츠로 전달할지 확정한다.
