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
import 'package:musahi/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SafetyContactStore.instance.load();
  await InterestRegionStore.instance.load();
  await loadTextSizeSetting();
  await loadNotificationSettings();
  await loadLanguageSetting();
  // 알림 on/off, 관심지역 설정을 먼저 불러온 뒤 초기화해야
  // NotificationService가 최신 값 기준으로 구독/필터링한다.
  await NotificationService.init();

  runApp(const MyApp());
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
