# 행궁다과

화성행궁의 분위기를 담은 전통 다과 카페 웹 데모입니다. Flutter Web으로 제작했으며, Figma 디자인을 기준으로 홈, 메뉴, 체험 예약, 케이터링, 나만의 다과 추천 화면을 구현했습니다.

## 주요 기능

- 브랜드 소개와 대표 메뉴를 보여주는 홈 화면
- 전통차와 다과를 확인할 수 있는 메뉴 화면
- 떡 만들기와 다식 만들기 체험 예약 화면
- 6구 다과 상자를 직접 구성하는 케이터링 화면
- 취향 질문을 바탕으로 다과를 추천하는 AI 추천 화면
- 우측 하단 플로팅 챗봇 데모 버튼

## 기술 스택

- Flutter / Dart
- Flutter Web
- Material Design 기반 커스텀 UI
- Figma 기반 이미지 asset

## 실행 방법

```bash
flutter pub get
flutter run -d chrome
```

웹 배포용 빌드는 아래 명령으로 생성합니다.

```bash
flutter build web --no-wasm-dry-run
```

## 프로젝트 구조

```text
lib/
  main.dart
  pages/       # 라우트별 페이지
  widgets/     # 화면 섹션과 공통 UI
  models/      # 추천 결과 모델
  services/    # 다과 추천 로직
  theme/       # 색상과 앱 테마
assets/
  figma/       # Figma에서 가져온 화면 이미지와 다과 이미지
```

## 주요 라우트

- `/` 홈
- `/menu` 메뉴
- `/experience` 체험 예약
- `/catering` 케이터링 다과 상자 구성
- `/ai` 나만의 다과 추천

## 검증 명령

```bash
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```
