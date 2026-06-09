# design

앱 전역 **디자인 시스템** 패키지입니다.

## 역할

- `assets/` — 이미지, 아이콘 리소스
- `images/` — asset 기반 이미지 위젯 자동 생성
- `types/` — 색상, 텍스트 스타일 등 공통 디자인 토큰

## 이미지 자동 생성

`assets/`에 리소스를 추가한 뒤:

```bash
melos run build:design
```

`image.generated.dart`에 위젯 팩토리가 생성됩니다.
