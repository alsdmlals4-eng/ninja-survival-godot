# Base Rules Version

## 프로젝트에 동기화된 기준

- 공용 원본: `alsdmlals4-eng/Base`
- 기준 브랜치: `main`
- 프로젝트에 마지막으로 명시 동기화된 기준 커밋: `499c20eb9b449241864f5ada0c915fba8a7806ac`
- 해당 동기화 확인 날짜: `2026-07-10`

이 SHA는 **현재 Base 원격 HEAD라는 뜻이 아니다**. 프로젝트에 어떤 Base 기준이 마지막으로 명시 동기화됐는지를 기록한다.

## 최신 원격 관찰

```yaml
latest_base_main_observed: 315c66eea9614c284b9c11c4d522141065dfa4b0
observed_at: 2026-08-11 KST
full_base_rule_sync: NOT_RUN
```

이번 MVP-4 기획 작업은 최신 Base에서 다음 현행 패턴을 조회·재사용했다.

- PLAN / BUILD / REVIEW Work Mode + Registry automatic routing.
- `[연속작업] 진행해` continuous-work recovery/defer/continue 계약.
- `maintaining-project-context-and-handoff` current-state ownership.
- L2 `GAME_FEATURE_DESIGN_SPEC` hierarchy.
- `EXTERNAL_PROCESS_OVERLAY` 경계: Superpowers는 실행 프로세스이며 프로젝트 정본/Decision 권위를 소유하지 않음.
- 적대적 검토와 canonical-reference freshness 계약.

최신 원격 Base를 읽고 일부 패턴을 사용한 사실을 **프로젝트 전체 Base 동기화 완료**로 해석하지 않는다.

## 사용 규칙

1. 최신 사용자 지시와 프로젝트 `AGENTS.md`가 우선한다.
2. 제품 Decision은 `docs/CURRENT_CONFIRMED_DECISIONS.md`, 현재 상태는 `docs/ACTIVE_CONTEXT.md`를 따른다.
3. 일상 작업은 프로젝트에 동기화된 규칙을 사용하되, 사용자가 Base 최신본 검토를 요구하거나 drift가 작업에 영향을 줄 때 Base 원격을 다시 조회한다.
4. 원격 Base의 새 계약을 선택적으로 REUSE할 수 있지만, 프로젝트 정본을 자동 덮어쓰거나 `full sync`로 보고하지 않는다.
5. Base 전체 동기화가 필요하면 별도 operating-system audit/migration/verification 범위로 수행한다.

## 현재 프로젝트 상태

- Godot 전환 초기화 단계가 아니다.
- MVP-0~MVP-3 runtime은 통합돼 있다.
- MVP-4는 설계 완료 후 written-spec review 단계이며 production implementation은 시작하지 않았다.

구현/검증 상태의 세부 원본은 `docs/ACTIVE_CONTEXT.md`다.