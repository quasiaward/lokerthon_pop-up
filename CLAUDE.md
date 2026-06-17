# CLAUDE.md — 행궁다과 프로젝트

## 프로젝트 개요
화성행궁 근처 전통 다과 브랜드 **행궁다과**의 공식 웹사이트.
Flutter Web(프론트) + FastAPI(백엔드) 구조. 로그인/DB 없음.

## 기술 스택
- **프론트**: Flutter Web (Dart) → Vercel 배포
- **백엔드**: FastAPI (Python) → Railway 배포
- **AI**: OpenAI API (다과 추천)
- **이메일**: SMTP (예약/주문 → 사장님 이메일 발송)

## 라우팅
| 경로 | 페이지 |
|------|--------|
| `/` | 홈화면 |
| `/menu` | 메뉴화면 |
| `/experience` | 원데이클래스 예약 |
| `/ai` | 나만의 다과 추천 |
| `/custom` | 커스텀 다과상자 주문 |

> ⚠️ `/catering` 경로는 사용하지 않음. `/custom` 사용.

## 디렉토리 구조
```
lokerthon/
├── lib/
│   ├── main.dart                        ← 앱 진입점, 라우팅 설정
│   ├── pages/
│   │   ├── home_page.dart               ← 홈화면 (소셜링크, 서비스 3버튼, 대표메뉴)
│   │   ├── menu_page.dart               ← 메뉴화면 (카테고리 탭, 카드 클릭 시 팝업)
│   │   ├── experience_page.dart         ← 원데이클래스 예약 폼 + 이메일 발송
│   │   ├── ai_recommendation_page.dart  ← 6문항 퀴즈 + OpenAI 추천 결과
│   │   └── custom_page.dart             ← 다과상자 구성 + 주문 폼 + 이메일 발송
│   ├── widgets/
│   │   ├── app_nav.dart                 ← 상단 네비게이션 바
│   │   ├── footer.dart                  ← 하단 푸터
│   │   ├── floating_chatbot.dart        ← 우하단 챗봇 버튼 (작동 안 하는 UI만)
│   │   ├── menu_section.dart            ← 홈 내 대표메뉴 3개 미리보기 섹션
│   │   ├── ai_recommendation_section.dart ← 홈 내 AI추천 소개 섹션
│   │   ├── reservation_section.dart     ← 홈 내 예약 유도 섹션
│   │   ├── catering_section.dart        ← 홈 내 다과상자 소개 섹션
│   │   ├── watercolor_deco.dart         ← 배경 수채화 장식 UI
│   │   ├── page_shell.dart              ← 공통 페이지 레이아웃 래퍼
│   │   ├── brand_logo.dart              ← 브랜드 로고 위젯
│   │   ├── lang_toggle.dart             ← 한/영 언어 전환 버튼
│   │   └── common.dart                  ← 공통 UI 컴포넌트 모음
│   ├── models/
│   │   ├── product.dart                 ← 메뉴 상품 데이터 모델
│   │   └── recommendation.dart          ← AI 추천 결과 데이터 모델
│   ├── services/
│   │   └── recommendation_service.dart  ← FastAPI 백엔드 API 호출 서비스
│   ├── data/
│   │   └── place_info.dart              ← 매장 정보, 소셜 링크, 메뉴 정적 데이터
│   ├── theme/
│   │   ├── app_theme.dart               ← 전체 앱 테마 설정
│   │   └── app_colors.dart              ← 색상 상수 정의
│   └── l10n/
│       └── lang.dart                    ← 한/영 다국어 텍스트 정의
├── backend/
│   ├── main.py                          ← FastAPI 앱 진입점, 라우터 등록, CORS 설정
│   ├── routers/
│   │   ├── ai.py                        ← POST /recommend 엔드포인트만 (얇게 유지)
│   │   └── email.py                     ← POST /email/experience, /email/custom
│   ├── ai/
│   │   ├── client.py                    ← OpenAI 클라이언트 초기화
│   │   ├── prompts.py                   ← 다과 추천용 프롬프트 템플릿 (직접 수정)
│   │   └── recommend.py                 ← 추천 핵심 로직 (OpenAI 호출 + 결과 파싱)
│   ├── .env                             ← API 키, 이메일 설정 (git 제외)
│   └── requirements.txt                 ← 패키지 목록
├── web/
│   ├── index.html                       ← Flutter Web 진입 HTML
│   ├── manifest.json                    ← PWA 설정
│   └── icons/                           ← 앱 아이콘
├── assets/
│   ├── figma/                           ← 피그마에서 가져온 이미지 에셋
│   └── fonts/                           ← 폰트 파일
├── pubspec.yaml                         ← Flutter 패키지 및 에셋 설정
├── vercel.json                          ← Vercel 배포 설정
└── CLAUDE.md                            ← 이 파일
```

## 페이지별 스펙

