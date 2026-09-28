# 행궁다과 — 다과 추천 아이패드 앱

화성행궁 전통 다과 브랜드 **행궁다과**의 팝업 부스용 아이패드 앱입니다.
6문항 취향 테스트로 오늘의 다과를 추천합니다. 12개 다과 데이터를
보존하면서 금귤정과·매작과·양갱·콩고물 도라지정과·흑임자다식 5종을 운영합니다.

기존 Flutter Web 홈페이지에서 **다과 추천 기능만** 떼어내 단일 화면 iOS 앱으로
재구성했습니다. 메뉴·체험예약·케이터링 등 나머지 웹 화면과 웹 빌드 설정은 제거했습니다.

## 동작 방식

추천은 **기기 안에서 규칙 기반으로 계산**합니다. 네트워크도 API 키도 필요 없습니다.

6개 답변마다 어울리는 다과에 가중치를 더하고, 총점이 가장 높은 다과를 고릅니다.
가중치는 기존 백엔드 프롬프트(`backend/ai/prompts.py`)의 "각 질문의 의미"를 그대로
옮긴 값이라, 나중에 OpenAI 추천으로 바꿔도 결과 성향이 크게 달라지지 않습니다.

`lib/data/dangwa_catalog.dart`의 `activeDagwaMenus`가 운영 5종을 관리합니다.
나머지 7종은 추천 결과·시작 이미지 순환에서 제외되지만 설명,
번역, 이미지와 점수 정보는 삭제하지 않습니다.

### 관리자 재고 설정

시작 화면 상단의 **‘행궁다과’ 로고를 길게 누르면** 관리자 설정이 열립니다.
품절된 다과를 끄면 다음 추천부터 결과와 시작 이미지에서 즉시 제외됩니다.
설정은 아이패드에 저장되어 앱을 재실행해도 유지되며, 추천 가능한 다과는 최소 1종이 남도록 보호합니다.

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

- `test/widget_test.dart` — 4096개 답변 조합을 전수로 돌려 운영 5종만 추천되는지,
  품절 메뉴가 결과에 섞이지 않는지, 같은 답변에 같은 결과가 나오는지 확인합니다.
- `test/dangwa_inventory_test.dart` — 품절 설정 저장·복원, 비운영 메뉴 차단,
  마지막 재고 1종 보호를 확인합니다.
- `test/ipad_layout_test.dart` — 11형 화면 채움과 1366×1024(12.9형 가로)에서 Idle → Intro → 6문항 →
  전환 → 결과까지 실제로 눌러 가며 오버플로가 없는지, 상세 시트가 열리고 닫히는지,
  12개 다과 결과 화면이 모두 깨지지 않는지, 전환 중 두 화면이 겹치지 않는지 확인합니다.

- `test/release_review_test.dart` — 실제 폰트로 세 언어의 질문·결과·상세 화면,
  터치 영역, 버튼 접근성, 상단 정렬, 중복 터치, 뒤로 이동, 오류 후 재시도,
  자동 초기화와 이전 세션의 늦은 응답, 동작 줄이기를 검증합니다.

## 화면 구성

`lib/pages/kiosk_page.dart`가 단계 전환을 관리합니다.

| 단계 | 내용 |
|------|------|
| Idle | 팝업 공간의 디지털 포스터. 터치하면 시작 |
| Intro | 시작해도 된다는 확신을 주는 화면 |
| Question | 6문항 (기분 색 / 마음의 날씨 / 동행 / 식감 / 계절 / 문양) |
| Transition | 결과 공개 직전 연출 (1.6초, spinner 없음) |
| Result | 다과 이미지·추천 이유·수령 안내·행궁다과 도보 길찾기·다시하기 액션 |
| Story | 다과 상세 이야기 (아래에서 올라오는 시트) |

