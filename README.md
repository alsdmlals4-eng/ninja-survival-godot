# Ninja Survival Godot

`닌자 서바이벌`의 Godot 4.x 재구현 저장소다.

기존 Unity 구현은 별도 아카이브 저장소에 보존하고, 이 저장소에서는 Godot + GDScript 기준으로 재설계한다.

## 관련 저장소

- Unity 보존 저장소: `alsdmlals4-eng/ninja-survival-unity-archive-Unity-`
- Godot 전환 저장소: `alsdmlals4-eng/ninja-survival-godot`

## 핵심 방향

- Unity 코드를 그대로 번역하지 않는다.
- Unity 구현은 참고 자료로만 사용한다.
- Godot 4.x의 Scene/Node/GDScript 구조에 맞춰 재설계한다.
- 첫 Godot MVP는 최소 전투 루프만 다룬다.

## 첫 MVP 범위

포함:

- 플레이어 8방향 이동
- 카메라 추적
- 하급 적 1종 추적
- 자동 투사체 공격
- 적 피격/제거
- 기본 점수 UI
- 기본 게임오버 흐름

제외:

- 가방 시스템
- 문파 선택
- 인법 조합
- 오의/보법 강화
- 휴식 페이즈
- 상점/강화
- 복잡한 애니메이션 전체 이식

## 실행 기준

Godot 4.x 기준으로 `project.godot`을 열고, 이후 생성될 메인 씬을 실행한다.

현재 저장소는 전환 준비용 골격 상태이며, 실제 Unity ZIP 분석 후 `docs/UNITY_MIGRATION_AUDIT.md`와 `docs/GODOT_PORT_PLAN.md`를 갱신해야 한다.
