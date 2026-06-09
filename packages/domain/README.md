# domain

Clean Architecture의 **도메인 레이어** 패키지입니다.

## 역할

- `entity` — 비즈니스 모델
- `repository` — 데이터 접근 인터페이스 (abstract)
- `usecase` — 비즈니스 로직 진입점

## 예시: payment

```
lib/domain/payment/
├── entity/payment.entity.dart
├── repository/payment.repository.dart
└── usecase/payment.usecase.dart
```

## 규칙

- UI, API, DB 등 구현 세부사항에 의존하지 않습니다.
- `data`, `presentation` 레이어가 이 패키지를 참조합니다.
