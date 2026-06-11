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

> 자동 마이그레이션 명령은 아직 없습니다. 추후 `migrate` 명령 추가 예정.

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
