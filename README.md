# musahi (무사히)

재난문자를 관심지역 기준으로 실시간 수신하고, 대피소·안전연락처 정보를 제공하는 Flutter 재난 안전 앱입니다.

## 사용한 기술

**Client**
- Flutter / Dart
- [go_router](https://pub.dev/packages/go_router) — 라우팅
- [firebase_core](https://pub.dev/packages/firebase_core), [cloud_firestore](https://pub.dev/packages/cloud_firestore), [firebase_messaging](https://pub.dev/packages/firebase_messaging) — Firebase / FCM 푸시 알림
- [dio](https://pub.dev/packages/dio) — HTTP 통신
- [shared_preferences](https://pub.dev/packages/shared_preferences) — 로컬 설정 저장
- [intl](https://pub.dev/packages/intl) — 날짜/시간 포맷
- Pretendard — 앱 폰트

**Server**
- Firebase Functions (Node.js / TypeScript)
- 행정안전부 재난안전데이터공유플랫폼(safetydata.go.kr) API, SGIS Open API — 외부 연동
- Firebase Firestore, Cloud Messaging — 데이터 저장 및 토픽 발행

## 아키텍처

Flutter 앱은 `core`(공통)와 `features`(기능별) 레이어로 나뉘고, 각 feature는 model / repository / presentation 하위 레이어로 구성됩니다.

- **core**: 공통 상수(색상·폰트), 라우팅(go_router), 알림 구독/동기화 서비스, 전역 설정(언어·알림·글자크기), 공통 위젯
- **features**: 재난문자(disaster), 설정·관심지역·안전연락처(setting), 대피소(shelter), 행동요령 가이드(guide), 공유하기(share), 홈(main)
- **functions**: 재난문자 수집 스케줄러, 행정구역 검색 프록시, FCM 토픽 발행을 담당하는 Firebase Functions 서버

서버가 재난안전데이터공유플랫폼에서 재난문자를 주기적으로 수집해 Firestore에 저장하고, 심각도와 지역에 따라 FCM 토픽으로 발행합니다. 클라이언트는 관심지역 설정에 따라 해당 지역의 알림 토픽을 구독합니다.

### 관심지역과 알림

`관심지역 관리`에서 SGIS 행정구역을 단계별로 검색해 동·읍·면을 선택하면, 실제 재난문자 수신지역과 매칭되는 가장 세분화된 지역(없으면 상위 시군구·시도) 기준으로 알림을 구독합니다.

기존 방식으로 등록된 관심지역이 있다면 앱 시작 시 서버 지역과 자동으로 매칭·전환되며, 매칭되는 지역이 없으면 구독 대신 화면에 원인을 표시합니다. 알림 스위치나 관심지역을 변경하면 즉시 구독/해제에 반영되고, 포그라운드 알림 표시도 알림 스위치를 따릅니다. 동기화에 실패하면 설정/관심지역 화면에 표시되며, 재시도·앱 재진입·토큰 갱신 시 다시 동기화를 시도합니다.

## 실행 방법

**클라이언트 (Flutter)**

```bash
flutter pub get
flutter run
```

Firebase 프로젝트 연결을 위해 `lib/firebase_options.dart`가 필요합니다(FlutterFire CLI로 생성).

**서버 (Firebase Functions)**

```bash
cd functions
npm install
firebase deploy --only functions
```

**테스트**

```bash
flutter test
```

## 만든 사람

- GitHub: [chltmddn29](https://github.com/chltmddn29)
