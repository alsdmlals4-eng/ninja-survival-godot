# AI work-log / evidence supplement

Owner role: derived monthly report, not game-design canon or an official settlement form.
Current user destination: `C:/Users/user/Documents/증빙서류/9월 증빙서류`.
Project: 닌자의 신 / ninja-survival-godot. Keep project name in every PDF filename.

Use existing commits, exact-head CI, task records and actual assets; no invented sessions,
screenshots, work dates, account identity, paid-plan/model claims or human approvals.
The first issue is a partial September retrospective covering the four verified 2026-09-14
commits, not a claim that September history or all required submission evidence is complete.
Git author/committer dates are source metadata, not independent certified work timestamps.
CI timestamps are UTC and must also be shown in KST. Capture/publication dates are separate.

Each issue: cover/scope, dated index, per-work before/change/result/verification/source,
actual input-record extract when available, AI/account index, missing evidence, payment
appendix references and source hashes. Raw personal/payment files stay outside Git.
Prompt transcript extracts are not screenshots; never render a fake chat UI as evidence.
Missing required screenshots/account/receipts remain MISSING, not silently substituted.
No automatic external submission, email reply, agreement signing or eligibility judgment.

Generator: `tools/export_ai_work_evidence.py`. Reuse existing Korean PDF fonts and libraries.
Latest user instruction (2026-09-16): keep one cumulative monthly working PDF.
Append dated summaries here and update the existing unsubmitted v0.3 PDF in place;
do not create v0.4/v0.5 or separate daily journals. Submitted copies, if any, remain immutable.
The historical first nine pages are preserved; the dated supplement is regenerated from
the dated entries below, not appended twice. Use --update-daily on the existing file.
Keep source captures plus manifest beside the PDF, keyed by the issue filename.
Version corrections explicitly, noting what changed; previous submitted copies stay intact.
Future work-package handoffs update the same monthly supplement from current evidence; do not
create a separate planning dashboard or duplicate manually maintained mechanics tables.

Approach comparison: manual daily narrative REJECT (high repetition/date ambiguity);
game Blueprint expansion REJECT (different purpose/duplicate canon); source-bound monthly
derived report ADAPT (reuses evidence, preserves traceability). GitHub Actions official
workflow history documentation supports job/step log readback, not AI account/expense proof:
https://docs.github.com/en/actions/how-tos/monitor-workflows/view-workflow-run-history

Image processing policy is owned by CURRENT_VISUAL_HANDOFF and CURRENT_CONFIRMED_DECISIONS.
For this report, no newly generated illustration is needed: it would not prove prior work.

First issue correction history: v0.1 -> v0.2 fixes index date wrapping and missing-input
disclosure; v0.2 -> v0.3 also strips literal terminal color markers from displayed excerpts.
Raw logs remain unchanged. All three are unsubmitted drafts; v0.3 is the review copy.

## Cumulative dated summaries

### 2026-09-14

작업일: 2026-09-14 KST(커밋 메타데이터 기준). 요약 작성일: 2026-09-16 KST. 사후 정리이며 날짜 인증이나 별도 AI 계정 증명은 아니다.

기존 1~9쪽은 최초 네 작업의 당시 기록으로 보존한다. 이후 추가 작업: 임시 저장 실패 보호, 상점·보상 후보와 난수 상태 보존, 선택형 획득 목록 교정, 보스전 후 준비 상태와 미배치 가방 저장, 복구 후보 조회와 변경 감지, 기존 소울 잔액의 1회 비파괴 이관, 재도전 보상 자격 보존, 미확정 운명 예약 저장을 구현했다.

반영 원본: 73ad4d2, 27cefdb, 0abb15e, 2ecb98f, 4ae3cd9, 4a7ec67, d2b4c87. 작업 책임은 기존 RunResumeStore/Codec, RestBackpackSession, Reward/Shop/FateController에 유지했다. 실제 사용자 저장 파일과 기존 이미지는 변경하지 않았다.

검증: d2b4c8792fab240450b6f2fb42b5b983f6f969b1의 GitHub 실행 34855733167에서 GUT와 Windows 내부 빌드 성공. 로컬 최종 기록은 102개 스크립트, 820개 테스트, 11,977개 단언 통과다. 로컬 기록은 Active Context에 남아 있으며 CI 결과와 증거 종류를 혼동하지 않는다.

원본 변경: https://github.com/alsdmlals4-eng/ninja-survival-godot/commit/d2b4c8792fab240450b6f2fb42b5b983f6f969b1
검사 기록: https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/34855733167

한계: Main의 새 저장 경로 적용, 복구 확정 UI, 준비 업무 거래·출전 연결은 남아 있다. 자동검사 통과는 실제 완주, 사람 검수, 실기기, 출시 승인과 다르다. 기존 본문의 '준비 상태 저장 미완료'는 최초 발행 당시 상태이며 이후 위 저장 계층이 구현되었다. 전체 게임 완성이나 main 병합을 뜻하지 않는다.

### 2026-09-16