### 1. 홈화면 (`/`)
- 스크롤 웹페이지 (모바일 아님)
- 소셜 링크 버튼: 인스타그램, 블로그, 유튜브 (외부 링크)
- 대표 메뉴 섹션: 카드 3개 미리보기 → "메뉴 자세히 보러가기" 버튼 → `/menu`
- 서비스 3버튼 (내부 라우팅):
  - 나만의 다과 추천 → `/ai`
  - 원데이클래스 → `/experience`
  - 커스텀 다과상자 → `/custom`
- 우하단 플로팅 챗봇 버튼: **UI만 존재, 기능 구현하지 말 것**

### 2. 메뉴화면 (`/menu`)
- 카테고리 탭: 음료 / 다과 / 빙수 (탭 클릭 시 해당 카테고리만 표시)
- 메뉴 데이터: 정적 하드코딩
- 메뉴 카드 클릭 → 팝업/모달 오픈
  - 모달 내 설명: OpenAI로 미리 생성해둔 2~3줄 텍스트 하드코딩 (실시간 API 호출 없음)
- 가격 표시 있음

### 3. 원데이클래스 (`/experience`)
- 체험 종류: 떡 만들기 / 다식 만들기 (각 1인당 50,000원)
- 폼 항목: 체험 종류, 성인 인원, 어린이 인원, 날짜, 시간
- 체험비 자동 계산 (인원 입력 시 실시간 표시)
- 플로우: "체험문의접수하기" 클릭 → 확인 모달 → "확인" 클릭 → `POST /email/experience` → 사장님 이메일 발송

### 4. 나만의 다과 추천 (`/ai`)
- 질문 6가지 순서대로 진행
- 6개 답변 → `POST /recommend` → OpenAI가 아래 12개 메뉴 중 1개 선택 반환
- **추천 가능한 12개 메뉴 (이 목록 안에서만 선택):**
  1. 흑임자다식
  2. 도라지정과
  3. 육포다식
  4. 콩고물 도라지정과
  5. 곶감 호두말이
  6. 구움 견과 강정
  7. 금귤정과
  8. 깨강정
  9. 영양찰떡
  10. 양갱
  11. 매작과
  12. 수원약과
- 결과 화면: 추천 메뉴 표시 + "메뉴 보러가기" 버튼 → `/menu`
- **기존 룰베이스 로직(recommendation_service.dart) 삭제할 것**
- OpenAI 프롬프트는 개발 시 별도 전달 예정

### 5. 커스텀 다과상자 (`/custom`)
- 1단계: 상자 크기 선택
  - 4구 8,000원 / 6구 12,000원 / 9구 18,000원
  - 포장비 1,500원 고정 추가
- 2단계: 수량 선택 (같은 구수만 복수 주문 가능, 혼합 불가)
- 3단계: 선택한 구수만큼 다과 담기 (다과류만, 중복 가능)
- 4단계: 주문 폼 (성함, 연락처, 희망 픽업 날짜, 희망 픽업 시간)
- 가격 자동 계산: (상자 가격 × 수량) + 포장비 1,500원
- 플로우: 확인 모달 → "확인" 클릭 → `POST /email/custom` → 사장님 이메일 발송

## 백엔드 API 엔드포인트

### POST `/recommend`
- Input: `{ answers: [string, string, string, string, string, string] }`
- 처리: OpenAI 호출 → 12개 메뉴 중 1개 선택
- Output: `{ menu: string }`

### POST `/email/experience`
- Input: `{ type, adults, children, date, time, total_price }`
- 처리: 사장님 이메일로 예약 문의 내용 발송
- Output: `{ success: boolean }`

### POST `/email/custom`
- Input: `{ name, phone, box_size, quantity, items: string[], pickup_date, pickup_time, total_price }`
- 처리: 사장님 이메일로 주문 내용 발송
- Output: `{ success: boolean }`

## 환경 변수
`.env` 파일 참고 (`.env.example` 기준으로 생성)

## 실행 명령어

### 프론트 (Flutter)
```bash
flutter pub get
flutter run -d chrome
flutter build web --no-wasm-dry-run
flutter analyze
```

### 백엔드 (FastAPI)
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## 배포
- **프론트**: Vercel (vercel.json 설정 완료, GitHub 연동)
- **백엔드**: Railway (GitHub 연동 완료)

## 주의사항
- `.env` 파일은 절대 git에 커밋하지 말 것
- `/catering` 경로 사용 금지 → `/custom` 사용
- 챗봇 버튼은 UI만, 기능 구현 금지
- 메뉴 설명 텍스트는 하드코딩 (실시간 API 호출 없음)
- FastAPI에 CORS 설정 필수 (Flutter Web → Railway 호출 시 필요)
- 기존 `recommendation_service.dart` 룰베이스 로직은 삭제 예정
- `backend/ai/` 폴더 코드는 초기 구현 후 사용자가 직접 리뷰하고 수정함 → 한 번 짠 이후에는 사용자 확인 없이 임의로 변경하지 말 것
