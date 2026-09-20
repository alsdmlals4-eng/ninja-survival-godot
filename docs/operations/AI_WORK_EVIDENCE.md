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

같은 날짜 추가 승인 후: 사용자가 세부 자료 판단을 위임하고 새 규칙으로 네 유파와
최종 보스까지 직접 플레이할 수 있는 구현을 승인했다. 유파 흔적 강화는 장착 장비의
유파 특성 부여로, 엽전 확률 강화는 별도 수치 단계로 분리했다. 기존 수치 강화 저장은
그대로 읽고 과거 기록에 새 유파 능력을 소급 지급하지 않는다. 새 능력은 흔적 선택
기록과 실제 장비 ID를 대조한다. 실패한 확률 강화는 비용만 차감하며 장비를 파괴하지 않는다.

이번 구현은 준비 진입의 1회 회복·보상/운명 후보 예약, 인법·외부 장비·가방·회복약·
비상약 구매, HP/비상약 수량 저장, 출전 경계 HP 이월, 기본무기 유파 능력의 실제
전투 소비처다. 구매·강화는 후보 복제→검증→기존 저장 책임자→재읽기 순서로 처리한다.
저장 실패·연타·오래된 요청·가득 찬 보관함·미해금 인법·회복약 상한을 검사했다.
회복 보너스가 커져도 흡혈 실회복 상한을 유지하고 관통/다중 대상에서 부가타가
재귀 발동하지 않도록 했다. 새 프로필의 Main/준비 메뉴 연결은 아직 미구현이다.

변경 집중 독립 검토에서 장비 부가타 처치가 봉마 오의 충전 경로에서 빠진 P2를
발견했다. 실제 피해 해결자로 실패를 재현하고 허용된 소유 피해 목록만 교정했다.
후속 구매·준비 진입 정적 검토에는 새 P0/P1/P2가 없었다. 검토의 엔진 실행이나
사람 검수를 추정하지 않았고 기존 전체 검토 예산을 다시 시작하지 않았다.

최종 로컬 검사: GUT892/892,109스크립트,14,933단언,297.081초,종료0;
Python21/21 및 차이 검사 통과. 최초 전체 검사의 잘못된 미해결 흔적 fixture1건은
새 유파 능력도 함께 초기화하도록 교정한 뒤 위 전체 검사를 다시 실행했다.
로그: diagnostics/camp-growth-final-full-20260920.log. 실제 사용자 파일, 다른 프로젝트의
열린 Godot 편집기, 승인 이미지, 전역 설정은 보호했다. 새 이미지/PDF는 만들지 않았다.
실제 화면·입력·자연 완주·사람 재미·기기·출시는 아직 NOT_RUN이다.

성장 증분 ac39fa60e8e3673bd03d901513181c09fc3a8a00의 원격 검사도 통과했다:
https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/35513867898 .
GUT와 Windows 내부 빌드 결과이며 정확한 작업 브랜치 readback을 확인했다.

같은 날짜 이어서 보스 보상 선택·상자·판매·재추첨을 같은 준비 거래로 연결했다.
구매/수령 시 편집한 배치를 함께 보존하되 소유품 전체와 실제 공간 합법성을 먼저
대조하고 전투 checkpoint는 변경하지 않는다. 구매한 가방을 배치해도 출전이 막히는
결함을 RED1/1로 재현하고 정상 구매 가방의 배치만 허용하도록 교정했다.
출전 집중16/16·1,248단언, 준비 거래 집중6/6·154단언 통과. 변경 집중 독립 정적
검토에서 근거 있는 P0/P1/P2 없음. 재추첨 재시도와 구매 가방 동반 배치는 검토 뒤
시험을 추가했다. 현재 기본 Main/UI에는 아직 새 거래를 연결하지 않았으므로 이
결과는 새 규칙으로 실제 플레이 가능한 완성본이나 사람이 완주한 증거가 아니다.

후속 변경 포함 로컬 전체: GUT899/899,110스크립트,15,112단언,298.771초,종료0;
Python21/21 및 차이 검사 통과. diagnostics/camp-business-final-full-20260920.log에
엔진 오류/경고 없음. Master GDD의 과거 고정 SHA를 최신 실행 기준으로 오해하지
않도록 현재 결정·상세 규칙·구현 명세 읽기 경로를 연결했다. 역사 기록은 보존했다.

