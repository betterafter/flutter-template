# Flutter Clean Architecture Template

Flutter 앱을 Clean Architecture 구조로 빠르게 시작할 수 있는 템플릿 프로젝트입니다.

- **Clean Architecture** 기반 멀티 패키지 구조 (`domain`, `data`, `presentation`, `design`)
- **melos** 기반 모노레포 빌드 자동화
- **Injectable + GetIt** 의존성 주입
- **Riverpod** 상태 관리 (presentation)
- **CLI**로 프로젝트 초기화 및 feature 스캐폴딩

---

## 프로젝트 구조

```
project/
├── lib/                    # 앱 셸 (main, DI 조합)
├── packages/
│   ├── domain/             # entity, repository, usecase
│   ├── data/               # datasource, dto, mapper, repository impl
│   ├── presentation/       # provider, page
│   └── design/             # 디자인 시스템, assets
├── melos.yaml
└── tools/cli/              # flutter_clean_arch CLI
```

`domain`을 중심으로 `data`와 `presentation`이 의존하며, 루트 `lib/di.dart`에서 레이어별 DI를 조합합니다.

---

## payment 예시 (레이어별 구조)

이 저장소에는 `payment` feature가 **각 레이어의 구조 예시**로 포함되어 있습니다.

```
packages/domain/lib/domain/payment/
├── entity/payment.entity.dart
├── repository/payment.repository.dart
└── usecase/payment.usecase.dart

packages/data/lib/data/payment/
├── datasource/payment.remote.datasource.dart
├── dto/payment.dto.dart
├── dto/payment.dto.parser.dart
├── mapper/payment.mapper.dart
└── repository/payment.repository.dart       # PaymentRepositoryImpl

packages/presentation/lib/payment/
├── provider/payment.provider.dart
└── page/payment.page.dart
```

새 feature를 추가할 때도 동일한 폴더 규칙을 따릅니다.

---

## CLI 사용법

CLI 소스는 `tools/cli/`에 있습니다.  
**별도 설치 없이** 이 저장소를 클론한 뒤 아래 명령을 그대로 실행하면 됩니다.

### 이 저장소에서 실행 (가장 흔한 경우)

프로젝트 **루트**에서:

```bash
# feature 추가
dart run tools/cli/bin/flutter_clean_arch.dart add feature user_profile --with-ui

# 도움말
dart run tools/cli/bin/flutter_clean_arch.dart --help
```

> `<cli-path>` 같은 경로 placeholder는 없습니다.  
> 위처럼 `tools/cli/bin/flutter_clean_arch.dart`를 **프로젝트 루트 기준**으로 실행하면 됩니다.

### 다른 Flutter 프로젝트에 구조 주입할 때

```bash
# 1. 새 앱 생성
flutter create my_app
cd my_app

# 2. 이 저장소의 CLI를 복사하거나 클론한 경로를 지정해서 init
dart run /path/to/flutter-template/tools/cli/bin/flutter_clean_arch.dart init
```

`/path/to/flutter-template`은 이 템플릿 저장소가 클론된 실제 경로로 바꿔주세요.

### 전역 설치 (선택)

매번 경로를 치기 싫다면:

```bash
cd tools/cli
dart pub get
dart pub global activate --source path .

# 이후 어디서든
flutter_clean_arch add feature login --with-ui
```

`dart pub global activate` 후에는 `flutter_clean_arch` 명령만으로 사용할 수 있습니다.

---

## CLI 명령어

### `init` — 프로젝트 구조 생성

기존 Flutter 프로젝트에 Clean Architecture 구조를 추가합니다.  
`android/`, `ios/` 등 플랫폼 설정은 건드리지 않습니다.

```bash
# 다른 프로젝트 디렉터리에서 실행
dart run /path/to/flutter-template/tools/cli/bin/flutter_clean_arch.dart init
```

#### 생성되는 항목

| 경로 | 설명 |
|------|------|
| `packages/domain/` | 도메인 레이어 패키지 |
| `packages/data/` | 데이터 레이어 패키지 |
| `packages/presentation/` | 프레젠테이션 레이어 패키지 |
| `packages/design/` | 디자인 시스템 패키지 |
| `melos.yaml` | melos 모노레포 설정 |
| `lib/di.dart` | 레이어 DI 조합 파일 |
| `pubspec.yaml` | path 의존성 및 필수 패키지 추가 |

