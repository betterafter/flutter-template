# flutter_clean_arch_scaffold

Flutter Clean Architecture 구조를 **기존 Flutter 프로젝트에 복제**하는 CLI입니다.

## 설치

```bash
dart pub global activate flutter_clean_arch_scaffold
```

`~/.pub-cache/bin`이 PATH에 있어야 합니다.

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 사용법

```bash
flutter create my_app
cd my_app

flutter_clean_arch init
flutter_clean_arch add feature payment --with-ui

melos bootstrap
melos run build:all
```

## 명령어

| 명령 | 설명 |
|------|------|
| `flutter_clean_arch init` | `packages/`, `melos.yaml`, `lib/di.dart` 복제 |
| `flutter_clean_arch add feature <name>` | feature 스캐폴딩 |

자세한 내용은 [프로젝트 README](https://github.com/betterafter/flutter-template#readme)를 참고하세요.

## pub.dev 배포

[doc/PUBLISHING.md](doc/PUBLISHING.md)
