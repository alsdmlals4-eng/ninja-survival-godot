# SYSTEM_MAP

## 목적

이 문서는 `닌자 서바이벌` Godot 버전의 시스템 구조와 파일 역할을 정리한다.

## MVP-001 시스템 맵

| 시스템 | Godot 파일/씬 후보 | 역할 | 상태 |
|---|---|---|---|
| 게임 상태 | `scripts/core/game_state.gd` | 점수, 게임 진행 상태 관리 | 예정 |
| 메인 씬 | `scenes/main/main_scene.tscn` | 테스트 실행 루트 | 예정 |
| 플레이어 | `scenes/player/player.tscn` / `scripts/player/player_controller.gd` | 이동, 방향, 기본 상태 | 예정 |
| 카메라 | `Camera2D` child or main scene camera | 플레이어 추적 | 예정 |
| 적 | `scenes/enemies/enemy_basic.tscn` / `scripts/enemies/enemy_chaser.gd` | 플레이어 추적, 피격 | 예정 |
| 자동 공격 | `scripts/combat/auto_attack_controller.gd` | 주기적으로 투사체 생성 | 예정 |
| 투사체 | `scenes/projectiles/projectile_basic.tscn` / `scripts/combat/projectile.gd` | 이동, 충돌, 적 피격 | 예정 |
| UI | `scenes/ui/hud.tscn` / `scripts/ui/hud.gd` | 점수 표시 | 예정 |
| 데이터 | `data/enemies/enemies.json`, `data/weapons/weapons.json` | 적/무기 수치 | 예정 |

## Unity 분석 후 갱신할 항목

- Unity 스크립트명
- 기존 구현 기능
- Godot 대응 파일
- 유지/변경/삭제 여부
- 이식 우선순위
- 위험 요소

## 설계 원칙

- 상태 소유자를 중복시키지 않는다.
- 플레이어, 적, 투사체, UI 책임을 분리한다.
- 첫 MVP에서는 데이터화보다 실행 가능한 최소 루프를 우선한다.
- 저장/가방/인법 조합은 후속 MVP로 분리한다.
