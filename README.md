# musahi (무사히)

관심지역 기준으로 재난문자를 수신하고, 가까운 대피소 안내와 행동요령, 안전 연락처 공유를 제공하는 Flutter 재난 안전 앱입니다.

## 프로젝트 개요

- **핵심 목적**: 사용자가 등록한 관심지역(동·읍·면)에 해당하는 재난문자만 푸시로 받고, 재난 상황에서 바로 필요한 정보(대피소, 행동요령, 가족 공유)를 한 앱에서 제공합니다.
- **해결하려는 문제**: 기본 재난문자는 현재 위치 기준으로만 오고 내용이 뭉뚱그려져 있어, 가족·부모님이 사는 지역의 재난 소식을 놓치기 쉽고 문자를 받은 뒤 무엇을 해야 할지 알기 어렵습니다.

## 기술 스택

**Client**
- Flutter / Dart (SDK ^3.12.2)
- [go_router](https://pub.dev/packages/go_router) — 라우팅
- [firebase_core](https://pub.dev/packages/firebase_core), [cloud_firestore](https://pub.dev/packages/cloud_firestore), [firebase_messaging](https://pub.dev/packages/firebase_messaging) — Firebase, FCM 푸시
- [dio](https://pub.dev/packages/dio) — HTTP 통신
- [shared_preferences](https://pub.dev/packages/shared_preferences) — 로컬 설정 저장
- [flutter_map](https://pub.dev/packages/flutter_map), [latlong2](https://pub.dev/packages/latlong2), [geolocator](https://pub.dev/packages/geolocator) — OpenStreetMap 지도, 위치
- [intl](https://pub.dev/packages/intl) — 날짜/시간 포맷
- Pretendard — 앱 폰트

**Server (`functions/`)**
- Firebase Functions (Node.js 24 / TypeScript), Firestore, Cloud Messaging
- 외부 API: 재난안전데이터공유플랫폼(재난문자·대피소), SGIS(행정구역), TMAP(보행자 경로)

## 설치 및 실행 방법

### 사전 요구사항

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.12.2 포함)
- Node.js 24, npm (서버 작업 시)
- [Firebase CLI](https://firebase.google.com/docs/cli), [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) (Firebase 프로젝트 연결 및 배포 시)
- iOS 빌드는 Xcode, Android 빌드는 Android Studio 필요

### 클라이언트

```bash
git clone https://github.com/chltmddn29/musahi.git
cd musahi
flutter pub get
flutter run
```

`lib/firebase_options.dart`는 FlutterFire CLI로 생성합니다(`flutterfire configure`). 외부 API 키는 앱에 두지 않고 모두 Functions에서만 사용하며, 앱은 `lib/core/constants/api.dart`의 Functions 주소로 요청합니다.

> iOS 시뮬레이터는 APNS 토큰을 발급하지 못해 알림 동기화 오류가 표시될 수 있습니다. 푸시 동작은 실기기에서 확인하세요.

### 서버 (Firebase Functions)

```bash
cd functions
npm install
npm run build
```

배포 전에 다음 시크릿을 Firebase에 등록해야 합니다.

```bash
firebase functions:secrets:set DISASTER_API_KEY
firebase functions:secrets:set SHELTER_API_KEY
firebase functions:secrets:set SGIS_CONSUMER_KEY
firebase functions:secrets:set SGIS_CONSUMER_SECRET
firebase functions:secrets:set TMAP_APP_KEY
firebase deploy --only functions
```

### 검사 및 테스트

```bash
flutter analyze
flutter test
cd functions && npm test
```

## 사용법

### 주요 기능

| 탭/화면 | 설명 |
|---|---|
| 알림 | 재난문자 목록, 카테고리 필터, 상세(재난 지역 지도, 행동요령·대피소 바로가기) |
| 위치 | 현재 위치 기준 가까운 대피소 5곳, 지도 표시, 도보 경로 안내 |
| 행동요령 | 재난 유형별 행동요령 가이드 |
| 공유 | 안전 연락처에 보낼 메시지를 작성하고 미리보기 (실제 전송은 하지 않음) |
| 설정 | 관심지역, 안전 연락처, 알림 on/off, 언어, 글자 크기 |

### 관심지역과 알림 동작

1. 설정 > 관심지역 관리에서 시도 → 시군구 → 동·읍·면 순으로 SGIS 행정구역을 선택합니다.
2. 앱은 실제 재난문자 수신지역과 매칭되는 가장 세분화된 지역(없으면 상위 시군구·시도)의 FCM 토픽을 구독합니다.
3. 서버가 5분마다 재난문자를 수집해 Firestore에 저장하고, 심각도와 지역에 따라 `region_<지역ID>_<등급>` 토픽으로 발행합니다.
4. 알림 스위치나 관심지역을 바꾸면 구독이 즉시 갱신됩니다. 동기화에 실패하면 설정 화면에 표시되며 재시도·앱 재진입·토큰 갱신 때 다시 시도합니다.

### 서버 엔드포인트 예시

Functions는 `asia-northeast3` 리전에 배포되며, 앱은 `dio`로 다음 함수를 호출합니다.

```dart
final dio = Dio(BaseOptions(baseUrl: functionsBaseUrl));
final res = await dio.get<Map<String, dynamic>>(
  '/nearbyShelters',
  queryParameters: {'lat': 37.5665, 'lng': 126.9780, 'limit': 5},
);
final shelters = res.data!['shelters'] as List;
```

| 함수 | 역할 |
|---|---|
| `pollDisasterAlerts` | 5분 주기 재난문자 수집, Firestore 저장, FCM 발행 |
| `sgisRegions` | SGIS 행정구역 검색 프록시 |
| `syncShelters`, `nearbyShelters` | 대피소 동기화, 주변 대피소 조회 |
| `disasterAreas` | 재난문자 대상 지역 조회 |
| `walkingRoute` | 대피소까지의 보행자 경로 |

### 프로젝트 구조

```
lib/
├── core/        # 공통 상수, 라우팅, 알림 서비스, 전역 설정, 공통 위젯
├── features/    # disaster, guide, main, setting, share, shelter
│   └── <기능>/  # model / repository / presentation (widgets)
functions/src/   # 스케줄러, SGIS 프록시, 대피소·경로 함수
```

## 만든 사람

- GitHub: [chltmddn29](https://github.com/chltmddn29)