#### 옵션

| 옵션 | 설명 |
|------|------|
| `-f`, `--force` | 이미 존재하는 파일을 덮어씁니다 |
| `--skip-build` | init 후 `build_runner`를 실행하지 않습니다 |

#### init 이후

`lib/main.dart`가 이미 있으면 CLI는 해당 파일을 유지합니다.  
아래처럼 `configureDependencies()` 호출을 직접 추가해주세요.

```dart
import 'di.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}
```

---

### `add feature` — feature 스캐폴딩

feature 이름 하나로 domain / data / presentation 레이어 파일을 역할별 폴더로 생성합니다.

```bash
dart run tools/cli/bin/flutter_clean_arch.dart add feature <feature_name>
```

#### feature 이름 규칙

- **snake_case** 영문만 사용
- 예: `payment`, `payment_history`, `user_profile`

#### 기본 생성 구조

`add feature payment` 실행 시 (`payment` 예시와 동일):

```
packages/domain/lib/domain/payment/
├── entity/payment.entity.dart
├── repository/payment.repository.dart
└── usecase/payment.usecase.dart

packages/data/lib/data/payment/
├── datasource/payment.remote.datasource.dart
├── dto/payment.dto.dart
├── dto/payment.dto.parser.dart
├── mapper/payment.mapper.dart
└── repository/payment.repository.dart

packages/presentation/lib/payment/    # --with-ui 옵션 시
├── provider/payment.provider.dart
└── page/payment.page.dart
```

#### 옵션

| 옵션 | 설명 |
|------|------|
| `--with-local` | `datasource/payment.local.datasource.dart` 추가 생성 |
| `--with-ui` | presentation 레이어 `provider/`, `page/` 추가 생성 |
| `--methods` | 생성할 메서드 목록 (쉼표 구분) |
| `--skip-build` | 생성 후 `build_runner` 실행 생략 |
| `-f`, `--force` | 이미 존재하는 파일 덮어쓰기 |

#### 예시

```bash
# 기본 (domain + data)
dart run tools/cli/bin/flutter_clean_arch.dart add feature order

# UI까지 포함
dart run tools/cli/bin/flutter_clean_arch.dart add feature order --with-ui

# local datasource + UI
dart run tools/cli/bin/flutter_clean_arch.dart add feature order --with-local --with-ui

# 메서드 지정
dart run tools/cli/bin/flutter_clean_arch.dart add feature order \
  --methods getOrders,createOrder
```

#### 생성 후 할 일

1. `entity`, `dto` 필드 정의
2. `datasource`에 API 호출 구현 (`compute`로 JSON 파싱)
3. `mapper`에 dto → entity 변환 로직 구현
4. `repository impl`에서 datasource + mapper 조합
4. (UI 생성 시) `page` 위젯 구현

`build_runner`가 자동 실행되면 barrel export(`*.generated.dart`)와 Injectable DI 등록이 갱신됩니다.

---

## melos 빌드 명령어

```bash
melos bootstrap          # 전체 패키지 pub get
melos run build:all      # 전체 build_runner 실행
melos run build:domain   # domain만
melos run build:data     # data만
melos run build:presentation
melos run build:design
melos run analyze        # 전체 정적 분석
melos run clean          # 전체 flutter clean
```

---

## Design 패키지

`packages/design/assets/`에 이미지·아이콘을 추가한 뒤:

```bash
melos run build:design
```

`image.generated.dart`에 assets 기반 위젯 팩토리가 자동 생성됩니다.

---

## 레이어별 의존 규칙

```
presentation → domain
data         → domain
design       → (독립)
```

- `domain`: Flutter/UI에 의존하지 않는 순수 비즈니스 규칙
- `data`: `datasource` → `dto` → `mapper` → `repository impl`
- `presentation`: `usecase`만 직접 사용 (repository 직접 참조 X)

---

## 전체 워크플로 요약

```bash
# [이 저장소] feature 추가
dart run tools/cli/bin/flutter_clean_arch.dart add feature login --with-ui

# [새 프로젝트] 구조 주입
flutter create my_app && cd my_app
dart run ../flutter-template/tools/cli/bin/flutter_clean_arch.dart init
dart run ../flutter-template/tools/cli/bin/flutter_clean_arch.dart add feature login --with-ui
```

---

## 라이선스

LICENSE 파일을 참고해주세요.