### 2026-09-21

9월20일 밤부터21일 새벽까지 기본 Main/휴식 연결 작업을 이어갔다. 새 게임의
두 권 선택과 독립 첫 전장, 흔적 흡수/장비 부여·유료 강화·구매·조합, 네 전장
출전과 최종 보스 정산을 기존 저장 책임자에 연결했다. 실제 소스·시험·캡처 기준이며
과거 기능을 이날 새로 제작했다고 하지 않는다. 사용자 저장·승인 이미지·다른 작업·
전역 설정은 보호했다. 신규 이미지 생성/외부 제출은 하지 않았다.

독립 영향 검토가 찾은3P2(휴식 오의 자원, 출전 저장 뒤 읽기 실패, 마지막 소울
재도전 복구)를 재현·수정했다. 집중26/26·1,499단언 통과. 이후 각성3소울 해금과
실제 공간을 차지하는 판매0 지원품, 선택 규칙 도감, 명시 선택형 저장 복구 화면을
연결했다. 복구는 기존 해시 검사·원본보관·게시 절차를 재사용한다. 새 저장체계 없음.

중간 전체921/921·115스크립트·15,608단언·421.109초 통과. 실제 클릭에서 제목
팝업의 WHEN_PAUSED 설정 때문에 내부 버튼이 먹지 않는 결함을 추가 발견했다.
반례시험 RED→교정후 title/codex7/7 통과; 복구UI/각성lifecycle7/7 통과.
이후 변경 포함 최종 GUT924/924·116스크립트·15,684단언·445.823초·종료0,
Python21/21 통과. 엔진 ERROR/WARNING은 없으나 이전 UI fixture의 시험 중간
orphan 목록이 있어 전체 무잔류 통과로 주장하지 않는다. 집중 복구 검사는 해당 보고 없음.
로그: diagnostics/selected-adoption-final-full-20260921.log. 원격 동기화는 별도 기록한다.
독립 변경 영향 검토에 추가 확정P0/P1/P2 없음. 전체 감사 예산을 재시작하지 않았다.

실제 Windows/OpenGL 포인터로 제목→시작 선택→전장, 가속 엘리트/흔적/보스→
흡수/보상/상자→출전, 각성/도감/지원품/새 게임 확인/복구 선택을 실행·캡처했다.
원본: tools/qa_selected_run_render.gd 및 diagnostics/selected-run-752054,
selected-render-recovery-final-20260921.log(C:/Users/user/Tools/NinjaSurvival-Local).
시간/피해 가속과 QA 전용 자금·손상 파일은 격리된 검사 데이터다. 자연 완주·사람
재미·기기·출시 검증으로 확대하지 않는다. R05설정/R06~R10 등 잔여 있음.
AI 등록계정·실제 프롬프트 화면·결제 증빙·지원 적격성 확인은 여전히 별도 미확인이다.

Windows 사용자 시험 빌드를 build/windows-playtest-20260921에 만들었다. 기존과
바이트가 같은 Godot4.7.1 실행기와 이미 설치된 export template을 재사용했다.
플러그인/전역 설정/엔진 설치는 바꾸지 않았다. 실제 EXE의 headless main 실행 종료0,
오류/경고 없음. 이 packaged smoke는 배포본 포인터/화면/기기 검증을 대신하지 않는다.

동일 날짜 후속으로 환경설정 저장/취소/복원과 실제 음량·화면 모드·피격 흔들림·
조작 안내·공격 효과 농도를 연결했다. 적 전조/피해는 그대로 유지한다. 독립검토가
찾은 복수 Main의 전역 음량 간섭을 재현·교정하고 메뉴 복귀 때 눌린 대시가 소모되는
결함도 실패시험 후 교정했다. 집중5/5·35단언, Windows 실제 설정 적용/멈춤/복귀
포인터 통과(캡처 selected-run-754722). 전체930/930·117스크립트·15,737단언·
490.462초 통과. 손상 프로필은 정상 live 후보0일 때 실제 보존 경로와 수동 검토를
안내하며 자동 복구 완료를 주장하지 않는다.

