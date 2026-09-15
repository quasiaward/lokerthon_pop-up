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
│   │   └── kiosk_page.dart                ← 단계 상태 머신 + 무동작 리셋
│   ├── screens/                           ← 화면 하나당 파일 하나
│   │   ├── idle_screen.dart               ← 01 Attract/Idle (디지털 포스터)
│   │   ├── intro_screen.dart              ← 02 Intro
│   │   ├── question_screen.dart           ← 03 Question (6문항)
│   │   ├── transition_screen.dart         ← 결과 공개 직전 연출
│   │   └── result_screen.dart             ← 결과 (editorial spread)
│   ├── widgets/
│   │   ├── kiosk/                         ← 디자인 시스템 컴포넌트
│   │   │   ├── kiosk_canvas.dart          ← 1366×1024 고정 캔버스
│   │   │   ├── glass_surface.dart         ← 반투명 유리 표면
│   │   │   ├── kiosk_button.dart          ← Primary/Secondary/Text
│   │   │   ├── choice_card.dart           ← 선택 카드
│   │   │   ├── kiosk_progress.dart        ← 진행 표시
│   │   │   ├── top_control.dart           ← 이전/처음으로
│   │   │   ├── dangwa_image.dart          ← 다과 이미지 컨테이너
│   │   │   ├── metadata_row.dart          ← 부가 정보 조판
│   │   │   ├── story_sheet.dart           ← 다과 상세 시트
│   │   │   └── ambient_field.dart         ← 느리게 떠다니는 배경 색
│   │   └── lang_toggle.dart               ← 한/영 전환 (Idle·Intro에서만 노출)
│   ├── services/
│   │   ├── recommendation_engine.dart       ← 엔진 인터페이스 + 다과 12종 목록
│   │   ├── local_recommendation_engine.dart ← 온디바이스 규칙 기반 추천 (기본값)
│   │   ├── api_recommendation_engine.dart   ← 백엔드 /recommend 호출 (추후 전환용)
│   │   └── recommendation_service.dart      ← 화면이 쓰는 진입점, 엔진 선택 지점
│   ├── data/
│   │   ├── dagwa_results.dart             ← 다과 12종 결과 카드 문구·이미지
│   │   ├── dagwa_tones.dart               ← 다과별 대표색 (이미지에서 추출)
│   │   └── quiz_questions.dart            ← 6문항 질문·선택지 원본
│   ├── theme/
│   │   ├── app_colors.dart                ← 색·여백·반경·모션 토큰
│   │   └── app_theme.dart                 ← 타이포 스케일 (Type)
│   └── l10n/lang.dart                     ← 한/영 문자열 (tr 헬퍼)
├── ios/                                   ← iOS 러너, 앱 아이콘, Info.plist
├── assets/
│   ├── branding/app_icon.png              ← 앱 아이콘 원본 (1024px)
│   ├── figma/quiz/                        ← 퀴즈 선택지 이미지
│   ├── figma/recommend/                   ← 랜딩 미리보기 이미지
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


## 디자인 시스템

Figma Make로 만든 키오스크 디자인을 이식했다. 원본은 `~/Downloads/이행 요청 처리`
(React + Tailwind)이며, 디자인 브리프는 그 안의
`src/imports/pasted_text/ipad-kiosk-design-brief.md`에 있다.

방향: **"한국 전통 다과를 현대적인 럭셔리 브랜드 경험으로 재해석한 디지털 테이스팅
인터페이스."** 전통을 직접 그리지 않고 여백·절제·비례·색으로 번역한다.

### 토큰 (`lib/theme/app_colors.dart`)
- 바탕: warm ivory `#F4F0E8` — 순백은 쓰지 않는다
- 먹: `#1C1917` / 보조 `#6B6357`
- accent: deep burgundy `#6D1F2B` **하나만** 쓴다
- 여백은 `Space` 스케일에서만 고른다 (8·12·16·24·32·40·48·64·80·96·120)
- 깊이는 그림자가 아니라 톤·여백·스케일로 만든다

### 타이포 (`lib/theme/app_theme.dart`의 `Type`)
Pretendard sans가 본문. 영문 accent에만 Fraunces italic을 보조로 쓴다.
**한글 본문은 serif로 만들지 않는다.** `Type.eyebrow`는 `latin` 플래그로 자간을
가른다 — 영문 대문자에는 넓은 자간, 한글에는 거의 주지 않는다.

### 레이아웃
모든 화면은 `KioskCanvas` 안의 **1366×1024 고정 좌표**로 그린다. 대상 기기에서
배율이 정확히 1이고, 비율이 다른 태블릿에서도 구조가 깨지지 않는다.
좌우 여백 88~96px, 상하 72~80px.

### 화면 흐름
```
Idle ─터치─> Intro ─시작─> Question ×6 ─> Transition ─> Result ─> Story(시트)
  ^                                                         │
  └────────────── 45초 무동작 또는 '처음으로' ────────────────┘
```

### 디자인 확인용 플래그
화면 하나를 바로 띄워 볼 수 있다.
```bash
flutter run --dart-define=KIOSK_STAGE=result      # idle|intro|question|transition|result
flutter run --dart-define=KIOSK_STAGE=result --dart-define=KIOSK_STORY=true
```

### 하지 않기로 한 것
그림자 남용, 모든 콘텐츠를 흰 카드에 담기, pill 버튼, gradient 남용,
전통문양·한지 texture·붓글씨 같은 직접적 클리셰, 하단 탭바·사이드바 등 전역 내비게이션.

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
- 온디바이스 추천은 즉시 끝난다. 기대감은 `TransitionScreen`의 2.2초가 만든다.
  spinner나 progress bar는 쓰지 않는다.
- 결과 화면은 앞 화면이 빠져나갈 시간을 주려고 등장을 380ms 늦춘다.
  이 값을 0으로 되돌리면 전환 화면과 겹쳐 보인다.
- `dagwa_results.dart`의 `runnerUp`에 `'견과류 강정'`처럼 메뉴 키와 다른 표기가
  있다. 문구는 그대로 두고 `result_screen.dart`의 `_runnerUpAliases`가 이미지
  조회만 이어 준다.
- 유리 표면(`GlassSurface`)은 `BackdropFilter`라 비싸다. 한 화면에 4~5개를
  넘기지 않는다.
