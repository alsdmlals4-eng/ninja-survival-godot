# MVP-4 Content Balance v1 — Initial Authoring Defaults

```yaml
planning_data_id: DATA-2026-08-11-MVP4-CONTENT-BALANCE-V1
feature: MVP-4 Backpack / Combination Basics
status: RECOMMENDED_DEFAULT_APPROVED_DIRECTION
related_decision: DEC-2026-08-11-002
approved_direction: HYBRID_SPATIAL_DEPENDENCY_A
numeric_authority: INITIAL_TUNING_DEFAULT
product_authority:
  - docs/CURRENT_CONFIRMED_DECISIONS.md
  - docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
benchmark_evidence: docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md
implementation_status: NOT_STARTED
human_evidence: NOT_RUN
player_experience_evidence: NOT_RUN
```

> 이 문서는 MVP-4 첫 구현/플레이테스트에 사용할 수치·태그·가중치 기본값을 소유한다. 핵심 제품 규칙을 새로 정의하지 않는다. 숫자는 플레이테스트로 조정 가능하며, `기획 완료` 전에는 production 구현에 적용하지 않는다.

## 1. Authoring principles

- 19개 기본 획득 아이템은 **전부 단독 효용**을 가진다.
- 19종 중 **8종만 strong spatial**로 둔다. 나머지 11종은 simple/one-condition이다.
- strong spatial bonus는 같은 관계를 접촉 변 수만큼 반복 계산하지 않는다.
- 조합 재료는 조합 전에도 정상적인 선택지다.
- 3개 조합 결과는 acquisition pool에서 제외하고 명시적 조합으로만 만든다.
- 별도 rarity 시스템을 추가하지 않는다.
- 기존 `RunModifierSet` 축을 최대한 재사용해 first pass schema 폭증을 막는다.
- `tag`는 reward/shop weighting, UI, combo hint에서 같은 뜻으로 사용한다.

### Strong-spatial roster — 8 / 19

```text
school_emblem
katana
shuriken
bomb
stealth_art
poison_needles
barrier_art
greater_summoning_circle
```

## 2. Base item catalog — 19

수치는 모두 `INITIAL_TUNING_DEFAULT`다.

| ID | 표시명 | Footprint | 가격 | 기본 효과 | Strong spatial effect | 핵심 태그 |
|---|---|---:|---:|---|---|---|
| `taijutsu_training` | 체술단련 | 1x1 | 20G | 이동속도 `+10%` | 없음 | support, movement, affinity_guiin |
| `protection_talisman` | 호신 부적 | 1x2 | 20G | 최대 HP `+20` | 없음 | support, survival |
| `fortune_talisman` | 행운 부적 | 1x1 | 20G | 일반 처치 GOLD `+25%` | 없음 | support, economy, affinity_heukyeong |
| `ninjutsu_training` | 인법단련 | 1x2 | 30G | 유파 피해 `+12%` | 없음 | support, ninjutsu, damage |
| `enlightenment` | 깨달음 | 1x1 | 30G | 유파 자원 획득 `+20%` | 없음 | support, resource, affinity_bongma |
| `regeneration_scroll` | 재생의 두루마리 | 1x2 | 30G | REST 시작 회복 `+20%` | 없음 | support, healing |
| `ultimate_treatise` | 오의 비전서 | 1x2 | 40G | 오의 준비 획득 `+25%` | 없음 | support, ultimate, affinity_bongma |
| `school_emblem` | 유파 증표 | 2x2 | 40G | 기존 4유파 전용 payload 유지 | 인접한 서로 다른 `ninjutsu` 아이템 1개당 유파 피해 `+3%`, 최대 3개=`+9%` | support, school, ninjutsu_anchor |
| `katana` | 일본도 | 1x3 | 35G | 비오의 유파 직접 피해 `+18%` | `element_style` 인접 1개 이상이면 추가 `+8%` once | weapon, melee, combo_core, affinity_guiin |
| `shuriken` | 수리검 | 1x1 | 20G | 비오의 유파 직접 피해 `+5%` | 인접한 서로 다른 `ninjutsu` 1개당 `+3%`, 최대 `+9%` | weapon, ranged, connector, affinity_heukyeong |
| `bomb` | 폭탄 | 2x2 | 40G | 유파 피해 `+16%` | `element_style` 인접 1개 이상이면 상태/반응 효과 `+10%` once | weapon, aoe, explosive, combo_core, affinity_cheonsul |
| `water_style` | 수둔 | 1x2 | 30G | 유파 자원 획득 `+15%` | 없음 | ninjutsu, element_style, water, status, combo_core, affinity_cheonsul |
| `lightning_style` | 뇌둔 | 1x2 | 35G | 오의 준비 획득 `+20%` | 없음 | ninjutsu, element_style, lightning, combo_core, affinity_cheonsul, affinity_guiin |
| `fire_style` | 화둔 | 1x2 | 35G | 유파 피해 `+10%`, 상태/반응 효과 `+10%` | 없음 | ninjutsu, element_style, fire, status, combo_core, affinity_cheonsul |
| `stealth_art` | 은신술 | 1x2 | 30G | 회피 `+5%p` | `weapon` 인접 1개 이상이면 비오의 유파 직접 피해 `+5%` once | ninjutsu, stealth, support, combo_core, affinity_heukyeong |
| `poison_needles` | 독침술 | 1x2 | 30G | 상태/반응 효과 `+15%` | `stealth` 인접 시 상태/반응 효과 추가 `+10%` once | weapon, ranged, poison, status, affinity_heukyeong |
| `barrier_art` | 결계술 | 2x2 | 40G | 받는 피해 `-10%` | `support` 인접 1개 이상이면 받는 피해 추가 `-5%` once | ninjutsu, survival, barrier, affinity_bongma |
| `greater_summoning_circle` | 대형 소환진 | 2x3 | 50G | 오의 위력 `+30%`, 유파 자원 `+15%` | `school_emblem` 또는 `barrier` 인접 시 오의 준비 `+12%` once | ninjutsu, summon, ultimate, ritual, affinity_bongma |
| `forbidden_talisman` | 금기의 부적 | 1x3 | 45G | 유파 피해 `+22%`, 유파 자원 `+20%`, 받는 피해 `+12%` | 없음 — 의도적 asymmetric risk/reward | curse, support, risk_reward |

