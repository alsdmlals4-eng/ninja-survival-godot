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
| `MVP_ROADMAP.md` | MVP-0~MVP-5 단계별 범위와 완료 기준 | MVP-4 승인 범위 동기화 |
| `docs/CURRENT_CONFIRMED_DECISIONS.md` | 최신 사용자 승인 제품/설계 결정 정본 | 현재 MVP-4 결정 기록 |
| `docs/ACTIVE_CONTEXT.md` | 현재 baseline, 구현/검증 상태, next executable step를 연결하는 resume router | 현재 MVP-4 상태 기록 |
| `docs/handoffs/*.md` | 세션/담당자 경계의 날짜별 인수인계 스냅샷. 결정 전문이나 구현 진척 정본을 중복 소유하지 않음 | 필요 시 추가 |
| `TEST_CHECKLIST.md` | 실행/검수 체크리스트 | 초기 작성, MVP 단계별 갱신 필요 |
| `docs/BASE_RULES_VERSION.md` | Base 공용 규칙 동기화 기준 | 초기 작성, current Base drift 확인 필요 |
| `docs/UNITY_MIGRATION_AUDIT.md` | Unity 원본 분석 결과 | Unity ZIP 확인 후 갱신 필요 |
| `docs/GODOT_PORT_PLAN.md` | Godot 전환 계획 | Unity 분석 및 새 MVP 범위 반영 필요 |
| `docs/SYSTEM_MAP.md` | 시스템/파일/노드 매핑 | 갱신됨 |
| `docs/CODEX_GOAL_MVP_001.md` | Codex MVP-001 / MVP-0 기본 전투 기반 실행 지시문 | 갱신됨 |

## 현재 문서 기준

현재 기획 MVP는 기존 최소 전투 루프보다 넓다.

- 기존 최소 전투 루프는 `MVP-0`으로 유지한다.
- 전체 기획 MVP는 `MVP_ROADMAP.md`의 `MVP-0`~`MVP-5`로 나눈다.
- 최신 승인된 제품 결정을 `docs/CURRENT_CONFIRMED_DECISIONS.md`에 기록한다.
- `docs/ACTIVE_CONTEXT.md`는 현재 구현/검증/다음 작업만 압축해 연결하고 제품 결정 전문을 복제하지 않는다.
- 날짜별 Handoff는 session boundary snapshot이며, 재개 시 GitHub 최신 상태와 다시 대조한다.
- Codex Goal 하나에 전체 기획 MVP를 넣지 않는다.
- 다음 Codex Goal은 `docs/CODEX_GOAL_MVP_001.md`처럼 작게 작성한다.

## 작업 기준

- Unity 원본 분석 전에는 구현 완료를 추정하지 않는다.
- Unity 코드는 참고 자료로만 사용한다.
- Godot 구현 문서는 Godot/GDScript 용어로 작성한다.
- 작업 시작 전 Base와 벤치마킹 기준을 확인한다.
- 사용자의 말을 좋은 작업 프롬프트로 변환한 뒤 진행한다.
- Base로 승격할 내용과 프로젝트 전용 내용을 구분한다.
- Handoff/Active Context가 현재 저장소 truth와 충돌하면 저장소 truth를 먼저 확인한 뒤 상태 문서를 교정한다.
