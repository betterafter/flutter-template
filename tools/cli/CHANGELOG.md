## 0.2.10

- README: `tool/fca build --scope` 레이어별 빌드 안내 추가 (기본값 `all`)

## 0.2.9

- `bin/fca.dart` 추가 — `dart pub global run flutter_clean_arch_scaffold:fca` 동작 수정

## 0.2.8

- `migrate` 보강: `melos.yaml`, `tool/fca`, `lib/di.dart`, domain `build.yaml`, 루트/domain pubspec 의존성 자동 보완
- `migrate` 완료 후 전체 패키지 `bootstrap` + 코드 생성
- `fca` 글로벌 실행 이름 추가, `build` / `bootstrap` CLI 명령 추가
- README 사용법 단순화 (시나리오별 명령 표, migrate를 사용 방법에 통합)

## 0.2.7

- Windows 호환: `init` 내부 `melos bootstrap`을 `dart pub global run`으로 실행 (PATH 불필요)
- Windows에서 `flutter` 명령 탐지 시 `where` 사용
- README: Windows에서 동작하는 `dart pub global run` 명령을 기본 가이드로 변경

## 0.2.6

- README 사용법 정리
  - `init` / `add feature`가 melos bootstrap·코드 생성까지 자동 처리함을 명시
  - 불필요한 melos 수동 실행 단계 제거
  - `dart pub global run`은 `command not found` 시 우회 방법으로만 안내

## 0.2.5

- melos `build:*` 및 CLI `build_runner` 실행 시 `--delete-conflicting-outputs` 기본 적용
  - init 템플릿 `melos.yaml` 포함

## 0.2.4

- `add feature --force` 시 feature 파일뿐 아니라 원격 데이터 레이어 코어 파일도 최신 템플릿으로 덮어쓰기
  - `DataState`, 네트워크 코어, `module.generator.dart`, `build.yaml` 등
- `migrate --force` 옵션 추가 (동일한 코어 파일 강제 덮어쓰기)

## 0.2.3

- `migrate` / `add feature` 시 구 프로젝트 호환 보완
  - `module.generator.dart`에 `.g.dart` export 제외 로직 없으면 템플릿으로 갱신
  - `presentation/build.yaml` 추가 — `injectable`이 `lib/di.dart`만 처리 (page/provider 빌드 오류 방지)
  - `presentation/pubspec.yaml`에 `flutter_riverpod` 등 누락 의존성 추가
- melos `build:all`에서 deprecated `--delete-conflicting-outputs` 제거

## 0.2.2

- `flutter_clean_arch migrate` 명령 추가
  - `DataState`, 네트워크 코어, `build.yaml` Retrofit 설정, `data` pubspec 의존성 자동 보완
  - 완료 후 `flutter pub get` + `build_runner` 실행 (`--skip-build`, `--skip-pub-get` 지원)

## 0.2.1

- `add feature` 실행 시 원격 데이터 레이어 필수 항목 자동 보완
  - `packages/domain/lib/core/data_state.dart` 없으면 생성
  - `packages/data/lib/core/network/` 코어 파일 없으면 생성
  - `packages/data/build.yaml`에 Retrofit builder 설정 없으면 추가
  - `packages/data/pubspec.yaml`에 `dio`, `retrofit` 등 필수 의존성 없으면 추가
- 기존 파일은 덮어쓰지 않음 (없는 항목만 추가)

## 0.2.0

### 네트워크 레이어 (Dio + Retrofit)

- `init` 템플릿에 원격 데이터 인프라 추가
  - `NetworkModule` — Dio 싱글톤 등록 (`@module`)
  - `LoggingInterceptor` — 요청/응답 로그
  - `ErrorInterceptor` — `RemoteFailure`로 에러 변환
  - `remote()` — 원격 호출을 `DataState`로 래핑 (`DataState.guard` + 네트워크 에러 매핑)
  - `RemoteFailure` — 원격 실패 표현 (기존 `ApiException` 대체)
- `packages/data` 템플릿 의존성 추가: `dio`, `retrofit`, `retrofit_generator`
- `build.yaml`에 Retrofit 코드 생성 설정 추가

### DataState

- `packages/domain`에 wrapper 스타일 `DataState<T>` 추가
  - `initial` / `loading` / `success` / `error` 상태
  - `copyWith`, `toLoading`, `map`, `when`, `maybeWhen`
  - `DataState.guard()` — 범용 try/catch 래핑
- Repository / Usecase / Page 템플릿이 `Future<DataState<T>>` 반환

### Feature 생성 (`add feature`)

- feature별 Retrofit API 파일 생성 (`lib/data/{feature}/api/{feature}.api.dart`)
- `RemoteDatasource`가 Dio 주입 + Retrofit API 호출
- `RepositoryImpl`이 `remote()`로 `DataState` 반환
- `--with-ui` Page가 `DataState.when()` 기반 UI 분기

### Payment 예시 feature

- mock JSON stub → Retrofit `@GET('/api/payments')` 기반으로 변경
- `DataState` + `remote()` 패턴 적용

### 기존 프로젝트 마이그레이션 안내

0.1.x로 `init`한 프로젝트는 아래를 수동 적용해야 합니다.

1. **네트워크 코어 복사** — 템플릿의 `packages/data/lib/core/network/` 전체
2. **domain에 DataState 추가** — `packages/domain/lib/core/data_state.dart`
3. **data `pubspec.yaml`** — `dio`, `retrofit` 의존성 및 `retrofit_generator` dev 의존성
4. **feature별** — `{feature}.api.dart` 생성, `RemoteDatasource` / `Repository` / domain `Repository`·`Usecase` / Page 업데이트
5. **`dart run build_runner build`** — Retrofit `.g.dart` 및 DI 재생성

> `flutter_clean_arch migrate` 명령으로 코어 파일·의존성은 자동 보완됩니다 (0.2.2+).

## 0.1.4

- README 상단에 `init` 시 payment 예시 feature 자동 생성 설명 추가
- pub.dev `description` 문구 업데이트

## 0.1.3

- `init` 시 payment 예시 feature를 함께 생성 (domain / data / presentation)
- `init --force` 시 `main.dart`에 `PaymentPage` 홈 화면 포함

## 0.1.2

- README 사용법을 순서대로 한 블록으로 정리
- `main.dart`에 `configureDependencies()` 추가 안내 보강
- CLI `init` 완료 시 `main.dart` 수정 가이드 출력
- `deactivate` 후 재설치 문제 해결 가이드 추가

## 0.1.1

- pub.dev global install(snapshot) 환경에서 templates 경로를 찾지 못하던 문제 수정
- `flutter create`로 생성한 `pubspec.yaml` 편집 시 발생하던 오류 수정

## 0.1.0

- `flutter_clean_arch init` — Clean Architecture 구조 복제
- `flutter_clean_arch add feature` — domain/data/presentation feature 스캐폴딩
- dto / mapper / compute 기반 data 레이어 템플릿