작업: 사용자 지시에 따라 월간 작업일지를 새 파일로 늘리지 않고 기존 문서에 날짜별로 누적하는 운영으로 변경했다. 기존 9쪽은 보존하고 이 날짜별 요약을 뒤에 반영한다. 이전 초안 v0.1/v0.2는 이번 작업에서 삭제하지 않는다.

검수: 최신 구현 커밋 d2b4c87의 원격 GUT·Windows 성공 상태를 다시 확인했다. 이날은 작업일지 누적 방식과 기록 정리 작업이며 9월 14일 구현을 9월 16일에 새로 구현했다고 기재하지 않는다.

이번 마감 범위: 누적 일지·운영 규칙·Active Context를 함께 갱신하고 현재 작업 브랜치에 커밋·푸시 후 원격 일치를 확인한다. PR #147은 미완료 게임 기능을 포함한 Draft로 유지한다. 다른 작업 브랜치, 기존 로컬 체크아웃과 main은 임의로 바꾸지 않는다.

미확인 증빙: 지원사업 등록 계정, 결제 영수증, 실제 프롬프트·결과 화면 캡처, 협약 및 제출 상태. 새 증빙을 확보한 것으로 표시하지 않으며 외부 제출은 수행하지 않는다.

### 2026-09-20

작업·기록일: 2026-09-20 KST. Codex 대화의 승인된 구현 재개 범위이며 등록 계정·결제 상품 증명은 아니다. 최신 main의 경량 작업 규칙과 재미 검증 연결을 PR147 개발 브랜치에 통합하고, 기존 R01 저장 계층에 사용자가 검토한 복구 후보의 명시적 확정 기능을 추가했다.

이전에는 복구 후보를 조회할 수 있었지만 원본 보존 후 정본으로 확정하는 API가 없었다. 이제 정본·이전본·임시본의 전체 해시를 다시 대조하고 손상된 원본도 바이트 그대로 보관한 뒤 선택본을 게시한다. 게임 규칙·그림·엔진·실제 사용자 저장은 변경하지 않았다. Main 화면의 복구 선택 연결은 R03 잔여다.

독립 검토 1회차에서 이전본만 있는 상태의 게시와 되돌림이 모두 실패하면 새 프로필로 오인하는 결함을 확인했다. 전용 시험으로 실패를 재현하고, 복구 미완료 표식을 남겨 재시작 후 새 저장·구형 지갑 이관을 차단했다. 2회차의 오래된 구현 중지·5회 검토 안내도 교정했다. 전체 검토 2회를 사용했으며 자동 검사와 사람 검수를 구분한다.

검증: 복구 집중12/12(319단언), 전체 GUT832/832(103스크립트·12,296단언), Python21/21 통과. 구현 커밋 bb713a5d77ec9ebd6ade2e1ebf46fd3f43b4bcf2의 GitHub 실행에서 임포트·메인 장면 자동 실행·GUT832·Windows 내부 빌드 성공을 확인했다. 실행 시작은 2026-09-20 10:38 UTC / 19:38 KST다. 실제 사람 플레이·복구 화면·실기기·정전 내구성은 미검증이다.

반영 원본: d802b643(main 통합), 8c236323(복구 확정), bb713a5(미완료 복구 지속 보호). 검사 기록: https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/35505637357

PR147은 R02 준비 거래·R03 메인 연결 등 후속 작업을 포함한 Draft이며 main 병합·전체 게임 완료를 뜻하지 않는다. 이번 원본은 저장소 변경과 검사 로그다. 프롬프트·결과 화면 캡처, AI 계정·결제·지원 적격성은 추가 확보하지 않았다. 기존 월간 PDF의 1~9쪽을 보존하고 이 날짜별 기록을 같은 미제출 v0.3 파일에 누적한다.

같은 날짜 후속 작업: R02 흔적 선택 확정을 기존 저장 책임자에 연결했다. 이전에는 access/장비의 값 검증만 있었지만 이제 저장된 준비 상태에서 흡수/강화 의도를 검증하고 함께 저장·재읽기한다. 미리보기는 무변경, 시작 유파는 강화만 허용, 타 유파 흡수는 획득 자격만 해금하며 책을 자동 지급하지 않는다. 반복 요청은 중복 강화하지 않고 이후 상점 등 최신 저장 상태를 유지한다. 저장 성공 뒤 다시 읽기만 실패한 경우도 미저장 실패와 구분한다.

이번 증분 검증: 집중12/12(310단언), 전체 GUT844/844(104스크립트·12,606단언·114.16초), Python21/21 통과. 변경 집중 독립 검토에서 근거 있는 P0/P1/P2 결함은 없었다. R01 전체 검토 예산을 다시 시작하지 않았다. 반영 원본: c14412da32d6d9839d4f45a550e7a8026e78a635. 출전 거래·라이브 소유자 채택·R03 Main/UI·사람 재미·기기 검증은 이번 구현 결과에 포함되지 않는다. 실제 사용자 저장 파일을 변경하지 않았다.

이번 구현 커밋의 GitHub 검사도 통과했다: https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/35506832482 (2026-09-20 11:04:48 UTC / 20:04:48 KST 시작). 임포트·메인 장면 자동 실행·GUT·Windows 내부 빌드 결과다. 실행 환경의 Node/Ubuntu 예정 변경 안내는 게임 오류가 아니며, 이번 작업에서 워크플로나 엔진 버전을 바꾸지 않았다.

