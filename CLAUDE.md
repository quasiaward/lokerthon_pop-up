# CLAUDE.md — 행궁다과 다과 추천 아이패드 앱

## 프로젝트 개요
화성행궁 근처 전통 다과 브랜드 **행궁다과**의 팝업 부스용 **아이패드 앱**.
6문항 취향 테스트로 다과를 추천하는 단일 화면 앱. 로그인/DB 없음.

원래는 Flutter Web 홈페이지였고, 거기서 다과 추천 기능만 떼어내 iOS 앱으로
재구성했다. 메뉴·체험예약·케이터링 화면과 웹 빌드 설정(web/, vercel.json,
build.sh)은 모두 제거했다.

## 기술 스택
- **앱**: Flutter (Dart) → iOS (iPad 전용, 가로 고정)
- **추천 로직**: 기기 안에서 도는 규칙 기반 알고리즘 (네트워크·API 키 불필요)
- **백엔드**: FastAPI (`backend/`) — 지금은 쓰지 않음. 추후 OpenAI 추천 전환용으로 보관

## 대상 기기
iPad Pro 12.9형(5세대), iPadOS 26.6. **가로 전용.**

## 디렉토리 구조
```
lokerthon_pop-up/
├── lib/
│   ├── main.dart                          ← 앱 진입점, 가로 고정 + 전체화면 설정
│   ├── pages/
│   │   └── ai_recommendation_page.dart    ← 단일 화면 (추천 퀴즈 + KO/EN 토글)
│   ├── widgets/
│   │   ├── ai_recommendation_section.dart ← 랜딩·퀴즈·로딩·결과 전체 UI (핵심 파일)
│   │   ├── watercolor_deco.dart           ← 배경 수채화 장식
│   │   └── lang_toggle.dart               ← 한/영 전환 버튼
│   ├── services/
│   │   ├── recommendation_engine.dart       ← 엔진 인터페이스 + 다과 12종 목록
│   │   ├── local_recommendation_engine.dart ← 온디바이스 규칙 기반 추천 (기본값)
│   │   ├── api_recommendation_engine.dart   ← 백엔드 /recommend 호출 (추후 전환용)
│   │   └── recommendation_service.dart      ← 화면이 쓰는 진입점, 엔진 선택 지점
│   ├── data/
│   │   └── dagwa_results.dart             ← 다과 12종 결과 카드 문구·이미지
│   ├── theme/                             ← app_theme.dart, app_colors.dart
│   └── l10n/lang.dart                     ← 한/영 문자열 (tr 헬퍼)
├── ios/                                   ← iOS 러너, 앱 아이콘, Info.plist
├── assets/
│   ├── branding/app_icon.png              ← 앱 아이콘 원본 (1024px)
│   ├── figma/quiz/                        ← 퀴즈 선택지 이미지
│   ├── figma/recommend/                   ← 랜딩 미리보기 이미지
│   ├── figma/deco/                        ← 수채화 장식
│   └── figma/result_*.png                 ← 결과 화면 다과 이미지
├── backend/                               ← FastAPI (현재 미사용)
└── test/
    ├── widget_test.dart                   ← 추천 알고리즘 전수 검증
    └── ipad_layout_test.dart              ← 12.9형 가로 레이아웃 검증
```

## 추천 알고리즘

`lib/services/local_recommendation_engine.dart`의 `_scoreTable` 하나가 전부다.

- 6개 답변마다 어울리는 다과에 가중치를 더하고, 총점 최고인 다과를 고른다.
- Q4 식감 / Q5 계절 / Q6 문양은 메뉴를 직접 가리키는 신호라 최대 4점.
- Q1 기분 / Q2 날씨 / Q3 동행은 분위기 신호라 최대 3점.
- 가중치는 `backend/ai/prompts.py`의 "각 질문의 의미"를 그대로 옮긴 값이다.
- 추천 성향을 바꾸려면 `_scoreTable`의 숫자만 고치면 된다.

> ⚠️ `_scoreTable`의 키는 `ai_recommendation_section.dart`의 `_QuizOption.title`과
> **정확히** 같아야 한다. 표시용 번역 문자열(`titleEn`, `displayTitle`)이 아니라
> 로직 키를 쓴다. 선택지 문구를 바꿀 때는 양쪽을 함께 고쳐야 한다.

### OpenAI 추천으로 전환
`RecommendationService`가 엔진을 고르는 유일한 지점이다.

```bash
flutter run --dart-define=USE_API=true --dart-define=API_BASE_URL=https://...
```

## 다과 12종
흑임자다식, 도라지정과, 육포다식, 콩고물 도라지정과, 곶감 호두말이,
구움 견과 강정, 금귤정과, 깨강정, 영양찰떡, 양갱, 매작과, 수원약과

`dagwaResults`(결과 카드)와 `dagwaMenus`(추천 대상)의 키가 1:1로 맞아야 한다.
테스트가 이를 검증한다.

## 검증 명령
```bash
flutter analyze
flutter test
```

## 작업 시 주의
- **가로 전용이다.** 세로 레이아웃은 지원하지 않는다.
  방향을 바꾸려면 `ios/Runner/Info.plist`와 `lib/main.dart` 양쪽을 고쳐야 한다.
- 온디바이스 추천은 즉시 끝나므로 로딩 화면이 깜빡인다.
  `_minLoadingDuration`(1.4초)으로 최소 노출 시간을 준다.
- 랜딩의 미리보기 캐러셀은 화면보다 넓다. `OverflowBox`로 가로 제약을 풀고
  바깥 `ClipRect`가 잘라내는 구조다. 이 조합을 건드리면 오버플로 경고가 뜬다.
