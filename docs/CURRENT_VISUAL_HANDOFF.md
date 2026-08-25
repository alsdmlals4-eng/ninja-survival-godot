# CURRENT VISUAL HANDOFF — Ninja Survival / 닌자의 신

> Updated: 2026-08-25 KST
> Purpose: next-chat resume router for the approved visual direction and current image-production state.
> Product/runtime authority remains `AGENTS.md` → `docs/CURRENT_CONFIRMED_DECISIONS.md` → `docs/ACTIVE_CONTEXT.md` → actual code/data/tests. This file owns the **current visual continuation state only**.

## 1. Exact repository / concurrency state at handoff

- Completed `main` observed for this visual handoff: `c0440e7043bcf3bb678f5cb7d1653883f93c07a2`.
- Open T12 implementation PR: **#49 `T12: atomic Workbench Fate route commit`**.
- PR #49 is a separate implementation workstream and is **READ_ONLY / NO MUTATION** for visual work.
- PR #49 changed files were checked; this visual handoff does not own its scripts/tests/plan.
- Visual/document work should start from then-current completed `main`, re-read this file + Notion Visual Bible, and avoid taking over unrelated PRs.

## 2. Approved hybrid visual architecture

The user approved a two-surface visual system that must still look like one IP.

### Presentation / key art / lore

**Hand-drawn ink codex / painterly ninja fantasy**:

- paper / ink wash / pencil / brush texture,
- dark moonlit ninja fantasy,
- premium painterly anime proportions,
- circular brush stroke / moon framing,
- Korean brush-calligraphy title language,
- black / deep navy / charcoal + red + warm gold,
- school accents are secondary to silhouette and motif.

Use for title/key art, school explanation, lore/trace, loading/chapter art, planning/PPT, marketing explanation.

### In-game

**Animation-forward 2–3 head SD anime + C-leaning dark painterly DNA**:

- one readable chibi/anime player silhouette,
- clear cel-animation-like planes and fast readable actions,
- simplified detail compared with key art,
- restrained ink/rough-edge texture so gameplay and presentation do not look like different games,
- readability of player/enemy/hazard/projectile/pickup is above decorative density.

Do **not** turn in-game art into four different player characters.

## 3. Core runtime character identity — USER APPROVED

### ONE_CHARACTER_IDENTITY

The player character remains **one fixed ninja identity** across the whole Run:

- same face,
- same hair,
- same body proportion,
- same core outfit identity,
- same base weapon language unless gameplay data explicitly changes equipment.

School progression must not replace the player's body/identity with four school-specific protagonists.

### TRACE_AS_LAYER

Collecting school traces adds **items / aura / companion / shadow effects** around the same character.

The visual result should read as:

`one ninja -> accumulated traditions -> one completed ninja`

not:

`four unrelated school costumes combined`.

### FOUR_SCHOOLS_COMBINE_CLEANLY

A full four-school state must remain visually coherent. Use layer priority, size and location so effects do not compete:

- body-mounted accents are limited,
- large effects prefer separate spatial zones (feet / back / side companion / hands / weapon),
- the face and core silhouette remain readable,
- accumulated traces must look intentional rather than loot clutter.

### MAIN_SCHOOL_STAGE_3_ONLY

The strongest **Trace Stage 3** visual expression is available **only for the school chosen as the Run's starting/main school**.

Other schools may accumulate recognizable supporting trace layers but must not all reach simultaneous full Stage-3 dominance.

This rule prevents four maximal school identities from visually fighting on one character and preserves a readable "main tradition + learned traditions" hierarchy.

## 4. Approved school visual motifs

These motifs are the current user-approved visual shorthand. Do not substitute generic element colors as the school identity.

### 봉마류

- primary visual motifs: **부적 + 식신**,
- talismans can mount on outfit/gear in restrained numbers,
- shikigami should preferably occupy a side/companion silhouette zone,
- supports prepared-space / mobile-stronghold identity.

### 천술류

- primary visual motif: **차크라 기운**,
- use flowing energy around hands / feet / weapon / behind-body path rather than one giant full-body circle,
- must remain compatible with other accumulated trace layers,
- supports setup / ordered reaction / field-transformation identity.

### 귀인류

- primary visual motifs: **오니가면 + 귀기**,
- oni mask should not permanently erase the fixed protagonist face; prefer waist / shoulder / back carry or an emphasized activation moment,
- demonic aura communicates dangerous close-range pressure,
- avoid reducing the school to generic low-HP berserker language.

### 흑영류

- primary visual motifs: **그림자 + 어둠**,
- place darkness in ground shadow / back silhouette / afterimage zones,
- avoid covering equipment and hit/hazard readability,
- supports stealth / threat-priority / execution identity.

