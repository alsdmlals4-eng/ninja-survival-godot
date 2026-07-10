# GODOT_PORT_PLAN

## 목표

기존 Unity 구현물을 참고하여 `닌자 서바이벌`을 Godot 4.x + GDScript 구조로 재구현한다.

## 전환 원칙

```text
Unity 원본 보존 → 기능/의도 추출 → Godot 구조 재설계 → MVP 단위 재구현 → 검증 → Compound Review
```

## 저장소 분리

| 저장소 | 역할 |
|---|---|
| `ninja-survival-unity-archive-Unity-` | Unity 원본 보존 |
| `ninja-survival-godot` | Godot 재구현 |

Unity 저장소의 코드는 직접 수정하지 않고, Godot 구현의 참고 자료로 사용한다.

## MVP-001 구현 목표

Godot에서 최소 전투 루프를 만든다.

### 포함

- `main_scene.tscn`: 테스트 메인 씬
- `player.tscn`: 플레이어 씬
- `enemy_basic.tscn`: 하급 적 씬
- `projectile_basic.tscn`: 기본 투사체 씬
- `hud.tscn`: 점수 UI
- 플레이어 이동
- 카메라 추적
- 적 추적
- 자동 투사체 발사
- 적 피격/제거
- 점수 증가

### 제외

- 전체 Unity 씬 변환
- 전체 애니메이션 이식
- 문파/인법/가방/휴식 시스템
- 상점/강화/메타 성장
- 복잡한 적 패턴

## 권장 Godot 구조

```text
scenes/
  main/main_scene.tscn
  player/player.tscn
  enemies/enemy_basic.tscn
  projectiles/projectile_basic.tscn
  ui/hud.tscn
scripts/
  core/game_state.gd
  player/player_controller.gd
  enemies/enemy_chaser.gd
  combat/projectile.gd
  combat/auto_attack_controller.gd
  ui/hud.gd
assets/
  sprites/
  animations/
  audio/
data/
  enemies/enemies.json
  weapons/weapons.json
```

## Unity → Godot 개념 매핑

| Unity 개념 | Godot 대응 |
|---|---|
| GameObject | Node/Scene |
| Prefab | `.tscn` Scene |
| MonoBehaviour | GDScript attached to Node |
| Rigidbody2D movement | `CharacterBody2D` movement |
| Collider2D trigger | `Area2D` body/area signal |
| Animator | `AnimatedSprite2D` or `AnimationPlayer` |
| ScriptableObject | `.tres` Resource or JSON data |
| PlayerPrefs | `ConfigFile` or JSON save |
| Canvas UI | `Control` UI tree |

## 위험 요소

- Unity 코드를 줄 단위 번역하면 Godot 구조가 어색해질 수 있다.
- 프리팹/씬/애니메이터 개념을 혼동할 수 있다.
- 첫 MVP 범위가 커지면 전환 실패 위험이 높다.
- Unity ZIP이 아직 확인되지 않았으므로 실제 구현 상태는 추정하면 안 된다.

## 다음 단계

1. Unity ZIP이 GitHub에 커밋되었는지 확인한다.
2. Unity 스크립트와 씬을 분석한다.
3. `UNITY_MIGRATION_AUDIT.md`를 실제 파일 기준으로 갱신한다.
4. MVP-001 Codex Goal을 실행한다.
5. Godot 최소 전투 루프를 구현한다.
