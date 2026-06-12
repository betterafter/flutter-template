# Flutter Clean Architecture Template

Flutter Clean Architecture를 **CLI로 프로젝트에 복제**하는 템플릿입니다.  
[pub.dev 패키지](https://pub.dev/packages/flutter_clean_arch_scaffold)로 설치해 사용하고, 이 저장소는 CLI 소스 + **payment 예시** 기준 구현입니다.

---

## 무엇을 쓰면 되나

| 상황 | 명령 |
|------|------|
| **처음 설치** (PC당 1회) | `dart pub global activate flutter_clean_arch_scaffold` |
| **새 프로젝트 시작** | `dart pub global run flutter_clean_arch_scaffold:fca init` |
| **구버전 / 누락 파일 보완** | `dart pub global run ... fca migrate` (tool/fca 없을 때) |
| **feature 추가** | `tool/fca add feature order --with-ui` |
| **파일 수정 후 코드 재생성** | `tool/fca build` (전체) / `tool/fca build --scope data` (레이어별) |
| **앱 실행** | `flutter run` |

> Windows: `tool/fca` → `tool\fca` (또는 `tool\fca.bat`)

---

## 1. 신규 프로젝트

```bash
dart pub global activate flutter_clean_arch_scaffold

flutter create my_shop
cd my_shop

dart pub global run flutter_clean_arch_scaffold:fca init
```

**init 직후**

`flutter create` 직후 init이면 `lib/main.dart`는 유지됩니다. DI 연결을 직접 추가하세요.

```dart
import 'di.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}
```

또는 `init --force`로 main까지 교체 (PaymentPage 홈 포함).

**이후 개발 루프**

```bash
tool/fca add feature order --with-ui
# entity · dto · API · page 구현 (payment 예시 참고)
tool/fca build
flutter run
```

---

## 2. 기존 프로젝트 (migrate)

> **`tool/fca`가 없으면 `tool/fca migrate`는 안 됩니다.** 첫 migrate는 긴 명령으로 실행하세요.

```bash
cd my_shop

# tool/fca 없을 때 (기존 프로젝트 최초 1회)
dart pub global run flutter_clean_arch_scaffold:fca migrate

dart pub global run flutter_clean_arch_scaffold:fca migrate --force        # 덮어쓰기
dart pub global run flutter_clean_arch_scaffold:fca migrate --skip-build   # 파일만
```

migrate 후 `tool/fca build`, `tool/fca migrate` 등 짧은 명령 사용 가능.

---

## payment 예시 (참고용)

```
packages/domain/lib/domain/payment/
packages/data/lib/data/payment/
packages/presentation/lib/payment/
```

---

## 프로젝트 구조

```
project/
├── lib/              앱 셸 (main, DI)
├── tool/             fca — 짧은 CLI 래퍼
├── packages/
│   ├── domain/       entity, repository, usecase
│   ├── data/         api, datasource, dto, mapper
│   ├── presentation/ provider, page
│   └── design/
└── melos.yaml
```

| 레이어 | 역할 |
|--------|------|
| `domain` | 비즈니스 규칙 |
| `data` | API · datasource · dto · mapper |
| `presentation` | usecase → UI |
| `design` | 디자인 토큰, assets |

---

## 문제 해결

| 증상 | 해결 |
|------|------|
| init 전 명령 안 됨 | `dart pub global run flutter_clean_arch_scaffold:fca init` |
| init 후 명령 안 됨 | `tool\fca.bat` (Windows) / 프로젝트 루트에서 실행 |
| CLI 이상 | `dart pub global deactivate flutter_clean_arch_scaffold` 후 재설치 |

---

## 기여 / pub.dev 배포

- CLI 개발: `cd tools/cli && dart pub global activate --source path .`
- pub.dev README: `tools/cli/README.md`
- 배포: [`tools/cli/doc/PUBLISHING.md`](tools/cli/doc/PUBLISHING.md)

---

## 라이선스

Apache License 2.0 — [LICENSE](LICENSE)
