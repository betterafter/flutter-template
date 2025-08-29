# FLUTTER TEMPLATE

flutter로 앱을 만들 때 정형화된 구조로 개발할 수 있게 만든 프로젝트입니다. 해당 프로젝트 기반으로 쉽게 앱을 설계할 수 있게 기반을 마련해두었습니다.

- `Clean Architecture` 기반 프로젝트
- `melos`를 이용한 빌드 자동화
- 

## Clean Architecture 구조 기반

```
- project
    - lib
        - di
    - packages
        - data
        - domain
        - presentation
        - design
    - pubspec.yaml

```

최상위 lib에서 각 도메인에 대한 DI를 관리하게 됩니다. 이 경우 data -> domain <- presentation 간의 의존성이 생기지 않고, data와 presentation이 domain에 대한 의존성만 가지고 있는 채 설계를 할 수 있게 되며, DI 또한 적용할 수 있습니다.
그렇지 않으면 각 도메인 별로 의존성 주입을 위해 서로에 대한 의존성을 가지게끔 설계할 수 밖에 없습니다.

<br><br><br><br>

## Design 패키지

`design/assets`에 리소스를 관리하게끔 설계되어 있습니다. 이 경우 `flutter pub run build_runner build`에 상응하는 auto generate를 하게 되면 image 위젯을 자동 생성해줄 수 있도록 설계되어 있습니다. 

`build.yaml`을 통해 assets에 있는 이미지를 찾아서 그것을 widget로 변환해주는 자동화 코드가 포함되어 있으며, 자세한 것은 `desgin/assets/lib/images`의 `iamge.generator.dart`에서 확인할 수 있습니다.

<br><br><br><br>

## Melos

`melos run build` 명령어를 이용해 빌드할 수 있습니다. (예를 들어, melos run build:presentation) 패키지별로 flutter pub run build_runner build를 하지 않고 전체적으로 한꺼번에 편하게 빌드하기 위해 세팅해두었습니다.



```
scripts:
  build:all:
    run: melos exec -c 1 -- "flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs"

  build:di:
    run: melos exec -c 1 -- "flutter pub run build_runner build --delete-conflicting-outputs"

  build:design:
    run: melos exec -c 1 --scope=design -- "find lib -name 'image.generated.dart' -delete && flutter pub run build_runner build --delete-conflicting-outputs"

  build:presentation:
    run: melos exec -c 1 --scope=presentation -- "flutter pub run build_runner build --delete-conflicting-outputs"

  build:data:
    run: melos exec -c 1 --scope=data -- "flutter pub run build_runner build --delete-conflicting-outputs"

  build:domain:
    run: melos exec -c 1 --scope=domain -- "flutter pub run build_runner build --delete-conflicting-outputs"

  clean:
    run: melos exec -- flutter clean

  analyze:
    run: melos exec -- flutter analyze
```