인법 조회 중복 전체생성을 줄이는 동일동작 리팩터링을 했다. 1,000회 조회 미세측정
2680.236ms→6.25ms이며 전체 FPS/휴식 지연 개선율은 아니다. 공개 반환값의 변경이
정본에 번지지 않는 시험을 먼저 통과시켰다. 적 전조가 부모 위치를 중복 상속하는
결함을 기대(410,135)/실제(625,55)로 재현하고 월드 고정으로 교정했다. 집중7/7·
36단언 통과. 독립 영향 검토 추가 확정P0/P1/P2 없음. 후속 전체·96경로 결과는 완료
뒤 같은 일지에 누적한다. f7abf0d 원격 GUT/Windows 검사 통과:
https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/35521299978 .

설정/좌표 교정8267121의 전체932/932·117스크립트·15,747단언·355.624초·종료0,
해당 HEAD 원격 GUT/Windows 검사 통과(run35522701312). 4시작 유파×24방문순서
96개 고유 경로가 실제 Main/배우/저장/최종정산으로 통과했다(4분할 각24,모두 종료0).
시간/피해 가속·UI 신호 입력이며 자연속도/96개 포인터 완주가 아니다. 행렬 실행 뒤
추가한 전조 도형 검증 대신 쓰지 않는다.

후속 R06은 원형/캡슐 피해와 경계가 같은 도형을 사용하도록 교정했다. 전용 PNG
크기는 더 이상 피해 범위 기준이 아니다. 독립검토에서 소환 전조가 지연 피해 전에
사라짐을 찾아 RED 재현 후 소환체 소유의 경계 수명으로 고쳤다. 집중10/10·95단언.
실제 렌더에서 적20개 중18개의 전용파일 누락을 발견하고 기존 승인 이미지로
안전한 표시 fallback을 연결했다. 원래2개 전용 이미지는 보존했다. 새 이미지 생성,
18개 최종외형 제작/승인 완료는 아니다. 원본/가져온 player·봉마Boss alpha차이0,
독립 sprite렌더 정상; 작은 어두운 실루엣/배경 대비는 잔여 시각검수로 남긴다.
Windows 실제 캡처 selected-run-774574, 원형/직선 fixture는 의도적으로 배치·정지한
검사이며 자연 전투로 과장하지 않는다. 로그는 기존 diagnostics 아래에 보관한다.

전조/대체표시 최종 코드 전체 GUT935/935·117스크립트·15,806단언·284.037초·종료0.
독립 영향 재검토에서 소환 경계 교정 후 추가 확정P0/P1/P2 없음. 전체 감사 예산은
초기화하지 않았다. 로그 actor-warning-final-full-20260921.log. 유파별 최종아트,
공유 위험 슬롯/회피 안전경로/스폰 예고, 자연속도 완주 및 사람 재미는 잔여다.

코드7cba5cb 동기화 후 정확한 코드로 Windows 시험본을 다시 내보냈다.
build/windows-playtest-20260921-settings/README.md에 조작법·기준·제한·해시를
연결했다. export/실제 EXE headless main 모두 종료0, 엔진오류 없음. 구형 자체 생성
빌드2개·161,263,296bytes는 DELETE_REVIEW/ninja-survival-godot/20260921로
복구 가능 이동했다. 사용자 최종삭제 방식이며 삭제나 저장 파일 변경은 하지 않았다.

같은 날 공동 위험 슬롯을 Main별로 연결했다(StageProfile1/1/2/2). 회복 이후 잔류
투사체·소환체까지 점유하고 pause는 동결한다. 발사체가 시전자 이동에 끌리는 좌표
결함과 사망 직후19피해를 주는 종료 틈을 각각 RED 재현 후 교정했다. 집중6/6·
41단언, 실제 Main연결1/1·3단언 통과. 독립 정적 영향검토 추가확정P0/P1/P2 없음.
이 결과로 WINDUP/LOCKED·안전 경로·스폰 예약·자연속도 플레이까지 완료하지 않는다.

공동 슬롯18122f8 원격 검사 통과(run35524550021), GUT942/942·15,850단언 확인.
이어 기존 스포너에 화면밖/최소420거리·0.8초 예약 예고를 연결했다. floor는 살아있는
일반+예약으로 계산하며 플레이어가 접근하면 새 위치에서 예고를 재시작한다. 강적
전환은 예약만 취소하고 기존 군중은 보존한다. 적 최대수 제한은 추가하지 않았다.
취소 콜백 중 배열 인덱스 오류를 RED로 재현해 epoch 검사로 교정했다. 집중6/6·
52단언, 실제Main1/1·5단언, 전체949/949·119스크립트·15,910단언·265.442초·종료0.
실제Windows 포인터/렌더 통과(selected-run-730017), 가장자리 예고 화면 확인.
독립 정적 영향검토 추가 확정P0/P1/P2 없음. 자연속도·사람 재미 검증은 아니다.