Intro·질문·결과·상세 이야기에서 45초 동안 아무 조작이 없으면 답변을 지우고 Idle로 돌아갑니다.
시작 화면과 Intro는 상단 조작 버튼을 제외한 화면 어디든 터치해 진행할 수 있습니다.
동작 줄이기를 켜면 배경·손가락·이미지의 반복 움직임과 이미지 자동 교체가 멈춥니다.
KO/EN/JP 토글은 Idle·Intro에서만 보입니다 — 체험 중에는 흐름을 방해하지 않습니다.

결과 화면의 **‘행궁다과도 만나보세요’** 카드를 누르면 팝업 장소인 가회당에서
행궁다과까지의 도보 경로(약 1분·98m)를 앱 안의 안내 그림과 두 단계 설명으로 보여 줍니다.

## 다국어

**한국어 · 영어 · 일본어** 세 언어를 지원합니다. 다과 추천 결과의 긴 설명,
어울리는 차, 다음 추천, 상세 이야기까지 전부 번역되어 있어 영어·일본어를 고르면
화면에 한국어가 남지 않습니다.

- UI 문구는 `tr(ko, en, ja)`, 데이터 문구는 `L10nText(ko, en, ja)`를 씁니다.
- 추천 알고리즘이 읽는 **로직 키는 한국어로 고정**입니다. 선택지는 `title`(키)과
  `label`(표시), 다과는 `menuName`(키)과 `name`(표시)을 따로 갖습니다.
- `test/l10n_test.dart`가 번역 누락과 한글 잔존을 막습니다.

특정 언어로 바로 띄워 확인하려면:

```bash
flutter run --dart-define=KIOSK_LANG=ja --dart-define=KIOSK_STAGE=result
```

## 디자인

행궁다과의 다식 꽃문양과 버건디·금빛·쑥빛을 중심으로 브랜드 인상을 강화했습니다.
밝은 아이보리 배경 위에 Apple Liquid Glass에서 가져온 반투명 표면, 빛 테두리,
주변색 반사를 주요 버튼·상단 조작·상세 시트에 절제해 적용했습니다. 반복되는 선택
카드는 가벼운 반투명 표면으로 처리해 가독성과 프레임 성능을 유지합니다. 화면 전환은
이전 화면이 완전히 사라진 뒤 다음 화면을 표시해 이미지와 글자가 겹치는 잔상을 막습니다.
모든 화면은 1366×1024를 기준으로 그립니다. 11형처럼 더 넓은 화면에서는
캔버스 폭을 늘려 양옆까지 배경과 콘텐츠를 채웁니다.

질문·선택지·다과 이미지·결과 문구·추천 로직은 **기존 것을 그대로 유지**했고,
바꾼 것은 art direction·레이아웃·타이포·컴포넌트·모션입니다.

화면 하나를 바로 띄워 확인하려면:

```bash
flutter run --dart-define=KIOSK_STAGE=result   # idle|intro|question|transition|result
```

## 아이패드 설정

- **대상 기기**: iPad Pro 12.9형 (5세대) 및 11형 (3세대), 가로 화면
- **가로 전용**: `Info.plist`의 `UISupportedInterfaceOrientations`와
  `main.dart`의 `setPreferredOrientations` 양쪽에서 가로로 고정
- **전체화면 고정**: `UIRequiresFullScreen = true` (스플릿뷰·슬라이드오버 차단)
- **상태표시줄 숨김**: `UIStatusBarHidden = true` + `immersiveSticky` 모드
- **앱 아이콘**: `assets/branding/app_icon.png` (다식판 꽃문양 모티브)
- **폰트**: Pretendard(본문) + Fraunces(영문 accent)

## 실기기 설치

처음 한 번은 수동 설정이 필요합니다.

1. **Xcode에 Apple ID 로그인** — Xcode → Settings → Accounts → `+` → Apple ID
2. **아이패드 개발자 모드 켜기** — 설정 → 개인정보 보호 및 보안 → 개발자 모드 → 켬 → 재시동
3. 유선 연결 후 설치

```bash
flutter devices          # 아이패드가 보이는지 확인
flutter build ios --release
flutter install --release -d <기기 ID>
```