같은 날짜 출전 거래 보강: 준비한 가방 배치·장착 장비·활성 인법·운명·다음 전장을 기존 저장 책임자의 한 거래로 확정하고 재읽기하는 API를 구현했다. 미처리 흔적/보상/미배치 구매 가방, 방문한 전장, 오래된 revision을 거부한다. 소유 목록이나 재화를 요청으로 덮어쓸 수 없고 가방 밖 보관함의 인법은 전투력을 만들지 않는다. 최종 준비에는 다섯 번째 전장을 요구하지 않는다. 중복 요청은 최신 저장 상태를 반환하며 종료한 런을 되살리지 않는다.

원본 구현: 83ba0ed1fc698a2ec5153fbac8286ce59045232d. RED7/7 후 출전 집중15개를 포함한 로컬 전체859/859(105스크립트·13,824단언), Python21/21 통과. 독립 변경 집중 검토는 제품 코드와 초기7개 시험을 검토했고 근거 있는 P0/P1/P2 지적이 없었다. 이후8개 보강 시험은 독립 검토 범위에 포함되지 않으며 전체 회귀검사로 확인했다. 네 전장24순서는 데이터 조합 시험이지24회 실제 완주가 아니다.

원격 첫 검사35508027472는859개 기능 시험이 통과했지만 종료 시11개 객체/5개 자원 잔류로 실패했다. 재진입 시험 콜백의 참조 순환을 약한 참조 검사로 재현(22/24단언)하고 시험 주입부만 교정하여24/24단언으로 확인했다. 교정 원본: 67c6bf175998193dacaa2b6f68f871dfa42e2f7d. 오류를 무시하거나 제품에 강제 정리 코드를 넣지 않았다. Windows 로컬 로그에 오류가 없었다는 이유로 Linux 검사를 통과로 취급하지 않았다.

이번 범위는 저장 명령의 기반이며, 보스 후 준비 진입의 실제 저장 연결·저장된 값의 라이브 일괄 반영·R03 새 게임/이어하기/복구 화면은 남아 있다. 실제 사용자 저장, 기존 승인 이미지, 전투 수치, 엔진과 스키마, 설치 플러그인과 전역 설정은 변경하지 않았다. 사람 재미·실기기·실제 화면·전체 런·출시 승인은 미검증이다.

교정 커밋의 정확한 원격 검사: https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/35508292707 (2026-09-20 11:36:09 UTC / 20:36:09 KST 시작). 전체 GUT859/859·13,826단언·62.685초 및 종료 오류 검사, 정본 연결 검사, 임포트·메인 장면 자동 실행, Windows 내부 빌드 통과. PR147은 Draft로 유지하며 이 결과를 main 병합이나 게임 화면 연결 완료로 표시하지 않는다.

같은 날짜 휴식 경로 확인: 사용자의 ‘네 유파 엘리트·보스·휴식 구현 여부’에 대해
실제 Main을 각 유파로 시작해 엘리트→흔적→보스→Workbench 진입, 전투/시간 정지,
보상 중복·재추첨 없음, 적 정리를 자동 검사했다. 시간을 앞당기고 큰 피해로 처치한
기계 검사이며 자연 플레이·새 selected-profile Main 연결·회복 저장 완료가 아니다.
집중2/2·356단언 통과. 독립 검토의 최대HP fixture 약점을 교정하고 임시 heal(1)
변이로 네 유파 모두 실패함을 확인한 뒤 그 변이를 제거했다.

이 과정에서 휴식 경로 선택 카드가 사라진 후 지연 포커스가 실행되는 실제 엔진 오류를
발견했다. 전용 회귀 시험 RED1/1 후 객체 대신 ID를 전달하고 실행 시 유효성을 확인해
수정했다. 화면 집중18/18·158단언, 최종 로컬 전체861/861(105스크립트·14,060단언·
138.562초), Python21/21 통과. 변경 영향 독립 재검토에서 추가 P0/P1/P2 없음.
기존 전체 검토 예산은 재시작하지 않았다. 원본은 rest_flow_ui.gd와 두 통합 시험,
diagnostics/rest-focus-{red,green,final-full}-20260920.log다.

사용자의 추가 유파 특성 부여/모닥불 확률 강화/인법·가방·소모품 구매 요구는
Decisions·상세 규칙·Implementation Packet에 현재 구현과 분리해 기록했다.
기존 흔적 강화는 단순 수치 단계였으므로 새 요구까지 완료했다고 표시하지 않는다.
Brotato 공식 소개와 Last Epoch 개발자 제작 개선 회고를 조사해 비파괴 확률형과
명시적 결과 표시를 권장안으로 남겼다. 세부 경제·효과·소모품과 저장 호환은 설계 검토
대기이며 제품 코드에 임의 적용하지 않았다. 이번 중간 기록은 이 일지에만 누적했고
월간 PDF는 아직 이 증분을 포함하지 않는다. 사람·화면 캡처·기기 검증도 추가하지 않았다.
