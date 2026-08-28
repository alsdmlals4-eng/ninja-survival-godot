# DEC-034 — 생성 후 확정 승인 시각자료 작업 흐름

```yaml
decision_id: DEC-034
status: APPROVED_WORKFLOW_SCOPE
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec034-generate-then-approve-visual-workflow.md
implementation_reality: WORKFLOW_ONLY_NO_NEW_ASSET
human_player_evidence: NOT_APPLICABLE
```

## 결정

앞으로 시각자료가 실제로 필요한 승인 작업에서는 사전 이미지 생성 승인 질문을 하지 않는다. AI는 current visual canon, 실제 consumer 또는 명시된 planning-visualization 목적을 fresh-read한 뒤 **한 개의 이미지 결과**를 먼저 만든다. 사용자는 그 결과를 Project Asset/Visual Direction/후속 제작 기준으로 **확정할지**만 승인하거나 수정 지시한다.

```text
fresh visual + consumer read
-> concrete consumer or planning-board brief
-> generate one candidate without a pre-generation approval question
-> user: LOCK / REVISE / REJECT
-> only LOCK: durable asset registration or direction lock
```

## 보호 경계

- 채팅 시작, 막연한 gap, 또는 기존 asset 교체 사유만으로 이미지를 생성하지 않는다. 구체적인 runtime consumer, screen-reference 목적, 또는 현재 기획 검토에 필요한 보드 목적이 있어야 한다.
- 생성 후보는 `GENERATED_EXPLORATION` 또는 `CANDIDATE`다. user `LOCK` 전에는 approved project asset, Godot 적용, runtime/UX evidence, Notion asset library 완료로 승격하지 않는다.
- 기존 승인 asset은 새 sheet의 장식성 때문에 재생성·대체하지 않는다.
- planning board의 긴 텍스트나 pseudo-text는 정본이 아니다. 정확한 rule/flow/copy는 repository structured text가 소유한다.
- user가 복수 후보/변형을 명시하지 않으면 한 task당 한 결과만 만든다. 권리·출처·reference similarity와 existing visual grammar 검수는 계속 필수다.
- `LOCK`된 runtime asset은 기존 dual-storage, manifest, actual consumer, import/runtime-validation gate를 그대로 따른다.

## superseded 범위

이 결정은 이전의 `text brief -> user explicitly approves generation -> generate` 사전승인 단계만 supersede한다. consumer-first, one-fixed-character, visual grammar, approval level, durable provenance, Human/Player evidence 분리는 계속 CURRENT다.

## Incident / Solution / Lesson

- **Incident:** user가 생성 뒤 확정만 받는 흐름을 승인했지만, Notion Visual Bible에는 이전의 `다음 메시지 승인 -> 1건 생성` 사전승인 문구가 남아 있었다.
- **Solution:** repository DEC-034, current decision/router/GDD를 새 흐름으로 맞추고, Visual Bible의 해당 문구를 `concrete consumer/board -> one candidate -> LOCK/REVISE/REJECT`로 정확히 교정했다. 2026-08-28 KST destination readback은 새 문구가 보존된 것을 확인한다.
- **Lesson:** 이미지 작업의 cadence 변경은 단순 대화 습관이 아니라 candidate, approved asset, runtime evidence를 구분하는 approval contract다. source-of-truth의 이전 승인 순서가 남아 있으면 사용자의 다음 작업 cadence와 자산 승격 기준이 함께 drift한다.

## Base 승격 판정

`NO_BASE_PROMOTION`: 생성 사전승인 생략의 허용 범위, one-result cadence, project asset lock, and Notion/runtime handoff boundary가 현재 프로젝트의 visual workflow 및 user preference에 결속된다.
