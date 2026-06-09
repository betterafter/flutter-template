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
