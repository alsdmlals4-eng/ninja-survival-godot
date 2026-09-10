# Blueprint 제작 조사 보강

확인일 2026-09-11. 공식 제품 소개·개발자 발표·도구 문서 기반 데스크 리서치다. 직접 플레이, 상용 게임 내부 코드 분석, 현업 인터뷰, 사용자 모집은 실시하지 않았다. 수치·시장 성공 인과를 외삽하지 않는다. 기존 15작 연구는 별도 보존한다.

## 비교작과 결정 연결

| 공식 출처 | 확인 범위와 판단 | 이번 적용 |
|---|---|---|
| [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | 군중 생존의 단순 입력, REFERENCE_ONLY | 일반 적을 빠르게 처치하는 리듬; 소재/수치 복제 없음 |
| [Brotato](https://store.steampowered.com/app/1942280/Brotato/) | 자동무기와 준비 선택, TEST | 보스 뒤 집중 준비와 짧은 웨이브식 준비의 피로 비교 |
| [Halls of Torment](https://store.steampowered.com/app/2218750/Halls_of_Torment/) | 군중·성장·강적, ADAPT | 일반 군중과 보스 패턴의 인지 부담 분리 |
| [Death Must Die](https://store.steampowered.com/app/2334730/Death_Must_Die/) | 회피와 강화 선택, ADAPT | 자동공격 위에 직접 대응을 올리되 수동 평타 없음 |
| [Soulstone Survivors](https://soulstonesurvivors.com/) | 다수 기술과 강적 장면, REFERENCE_ONLY | 효과가 많은 장면을 가독성 반례 후보로 비교; 실제 불편 발생 확정 아님 |
| [Deep Rock Galactic: Survivor 개발사](https://www.fundaygames.dk/deep-rock-galactic-survivor) | 자동 전투와 이동 목적, ADAPT | 도주 이외 이동 판단. 채굴/지형파괴는 REJECT |
| [Backpack Hero](https://store.steampowered.com/app/1970580/Backpack_Hero/) | 인벤토리 위치의 효과, ADAPT | 배치 결과를 전투 행동과 연결 |
| [Backpack Battles](https://store.steampowered.com/app/2427700/Backpack_Battles/) | 배치·조합 중심 선택, ADAPT | 공간 기회비용; PvP/경제 수치는 도입 안 함 |
| [God Of Weapons](https://store.steampowered.com/app/2342950/God_Of_Weapons/) | 자동 전투+공간 인벤토리, REFERENCE_ONLY | 조합 자체가 독창적이라는 주장 REJECT |
| [Nova Drift](https://store.steampowered.com/app/858210/Nova_Drift/) | 모듈형 변형·실험, ADAPT | 행동을 바꾸는 소수 조합, 대규모 모듈 수 복제 없음 |
| [Spell Disk](https://store.steampowered.com/app/2292060/Spell_Disk/) | 주문·조건 시너지, TEST/REJECT | 비교 대안으로 검토; 무제한 조건식 엔진은 제작 비용상 보류 |
| [Hades 개발사](https://www.supergiantgames.com/games/hades/) | 반복 회차·강적 대응, REFERENCE_ONLY | 입력 피드백/공략 감각. 수동 공격 체계 이식 안 함 |

Soulstone/DRG Steam 본문은 연령 확인 리디렉션으로 막혀 위 개발사 공식 페이지로 교차 확인했다. 특정 보스 AI·정확한 재사용 대기시간은 이 자료에서 확인한 것이 아니다. 흥행 성공 사례만 보고 현재 설계의 재미를 증명하지 않는다.

## 세 가지 제작 대안

| 대안 | 장점 | 비용·위험 | 판정 |
|---|---|---|---|
| 과거 승인 키아트를 축소 재사용 | 제작이 빠르고 기존 인상 유지 | 최신 사용자 새 제작 지시·인게임 스케일과 불일치 | REFERENCE_ONLY |
| 모델로 전체 영상/완성 화면만 제작 | 목표 느낌 전달에 유리 | 실제 분리 자산·상태·판정 소비처가 없음 | 화면 미리보기만 ADAPT, 게임 자산 대체는 REJECT |
| 역할별 투명 아틀라스 + 분리 VFX + 데이터 시간표 | 같은 자산을 PDF 검수와 게임에 연결 가능 | 알파/셀/발 접점/중간 프레임 검수 필요 | ADAPT, 품질 gate 통과 전 후보 |

순수 코드 벡터 그림으로 필요한 래스터 자산을 대신하지 않는다. PDF의 표·선·버튼 틀은 편집 가능한 구조 설명이며 게임 원화라고 주장하지 않는다. 자동 제거 알고리즘으로 무단 픽셀 편집하지 않고 알파 실패는 이미지 모델 재생성/편집으로 교정한다.

## 실무·엔진 근거

| 1차 자료 | 채택할 원리 | 증거 한계 |
|---|---|---|
| [Slay the Spire GDC 2019 개발자 발표 슬라이드](https://media.gdcvault.com/gdc2019/presentations/Giovannetti_Anthony_SlayTheSpire.pdf) | 플레이 관찰과 수치를 함께 사용, 반복 조정 | 이 프로젝트의 밸런스나 매출 보증 아님 |
| [Microsoft XAG 103](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103) | 색 외 모양·텍스트·소리 단서 | 문서 채택은 접근성 시험 PASS가 아님 |
| [Godot 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) | SpriteFrames/AnimatedSprite2D와 시트 사용 | 현재 런타임으로 프레임을 시험했다는 뜻 아님 |
| [Aseprite sprite sheets](https://www.aseprite.org/docs/sprite-sheet/) | 동일 셀·시트 import/export·메타데이터 | 모델이 그린 셀 정렬을 자동 보증하지 않음 |
| [Aseprite CLI](https://www.aseprite.org/docs/cli/) | 프레임/태그/패딩 export 개념 | 로컬 restricted MCP가 제공하지 않는 명령 실행 권한은 아님 |
| [Godot MultiMesh](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html) | 다수 렌더링 비용 묶기, 제약 확인 | AI·충돌 병목 해결을 보장하지 않음 |

기술 검토에서 기존 RunResumeStore는 previous 정리 실패와 본 저장 실패를 같은 bool로 반환하고, wallet은 직접 덮어쓰기한다. 새로운 소울 지급·재도전에서는 재시도 중복 위험이 커지므로 단일 profile 거래와 transaction_id를 권장했다. 이는 기존 게임을 이번에 고쳤다는 보고가 아니라 P04의 명시적 구현 입력이다.

## 재검토 조건

천술 순서 반응이 보조 기술과 충돌하면 반응 추가 대신 기존 상태 의미를 먼저 보호한다. 첫 이미지에서 체크무늬가 알파가 아닌 픽셀로 생성된 것이 확인되어 입력을 단순화해 재생성했다. 시트의 셀 경계가 겹치거나 이동이 미끄러우면 프레임 수를 늘리기 전 pivot/표시 크기를 확인한다. 도구 사용 성공을 아트 승인으로 승격하지 않는다.

개선의 실증은 두 빌드 비교, 실제 강적 전조 회피, 저사양 누적 군중, 한국어 읽기와 사람 경험 검사에서 얻는다. 현재 연구는 설계 근거이며 이 검사들은 NOT_RUN이다.
