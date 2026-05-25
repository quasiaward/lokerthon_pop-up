# Figma AI에 보낼 자료

아래 3개를 Figma AI에 함께 넣으면 됩니다.

## 1. 붙여 넣을 프롬프트

- `figma_ai_prompt.txt`

## 2. 첨부할 스크린샷

- `screenshots/haenggung_desktop_first_fold.png`
- `screenshots/haenggung_desktop_long_page.png`

## 3. 선택 첨부

- `design_tokens.json`
- `figma_handoff.md`

## Figma AI 입력 예시

1. Figma AI 또는 Make Design을 엽니다.
2. `figma_ai_prompt.txt` 내용을 그대로 붙여 넣습니다.
3. 스크린샷 2장을 첨부합니다.
4. 결과가 너무 이미지처럼 나오면 이렇게 추가 요청합니다.

```text
첨부 이미지는 참고용으로만 사용하고, 최종 결과는 텍스트와 도형이 모두 편집 가능한 Auto Layout 기반 Figma 레이어로 다시 만들어줘. 스크린샷을 그대로 배치하지 말고 컴포넌트화해줘.
```

## 가장 중요한 요구

- 데스크톱 웹 우선
- 편집 가능한 레이어
- Color Styles / Text Styles 적용
- 카드 radius 8px 이하
- 전통적이지만 세련된 프리미엄 다과 브랜드
- `AI 다과 추천` 결과는 다과상이 아니라 개별 다과 추천 느낌으로 구성
