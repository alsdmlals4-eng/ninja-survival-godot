# 화면 블루프린트 퇴행 복구 — 적대적 검토

```yaml
review_id: NS-BLUEPRINT-REATTACK-20260902
scope: reader_route_visual_atlas_current_main_consumer_reconciliation
baseline_main: 477ac7343bd655278d4f045d3152f6b7e4214062
candidate_branch: codex/blueprint-regression-repair-143
new_runtime_code: false
new_image_binary: false
required_loops: 5
status: CLEAN_CANDIDATE_PENDING_PR_CI_AND_MERGE
```

## 검토 방법

매 loop는 같은 전체 범위—사람 열람 경로, 잠금 시각 참조, current-main
consumer, evidence 경계, 파생 문서 owner, asset provenance, rollback/장기
유지성—를 다시 읽었다. 발견을 먼저 실제 Source/Scene/Test/manifest로 검증한 뒤
필요한 문서만 고쳤다. 이미지나 runtime code를 “문서를 보기 좋게 하려고” 추가하지
않았다.

| Loop | 전체 범위 공격 | 검증한 사실 | 유효 발견과 조치 | 재검증 / 더 나은 대안 | 결과 |
| --- | --- | --- | --- | --- | --- |
| 1 | 새 문서가 실제 구현을 다시 예정으로 만들지 않는가? | `main_scene.tscn`의 `TitleScreen` instance, `MainController`의 title signal 연결, title integration tests, `BackpackState.create_starting_state()`와 3×3 unit contract | `NS-BLUEPRINT-001`이 Title·3×3·Stage/Phase를 planned/migration으로 서술한 퇴행을 확인. current main baseline, Title consumer, 3×3 machine 경계로 교정 | static readback가 baseline/consumer/3×3 문구와 stale title 문구 부재를 확인. 새 구현 패키지를 만들기보다 source readback atlas가 더 작은 안전한 대안 | PASS — source/machine과 live/Human을 구분 |
| 2 | 이전의 사람이 읽을 Blueprint와 화면 이미지를 줄이거나 대체하지 않는가? | `NINJA_SURVIVAL_HUMAN_GDD.md`, 28쪽 PDF 존재, 5개 locked screen reference 존재 | 이전 PDF의 역할이 화면 Blueprint에서 약해진 것을 확인. PDF/Human GDD를 first reader route로, 5개 기존 PNG를 Visual Atlas로 복구 | PDF binary는 변경하지 않고 5/5 relative Markdown image link를 실제 file 존재로 확인. 새 포스터는 duplicate/unlocked asset이므로 거절 | PASS — 상세 reader와 editable atlas가 공존 |
| 3 | 이미지의 문서 소비처가 runtime texture/승인 변경으로 오인되지 않는가? | screen-reference README의 SHA-256, status, existing visual handoff boundary | 5개 image link의 문서 소비처가 README에 없으면 추적성이 약해짐. README에 documentation consumer를 추가하고 Godot consumer none 경계를 보존 | SHA-256 5/5 exact match, new image binary 0, planning reference/runtime separation re-read. runtime import/새 이미지는 불필요하여 거절 | PASS — provenance와 consumer 경계 보존 |
| 4 | Title 보정이 다른 화면 흐름을 여전히 과거 direct-start로 남기지 않는가? | `MainController._ready()`의 `title_screen.show_title()`, scene instance, coverage flow rows | coverage가 `launch Main -> school select`, boot exit와 school entry를 direct Main으로 남긴 사실을 발견. Title을 front door로 연결하고 checkpoint/profile, title-settings/in-combat-pause, Codex/deep-archive의 범위를 각각 `PARTIAL`/gap으로 교정 | coverage stale phrase 0, current title consumer/readback 6 claims pass. full profile/pause/archive를 구현했다고 쓰는 대안은 source 부재로 거절 | PASS — screen flow와 product boundary 정합 |
| 5 | 문서가 정적 증거를 visual/Human/device PASS로 과장하거나 다음 재개자가 옛 상태로 돌아가게 하지 않는가? | Active Context, Documentation Map, exact target paths, static link/hash check, Godot 4.7.1 import/editor/main smoke, focused and full GUT | Active Context/Map가 preproduction-only 상태를 유지한 것을 확인. reconciliation candidate·plan·review와 `NOT_RUN` visual/Human/device 경계를 기록. initial editor warning은 missing local GUT runtime이 원인임을 확인하고 temporary junction 후 focused→full GUT으로 재검증, junction과 generated import/uid files를 제거 | Focused 19 tests / 168 asserts and full 605 tests / 6,794 asserts pass; editor parse/main smoke pass with temporary GUT runtime; temporary junction/source preservation and generated files cleanup confirmed. live editor unavailable, so render/Human/device는 `NOT_RUN`으로 유지 | PASS — PR CI/merge/readback만 남음 |

## 검증 기록과 한계

| Evidence class | Result | 경계 |
| --- | --- | --- |
| Source / consumer readback | PASS | Title Scene/Script/tests, backpack source/test, current locked references와 owner 문서를 확인했다. |
| Static documentation | PASS | 15 target paths, 11 Blueprint claims, 5 reference hashes, 5 Visual Atlas links, 6 coverage claims, stale current-Title claims 0, `git diff --check` pass. |
| Focused GUT | PASS | `test_title_actions`, `test_main_title_resume_flow`, `test_backpack_state`: 19 tests / 168 asserts. |
| Full GUT | PASS | 90 scripts / 605 tests / 6,794 asserts. Temporary GUT runtime was not committed and was removed after run. |
| Godot import / editor parse / main smoke | PASS | Godot `4.7.1.stable.official.a13da4feb`; import, editor quit and 300-frame main-scene smoke succeeded with the temporary local test runtime. |
| Live runtime render / input | NOT_RUN | Hera reports no Ninja Survival live editor session; no screenshot, controller/touch or visual quality claim was inferred. |
| Human / Player Experience / device-export | NOT_RUN | Separate human vertical-slice and platform gates remain unchanged. |

## Clean exit and follow-up

No validated `MUST_FIX` remains inside this documentation-only scope. The next
safe actions are exact candidate commit, normal PR creation, exact-head CI,
normal merge, current-main readback, and a small receipt only if the mutable
router must change from candidate to merged state. Runtime code, assets and
the 28-page PDF remain untouched.