스폰예약f8f2353 원격 검사 통과(run35525213268). 부적 발사가 전조 후 목표를 다시
추적하는 반례를 교정하고 동일 고정 방향을 화살표로 표시했다. 집중11/11·104단언,
중간 전체950/950·119스크립트·15,919단언·268.505초 통과. 렌더 최초 제목 설정 클릭
실패1회를 숨기지 않는다. 같은 코드 재실행740431 및 후속736265 포인터 흐름 통과;
최초 클릭 실패의 확정 원인은 미확인이다. 단순 재실행을 결함 교정으로 기록하지 않는다.

selected 패턴에 WINDUP/LOCKED,16방향×4거리 보행 탈출 후보 및 현재 속도에 따른
전조 연장을 연결했다. 대시 중 적 충돌을 무시한 마스크로 보행을 허가하는 반례는
정상 보행마스크+겹침/이동 query로 교정했다. 집중7/7·31단언 통과(이후 표시 단언 추가).
적 생성 시점의 일시적 원점 충돌이 플레이어를 밀어내던 결함도 일반/엘리트/보스에서
재현해 생성 전 좌표 지정으로 교정했다. Main8/8·97단언 중간 통과, 최종 query 연결
집중1/1 통과. 독립 변경 영향검토 추가 확정P0/P1/P2 없음. 현재상태 검사이므로 미래
군중 이동·자연 플레이·재미 검증과 구분한다. 최종 전체 결과는 확인 후 누적한다.

최종 변경 상태 전체958/958·120스크립트·15,956단언·269.741초·종료0, Python21/21·
13.998초 통과. 로그 escape-final-full-20260921.log. 실제Windows 포인터/렌더743686
통과, 준비/고정 전조 캡처를 직접 확인했다. 배치·정지 fixture는 자연 전투가 아니다.
대시 보행 query 최종 독립 검토 추가 확정P0/P1/P2 없음. 사용자의 실제 프로필,
승인 원본 이미지, 엔진/설치 플러그인/전역 설정은 바꾸지 않았다.

같은 날2f1ef8d 원격 GUT/Windows 검사 통과(run35526650460). 군중 부하를 실제
Windows1280×720/RTX3050/VSync1에서100/300/600/1000으로 측정했다. 기준1000은
frame p50 193.930/p95 232.325ms. 고체력 QA 적·정지 플레이어 조건이며 정상 플레이나
최소 사양 시험이 아니다. 원거리만 직접 이동한 후보는 p95 234.139ms로 효과가 없어
철회했고 자체 시험파일만 DELETE_REVIEW의 ineffective-far-step에 복구 가능 보관했다.
삭제하지 않았다. 계측상 적 추적208,000회에3848.627ms가 소모되어 원형 접촉 계산으로
범위를 좁혔다. 몸체/쿨다운/대시/둔화는 유지하며 추가 mask 등은 물리로 돌아간다.
5시험 RED→GREEN·30단언, 첫1000 후보 p50 61.788/p95 136.800ms. 개선은 관찰했지만
여전히 끊김이 크므로 성능 통과로 기록하지 않는다. 같은 layer1 몸체 추가 시 Main
계약을 다시 확인해야 한다. 독립 정적 영향 검토 추가 확정P0/P1/P2 없음. 전체 검증은
결과 확인 후 누적하며 GPU 시간·자연 플레이·기기·사람 재미는 미검증으로 유지한다.

원형 접촉 변경 상태 전체963/963·121스크립트·15,986단언·268.932초·종료0 통과.
로그 contact-full-20260921.log. 접촉 회귀 통과와1000마리 성능 잔여는 별개다.

24f5ee3 원격 검사 통과(run35527770068). 반복 군중1000 표본은 p50 16.926/
p95 45.732ms로 최초 후보와 편차가 컸다. 이전에는 배치seed만 고정하고 시작 인법
선택seed를 고정하지 않았으므로 개선율을 일반화하지 않는다. 도구에 시작seed921/
실제 인법 목록 기록과 명시적 기존 충돌 경로 비교 옵션을 보강했다. 성능 잔여 유지.

