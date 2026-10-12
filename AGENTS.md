# musahi

관심지역 기준 재난문자 수신 앱 (Flutter + Firebase Functions). 구조와 기술 스택은 README.md 참고.

## 명령

- 앱: `flutter pub get` → `flutter run`
- 검사: `flutter analyze` (현재 이슈 0건 유지)
- 테스트: `flutter test` (현재 전부 통과)
- 서버(`functions/`): `npm run build`, `npm test`, `npm run lint`

변경을 마치기 전에 `flutter analyze`와 `flutter test`를 실행한다. `functions/`를 건드렸으면 `npm test`도 실행한다.

## 구조 규칙

- 기능은 `lib/features/<기능>/` 아래에 model / repository / presentation 계층으로 둔다.
- 둘 이상의 feature가 쓰는 코드만 `lib/core/`로 올린다.
- 새 화면이나 로직에는 `test/`에 테스트를 함께 추가한다.

## 코드 작성

- 요청받은 것만 만든다. 요청하지 않은 추상화, 옵션, 예외 처리, 주석을 추가하지 않는다.
- 간결하게 쓴다. 기존 코드나 `core/` 위젯으로 해결되면 새로 만들지 않고, 중복은 합친다.
- 한 파일에는 한 가지 역할만 둔다. 화면, 위젯, 모델, 저장소, 서비스를 한 파일에 섞지 않는다.
- 파일 하나가 200줄을 넘기려 하면 먼저 분리한다. 화면 안의 큰 위젯은 `widgets/` 아래 별도 파일로 뺀다.
- 화면(presentation)에서 Firestore, dio, shared_preferences를 직접 호출하지 않는다. repository나 service를 거친다.
- 파일명은 `snake_case`, 클래스 하나당 파일 하나를 기본으로 한다.
- 주석은 코드만 봐서는 알 수 없는 이유가 있을 때만 쓴다.

## Git 규칙

- 커밋 메시지는 한국어, 접두사는 `feat` `fix` `refactor` `perf` `chore` `test` `docs`.
- PR 대상 브랜치는 `develop` (`main`은 사용하지 않는다).
- 커밋, 푸시, PR 생성은 사용자가 요청할 때만 한다.

## 먼저 물어볼 것

- 의존성 추가나 업그레이드 (`pubspec.yaml`, `functions/package.json`)
- Firestore 스키마, FCM 토픽 이름 변경 (앱과 서버가 함께 바뀌어야 한다)
- Firebase 배포 (`firebase deploy`)

## 주의

- `config/dev.json`(SGIS 키)은 gitignore 대상이다. 읽거나 출력하거나 커밋하지 않는다.
- iOS 시뮬레이터에서 알림 동기화 오류가 나는 것은 알려진 현상이다 (`docs/qa-notes.md` QA-001).
  - 증상: 설정 탭 상단에 "알림 설정을 서버에 반영하지 못했습니다. 연결 후 다시 시도해주세요." 배너가 뜨고, 다시 시도해도 사라지지 않는다. 알림 토글을 바꾸면 화면 값은 바뀌지만 배너는 그대로다.
  - 추정 원인: 시뮬레이터가 APNS 토큰을 발급하지 못해 `NotificationService._waitForApnsToken()`(`lib/core/notifications/notification_service.dart`)이 10초 뒤 `TimeoutException`을 던진다. 로그로 확정한 것은 아니다.
  - 확인된 환경: iPhone 16 Pro 시뮬레이터(iOS 18.5)에서 재현했다. 다른 시뮬레이터 버전이나 APNs 샌드박스를 지원하는 환경에서는 다를 수 있다.
  - 이 증상만으로는 버그로 보고하지도, 버그가 아니라고 단정하지도 않는다. 알림 동기화(`notification_service.dart`, `notification_topic_sync.dart`, 설정 화면의 알림 토글)를 바꿨다면 실기기에서 배너가 사라지는지, 토픽 구독이 바뀌는지 확인한다.
  - 시뮬레이터에서 FCM 토픽 구독을 검증할 수 없으므로, 토픽 이름과 동기화 순서는 `test/notification_topic_sync_test.dart` 단위 테스트로 확인한다.
- 사용자에게 보이는 문구는 한국어로 쓴다. 사실과 다른 인상을 주지 않게 쓴다 (예: 실제로 전송하지 않는 화면에 "전송 완료"라고 쓰지 않는다).