### Existing MVP-3 preservation

기존 8종의 핵심 효과값은 first pass에서 그대로 보존한다.

```text
taijutsu_training      move_speed_pct +0.10
protection_talisman    max_health_flat +20
fortune_talisman       normal_kill_gold_pct +0.25
ninjutsu_training      school_damage_pct +0.12
enlightenment          school_resource_gain_pct +0.20
regeneration_scroll    rest_start_heal_pct +0.20
ultimate_treatise      ultimate_charge_gain_pct +0.25
school_emblem          4-school payload unchanged
```

공간 source of truth로 전환될 때도 이 값이 사라졌다고 가정하지 않는다.

## 3. Affinity groups for reward/shop weighting

Affinity는 “해당 유파만 사용할 수 있음”을 뜻하지 않는다. **현재 유파와 연결되는 추천/보상 가중치용 힌트**다.

### 봉마류

- `enlightenment`
- `ultimate_treatise`
- `school_emblem`
- `barrier_art`
- `greater_summoning_circle`

### 천술류

- `ninjutsu_training`
- `school_emblem`
- `bomb`
- `water_style`
- `lightning_style`
- `fire_style`

### 귀인류

- `taijutsu_training`
- `protection_talisman`
- `school_emblem`
- `katana`
- `lightning_style`

### 흑영류

- `fortune_talisman`
- `school_emblem`
- `shuriken`
- `stealth_art`
- `poison_needles`
- `forbidden_talisman`

## 4. Combination result catalog — 3

조합 결과는 **직접 획득하지 않는다**. source가 backpack 안에서 유효 배치 + 직교 인접하고 explicit combine을 거친 경우에만 생성한다.

| Result ID | 표시명 | Sources | Result footprint | Initial result effects | Identity / watchpoint |
|---|---|---|---:|---|---|
| `water_mist` | 물안개 | 수둔 + 은신술 | 2x2 | 회피 `+10%p`, 이동속도 `+8%`, 상태/반응 효과 `+20%` | 회피+제어형. 원본 4칸→4칸이라 공간 압축 없음 |
| `thunder_blade` | 뇌명도 | 일본도 + 뇌둔 | 1x3 | 비오의 유파 직접 피해 `+28%`, 유파 자원 `+10%`, 이동속도 `+5%` | 공격적 고속 순환. 원본 5칸→3칸 압축이 강하므로 1차 watch item |
| `explosive_bomb` | 폭렬탄 | 폭탄 + 화둔 | 2x2 | 유파 피해 `+22%`, 비오의 유파 직접 피해 `+10%`, 상태/반응 효과 `+22%`, 받는 피해 `+5%` | 광역/상태 고출력 + 작은 리스크. 원본 6칸→4칸 압축 |

### Combo rollback watch

`thunder_blade`가 조합 가능할 때 사실상 자동 선택이 되면 코어 조합 규칙을 건드리지 않고 다음 순서로 조정한다.

1. result footprint `1x3 → 1x4`.
2. 그래도 과하면 non-ultimate bonus `+28% → +22%`.
3. 그래도 과하면 resource bonus를 제거/감소.

