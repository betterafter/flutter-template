# presentation

Clean Architecture의 **프레젠테이션 레이어** 패키지입니다.

## 역할

- `provider` — Riverpod 상태/의존성 연결
- `page` — 화면 UI

## 예시: payment

```
lib/payment/
├── provider/payment.provider.dart
└── page/payment.page.dart
```

## 규칙

- `usecase`를 통해 비즈니스 로직에 접근합니다.
- `repository`를 직접 참조하지 않습니다.
