# data

Clean Architecture의 **데이터 레이어** 패키지입니다.

## 역할

- `datasource` — API, 로컬 DB 등 외부 데이터 소스 (`compute`로 JSON 파싱)
- `dto` — API 응답 데이터 구조
- `mapper` — dto → entity 변환
- `repository` — domain의 repository 인터페이스 구현

## 예시: payment

```
lib/data/payment/
├── datasource/payment.remote.datasource.dart
├── dto/payment.dto.dart
├── dto/payment.dto.parser.dart
├── mapper/payment.mapper.dart
└── repository/payment.repository.dart   # PaymentRepositoryImpl
```

## 규칙

- `domain` 패키지만 의존합니다.
- JSON 파싱은 `compute`로 isolate에서 처리합니다.
- entity 변환은 `mapper`에서만 수행합니다.
