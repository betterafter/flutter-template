# flutter_clean_arch_scaffold

Flutter Clean Architecture 구조를 **기존 Flutter 프로젝트에 복제**하는 CLI입니다.

`flutter_clean_arch init` 한 번으로:

- `packages/domain`, `data`, `presentation`, `design`과 `melos.yaml` 생성
- **`payment` 예시 feature** 자동 생성 (entity · dto · mapper · datasource · usecase · provider · page)
- `android/`, `ios/` 설정은 건드리지 않음

새 feature는 `payment` 폴더 구조를 보고 `add feature`로 추가합니다.

---

## 사용 방법

아래를 **위에서부터 순서대로** 실행하세요.

```bash
# 1. CLI 설치 (PC당 최초 1회)
dart pub global activate flutter_clean_arch_scaffold

# 2. 새 Flutter 프로젝트
flutter create my_app
cd my_app

# 3. 구조 생성 + payment 예시 + melos.yaml + bootstrap + 코드 생성
flutter_clean_arch init

# lib/main.dart 수정 — init이 기존 main.dart를 유지한 경우 필수
# import 'di.dart'; 추가 후 main() 맨 앞에 configureDependencies(); 호출

# 4. 새 feature 추가 (payment 예시를 참고)
flutter_clean_arch add feature order --with-ui

# 5. 앱 실행
flutter run
```

> `init` / `add feature`는 기본적으로 `melos bootstrap`과 `build_runner`까지 자동 실행합니다.  
> `--skip-build`를 썼을 때만 아래를 직접 실행하세요.
>
> ```bash
> melos bootstrap
> melos run build:all
> ```

### `lib/main.dart` 수정 (중요)

`flutter create` 직후 `init`을 실행하면 **기존 `lib/main.dart`는 유지**됩니다.  
DI가 동작하려면 아래를 직접 추가해야 합니다.

```dart
import 'di.dart';

void main() {
  configureDependencies(); // ← runApp()보다 먼저 호출
  runApp(const MainApp());
}
```

`init --force`를 쓰면 `main.dart`가 템플릿으로 교체되어 위 코드와 `PaymentPage` 홈 화면이 포함됩니다.

`init`은 **payment 예시 feature**도 함께 생성합니다 (`domain` / `data` / `presentation` 전 레이어).

---

## 생성되는 구조

```
my_app/
├── android/                  # flutter create 결과 (그대로)
├── ios/
├── lib/
│   ├── main.dart
│   └── di.dart               # init이 생성
├── packages/
│   ├── domain/               # entity, repository, usecase
│   ├── data/                 # datasource, dto, mapper, repository impl
│   ├── presentation/         # provider, page
│   └── design/               # 디자인 시스템, assets
└── melos.yaml
```

### 레이어 의존

```
presentation → domain
data         → domain
design       → (독립)
```

### feature 폴더 예시 (`add feature payment --with-ui`)

```
packages/domain/lib/domain/payment/
  entity/  repository/  usecase/

packages/data/lib/data/payment/
  api/  datasource/  dto/  mapper/  repository/

packages/presentation/lib/payment/
  provider/  page/
```

### data 레이어 흐름

```
Retrofit API → RemoteDatasource → dto → mapper → entity
                                              ↓
                                    Repository (remote() → DataState)
                                              ↓
                                         Usecase → UI
```

### 0.1.x → 0.2.x 마이그레이션

```bash
flutter_clean_arch migrate
melos bootstrap   # 또는 packages/data에서 flutter pub get
melos run build:data
```

`migrate`는 `DataState`, 네트워크 코어, `data` pubspec 의존성, Retrofit `build.yaml` 설정을
없는 항목만 추가합니다. 기존 feature의 Repository / API 파일은 수동으로 맞춰야 합니다.

---

## 명령어

| 명령 | 설명 |
|------|------|
| `flutter_clean_arch init` | Clean Architecture 구조 복제 |
| `flutter_clean_arch migrate` | 0.1.x → 원격 데이터 레이어 마이그레이션 |
| `flutter_clean_arch migrate --skip-build` | 파일/의존성만 추가 |
| `flutter_clean_arch add feature <name> --force` | feature + 코어 파일 덮어쓰기 |
| `flutter_clean_arch migrate --force` | 코어 파일 강제 덮어쓰기 |
| `flutter_clean_arch add feature <name>` | feature 스캐폴딩 |
| `flutter_clean_arch add feature <name> --with-ui` | presentation 포함 |
| `flutter_clean_arch add feature <name> --with-local` | local datasource 포함 |
| `flutter_clean_arch add feature <name> --methods a,b` | 메서드 stub 지정 |
| `flutter_clean_arch init --force` | 기존 파일 덮어쓰기 |
| `flutter_clean_arch init --skip-build` | build_runner 생략 |

`add feature` 실행 시 `DataState`, 네트워크 코어 파일, `packages/data/pubspec.yaml` 필수
의존성이 없으면 자동으로 추가합니다 (기존 파일은 덮어쓰지 않음).

feature 이름: **snake_case** (예: `payment`, `user_profile`)

---

## 문제 해결

### `command not found: flutter_clean_arch` / `melos`

`dart pub global activate`는 했는데 단축 명령이 안 되면 PATH 문제입니다.  
그때만 아래 형식으로 실행하세요.

```bash
dart pub global run flutter_clean_arch_scaffold:flutter_clean_arch init
dart pub global run melos:melos run build:all
```

### templates 오류 / 이상한 동작 / 옛 버전이 실행됨

CLI 캐시를 지우고 재설치하세요.

```bash
dart pub global deactivate flutter_clean_arch_scaffold
dart pub global activate flutter_clean_arch_scaffold
```

---

## pub.dev 문서 안내

| 위치 | 파일 | 내용 |
|------|------|------|
| 패키지 카드 짧은 설명 | `pubspec.yaml` → `description` | 검색 결과에 보이는 한 줄 요약 |
| 패키지 상세 페이지 | `tools/cli/README.md` (이 파일) | 설치법, 구조, 명령어 전체 |

README를 수정한 뒤 pub.dev에 반영하려면 버전을 올리고 재배포합니다.

```bash
cd tools/cli
# pubspec.yaml version bump + CHANGELOG
dart pub publish
```

---

## 링크

- [GitHub 저장소](https://github.com/betterafter/flutter-template)
- [pub.dev](https://pub.dev/packages/flutter_clean_arch_scaffold)
- [배포 가이드](doc/PUBLISHING.md)
