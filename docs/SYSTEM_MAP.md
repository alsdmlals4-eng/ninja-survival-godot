# SYSTEM_MAP

## 목적

이 문서는 `닌자 서바이벌` Godot 버전의 시스템 구조와 파일 역할을 정리한다.

## 현재 MVP 해석

기존 최소 전투 루프는 `MVP-0` 기반 전투로 유지한다.

현재 기획 MVP는 완성판이 아니라 핵심 재미 검증판이다. 각 시스템은 한 번에 완성하지 않고 단계형 Codex Goal로 구현한다.

## MVP 단계별 시스템 맵

| 단계 | 시스템 | Godot 파일/씬 후보 | 역할 | 상태 |
|---|---|---|---|---|
| MVP-0 | 게임 상태 | `scripts/core/game_state.gd` | 점수, 시간, 진행 상태 관리 | 예정 |
| MVP-0 | 메인 씬 | `scenes/main/main_scene.tscn` | 테스트 실행 루트 | 예정 |
| MVP-0 | 플레이어 | `scenes/player/player.tscn` / `scripts/player/player_controller.gd` | 이동, 방향, 기본 상태 | 예정 |
| MVP-0 | 카메라 | `Camera2D` child or main scene camera | 플레이어 추적 | 예정 |
| MVP-0 | 적 | `scenes/enemies/enemy_basic.tscn` / `scripts/enemies/enemy_chaser.gd` | 플레이어 추적, 피격 | 예정 |
| MVP-0 | 자동 공격 | `scripts/combat/auto_attack_controller.gd` | 주기적으로 투사체 생성 | 예정 |
| MVP-0 | 투사체 | `scenes/projectiles/projectile_basic.tscn` / `scripts/combat/projectile.gd` | 이동, 충돌, 적 피격 | 예정 |
| MVP-0 | HUD | `scenes/ui/hud.tscn` / `scripts/ui/hud.gd` | HP, 점수, 기본 상태 표시 | 예정 |
| MVP-1 | 처치 콤보 | `scripts/combat/kill_combo_tracker.gd` | 연속 처치, 최대 콤보, 콤보 타이머 관리 | 예정 |
| MVP-1 | 스타일리쉬 점수 | `scripts/results/stylish_score.gd` | 콤보/처치/전투 성과를 점수/랭크 후보로 변환 | 예정 |
| MVP-1 | 보상 흡수 | `scenes/pickups/pickup_orb.tscn` / `scripts/pickups/pickup_orb.gd` | 경험치/골드/보상 흡수감 | 예정 |
| MVP-2 | 유파 선택 | `scenes/ui/school_select.tscn` / `scripts/schools/school_selector.gd` | 4유파 선택 | 예정 |
| MVP-2 | 유파 데이터 | `data/schools/schools.json` | 봉마류/천술류/귀인류/흑영류 최소 구성 | 예정 |
| MVP-2 | 유파 규칙 | `scripts/schools/school_runtime.gd` | 영력, 오행 반응, 귀혈, 표식 등 얕은 고유 규칙 | 예정 |
| MVP-2 | 오의 | `scripts/combat/ultimate_controller.gd` | 유파별 기본 오의 발동 | 예정 |
| MVP-3 | 스테이지 타이머 | `scripts/stages/stage_timer.gd` | 5/10/15/20분 흐름 관리 | 예정 |
| MVP-3 | 중간보스 체크 | `scripts/stages/midboss_trigger.gd` | 스테이지 종료 조건과 휴식 진입 | 예정 |
| MVP-3 | 전투 기여도 | `scripts/results/combat_contribution_tracker.gd` | 딜/힐/방어/상태이상/콤보 기여도 집계 | 예정 |
| MVP-3 | 중간 결과 UI | `scenes/results/stage_result_screen.tscn` / `scripts/results/stage_result_screen.gd` | 스테이지 종료 카드형 요약 | 예정 |
| MVP-3 | 휴식 루프 | `scenes/rest/rest_screen.tscn` / `scripts/rest/rest_flow.gd` | 전투 결과→전리품→백팩→조합→상점→운명→다음 전투 | 예정 |
| MVP-3 | 운명 선택 | `scenes/rest/fate_select.tscn` / `scripts/rest/fate_controller.gd` | 보상+대가가 있는 한 판 규칙 변경 | 예정 |
| MVP-4 | 백팩 | `scenes/rest/backpack_panel.tscn` / `scripts/rest/backpack_model.gd` | 칸 제한, 임시 보관함, 아이템 배치 | 예정 |
| MVP-4 | 인접 시너지 | `scripts/rest/adjacency_synergy.gd` | 배치에 따른 시너지 후보/활성화 | 예정 |
| MVP-4 | 조합 힌트 | `scripts/rest/combination_hint.gd` | 대표 1차 조합 가능성 표시 | 예정 |
| MVP-5 | 최종 보스 흐름 | `scripts/stages/final_boss_flow.gd` | 20분 최종 전투 진입/종료 | 예정 |
| MVP-5 | 최종 결과 UI | `scenes/results/final_result_screen.tscn` / `scripts/results/final_result_screen.gd` | 랭크, MVP, 운명 결과, 결말문, 닌자소울 | 예정 |
| MVP-5 | 닌자소울 | `scripts/meta/ninja_soul.gd` | 획득/표시/간단한 해금 틀 | 예정 |

## 데이터 후보

| 데이터 | 후보 경로 | 목적 |
|---|---|---|
| 적 | `data/enemies/enemies.json` | 적 기본 수치와 타입 |
| 무기 | `data/weapons/weapons.json` | 자동 공격/장비 후보 |
| 인법 | `data/ninjutsu/ninjutsu.json` | 대표 전투/보조 인법 |
| 유파 | `data/schools/schools.json` | 4유파 최소 구성 |
| 스테이지 | `data/stages/stages.json` | 5분 루프, 보스, 보상 흐름 |
| 운명 | `data/fates/fates.json` | 보상/대가/결과 경향 |
| 조합 | `data/combinations/combinations.json` | 대표 1차 조합 후보 |

## 스테이지 중간 결과 지표

스테이지 종료 중간 결과 화면은 다음 지표를 카드형으로 표시한다.

- 딜량 1위
- 힐량 1위
- 방어량 1위
- 상태이상 부여 1위
- 콤보/처치 1위
- 최대 콤보
- 주요 획득물
- 추천 성장 힌트 1~2개

## 설계 원칙

- 상태 소유자를 중복시키지 않는다.
- 플레이어, 적, 투사체, UI, 결과 집계, 휴식 흐름의 책임을 분리한다.
- 첫 구현 Goal 하나에 현재 기획 MVP 전체를 넣지 않는다.
- MVP-0은 실행 가능한 전투 기반을 우선한다.
- MVP-1 이후부터 전투 DDD, 유파, 휴식, 백팩, 운명을 단계적으로 붙인다.
- 저장/완전한 경제/전체 조합/정교한 엔딩 분기는 후속 MVP로 분리한다.

## Unity 분석 후 갱신할 항목

- Unity 스크립트명
- 기존 구현 기능
- Godot 대응 파일
- 유지/변경/삭제 여부
- 이식 우선순위
- 위험 요소
