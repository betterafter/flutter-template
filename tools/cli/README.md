# flutter_clean_arch_scaffold

Flutter Clean Architecture 멀티 패키지 구조를 기존 프로젝트에 복제하는 CLI입니다.

`init` 한 번으로 `domain` / `data` / `presentation` / `design` + **payment 예시 feature** + `tool/fca` 래퍼가 생성됩니다.

---

## 무엇을 쓰면 되나

| 상황 | 명령 |
|------|------|
| **처음 설치** (PC당 1회) | `dart pub global activate flutter_clean_arch_scaffold` |
| **새 프로젝트 시작** (`tool/fca` 없을 때) | `dart pub global run flutter_clean_arch_scaffold:fca init` |
| **구버전 / 누락 파일 보완** | `dart pub global run ... fca migrate` (tool/fca 없을 때) |
| **feature 추가** | `tool/fca add feature order --with-ui` |
| **파일 수정 후 코드 재생성** | `tool/fca build` |
| **앱 실행** | `flutter run` |

> Windows는 `tool/fca` 대신 `tool\fca` (또는 `tool\fca.bat`)를 사용하세요.

---

## 1. 신규 프로젝트

```bash
# PC당 1회
dart pub global activate flutter_clean_arch_scaffold

flutter create my_app
cd my_app

# init 전에만 긴 명령 (이후 tool/fca 생성됨)
dart pub global run flutter_clean_arch_scaffold:fca init
```

**init 직후 확인**

- `lib/main.dart`에 `import 'di.dart';` + `configureDependencies();` 추가 (기존 main 유지 시)
- 또는 `dart pub global run flutter_clean_arch_scaffold:fca init --force` 로 main까지 교체

**이후 개발 루프**

```bash
tool/fca add feature order --with-ui   # 1. feature 추가
# 2. entity · dto · API · page 등 직접 구현 (payment 예시 참고)
tool/fca build                         # 3. .g.dart / DI 재생성
flutter run                            # 4. 실행
```

---

## 2. 기존 프로젝트 (migrate)

옛 버전이거나 `tool/fca`, `melos.yaml`, `DataState` 등이 없을 때:

> **`tool/fca`가 없으면 `tool/fca migrate`는 실행할 수 없습니다.**  
> `migrate`가 `tool/fca`를 만들어 주므로, **첫 migrate는 아래 긴 명령**을 쓰세요.

```bash
cd my_app

# tool/fca 없을 때 (기존 프로젝트 최초 1회)
dart pub global run flutter_clean_arch_scaffold:fca migrate

# 덮어쓰기 필요 시
dart pub global run flutter_clean_arch_scaffold:fca migrate --force

# migrate 완료 후에는 프로젝트 루트에서:
tool/fca build

# 이후부터는 짧은 명령 가능
tool/fca migrate   

```

파일만 보완하고 빌드는 직접 할 때:

```bash
dart pub global run flutter_clean_arch_scaffold:fca migrate --skip-build
tool/fca build
```

---

## 명령어 요약

init 이후 프로젝트 루트에서 `tool/fca` 사용 (Windows: `tool\fca`).

| 명령 | 설명 |
|------|------|
| `tool/fca init` | 구조 + payment 예시 생성 |
| `tool/fca migrate` | 누락된 필수 파일·설정 보완 |
| `tool/fca migrate --force` | 코어 파일·melos·di·tool/fca 덮어쓰기 |
| `tool/fca add feature <name> --with-ui` | feature 스캐폴딩 |
| `tool/fca build` | 전체 코드 생성 (기본값) |
| `tool/fca build --scope <레이어>` | 레이어별 코드 생성 |
| `tool/fca bootstrap` | 멀티 패키지 `pub get` |

**`build --scope` 값** (`-s` 축약 가능)

| scope | 대상 |
|-------|------|
| `all` | design + domain + data + presentation + root DI (기본값) |
| `domain` | `packages/domain` |
| `data` | `packages/data` |
| `presentation` | `packages/presentation` |
| `design` | `packages/design` |
| `di` | 루트 `lib/di.config.dart` |

```bash
tool/fca build                      # 전체
tool/fca build --scope data         # data만
tool/fca build -s presentation      # presentation만
```

feature 이름: **snake_case** (예: `payment`, `user_profile`)

---

## 생성되는 구조

```
my_app/
├── lib/           main.dart, di.dart
├── tool/          fca, fca.bat  ← 짧은 명령 래퍼
├── packages/
│   ├── domain/    entity, repository, usecase
│   ├── data/      api, datasource, dto, mapper, repository
│   ├── presentation/  provider, page
│   └── design/
└── melos.yaml
```

**payment 예시 위치** — 새 feature는 이 구조를 복사해서 만듭니다.

```
packages/domain/lib/domain/payment/
packages/data/lib/data/payment/
packages/presentation/lib/payment/
```

**data 흐름**

```
API → datasource → dto → mapper → entity → usecase → UI
```

---

## 문제 해결

### Windows — `.g.dart` 안 생김 / `build.dart.aot` 오류

build_runner **2.15+**는 기본 **AOT**입니다. Mac/Linux는 그대로 동작합니다.  
Windows **OneDrive · 한글 경로**에서만 AOT 실패가 날 수 있습니다.

`tool/fca build` 동작:

1. 기본: `dart run build_runner build` (Mac과 동일)
2. Windows에서 실패 시: 자동으로 `--force-jit` 재시도
3. 수동: `tool\fca build --force-jit`

```powershell
tool\fca build
tool\fca build --force-jit --scope data
```

**근본 해결** — `C:\dev\my_app` 등 OneDrive 밖 ASCII 경로로 이동.

Windows에서 `melos run build:*`가 실패하면 **`tool/fca build` 사용**을 권장합니다.

**`tool/fca`를 찾을 수 없음**

- init 전: `dart pub global run flutter_clean_arch_scaffold:fca init`
- init 후: 프로젝트 루트에서 `tool\fca.bat build` (Windows)

**CLI가 이상함 / 옛 버전**

```bash
dart pub global deactivate flutter_clean_arch_scaffold
dart pub global activate flutter_clean_arch_scaffold
```

---

## 링크

- [GitHub](https://github.com/betterafter/flutter-template)
- [pub.dev](https://pub.dev/packages/flutter_clean_arch_scaffold)
