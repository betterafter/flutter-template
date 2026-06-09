# Flutter Clean Architecture Template

Flutter Clean Architecture 구조를 **CLI 한 줄로 프로젝트에 복제**할 수 있는 템플릿입니다.

| 구분 | 설명 |
|------|------|
| **사용자** | pub.dev에서 `flutter_clean_arch_scaffold` 설치 → `flutter_clean_arch init` |
| **이 저장소** | CLI 소스 + 구조 참고 구현 (`payment` 예시) |

---

## 사용 방법

### 1. CLI 설치 (최초 1회)

```bash
dart pub global activate flutter_clean_arch_scaffold
```

PATH 설정 (`~/.pub-cache/bin`):

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

> pub.dev 배포 전 로컬 테스트:
> ```bash
> cd tools/cli && dart pub global activate --source path .
> ```

### 2. Flutter 프로젝트 생성

```bash
flutter create my_shop
cd my_shop
```

### 3. Clean Architecture 구조 복제

```bash
flutter_clean_arch init
```

사용자 프로젝트에 아래가 **복제**됩니다. `android/`, `ios/`는 그대로입니다.

```
my_shop/
├── packages/
│   ├── domain/
│   ├── data/
│   ├── presentation/
│   └── design/
├── melos.yaml
└── lib/di.dart
```

### 4. feature 추가

```bash
flutter_clean_arch add feature payment --with-ui
```

### 5. 빌드

```bash
melos bootstrap
melos run build:all
```

### 전체 흐름

```bash
dart pub global activate flutter_clean_arch_scaffold

flutter create my_shop
cd my_shop

flutter_clean_arch init
flutter_clean_arch add feature payment --with-ui

melos bootstrap
melos run build:all
```

---

## CLI 명령어

### `flutter_clean_arch init`

기존 Flutter 프로젝트에 Clean Architecture 구조를 복제합니다.

| 옵션 | 설명 |
|------|------|
| `-f`, `--force` | 기존 파일 덮어쓰기 |
| `--skip-build` | `build_runner` 생략 |

`lib/main.dart`가 이미 있으면 유지됩니다. 아래를 직접 추가하세요.

```dart
import 'di.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}
```

### `flutter_clean_arch add feature <name>`

feature 이름(**snake_case**)으로 레이어별 파일을 생성합니다.

| 옵션 | 설명 |
|------|------|
| `--with-ui` | presentation `provider/`, `page/` 생성 |
| `--with-local` | local datasource 생성 |
| `--methods` | 메서드 목록 (쉼표 구분) |
| `--skip-build` | `build_runner` 생략 |
| `-f`, `--force` | 기존 파일 덮어쓰기 |

```bash
flutter_clean_arch add feature order --with-ui
flutter_clean_arch add feature order --methods getOrders,createOrder
```

#### 생성 후 할 일

1. `entity`, `dto` 필드 정의
2. `datasource` API 구현 (`compute`로 JSON 파싱)
3. `mapper` dto → entity 변환
4. `repository impl` 조합
5. (UI 생성 시) `page` 구현

> melos는 의존성을 **추가하지 않습니다.** `pub get`과 코드 생성만 수행합니다.

### melos

```bash
melos bootstrap
melos run build:all
melos run build:domain
melos run build:data
melos run build:presentation
melos run build:design
melos run analyze
```

---

## 설계 및 구조

### 프로젝트 구조

```
project/
├── lib/                    # 앱 셸 (main, DI 조합)
├── packages/
│   ├── domain/             # entity, repository, usecase
│   ├── data/               # datasource, dto, mapper, repository impl
│   ├── presentation/       # provider, page
│   └── design/             # 디자인 시스템, assets
└── melos.yaml
```

### 레이어 의존

```
presentation → domain
data         → domain
design       → (독립)
```

| 레이어 | 역할 |
|--------|------|
| `domain` | 순수 비즈니스 규칙 |
| `data` | `datasource` → `dto` → `mapper` → `repository impl` |
| `presentation` | `usecase`만 사용 |
| `design` | 공통 디자인 토큰, assets |

### payment 예시 (이 저장소)

```
packages/domain/lib/domain/payment/
├── entity/
├── repository/
└── usecase/

packages/data/lib/data/payment/
├── datasource/
├── dto/
├── mapper/
└── repository/

packages/presentation/lib/payment/
├── provider/
└── page/
```

### data 레이어 흐름

```
API (JSON) → datasource (compute) → dto → mapper → entity → usecase → UI
```

---

## 기여 / 개발

CLI 소스: [`tools/cli/`](tools/cli/)

```bash
cd tools/cli
dart pub get
dart pub global activate --source path .

# 이 저장소 루트에서 feature 추가 테스트
flutter_clean_arch add feature login --with-ui
```

---

## pub.dev 배포

CLI 패키지 배포 가이드: [`tools/cli/doc/PUBLISHING.md`](tools/cli/doc/PUBLISHING.md)

요약:

```bash
cd tools/cli
dart pub publish --dry-run   # 검증
dart pub publish             # 배포
```

---

## 라이선스

Apache License 2.0 — [LICENSE](LICENSE)
