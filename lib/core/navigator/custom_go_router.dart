import 'package:go_router/go_router.dart';
import 'package:musahi/core/navigator/custom_bottom_navigator_bar.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/features/edit/edit_page.dart';
import 'package:musahi/features/guide/guide_page.dart';
import 'package:musahi/features/main/main_page.dart';
import 'package:musahi/features/share/share_page.dart';
import 'package:musahi/features/shelter/shelter_page.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/main',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomBottomNavigatorBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainPage(),
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
              path: '/edit',
              builder: (context, state) => const EditPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
