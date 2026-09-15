# 행궁다과 — 다과 추천 아이패드 앱

화성행궁 전통 다과 브랜드 **행궁다과**의 팝업 부스용 아이패드 앱입니다.
6문항 취향 테스트로 오늘의 다과를 추천합니다.

기존 Flutter Web 홈페이지에서 **다과 추천 기능만** 떼어내 단일 화면 iOS 앱으로
재구성했습니다. 메뉴·체험예약·케이터링 등 나머지 웹 화면과 웹 빌드 설정은 제거했습니다.

## 동작 방식

추천은 **기기 안에서 규칙 기반으로 계산**합니다. 네트워크도 API 키도 필요 없습니다.

6개 답변마다 어울리는 다과에 가중치를 더하고, 총점이 가장 높은 다과를 고릅니다.
가중치는 기존 백엔드 프롬프트(`backend/ai/prompts.py`)의 "각 질문의 의미"를 그대로
옮긴 값이라, 나중에 OpenAI 추천으로 바꿔도 결과 성향이 크게 달라지지 않습니다.

```text
lib/services/
  recommendation_engine.dart        ← 엔진 인터페이스 + 다과 12종 목록
  local_recommendation_engine.dart  ← 온디바이스 규칙 기반 추천 (현재 기본값)
  api_recommendation_engine.dart    ← 백엔드 /recommend 호출 (추후 전환용)
  recommendation_service.dart       ← 화면이 쓰는 진입점, 여기서 엔진을 고른다
```

### OpenAI 추천으로 전환하기

`RecommendationService`가 엔진을 고르는 유일한 지점입니다. 빌드 플래그만 켜면 됩니다.

```bash
flutter run --dart-define=USE_API=true \
            --dart-define=API_BASE_URL=https://<배포된-백엔드-주소>
```

백엔드는 `backend/`에 그대로 두었습니다. 추천 API(`/recommend`)만 남기고
예약 이메일 발송 기능은 제거했습니다.

## 실행

```bash
flutter pub get
flutter run -d <기기 또는 시뮬레이터>
```

## 검증

```bash
flutter analyze
flutter test
```

- `test/widget_test.dart` — 추천 알고리즘. 4096개 답변 조합을 전수로 돌려
  12개 다과가 모두 추천되는지, 한 메뉴로 쏠리지 않는지(각 20% 미만),
  같은 답변에 같은 결과가 나오는지 확인합니다.
- `test/ipad_layout_test.dart` — 1366×1024(12.9형 가로)에서 랜딩 → 6문항 → 결과까지
  오버플로 없이 그려지는지 확인합니다.

## 화면 구성

단일 화면(`lib/pages/ai_recommendation_page.dart`)에 추천 퀴즈 하나만 올렸습니다.

| 단계 | 내용 |
|------|------|
| 랜딩 | 다과 미리보기 흐름 + 시작 버튼 |
| 퀴즈 | 6문항 (기분 색 / 마음의 날씨 / 동행 / 식감 / 계절 / 문양) |
| 로딩 | 분석 중 (최소 1.4초 노출) |
| 결과 | 추천 다과 + 어울리는 차 + 다음 추천 |

우측 상단에 KO/EN 토글이 있습니다.

## 아이패드 설정

- **대상 기기**: iPad Pro 12.9형 (5세대), iPadOS 26.6
- **가로 전용**: `Info.plist`의 `UISupportedInterfaceOrientations`와
  `main.dart`의 `setPreferredOrientations` 양쪽에서 가로로 고정
- **전체화면 고정**: `UIRequiresFullScreen = true` (스플릿뷰·슬라이드오버 차단)
- **상태표시줄 숨김**: `UIStatusBarHidden = true` + `immersiveSticky` 모드
- **앱 아이콘**: `assets/branding/app_icon.png` (다식판 꽃문양 모티브)

## 실기기 설치

처음 한 번은 수동 설정이 필요합니다.

1. **Xcode에 Apple ID 로그인** — Xcode → Settings → Accounts → `+` → Apple ID
2. **아이패드 개발자 모드 켜기** — 설정 → 개인정보 보호 및 보안 → 개발자 모드 → 켬 → 재시동
3. 유선 연결 후 설치

```bash
flutter devices          # 아이패드가 보이는지 확인
flutter install -d <기기 ID>
```
