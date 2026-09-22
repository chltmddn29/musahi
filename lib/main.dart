import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/navigator/custom_go_router.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/core/settings/language_settings.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/setting/repository/region_repository.dart';
import 'package:musahi/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 여기까지는 SharedPreferences만 읽으므로 즉시 끝난다. 첫 프레임이 올바른
  // 텍스트 배율·언어·연락처로 그려지려면 runApp() 앞에 있어야 한다.
  await SafetyContactStore.instance.load();
  await InterestRegionStore.instance.load();
  await loadTextSizeSetting();
  await loadNotificationSettings();
  await loadLanguageSetting();

  runApp(const MyApp());

  // 네트워크·권한이 걸린 작업은 첫 프레임 뒤로 미룬다. runApp() 앞에 두면
  // 알림 권한 다이얼로그를 사용자가 누를 때까지, 그리고 APNS 토큰 대기
  // (시뮬레이터는 10초 타임아웃)가 끝날 때까지 화면이 비어 있게 된다.
  unawaited(_initializeRemoteServices());
}

/// 관심지역 자동 전환 → 알림 초기화 순서를 지켜야 한다.
/// [NotificationService]가 전환된 지역 코드 기준으로 토픽을 구독하기 때문.
/// 실패는 각자 내부에서 잡아 [NotificationService.syncError]로 노출되고,
/// 설정 화면의 재시도 버튼으로 복구된다.
Future<void> _initializeRemoteServices() async {
  await _migrateLegacyInterestRegions();
  await NotificationService.init();
}

Future<void> _migrateLegacyInterestRegions() async {
  try {
    final serverRegions = await RegionRepository().fetchNotificationRegions();
    await InterestRegionStore.instance.migrateLegacyRegions(serverRegions);
  } on FirebaseException catch (error) {
    debugPrint('관심지역 자동 전환 실패: $error');
  } on FormatException catch (error) {
    debugPrint('관심지역 자동 전환 실패: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: AppColors.surface,
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
      ),
      builder: (context, child) {
        return ValueListenableBuilder<int>(
          valueListenable: textSizeStep,
          builder: (context, step, _) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: composeTextScaler(mediaQuery.textScaler, step),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
