# Haenggung Dagwa Figma Handoff

이 폴더는 `demo ver0` 웹사이트 디자인을 Figma로 옮길 때 쓰는 핸드오프 문서입니다.

## 추천 작업 방식

1. 로컬 웹사이트 열기
   - URL: `http://127.0.0.1:5175/`
   - 서버가 꺼져 있으면 프로젝트 루트에서 `python3 -m http.server 5175 --directory build/web` 실행

2. 화면 캡처 가져오기
   - Chrome에서 페이지 열기
   - `Cmd + Option + I`
   - `Cmd + Shift + P`
   - `Capture full size screenshot` 실행
   - 저장된 PNG를 Figma 캔버스에 드래그

3. Figma에서 재구성
   - 캡처 이미지는 맨 아래 locked layer로 둡니다.
   - 아래 토큰을 Styles로 등록합니다.
   - 섹션, 카드, 버튼, 폼을 Auto Layout으로 다시 만듭니다.

## Figma 프레임

- Desktop: `1440 x 1024`
- Wide Desktop: `1728 x 1117`
- Mobile 참고용: `390 x 844`
- 콘텐츠 최대 폭: `1180`
- 좌우 패딩: desktop `24`, mobile `18`
- 주요 섹션 상하 패딩: `88-96`
- 카드 radius: `8`

## Color Styles

| Name | Hex | Use |
| --- | --- | --- |
| Cream | `#F7EFE4` | page background |
| Paper | `#FFFCF7` | header, cards, form surfaces |
| Hanji | `#F1E7D8` | soft fields, light panels |
| Wheat | `#D8C5AA` | borders, dividers |
| Porcelain | `#E9F0EC` | subtle cool background |
| Deep | `#211817` | primary text, dark buttons |
| Brown | `#604537` | secondary text, warm labels |
| Cinnabar | `#87352D` | brand accent, section eyebrow |
| Gold | `#C19A5B` | premium accent, focus border |
| Jade | `#2F6F5E` | cool accent |
| Plum | `#6A3A4A` | seasonal accent |
| Muted | `#6D6258` | body copy |
| Shadow | `rgba(33, 24, 23, 0.2)` | card shadow base |

## Typography

- Body font: `Noto Sans KR`
- Display font: `Noto Serif KR`
- Fallback serif: `AppleMyungjo`, `serif`

| Style | Font | Size | Weight | Line Height | Color |
| --- | --- | ---: | ---: | ---: | --- |
| Brand Logo Text | Noto Serif KR | 20 | 800 | 1.2 | Deep |
| Nav Item | Noto Sans KR | 16 | 800 | 1.2 | Deep |
| Section Eyebrow | Noto Sans KR | 11 | 600 | 1.2 | Cinnabar/Gold |
| Section Title | Noto Serif KR | 40 | 700 | 1.22 | Deep/Paper |
| Section Title Mobile | Noto Serif KR | 27 | 700 | 1.22 | Deep/Paper |
| Section Description | Noto Sans KR | 16 | 300 | 1.82 | Muted/Hanji |
| Card Title | Noto Serif KR | 24-32 | 800 | 1.15 | Deep |
| Body | Noto Sans KR | 14-16 | 300-600 | 1.45-1.65 | Muted/Deep |
| Tag | Noto Sans KR | 11-12 | 600-800 | 1.2 | Brown/Cinnabar |

## Components

### Header

- Height desktop: `72`
- Height compact: `104`
- Background: `Paper` at 95%
- Bottom border: `Wheat`
- Logo mark: circle `42 x 42`, Gold 12% fill, Gold 46% stroke
- Nav items: horizontal padding `15`, vertical padding `10`

### Section Shell

- Max width: `1180`
- Horizontal padding: `24`
- Mobile padding: `18`
- Center aligned

### Section Heading

- Max width: `760`
- Eyebrow letter spacing: desktop `4`, mobile `2.6`
- Eyebrow to title spacing: `14`
- Title to description spacing: `16`

### Soft Card

- Fill: `Paper`
- Radius: `8`
- Border: `Wheat` 58%
- Padding default: `26`
- Shadow: `0 14 22 -10 rgba(33,24,23,0.1)`

### Primary Button

- Fill: `Deep`
- Text: `Paper`
- Radius: `8`
- Padding: `24 x 16`
- Font: `14 / 700`

### Outlined Button

- Stroke: `Deep` 45%
- Text: `Deep`
- Radius: `8`
- Padding: `24 x 16`
- Font: `14 / 700`

### Form Field

- Fill: `Hanji` 50%
- Stroke: `Wheat`
- Focus stroke: `Gold`, `1.5`
- Radius: `8`
- Padding: `14 x 14`

### Tag Pill

- Fill: `Gold` 10%
- Stroke: `Gold` 30%
- Radius: `999`
- Padding: `10 x 5`
- Text: `11 / 600 / Brown`

## Page Sections

Figma에서는 아래 순서로 프레임을 나눠두면 수정하기 쉽습니다.

1. Header
2. Hero
3. 소개
4. 메뉴
5. 체험
6. 케이터링
7. AI 다과 추천
8. Footer
9. Floating Chatbot

## Figma Import 팁

- 빠르게 제출용 이미지만 필요하면 full-page screenshot만 가져가도 됩니다.
- 편집 가능한 시안을 만들려면 screenshot을 잠근 뒤, 위 토큰으로 컴포넌트를 다시 그리는 방식이 가장 깔끔합니다.
- `html.to.design` 플러그인은 Flutter Web 구조상 완전한 editable 변환이 어려울 수 있습니다.
- 현재 프로젝트는 Flutter Web이라 HTML 요소가 일반 웹처럼 세분화되어 있지 않아, Figma 자동 변환보다는 캡처 기반 재구성이 안정적입니다.