R07에서 승인 수식과 실제 호출을 대조했다. 일본도rank1+비전18%가13대신14,
쿠나이rank1+비전22%가8대신9였고, 확정 가방을 전투 무기로 연결하는 생산 호출이
아예 없었다. 기본 피해·강화 증가를 분리해 원타에 합산하고 최종 반올림 한 번으로
교정했다. 8무기×5단계×보조 유무80개 기대값+비행 중 변경 시험 포함21/21·874단언.
초기 fixture의 이미 장착된 기본 장비 재장착 false/selected 기본값 실수는 따로
교정했다. 수식 피해량과 Main 연결 실패는 실제 RED로 확인했으며 setup오류를 제품
결함으로 세지 않는다. Guiin 아닌 시작에 강제 변신한 fixture 역시 제외했다.

실제 Main continue에서 뇌명 원타10/부가0 대신12/6이 적용되며, 재도전 시 이전
탄환 재개/조합 대기시간 잔류도 재현했다. 체크포인트 재채택에서만 자체 탄환·이펙트·
임시 시계를 정리하고 확정 가방을 다시 적용한다. pause는 이 초기화와 분리했다.
Main집중2/2·15단언 통과. 독립 정적 영향검토 추가 확정P0/P1/P2 없음. 실제Windows
포인터/렌더729423 통과 및 전투 화면 확인; 가속 gate라 자연 완주는 아니다. Python
21/21·15.758초 통과. 전체 회귀·새 빌드/PDF 발행 결과는 확인 후 같은 날짜에 누적한다.

R07 변경 상태 전체967/967·122스크립트·16,605단언·274.767초·종료0 통과
(weapon-final-full-20260921.log). 전체 기획/자연 플레이/최종자산/기기 완료는 아니다.

4ee2491 원격 GUT/Windows 통과(run35528546943). 배치와 시작인법seed921을 모두
고정한1000군중 비교는 기존p95 239.029ms→원형접촉112.842ms였다. 여전히 성능
통과가 아니다. 정지 접촉 몸체가60tick동안 같은 transform을60회 다시 제출하는
별도 반례를 교정했다. 집중6/6·34단언, 피해시계 유지. 이후p95 129.746ms이므로
이 작은 guard의 FPS 향상은 주장하지 않는다. 진단에서 플레이어298회128.399ms,
적298,000회2989.086ms를 측정했다(계측 자체 비용 포함, GPU 제외). 독립 정적
영향검토 추가 확정P0/P1/P2 없음. 최대 적수 제한·저장·자산·전역 설정은 변경하지 않았다.

동일 좌표 guard 포함 전체968/968·122스크립트·16,609단언·274.468초·종료0,
Python21/21·15.489초 통과. 전체 결과 contact-guard-full-20260921.log.

R08 플레이어 카메라 후보1개도 제작했다. 최초 도구가 크로마키 요청 대신 직접
투명을 반환하여 같은 후보의 마젠타 배경 교정→배경 제거를 추가 실행했다. 원본/
키 배경/투명 PNG와 정확한 프롬프트·해시를 저장소 후보 폴더에 보존했다. 실제 alpha
검사에서 희미한 외곽 잔여와 작은 크기 가독성 문제를 확인해 기술 보완 필요로 남겼다.
Godot 단독 밝음/어두움·280/96/64px 렌더를 확인했지만 실제 Main 적용·모션·최종
사용자 승인은 아니다. 승인 원본 이미지는 변경하지 않았다. 상세 후보 기록은
docs/visual/candidates/player-gameplay-20260921/README.md.

검증 코드9d1bbf1을 기존 Windows 시험본 폴더에 다시 내보냈다. export 및 실제EXE의
headless main120프레임 모두 종료0, 엔진 오류 없음. PCK SHA256
2F907604214101388FC3818BE5A34F46BA273184F7BB7E920980C4151FE201C1.
같은 폴더 README 조작법/검증/잔여를 갱신했다. 새 플레이어 후보는 미적용이다.
실제EXE 전체 포인터 조작·자연속도 완주·사람 재미·기기·출시는 미검증으로 유지한다.
