# 화면 블루프린트 퇴행 복구 실행 계획 — 2026-09-02

> 설계: `docs/superpowers/specs/2026-09-02-blueprint-regression-repair-design.md`
> 기준 main: `477ac7343bd655278d4f045d3152f6b7e4214062`

## Task 1 — 읽기 경로와 현재-main 기준 복구

**Files**
- Modify: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`

1. 메타데이터를 current-main-reconciled 화면 atlas로 바꾼다.
2. 28쪽 Human Blueprint/PDF와 current screen atlas의 역할을 나누는 읽기 순서를 추가한다.
3. 기존 잠금 화면참조 5개를 상대 경로 Markdown image로 배치하고, 이미지가 runtime texture가 아님을 명시한다.
4. Title, Stage/Phase, 3×3, battle, Workbench의 실제 consumer와 machine/live/Human 증거를 각각 바로잡는다.

## Task 2 — 파생 owner 정합화

**Files**
- Modify: `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md`
- Modify: `docs/visual/screen-references/README.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/ACTIVE_CONTEXT.md`

1. 현재 `TitleScreen`의 Title/Continue/각성/도감/조작/설정/종료 consumer를 coverage에 반영한다.
2. multi-profile, in-combat pause/audio/input settings처럼 아직 없는 표면은 `PARTIAL`/`GAP_NONBLOCKING`으로 정확히 남긴다.
3. 다섯 PNG의 새 **문서 소비처**를 기록하되, Godot runtime consumer가 없다는 provenance 경계는 바꾸지 않는다.
4. Documentation Map/Active Context의 과거 preproduction 상태를 current main reconciliation candidate로 갱신한다.

## Task 3 — 검증·적대적 검토·동기화

1. 경로/문구/static readback와 `git diff --check`를 수행한다.
2. 기존 Godot 4.7.1에서 import, editor parse, main-scene smoke를 실행한다. 이 작업이 runtime feature 구현 검증이 아님을 기록한다.
3. 전체 범위 다섯 loop 적대적 검토를 기록한다. 각 loop에서 사실성, 사람 열람성, asset/provenance, evidence, 파생 owner/장기 유지성을 모두 다시 검사한다.
4. isolated branch commit/push/PR, exact-head CI, 일반 merge, fresh main readback를 수행한다. final receipt가 필요하면 별도 작은 문서 PR로 정합화한다.
