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
│   │   └── result_screen.dart             ← 결과·페어링·다시하기 액션
│   ├── widgets/
│   │   ├── kiosk/                         ← 디자인 시스템 컴포넌트
│   │   │   ├── kiosk_canvas.dart          ← 1366×1024 고정 캔버스
│   │   │   ├── kiosk_button.dart          ← Primary/Secondary/Text
│   │   │   ├── choice_card.dart           ← 선택 카드
│   │   │   ├── kiosk_progress.dart        ← 진행 표시
│   │   │   ├── top_control.dart           ← 이전/처음으로
│   │   │   ├── dangwa_image.dart          ← 다과 이미지 컨테이너
│   │   │   ├── story_sheet.dart           ← 다과 상세 시트
│   │   └── lang_toggle.dart               ← 한/영/일 전환 (Idle·Intro에서만 노출)
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
│   └── l10n/lang.dart                     ← 한/영/일 (Lang, tr, L10nText)
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

행궁다과의 다식 꽃문양과 버건디·금빛·쑥빛을 브랜드 축으로 삼는다. 큰 제목과
넉넉한 여백은 유지하되, Apple Liquid Glass의 반투명 표면·빛 테두리·주변색 반사를
주요 조작과 상세 시트에만 절제해 적용한다.

### 토큰 (`lib/theme/app_colors.dart`)
- 바탕: warm ivory `#F5F0E8`, 카드: `#FFFCF7`
- 텍스트: `#241B1B` / 보조 `#746663`
- 브랜드: burgundy `#773243`, gold `#D5B36C`, moss `#5D664F`
- 여백은 `Space` 스케일에서만 고른다 (8·12·16·24·32·40·48·64·80·96·120)
- 실제 blur는 버튼·상단 조작·상세 시트에만 쓰고 반복 카드에서는 끈다

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
그림자·블러·gradient 남용, 전통문양·한지 texture·붓글씨 같은 직접적 클리셰,
하단 탭바·사이드바 등 전역 내비게이션.

## 다국어 (한국어 · 영어 · 일본어)

표시 문구는 전부 세 언어를 갖는다. 화면에 보이는 한국어가 남아 있으면 안 된다.

### 두 가지 도구
- **UI 문구**: `tr(ko, en, ja)` — 코드 안에 직접 쓰는 짧은 문자열.
- **데이터 문구**: `L10nText(ko, en, ja)` — `dagwa_results.dart`,
  `quiz_questions.dart`처럼 데이터 파일에 들어가는 문구. 쓸 때는 `.t`로 꺼낸다.

### 로직 키는 절대 번역하지 않는다
아래 값들은 언어가 바뀌어도 한국어 그대로여야 한다. 번역하면 추천이 깨진다.

| 값 | 쓰이는 곳 |
|---|---|
| `QuizOption.title` | 추천 알고리즘 점수표 키 |
| `DagwaResult.menuName` | `dagwaResults` 맵 키, `toneFor()` 조회 키 |
| `DagwaResult.runnerUp` | 다음 추천 조회 키 |

그래서 **로직 키와 표시 문구를 분리**해 뒀다. 선택지는 `title`(키)과
`label`(표시), 다과는 `menuName`(키)과 `name`(표시)을 따로 갖는다.

### 폰트
Pretendard가 커버하지 못하는 가나·한자는 `kSansFallback`이 이어받는다.
같은 한자라도 일본어와 한국어의 자형이 달라서 **Hiragino를 한글 폰트보다 앞에**
둔다. 순서를 바꾸면 일본어 화면에 한국어용 자형이 섞인다.

### 확인
```bash
flutter run --dart-define=KIOSK_LANG=ja --dart-define=KIOSK_STAGE=result
```
`test/l10n_test.dart`가 세 언어가 모두 채워졌는지, 영어·일본어에 한글이
남아 있지 않은지, 로직 키가 언어와 무관하게 고정인지 검사한다.

