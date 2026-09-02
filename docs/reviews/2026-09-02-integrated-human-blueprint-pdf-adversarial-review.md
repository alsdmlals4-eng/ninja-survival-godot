# 통합 Human Blueprint PDF — 적대적 검토

```yaml
review_id: NS-INTEGRATED-HUMAN-BLUEPRINT-PDF-20260902
scope: preserved_historical_reader_plus_current_main_wireframes_flow_locked_visual_companion_download_route
baseline_main: 16cf7a6bb2a8676ad979985605d66f1ca3edd28c
candidate_branch: codex/human-blueprint-integrated-pdf-145
candidate_source_commit: cc40626c2158d561e94d1689d9b9c20e7b79da9e
new_runtime_code: false
new_image_binary: false
required_full_loops: 5
status: CLEAN_ON_BRANCH_PR_145_PENDING_EXACT_HEAD_CI_MERGE_AND_MAIN_READBACK
```

## 검토 기준

한 파일로 보인다는 이유로 기존 Human Blueprint를 줄이거나, visual reference를
runtime asset으로 오인하거나, 정적 PDF 검수를 Human/Device PASS로 올리지 않는다.
각 loop는 historical preservation, reader sequence, wireframe completeness, asset
provenance/consumer, generated artifact integrity, evidence boundary, download route,
future regeneration을 모두 다시 공격한다.

| Loop | 전체 범위 공격 | 확인한 사실 | 유효 발견과 조치 | 재검증 / 대안 비교 | 결과 |
| --- | --- | --- | --- | --- | --- |
| 1 | “통합”이 기존 28쪽을 다시 그려 layout·검수 snapshot을 바꾸지 않는가? | original PDF `28`쪽, landscape A4, SHA `0cf567…`; composer가 pypdf로 historical page object를 직접 `add_page`하는 구조 | 28쪽을 Markdown에서 재렌더하는 대안은 기존 human-review layout을 바꿀 위험이 있어 **REJECT**. 3쪽 guide 뒤 pages 4–31에 original pages를 직접 결합 | focused export test, pypdf page count `38`, page 4와 page 31 rendered inspection | PASS — historical reader preservation |
| 2 | 보강부가 화면 의미를 빼거나 “예쁜 보드”만 만드는가? | current screen Blueprint의 Title → Stage → Core → Elite → Trace → Boss → Result → Workbench → Fate flow와 six screen wireframe owner를 readback | guide 3쪽 + Title/Stage/Battle/Elite-Trace-Boss/Result-Workbench/Game Over/assets 7쪽으로 입력 순서를 고정. 기존 본문은 유지 | separate PDF links는 한 파일 요구를 못 채워 **REJECT**; 38쪽 reader flow와 7 companion pages rendered inspection | PASS — player-flow and wireframe coverage |
| 3 | image source가 새 candidate/무소비자 decorative binary가 되거나 planning reference를 runtime texture로 바꾸는가? | title 3, screen reference 5, Bongma Boss/familiar 2의 SHA and status; actual title/encounter consumers; screen-reference README boundary | 새 이미지 생성 필요 없음. 10 existing user-locked/dual-stored source의 PDF documentation consumer만 manifest에 추가 | imagegen은 concrete gap이 없으므로 **REJECT**. `git status`에서 new PNG 0, 10 asset hashes read back, manifest roles verified | PASS — provenance/consumer separation |
| 4 | 제작은 성공했어도 가독성·잘림·문서 route가 깨지지 않는가? | full `pdftoppm -png -r 144` output initially showed a clipped Result/Workbench wireframe row; existing full PDF regression test also failed before this branch’s content change | Result/Workbench wireframe을 4개 좁은 행에서 3개 충분한 높이 행으로 수정하고 re-export/re-render. stale test expected `PDF_FINAL_REVIEW_PENDING`, but fresh `origin/main` Master GDD had already moved to semantic `final Human Blueprint PDF review`; assertion을 current main fact로 교정 | re-rendered Result/Workbench page has no overlap. focused integrated test `1/1` and legacy PDF suite `9/9` pass. stale test was traced to `6d695768`, while Master GDD changed by #139; restoring old state was **REJECT** | PASS — visual clipping corrected; regression expectation current |
| 5 | 다운로드 경로/manifest/reader navigation이 current artifact를 가리키면서도 runtime/Human proof를 과장하지 않는가? | README, Documentation Map, PDF_EXPORT, Screen Blueprint, ACTIVE_CONTEXT, visual handoff, manifest all route to one new `exports/` file; `pdfinfo`/pypdf/readback complete | GitHub blob + raw-download routes are recorded for post-main use. `CURRENT_ON_BRANCH_PENDING_MAIN_PUBLICATION` is retained until exact CI/merge/readback; no false `CURRENT_ON_MAIN` claim | external hosting/SaaS is cost/dependency increase로 **REJECT**. `pdfinfo`: 38 pages/A4/not encrypted; 38/38 render, 0 zero-byte; front matter + every new companion + representative first/last historical pages visually inspected | PASS — download route and evidence ceiling honest |
| 6 | GitHub가 50 MiB 초과 artifact를 경고해도, 원본 visual asset을 바꾸지 않고 다운로드 경로를 가볍게 유지하는가? | 최초 integrated PDF는 `53,699,895` bytes (51.21 MiB)로 push는 됐지만 GitHub 권고선보다 컸다 | opaque reference만 PDF composer 메모리 안에서 최대 1600px/JPEG quality 94로 encoding하고, alpha title/encounter asset과 모든 source PNG bytes/SHA/provenance는 보존 | Git LFS는 새 저장 의존성과 reader friction을 늘리므로 **REJECT**. 새 artifact `35,265,832` bytes (33.63 MiB), focused test의 `<50 MiB` contract, 38-page re-render와 5-page targeted visual inspection | PASS — source asset 불변, artifact 17.58 MiB 감소 |