## 5. Bag catalog — 5

현 승인 방향 `일반 4 + 특수 1`을 유지한다.

| ID | Cells | 가격 | Type | Initial auxiliary effect |
|---|---|---:|---|---|
| `small_pouch` | `(0,0),(1,0)` | 20G | normal | 없음 |
| `long_pouch` | `(0,0),(1,0),(2,0)` | 30G | normal | 없음 |
| `square_pouch` | `(0,0),(1,0),(0,1),(1,1)` | 40G | normal | 없음 |
| `tactical_t_pouch` | `(0,0),(1,0),(2,0),(1,1)` | 45G | normal / irregular | 없음 — T 모양 자체가 가치 |
| `ninjutsu_l_pouch` | `(0,0),(0,1),(0,2),(1,2)` | 50G | **special / irregular** | 1칸 이상 overlap한 `ninjutsu` item마다 `school_resource_gain_pct +4%`, 같은 bag instance는 item당 1회 |

Distinct special bag instances may each apply once per the approved core rule, but REST당 bag 구매 최대 1개 권장값을 유지한다.

### Initial bag offer weights

```yaml
small_pouch: 0.28
long_pouch: 0.24
square_pouch: 0.20
tactical_t_pouch: 0.13
ninjutsu_l_pouch: 0.15
```

특수 L가 지나치게 필수/희귀하게 느껴지면 `10%~20%` 범위 안에서 먼저 조정한다.

## 6. Acquisition weighting

가중치는 서로 다른 획득처의 역할을 유지한다.

### Boss reward — quality / choice

- 3 options → choose 1.
- **Slot A**: current-school affinity 후보만 대상으로 weighted draw하여 최소 1개 보장.
- **Slot B/C**: general weighted pool, 이미 선택된 item id 제외.
- combo result는 pool에서 제외.

General initial weight:

```yaml
base: 100
recipe_completion_if_player_holds_other_source: +60
matches_one_of_top_active_build_tags: +30
high_value_price_ge_40_or_footprint_ge_4: +25
already_owned_duplicate: -30
minimum_weight: 40
maximum_weight: 220
```

`high_value` 보정은 boss reward에만 적용한다.

### Shop — control / economy

- 아이템 3개는 without replacement.
- 별도 bag offer 1개.
- reroll `5G → 10G → 15G` 유지.
- sell value는 기존 `floor(base_price / 2)` 유지.
- current duplicate cap `2`는 first pass 유지한다.

Initial item weight:

```yaml
base: 100
current_school_affinity: +35
recipe_completion: +50
matches_active_build_tag: +25
already_owned_duplicate: -25
minimum_weight: 40
maximum_weight: 200
```

### Chest — quantity / randomness

Chest는 curated shop의 복제본이 되지 않는다.

```yaml
base: 100
current_school_affinity: +10
matches_active_build_tag: +10
recipe_completion_bonus: 0
high_value_bonus: 0
```

- token 1개 → 아이템 2개.
- 두 아이템은 같은 chest draw 안에서 id 중복 없이 권장.
- buffer free slots `<2`면 기존 승인대로 개봉 불가/토큰 미소비.

## 7. Tag vocabulary

### Player-facing primary groups

```yaml
school_affinity:
  - bongma
  - cheonsul
  - guiin
  - heukyeong
attack_style:
  - melee
  - ranged
  - aoe
function:
  - summon
  - status
  - survival
  - support
  - movement
  - stealth
attribute:
  - fire
  - water
  - lightning
  - poison
equipment:
  - weapon
  - ninjutsu
  - curse
special:
  - combo_core
  - connector
  - ritual
```

MVP-4에서 사용하지 않는 미래 `set`, 깊은 curse system, arbitrary rarity는 player-facing active tag로 확대하지 않는다.

### Tag readability rule

한 아이템 카드에서 기본 노출 태그는 **최대 3개**를 우선한다. 나머지는 상세보기/내부 affinity로 둘 수 있다. 태그 수가 많다고 정보량이 좋아지는 것은 아니다.

## 8. First REST onboarding

목표: 팝업 설명을 읽었다는 사실이 아니라 **혼자 다음 전투를 준비할 수 있음**을 증명한다.

### RULE → NEED → DISCOVER → FEEL → PROVE → TRANSFER

1. **RULE** — buffer item은 아직 combat-active가 아니다.
2. **NEED** — boss reward가 buffer에 들어오고 Fate checklist가 이를 미완료 상태로 보여준다.
3. **DISCOVER** — reward 선택 시 legal cells + footprint preview를 보이고, 첫 invalid placement는 이유+다음 행동을 보여준다.
4. **FEEL** — 첫 valid placement 직후 `BuildPreviewSnapshot`의 변화량을 즉시 보여준다. 예: `유파 피해 +12%`.
5. **PROVE** — 플레이어가 buffer를 0으로 만들고 Fate check를 스스로 통과한다.
6. **TRANSFER** — 다음 REST에는 강제 callout을 접고 동일한 board feedback만으로 수행하게 한다.

