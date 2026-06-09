# pub.dev 배포 가이드

`flutter_clean_arch_scaffold` 패키지를 pub.dev에 배포하는 방법입니다.

> **패키지 이름 안내**  
> `flutter_clean_arch_cli`는 pub.dev에 이미 다른 패키지가 사용 중입니다.  
> 이 프로젝트는 `flutter_clean_arch_scaffold`로 배포하며, 실행 명령어는 `flutter_clean_arch`입니다.

## 사전 준비

1. [pub.dev](https://pub.dev) 계정 생성
2. Google 계정으로 로그인 후 publisher 등록
3. 터미널에서 pub 로그인

```bash
dart pub login
```

4. 패키지 점수를 위해 다음 파일 확인

| 파일 | 필수 |
|------|------|
| `pubspec.yaml` | description, homepage, repository |
| `README.md` | 사용법 |
| `CHANGELOG.md` | 버전 이력 |
| `LICENSE` | 라이선스 |

## 배포 전 검증

`tools/cli` 디렉터리에서 실행합니다.

```bash
cd tools/cli
dart pub get
dart analyze
dart pub publish --dry-run
```

`templates/` 디렉터리가 패키지에 포함되는지 반드시 확인하세요.

### 로컬 동작 확인

```bash
cd tools/cli
dart pub global activate --source path .

mkdir -p /tmp/clean_arch_test && cd /tmp/clean_arch_test
flutter create test_app
cd test_app

flutter_clean_arch init --skip-build
flutter_clean_arch add feature payment --with-ui --skip-build
```

## 버전 올리기

`pubspec.yaml`의 `version`과 `CHANGELOG.md`를 함께 수정합니다.

```yaml
version: 0.1.1
```

## 배포

```bash
cd tools/cli
dart pub publish
```

확인 프롬프트에서 `y` 입력.

배포 후: https://pub.dev/packages/flutter_clean_arch_scaffold

## 사용자 설치 (배포 후)

```bash
dart pub global activate flutter_clean_arch_scaffold
flutter_clean_arch init
```

버전 고정:

```bash
dart pub global activate flutter_clean_arch_scaffold 0.1.0
```

## 주의사항

- `publish_to: none`이 있으면 배포되지 않습니다.
- 템플릿 수정 후 `--dry-run` + 로컬 `init` 테스트를 반복하세요.
- pub.dev에 올리는 것은 `tools/cli` 패키지뿐입니다. 루트 `flutter-template` 앱은 별도입니다.

## CI 자동 배포 (선택)

```yaml
name: Publish CLI

on:
  push:
    tags:
      - 'cli-v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - name: Publish
        working-directory: tools/cli
        run: dart pub publish --force
        env:
          PUB_CREDENTIALS: ${{ secrets.PUB_CREDENTIALS }}
```

태그: `git tag cli-v0.1.0 && git push origin cli-v0.1.0`

`PUB_CREDENTIALS`는 `dart pub token add`로 발급한 CI 토큰을 GitHub Secrets에 등록합니다.