## Evidence record

| Evidence class | Result | Scope and ceiling |
| --- | --- | --- |
| Fresh repository/Base authority read | PASS | fetched `origin/main` `16cf7a6…`, latest Base remote `aaa94caf…`, project AGENTS, existing publication contract, screen Blueprint, visual handoff, asset owner tables read before mutation |
| External implementation research | PASS | current GitHub Docs confirms repository file/raw download routing; selection remains repository-owned binary rather than external host |
| TDD RED | PASS | `test_export_integrated_human_blueprint_pdf.py` first failed because the composer did not exist |
| Focused integrated exporter | PASS | `1/1`; temporary real PDF output checks header, <50 MiB size, page count, retained 28-page source, and integration copy |
| Existing Human PDF exporter suite | PASS | `9/9`; one stale source assertion was root-caused against fresh `origin/main`, then corrected to current Master GDD language |
| Manifest/static | PASS | JSON parser, expected path presence, exact artifact/composer/test/asset SHA checks, original 28-page extracted-text equivalence, <50 MiB check, `git diff --check` |
| PDF structure | PASS | `pdfinfo` and pypdf: 38 pages, landscape A4, unencrypted, metadata present; historical source starts at page 4 |
| Render | PASS | final `pdftoppm -png -r 144`: `38/38`, zero-byte pages `0`; no blank new page observed |
| Codex visual review | PASS | final output guide cover, Title, Battle HUD, Result/Workbench and evidence pages were directly re-rendered/inspected; first-pass Result wireframe clipping was corrected before clean exit |
| Godot runtime/render/input | NOT_RUN | no Godot runtime behavior was changed by this PDF-only package |
| Human Usability / Player Experience / device/export / release | NOT_RUN | PDF visual inspection is not player, accessibility, device, or release validation |
| Remote CI / merge / post-main readback | NOT_RUN | PR #145 exists; exact-head CI, regular merge, and main readback are the remaining delivery gates |

## Clean-exit boundary and remaining delivery work

No validated `MUST_FIX` remains within the **branch-local PDF composition and
documentation-route** scope. The only remaining required work is delivery
routing: branch commit/push → PR → exact-head GitHub CI → regular merge → fresh
main source/artifact readback → small receipt update changing pending publication
status to current-on-main. No user product-meaning decision is needed for that
remaining delivery sequence.