### Onboarding details

- 첫 Workbench 진입 시 1회: `버퍼 아이템은 아직 다음 전투에 적용되지 않습니다.`
- reward 선택 시 배치 가능 footprint highlight.
- invalid는 색만 쓰지 않고 outline + reason text + 가능한 다음 행동.
- 인접/조합 가능 상태는 icon/text cue를 함께 사용.
- rotate는 첫 REST에 무조건 강제하지 않는다. 실제로 회전이 유용하거나 필요한 첫 상황에서 contextual hint를 연다.
- Fate blocker를 누르면 해당 buffer/placement/pending-combo surface로 focus 이동.
- 첫 성공 배치 후 장문 callout은 사라지고 normal tooltip로 축소.
- keyboard/gamepad/touch에 동일한 학습 목표를 적용한다.

## 9. Formative playtest contract

아래는 **작은 표본의 formative target**이지 통계적 출시 증명이 아니다.

```yaml
initial_target_participants: 5
human_usability_evidence: NOT_RUN
player_experience_evidence: NOT_RUN
```

### Usability targets

- `>=4/5`: 진행자 조작 도움 없이 boss reward를 buffer→유효 backpack placement로 옮기고 Fate까지 진입.
- `>=4/5`: “buffer item은 배치/commit 전 combat-active가 아니다”를 자신의 말로 설명.
- `>=4/5`: adjacency 또는 combination cue 하나 이상을 이해.
- first REST median target: `<=120s`.
- second/repeat REST median target: `<=75s`.

### Player-experience targets

- `>=4/5`: “왜 거기에 놓았나?” 질문에 공간/시너지/조합 중 하나 이상의 이유를 답함.
- `>=4/5`: REST 전후 다음 전투에서 달라질 점을 하나 이상 정확히 예측.
- 정답 자동배치처럼 느껴진다는 반복 피드백이 없어야 함.

## 10. Planned telemetry / observation events

```text
rest_enter
boss_reward_selected
reward_to_buffer
item_selected
placement_attempted
placement_invalid_reason
item_rotated
adjacency_changed
combo_hint_level_changed
combo_preview_opened
combo_committed
combo_cancelled
fate_block_reason
rest_exit
rest_duration
next_combat_contribution_summary
```

자동 telemetry만으로 HUMAN_USABILITY 또는 PLAYER_EXPERIENCE를 PASS 처리하지 않는다.

## 11. Tuning signals and rollback

### REST too slow

If repeat REST median remains `>90s` after onboarding:

```text
1. reduce info noise / tooltips
2. improve placement and synergy cues
3. reduce or cap individual strong-spatial bonuses/rules
4. adjust acquisition choice density
5. only then reconsider footprint/core rules
```

Board 6x6, rotation, adjacency, Persistent Workbench를 첫 대응으로 삭제하지 않는다.

### Spatial effects too weak

Strong-spatial item이 offer 되었을 때 선택/유지가 `<20%` 수준으로 반복되고 사람 관찰에서도 공간효과를 무시한다면:

- 해당 spatial bonus를 약 `+15~20%` 상대 조정하거나,
- cue/readability 문제를 먼저 수정한다.

### Spatial outlier too dominant

특정 spatial item이 가용한 성공 layout의 `>70%`에서 사실상 자동 채택되고 이유가 “너무 세서”로 수렴하면:

- spatial bonus를 `20~30%` 상대 감소하거나 cap을 낮춘다.
- 아이템을 삭제하거나 전체 adjacency 규칙을 약화하지 않는다.

### Reward steering too strong

같은 recipe/school cluster가 대부분 run에서 반복되면:

- boss/shop affinity/recipe weight를 10~20포인트씩 낮춘다.
- chest bias를 더 강화하지 않는다.

## 12. Implementation handoff note

이 문서의 값은 `기획 완료 → PHASE B PASS` 전에는 실행하지 않는다.

Phase B에서 반드시 재확인할 것:

1. current `RunModifierSet` / school runtimes가 위 modifier를 실제 소비하는지.
2. T01 catalog schema가 tag/affinity/spatial rule을 중복 authority 없이 표현하는지.
3. `BackpackResolver`가 strong-spatial effect를 deterministic하게 계산하는지.
4. reward weighting이 seed/injection 가능한지.
5. combo result가 acquisition pool에 들어가지 않는지.
6. current code/plan과 충돌하는 새 field가 생기면 구현 편의로 임의 확정하지 말고 Phase B finding으로 처리.