## 5. Current image inventory and authority level

### A. Hybrid Key Visual — APPROVED MASTER BRIDGE

Purpose:
- connects mature painterly/ink presentation art with the same project's gameplay language,
- central ninja + four school languages + moon/ink circle + `닌자의 신` calligraphy.

Notion:
- `02 · 비주얼 바이블` contains a **Notion-native low-resolution preview attachment**.
- server readback resolved to Notion-owned `prod-files-secure`.
- original generated high-resolution image in the originating chat remains the quality reference.
- actual browser/mobile pixel observation: NOT_RUN in this handoff.

### B. Four-school full-body silhouette sheet — APPROVED SUPPORTING REFERENCE

Purpose:
- compare school clothing, silhouette and motif languages for Presentation/Lore design.

Important limitation:
- the four figures are **not four in-game player protagonists**.
- runtime uses ONE_CHARACTER_IDENTITY.

Notion:
- a low-resolution Notion-native preview was attached to the Visual Bible during closeout.
- destination readback must be checked before claiming final attach PASS.

### C. SD / action / icon three-panel sheet — WORKING REFERENCE, DETAILS SUPERSEDED

Reusable:
- SD scale direction,
- action exaggeration / readability idea,
- school skill-icon grouping,
- trace layering as a visual progression concept.

Superseded details to correct in the next visual session:
- one fixed base character must be more explicit,
- Trace Stage 3 only for the starting/main school,
- all four traces must combine naturally,
- exact motifs are 봉마=부적/식신, 천술=차크라 기운, 귀인=오니가면/귀기, 흑영=그림자/어둠.

Notion:
- a low-resolution working-reference preview was attached during closeout.
- it must stay labeled WORKING_REFERENCE, not approved final runtime art.

## 6. Notion human-facing authority

Primary visual page:
- **`닌자 서바이벌 · Home` → `02 · 비주얼 바이블`**
- Notion page ID: `3c01b237-eb1c-8116-9028-c8c8c427e467`

Human Home:
- `닌자 서바이벌 · Home`
- currently describes the Hybrid Master Style and links to the Visual Bible.

Project work control:
- `01 · 프로젝트 전체 작업계획`
- should contain this closeout state and the next visual resume gate.

Notion is the human-facing visual authority. Repository files record structured handoff/status; actual runtime art implementation remains code/assets/runtime evidence.

## 7. Next visual work — resume point

Do not generate automatically on chat start.

First next task should be a **revised 1–3 visual set** based on this handoff:

1. **In-game fixed-character SD trace-layer sheet**
   - same base character repeated,
   - show no-trace / supporting trace layers / one starting-school Stage-3 example / coherent all-four state,
   - main goal: prove all four can coexist without visual clutter.
2. **SD action / animation key-pose sheet**
   - same character identity,
   - school identity comes from layered effects and action grammar, not different bodies.
3. **School skill/symbol icon rough**
   - 봉마: talisman/shikigami,
   - 천술: chakra flow,
   - 귀인: oni mask/demonic aura,
   - 흑영: shadow/darkness.

After this corrected 1–3 set is approved:

4. Persistent Workbench / backpack UI prototype.
5. Backpack item visual-language sheet.
6. Title / loading / marketing derivative visuals.

Image process remains:

`text brief -> user approval -> generate requested batch/result -> result review -> Notion durable placement -> next brief`.

Do not silently reuse an older image as final when its detail contract is superseded.

## 8. Quality bar for the next chat

Before generating:

- read current `AGENTS.md`, `CURRENT_CONFIRMED_DECISIONS.md`, `ACTIVE_CONTEXT.md`, this handoff and Notion Visual Bible,
- preserve four-school gameplay philosophies,
- preserve the current Hybrid Master Style,
- compare each draft against the approved Hybrid Key Visual and the fixed-character trace-layer rules,
- explicitly check a full four-school accumulated state for clutter and silhouette loss,
- keep long Korean explanatory text outside generated image pixels where possible,
- do not claim image attachment until Notion attach + destination readback succeeds.

The target is not merely "same prompt style". The target is **same character identity, same school motifs, same visual hierarchy, and the same evidence discipline**.

## 9. Evidence ceiling at closeout

Verified in this visual session:
- user approval of Hybrid direction,
- user approval of fixed-character trace-layer direction,
- exact school motif choices,
- Notion text updates invoked,
- Hybrid Key Visual Notion server readback previously PASS,
- supplementary Notion preview uploads invoked.

Not verified / not claimed:
- high-resolution pixel-equivalent Notion upload,
- browser/Android/iOS client render of the latest attachments,
- actual Godot implementation of the new SD art direction,
- animation runtime quality,
- Human Usability / Player Experience,
- full four-school final composite rendered under the latest rules.
