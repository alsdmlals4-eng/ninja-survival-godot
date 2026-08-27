# 2026-08-28 정본 Frontier 불일치 교정

## Incident

`AGENTS.md`가 T11을 현재 구현 frontier로, T12를 미병합으로 기록했다. 그러나 remote `main`과 `ACTIVE_CONTEXT`, `CURRENT_CONFIRMED_DECISIONS`, 병합 PR #61/#63/#66/#69/#73은 T12~T16이 병합된 machine-scope 이력임을 보였다.

## Solution

- `AGENTS.md`의 구현 frontier와 다음 게이트를 T12~T16 병합 및 Human vertical-slice validation `NOT_RUN`으로 정정했다.
- 정적 SHA를 문서의 "current main"으로 재고정하지 않고, mutation 전 remote default branch fresh-read를 유지했다.
- PR #43/#44/#49는 historical 또는 superseded read-only reference로 명시했다.

## Lesson

상위 지시 파일의 과거 reactivation snapshot은 코드·Active Context·병합 PR보다 현재 구현 상태를 우선할 수 없다. `CURRENT` 판정에는 remote default branch fresh-read와 current owner 간 대조가 필요하다.

## Base promotion

`NO_BASE_PROMOTION`: Base에는 이미 fresh-read, drift gate, self-stale current-pointer 방지 규칙이 있다. 이번 사례는 그 규칙의 프로젝트별 정정 증거다.
