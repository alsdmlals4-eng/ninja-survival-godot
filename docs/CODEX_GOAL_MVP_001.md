# Codex Goal: MVP-001 Godot 최소 전투 루프

## 시작 문구

```text
@Superpowers Use this repository's spec-first workflow.
```

## 목표

Unity 원본을 참고하되 직접 번역하지 않고, Godot 4.x + GDScript 기준으로 `닌자 서바이벌`의 최소 전투 루프를 구현한다.

## 먼저 읽을 문서

1. `AGENTS.md`
2. `README.md`
3. `PROJECT_BRIEF.md`
4. `DESIGN_INTENT.md`
5. `MVP_ROADMAP.md`
6. `TEST_CHECKLIST.md`
7. `docs/BASE_RULES_VERSION.md`
8. `docs/DOCUMENTATION_MAP.md`
9. `docs/UNITY_MIGRATION_AUDIT.md`
10. `docs/GODOT_PORT_PLAN.md`
11. `docs/SYSTEM_MAP.md`

## 작업 전 요약 필수

파일 수정 전 다음을 먼저 요약한다.

- 목표
- 의도한 플레이어 경험
- 구현 범위
- 제외 범위
- 변경 가능성이 있는 파일
- 위험 요소
- 완료 기준
- 테스트 체크리스트

## 구현 범위

- 메인 테스트 씬
- 플레이어 8방향 이동
- 카메라 추적
- 하급 적 1종 추적
- 자동 기본 투사체 발사
- 투사체 충돌/적 피격
- 적 제거 또는 비활성화
- 점수 증가
- 기본 HUD 표시

## 제외 범위

- Unity 코드 줄 단위 번역
- 문파 선택
- 인법 조합
- 가방/휴식 페이즈
- 상점/강화
- 오의/보법 확장
- 복잡한 애니메이션 전체
- 고급 무한맵
- 저장 시스템

## 권장 파일 구조

```text
scenes/main/main_scene.tscn
scenes/player/player.tscn
scenes/enemies/enemy_basic.tscn
scenes/projectiles/projectile_basic.tscn
scenes/ui/hud.tscn
scripts/core/game_state.gd
scripts/player/player_controller.gd
scripts/enemies/enemy_chaser.gd
scripts/combat/auto_attack_controller.gd
scripts/combat/projectile.gd
scripts/ui/hud.gd
```

## 완료 기준

- Godot 프로젝트가 열린다.
- 메인 씬이 실행된다.
- 플레이어가 8방향으로 이동한다.
- 카메라가 플레이어를 따라간다.
- 적이 플레이어를 추적한다.
- 투사체가 자동으로 발사된다.
- 투사체가 적에게 닿으면 피격/제거가 처리된다.
- 점수가 증가하고 HUD에 표시된다.
- 테스트하지 못한 항목은 보고된다.

## 최종 보고 형식

```md
## Superpowers 사용 여부

- 호출 가능 여부:
- 실제 호출 여부:
- 자동 적용/명시 호출 여부:

## 변경 파일

-

## 구현 내용

-

## 검증 내용

-

## Godot 확인 순서

1.
2.
3.

## 남은 위험

-

## Compound Review

- 실수 또는 near-miss:
- 교훈:
- 다음 작업 예방 체크리스트:
- 다음 Codex 프롬프트에 추가할 문장:
- Base 승격 후보:
- 프로젝트 전용 규칙 후보:
```
