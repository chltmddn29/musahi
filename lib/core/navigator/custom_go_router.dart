import 'package:go_router/go_router.dart';
import 'package:musahi/core/navigator/custom_bottom_navigator_bar.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/features/guide/guide_page.dart';
import 'package:musahi/features/main/presentation/info_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/language_change_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/region_manage_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/safety_contact_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/text_size_page.dart';
import 'package:musahi/features/setting/presentation/setting_page.dart';
import 'package:musahi/features/share/share_page.dart';
import 'package:musahi/features/shelter/shelter_page.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/info',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomBottomNavigatorBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/info',
              builder: (context, state) => const InfoPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shelter',
              builder: (context, state) => const ShelterPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/guide',
              builder: (context, state) => const GuidePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/share',
              builder: (context, state) => const SharePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/setting',
              builder: (context, state) => const SettingPage(),
              routes: [
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguageChangePage(),
                ),
                GoRoute(
                  path: 'region',
                  builder: (context, state) => const RegionManagePage(),
                ),
                GoRoute(
                  path: 'contacts',
                  builder: (context, state) => const SafetyContactPage(),
                ),
                GoRoute(
                  path: 'text-size',
                  builder: (context, state) => const TextSizePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
