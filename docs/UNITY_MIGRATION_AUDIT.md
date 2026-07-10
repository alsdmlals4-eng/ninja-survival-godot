# UNITY_MIGRATION_AUDIT

## 목적

이 문서는 기존 Unity `닌자 서바이벌` 프로젝트를 Godot로 재구현하기 전에, Unity 원본에서 보존해야 할 구현/기획 정보를 추출하기 위한 감사 문서다.

## 현재 확인 상태

- Unity 아카이브 저장소: `alsdmlals4-eng/ninja-survival-unity-archive-Unity-`
- Unity ZIP 확인 커밋: `99c241a979649b1f0a7574c2d39e11ca73e67cdc`
- Unity ZIP 파일명: `ninza.zip`
- GitHub 커넥터로 ZIP 파일 존재와 blob SHA는 확인했다.
- 현재 ChatGPT/GitHub 커넥터에서는 ZIP 바이너리 내부를 직접 풀어 분석하지 못했다.
- 다음 단계는 Codex 또는 로컬 환경에서 ZIP을 풀고 `Assets/`, `Packages/`, `ProjectSettings/` 구조를 확인하는 것이다.

## 확인할 Unity 자료

| 항목 | 확인할 내용 | Godot 반영 방향 | 상태 |
|---|---|---|---|
| ZIP 압축 해제 | `ninza.zip` 내부 폴더 구조 | 분석 전제 조건 | 확인 필요 |
| Assets/ | 스크립트, 씬, 프리팹, 애셋 | Godot 이식 기준 자료 | 대기 |
| Packages/ | Unity 패키지 의존성 | Godot에서 대체/제외 판단 | 대기 |
| ProjectSettings/ | 입력, 물리, 태그, 레이어 설정 | Godot 프로젝트 설정 참고 | 대기 |
| PlayerMovement.cs | 이동, 방향, 애니메이션 파라미터 | `player_controller.gd` 설계 참고 | 대기 |
| EnemyChase.cs | 적 추적, 공격 거리, 쿨다운 | `enemy_chaser.gd` 설계 참고 | 대기 |
| 투사체 스크립트 | 수리검 이동, 관통, 충돌 | `projectile.gd` 설계 참고 | 대기 |
| 스폰 시스템 | 적 생성 위치/주기 | `spawn_manager.gd` 설계 참고 | 대기 |
| 점수 UI | 점수 표시/최고 점수 | `score_ui.gd` 설계 참고 | 대기 |
| 게임오버 UI | 종료/재시작 흐름 | `game_over_ui.gd` 설계 참고 | 대기 |
| 카메라 | 추적 방식 | Godot `Camera2D` 구조 참고 | 대기 |
| 애니메이션 | Idle/Move/Attack/Hit/Death | `AnimatedSprite2D` 또는 `AnimationPlayer` | 대기 |
| 애셋 | 128x128 SD 픽셀 아트 | `assets/sprites/`로 분리 | 대기 |

## Godot 전환 원칙

- Unity C# 코드를 GDScript로 줄 단위 번역하지 않는다.
- Unity Prefab은 Godot Scene으로 재구성한다.
- Unity Animator는 Godot `AnimatedSprite2D` 또는 `AnimationPlayer`로 재설계한다.
- Unity Rigidbody2D 기반 이동은 Godot `CharacterBody2D` 또는 `Area2D` 구조로 재설계한다.
- PlayerPrefs가 있다면 Godot 저장 파일 또는 `ConfigFile`/JSON으로 바꾼다.

## Codex 분석 지시 초안

```text
@Superpowers Use this repository's spec-first workflow.

Goal:
Analyze the Unity archive ZIP `ninza.zip` from `alsdmlals4-eng/ninja-survival-unity-archive-Unity-` and update the Godot migration documents.

Do not implement Godot gameplay yet.
Do not directly convert Unity C# into GDScript.

First extract or inspect `ninza.zip`, then report:
1. Root folder structure
2. Whether Assets/, Packages/, ProjectSettings/ exist
3. C# scripts found under Assets/
4. Scenes, prefabs, animations, sprites, UI assets, and data files found
5. Existing implemented gameplay systems
6. Unity-to-Godot mapping table
7. MVP-001 scope adjustments
8. Risks and missing files

Then update:
- docs/UNITY_MIGRATION_AUDIT.md
- docs/GODOT_PORT_PLAN.md
- docs/SYSTEM_MAP.md

Final report must include Compound Review.
```

## Unity ZIP 분석 후 작성할 것

- 실제 Unity 파일 구조
- 핵심 스크립트 목록
- 각 스크립트 역할
- 유지할 기능
- 버릴 기능
- Godot MVP-001에 반영할 기능
- 후순위 기능
- 위험 요소
