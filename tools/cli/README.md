# flutter_clean_arch_scaffold

Flutter Clean Architecture 멀티 패키지 구조를 기존 프로젝트에 복제하는 CLI입니다.

`init` 한 번으로 `domain` / `data` / `presentation` / `design` + **payment 예시 feature** + `tool/fca` 래퍼가 생성됩니다.

---

## 무엇을 쓰면 되나

| 상황 | 명령 |
|------|------|
| **처음 설치** (PC당 1회) | `dart pub global activate flutter_clean_arch_scaffold` |
| **새 프로젝트 시작** (`tool/fca` 없을 때) | `dart pub global run flutter_clean_arch_scaffold:fca init` |
| **구버전 / 누락 파일 보완** | `tool/fca migrate` |
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

이미 이 템플릿으로 만든 프로젝트가 **옛 버전**이거나 `tool/fca`, `melos.yaml`, `DataState` 등이 없을 때:

```bash
cd my_app
tool/fca migrate
```

없는 필수 파일·의존성만 추가합니다. `bootstrap` + 코드 생성까지 자동 실행됩니다.

최신 템플릿으로 **덮어쓰기**가 필요하면:

```bash
tool/fca migrate --force
```

파일만 보완하고 빌드는 직접 할 때:

```bash
tool/fca migrate --skip-build
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
| `tool/fca build` | 전체 코드 생성 |
| `tool/fca build --scope data` | data 패키지만 |
| `tool/fca bootstrap` | 멀티 패키지 `pub get` |

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
