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
