# Flutter Clean Architecture Template

Flutter 앱을 Clean Architecture 구조로 빠르게 시작할 수 있는 템플릿 프로젝트입니다.

- **Clean Architecture** 멀티 패키지 (`domain`, `data`, `presentation`, `design`)
- **melos** 모노레포 빌드 자동화
- **Injectable + GetIt** 의존성 주입
- **Riverpod** 상태 관리 (presentation)
- **CLI** 프로젝트 초기화 및 feature 스캐폴딩

---

## 사용 방법

### 빠른 시작

#### 이 저장소를 템플릿으로 쓸 때

```bash
git clone <this-repo>
cd flutter-template

melos bootstrap
melos run build:all
```

feature를 추가할 때:

```bash
dart run tools/cli/bin/flutter_clean_arch.dart add feature login --with-ui
```

#### 새 Flutter 프로젝트에 구조를 주입할 때

```bash
flutter create my_app
cd my_app

dart run /path/to/flutter-template/tools/cli/bin/flutter_clean_arch.dart init
dart run /path/to/flutter-template/tools/cli/bin/flutter_clean_arch.dart add feature login --with-ui
```

`/path/to/flutter-template`은 이 저장소가 클론된 실제 경로로 바꿔주세요.

---

### CLI 실행

CLI 소스는 `tools/cli/`에 있습니다. 프로젝트 **루트**에서 아래처럼 실행합니다.

```bash
dart run tools/cli/bin/flutter_clean_arch.dart <command>
```

#### 전역 설치 (선택)

```bash
cd tools/cli
dart pub get
dart pub global activate --source path .

# 이후 어디서든
flutter_clean_arch add feature login --with-ui
```

---

### `init` — 프로젝트 구조 생성

기존 Flutter 프로젝트에 Clean Architecture 구조를 추가합니다.  
`android/`, `ios/` 등 플랫폼 설정은 건드리지 않습니다.

```bash
dart run tools/cli/bin/flutter_clean_arch.dart init
```

| 옵션 | 설명 |
|------|------|
| `-f`, `--force` | 이미 존재하는 파일을 덮어씁니다 |
| `--skip-build` | init 후 `build_runner`를 실행하지 않습니다 |

`lib/main.dart`가 이미 있으면 CLI는 해당 파일을 유지합니다. `configureDependencies()` 호출을 직접 추가해주세요.

```dart
import 'di.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}
```

---

### `add feature` — feature 스캐폴딩

```bash
dart run tools/cli/bin/flutter_clean_arch.dart add feature <feature_name>
```

- feature 이름: **snake_case** 영문 (예: `payment`, `user_profile`)

| 옵션 | 설명 |
|------|------|
| `--with-local` | local datasource 추가 생성 |
| `--with-ui` | presentation `provider/`, `page/` 추가 생성 |
| `--methods` | 메서드 목록 지정 (쉼표 구분) |
| `--skip-build` | 생성 후 `build_runner` 실행 생략 |
| `-f`, `--force` | 기존 파일 덮어쓰기 |

```bash
# 기본 (domain + data)
dart run tools/cli/bin/flutter_clean_arch.dart add feature order

# UI + local datasource
dart run tools/cli/bin/flutter_clean_arch.dart add feature order --with-local --with-ui

# 메서드 지정
dart run tools/cli/bin/flutter_clean_arch.dart add feature order \
  --methods getOrders,createOrder
```

#### 생성 후 할 일

1. `entity`, `dto` 필드 정의
2. `datasource`에 API 호출 구현 (`compute`로 JSON 파싱)
3. `mapper`에 dto → entity 변환 구현
4. `repository impl`에서 datasource + mapper 조합
5. (UI 생성 시) `page` 위젯 구현

> melos는 `pubspec.yaml`에 의존성을 **추가하지 않습니다.**  
> `melos bootstrap`으로 설치, `melos run build:*`로 코드 생성만 수행합니다.  
> 새 외부 패키지(예: `dio`)가 필요하면 해당 패키지 `pubspec.yaml`에 직접 추가하세요.

---

### melos 명령어

```bash
melos bootstrap          # 전체 패키지 pub get
melos run build:all      # 전체 build_runner 실행
melos run build:domain   # domain만
melos run build:data     # data만
melos run build:presentation
melos run build:design   # assets → image 위젯 생성
melos run analyze        # 전체 정적 분석
melos run clean          # 전체 flutter clean
```

`packages/design/assets/`에 이미지·아이콘을 추가한 뒤 `melos run build:design`을 실행하면 `image.generated.dart`가 생성됩니다.

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
├── melos.yaml
└── tools/cli/              # flutter_clean_arch CLI
```

`domain`을 중심으로 `data`와 `presentation`이 의존하며, 루트 `lib/di.dart`에서 레이어별 DI를 조합합니다.

### 레이어별 의존 규칙

```
presentation → domain
data         → domain
design       → (독립)
```

| 레이어 | 역할 |
|--------|------|
| `domain` | 순수 비즈니스 규칙. UI/API 구현에 의존하지 않음 |
| `data` | `datasource` → `dto` → `mapper` → `repository impl` |
| `presentation` | `usecase`만 직접 사용 (repository 직접 참조 X) |
| `design` | 공통 디자인 토큰, assets, 이미지 위젯 |

### payment 예시

이 저장소에는 `payment` feature가 **각 레이어의 구조 예시**로 포함되어 있습니다.  
`add feature`로 새 feature를 추가할 때도 동일한 폴더 규칙을 따릅니다.

```
packages/domain/lib/domain/payment/
├── entity/payment.entity.dart
├── repository/payment.repository.dart
└── usecase/payment.usecase.dart

packages/data/lib/data/payment/
├── datasource/payment.remote.datasource.dart
├── dto/payment.dto.dart
├── dto/payment.dto.parser.dart      # compute용 JSON 파서
├── mapper/payment.mapper.dart       # dto → entity
└── repository/payment.repository.dart

packages/presentation/lib/payment/
├── provider/payment.provider.dart
└── page/payment.page.dart
```

### data 레이어 흐름

```
API 응답 (JSON)
  → datasource (compute로 dto 파싱)
  → mapper (dto → entity)
  → repository impl
  → usecase (domain)
  → presentation
```

---

## 라이선스

LICENSE 파일을 참고해주세요.
