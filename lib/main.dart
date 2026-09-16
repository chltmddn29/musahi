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
  await NotificationService.init();
  await SafetyContactStore.instance.load();
  await InterestRegionStore.instance.load();
  await loadTextSizeSetting();
  await loadNotificationSettings();
  await loadLanguageSetting();

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
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScaleForStep(step))),
              child: child!,
            );
          },
        );
      },
    );
  }
}
