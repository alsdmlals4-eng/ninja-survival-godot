# DOCUMENTATION_MAP

## 목적

이 문서는 `ninja-survival-godot` 저장소의 문서 역할을 구분한다.

## 핵심 문서

| 문서 | 역할 | 상태 |
|---|---|---|
| `AGENTS.md` | AI/Codex 최상위 작업 규칙, 현재 단계형 MVP 기준 | 갱신됨 |
| `README.md` | 저장소 소개와 현재 MVP 요약 | 갱신됨 |
| `PROJECT_BRIEF.md` | 프로젝트 한 줄 설명, 장르, 핵심 경험, 4유파 MVP 방향 | 갱신됨 |
| `DESIGN_INTENT.md` | 기획 의도, 전투 DDD, 휴식 구간, 벤치마킹 반영 원칙 | 갱신됨 |
| `MVP_ROADMAP.md` | MVP-0~MVP-5 단계별 범위와 완료 기준 | 갱신됨 |
| `TEST_CHECKLIST.md` | 실행/검수 체크리스트 | 초기 작성, MVP 단계별 갱신 필요 |
| `docs/BASE_RULES_VERSION.md` | Base 공용 규칙 동기화 기준 | 초기 작성 |
| `docs/UNITY_MIGRATION_AUDIT.md` | Unity 원본 분석 결과 | Unity ZIP 확인 후 갱신 필요 |
| `docs/GODOT_PORT_PLAN.md` | Godot 전환 계획 | Unity 분석 및 새 MVP 범위 반영 필요 |
| `docs/SYSTEM_MAP.md` | 시스템/파일/노드 매핑 | 갱신됨 |
| `docs/CODEX_GOAL_MVP_001.md` | Codex MVP-001 / MVP-0 기본 전투 기반 실행 지시문 | 갱신됨 |

## 현재 문서 기준

현재 기획 MVP는 기존 최소 전투 루프보다 넓다.

- 기존 최소 전투 루프는 `MVP-0`으로 유지한다.
- 전체 기획 MVP는 `MVP_ROADMAP.md`의 `MVP-0`~`MVP-5`로 나눈다.
- Codex Goal 하나에 전체 기획 MVP를 넣지 않는다.
- 다음 Codex Goal은 `docs/CODEX_GOAL_MVP_001.md`처럼 작게 작성한다.

## 작업 기준

- Unity 원본 분석 전에는 구현 완료를 추정하지 않는다.
- Unity 코드는 참고 자료로만 사용한다.
- Godot 구현 문서는 Godot/GDScript 용어로 작성한다.
- 작업 시작 전 Base와 벤치마킹 기준을 확인한다.
- 사용자의 말을 좋은 작업 프롬프트로 변환한 뒤 진행한다.
- Base로 승격할 내용과 프로젝트 전용 내용을 구분한다.