## 아이콘 규칙

아이콘이 화면마다 제각각이면 "아무 데나 붙인" 인상을 준다. 세 가지만 지킨다.

### 1. 계열은 `_rounded` 하나만
`Icons.home_rounded`처럼 **항상 `_rounded`** 를 쓴다. `_outlined`·`_sharp`는 쓰지
않는다. 같은 뜻의 아이콘이 화면마다 다른 계열로 들어가면 눈이 멈칫한다.
둥근 모서리(radius 24~44)와 Pretendard의 인상에도 `_rounded`가 맞는다.

### 2. 크기는 두 단계
| 단계 | 크기 | 쓰는 곳 |
|---|---|---|
| 본문 옆 | 20 | 상단 컨트롤, 선택 카드 체크, 안내 문구 |
| 강조 | 24 | CTA 버튼, 결과 화면의 배지 |

중간값(19·21·23·25)을 쓰지 않는다. 개별로는 안 보여도 한 화면에 모이면
정렬이 어긋난 느낌을 만든다.

### 3. 색은 역할로 정한다
| 역할 | 색 |
|---|---|
| 주 조작 | `AppColors.accent` |
| 보조 조작·닫기 | `AppColors.muted` / `charcoal` |
| 채워진 바탕 위 | `Colors.white` |
| 오류 | `Colors.red.shade700` |

**다과별 가변색(`tone.deep`)은 아이콘에 쓰지 않는다.** 타이포와 구분선에만 쓴다.
아이콘까지 다과마다 바뀌면 같은 자리의 같은 아이콘이 매번 달라 보인다.

### 4. 장식으로 아이콘을 얹지 않는다
문구만으로 뜻이 통하는 자리에는 아이콘을 넣지 않는다. 아이콘은 **할 일이
생겼을 때만** 나온다. 예를 들어 질문 화면 하단 안내는 평상시 문구만 보여 주고,
오류가 났을 때만 재시도 아이콘이 붙는다.

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
- 온디바이스 추천은 즉시 끝난다. 기대감은 `TransitionScreen`의 1.4초가 만든다.
  spinner나 progress bar는 쓰지 않는다.
- 단계 전환은 현재 화면을 완전히 투명하게 만든 뒤 다음 화면으로 교체한다.
  `AnimatedSwitcher` crossfade를 쓰면 두 화면이 동시에 그려져 잔상이 생기므로
  `KioskPage._change()`의 순차 fade 방식을 유지한다.
- `dagwa_results.dart`의 `runnerUp`에 `'견과류 강정'`처럼 메뉴 키와 다른 표기가
  있다. 문구는 그대로 두고 `result_screen.dart`의 `_runnerUpAliases`가 이미지
  조회만 이어 준다.
- 질문 단계는 **화면을 갈아끼우지 않는다.** `kiosk_page.dart`의 키가
  `ValueKey('question')`으로 고정이고, `QuestionScreen` 안에서 질문 블록만
  교체된다. 다음 질문도 현재 화면이 완전히 사라진 뒤 내용을 바꾼다.
- 큰 서브트리에 불투명도를 걸 때는 `RepaintBoundary`로 감싼다. 안 그러면 매
  프레임 `saveLayer`가 생긴다.

## 성능 측정

`lib/perf_probe.dart`가 프레임 build/raster 시간을 모아 3초마다 출력한다.
`kiosk_page.dart`의 `_autoDrive()`가 사람이 누르는 것과 같은 경로로 단계를
자동 주행해서, 손을 대지 않고도 같은 조건으로 반복 측정할 수 있다.

```bash
flutter run --profile -d <기기> --dart-define=PERF_PROBE=true
```

대상 기기는 120Hz(ProMotion)라 프레임 예산이 8.3ms다.
2026-09-15 측정 기준 모든 단계에서 raster p90 ≈ 1.0~1.7ms, jank 0%.
