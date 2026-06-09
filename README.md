# Flutter Clean Architecture Template

Flutter Clean Architecture 구조를 **CLI로 프로젝트에 복제**하는 템플릿입니다.

| 구분 | 설명 |
|------|------|
| **사용자** | [pub.dev](https://pub.dev/packages/flutter_clean_arch_scaffold)에서 CLI 설치 |
| **이 저장소** | CLI 소스 + 구조 참고 구현 (`payment` 예시) |

---

## 사용 방법

아래를 **위에서부터 순서대로** 실행하세요.

```bash
# CLI 설치 (최초 1회)
dart pub global activate flutter_clean_arch_scaffold

# PATH 설정
export PATH="$PATH:$HOME/.pub-cache/bin"

# 새 Flutter 프로젝트
flutter create my_shop
cd my_shop

# Clean Architecture 구조 복제
flutter_clean_arch init

# lib/main.dart 수정 — init이 기존 main.dart를 유지한 경우 필수
# import 'di.dart'; 추가 후 main() 맨 앞에 configureDependencies(); 호출

# feature 추가
flutter_clean_arch add feature payment --with-ui

# 의존성 설치 + 코드 생성
dart pub global activate melos
melos bootstrap
melos run build:all

# 앱 실행
flutter run
```

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

`init --force`를 쓰면 `main.dart`가 템플릿으로 교체되어 위 코드가 포함됩니다.

### feature 추가 후 할 일

- `entity`, `dto` 필드 정의
- `datasource` API 구현 (`compute`로 JSON 파싱)
- `mapper` dto → entity 변환
- `repository impl` 조합
- (UI 생성 시) `page` 구현

> melos는 `pubspec.yaml`에 의존성을 추가하지 않습니다. `bootstrap`은 설치, `build:*`는 코드 생성만 수행합니다.

---

## 문제 해결

### `command not found: flutter_clean_arch`

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

`~/.zshrc`에 추가 후 `source ~/.zshrc`

### templates 오류 / 이상한 동작 / 옛 버전이 실행됨

```bash
dart pub global deactivate flutter_clean_arch_scaffold
dart pub global activate flutter_clean_arch_scaffold
```

### PATH 없이 실행

```bash
dart pub global run flutter_clean_arch_scaffold:flutter_clean_arch init
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
  entity/  repository/  usecase/

packages/data/lib/data/payment/
  datasource/  dto/  mapper/  repository/

packages/presentation/lib/payment/
  provider/  page/
```

### data 레이어 흐름

```
API (JSON) → datasource (compute) → dto → mapper → entity → usecase → UI
```

---

## pub.dev 문서는 어디에 쓰나

| 보이는 곳 | 수정하는 파일 | 내용 |
|-----------|---------------|------|
| pub.dev 검색 카드 / 짧은 설명 | `tools/cli/pubspec.yaml` → `description` | 한두 문장 요약 |
| pub.dev 패키지 페이지 본문 | `tools/cli/README.md` | 설치법, 명령어, 구조 설명 전체 |

README나 `description`을 바꾼 뒤 pub.dev에 반영하려면 **버전을 올리고 재배포**해야 합니다.

```bash
cd tools/cli
dart pub publish
```

자세한 배포 절차: [`tools/cli/doc/PUBLISHING.md`](tools/cli/doc/PUBLISHING.md)

---

## 기여 / 개발

```bash
cd tools/cli
dart pub global activate --source path .

# 이 저장소 루트에서
flutter_clean_arch add feature login --with-ui
```

---

## 라이선스

Apache License 2.0 — [LICENSE](LICENSE)
