# 닌자복 장비 아이콘 — 외형 후보 / 기술 재작업 필요

- 상태: GENERATED_CANDIDATE / ALPHA_FAILED / USER_LOCK_PENDING / NOT_RUNTIME_BOUND.
- 파일: `ninja-outfit-appearance.png`, 1254×1254 RGB. 알파 채널 없음. 체크무늬가 실제 픽셀에 포함되어 투명 게임 아이콘으로 사용할 수 없다.
- SHA-256: `cbf5bee52886e9235575e7029bb1b12d9d57b715208a03e631e9b265fa63747e`.
- 생성: 내장 image_gen, 2026-09-11. 원본 실행: `exec-5ed9a9fd-2fb2-4f8d-93c0-015ee29bb72f.png`. 복사 후 픽셀 편집 없음.
- 참조: 사용자 제공 `KakaoTalk_20260826_193205188_12.png`, 캐릭터의 의상/선화 참고만. 별도 권리 증빙이나 출시 승인으로 취급하지 않는다.
- 예정 소비처: 캐릭터 의복 슬롯, 흔적 강화 대상 카드, 장비 도감. 64~96px 가독성/투명 배경 검수와 사용자 LOCK 후 연결. 런타임 consumer는 현재 없음.
- Aseprite: 단일 정적 아이콘이므로 현재 프레임 패킹 불필요. 투명 배경은 이미지 모델 재작업 대상이며 수동 그림/임의 색 제거로 대체하지 않는다. 이번 후보 승인 전 추가 변형은 제작하지 않는다.

## 실제 생성 프롬프트

Use case: stylized-concept. Generate ONE new game equipment icon, not a character portrait. Input image is ONLY a costume/style reference, not an edit target. Subject: the ninja outfit armor, shown as a single compact torso garment with short hanging skirt panels: charcoal black overlapping cloth tunic, deep navy neck scarf, modest warm aged-gold shoulder reinforcement and edging, red braided waist cord. Match the reference's premium hand-painted anime linework and palette, but simplify small ornaments to read at 64 to 96 pixels. Three-quarter near-front view, centered whole garment, clean strong silhouette, approximately 75% of square canvas, ample empty margin. No person, no head, no hands, no legs, no mannequin or hanger, no weapons, no separate accessories, no UI frame, no text. It is lightweight ninja armor, not bulky knight plate armor. Genuine transparent PNG background: empty pixels must have zero alpha, no black/white background, no checkerboard painted into the image, no glow, no halo, no floor or cast shadow. Opaque garment interior and clean antialiased boundary. Single 1024 square asset.
