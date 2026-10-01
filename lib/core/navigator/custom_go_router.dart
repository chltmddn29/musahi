import 'package:go_router/go_router.dart';
import 'package:musahi/core/navigator/custom_bottom_navigator_bar.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';
import 'package:musahi/features/disaster/presentation/disaster_detail_page.dart';
import 'package:musahi/features/guide/presentation/guide_detail_page.dart';
import 'package:musahi/features/guide/presentation/guide_page.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';
import 'package:musahi/features/main/presentation/info_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/add_contact_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/language_change_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/region_manage_page.dart';
import 'package:musahi/features/setting/presentation/setting_detail/safety_contact_page.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/presentation/setting_detail/text_size_page.dart';
import 'package:musahi/features/setting/presentation/setting_page.dart';
import 'package:musahi/features/share/share_complete_page.dart';
import 'package:musahi/features/share/share_page.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';
import 'package:musahi/features/shelter/presentation/shelter_page.dart';
import 'package:musahi/features/shelter/presentation/shelter_route_page.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/info',
  routes: [
    // 재난문자 상세에서 여는 재난 지역 대피소. 탭 밖에 쌓아 뒤로가기로 상세에 돌아온다.
    GoRoute(
      path: '/disaster-shelters',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          ShelterPage(disasterRegion: state.extra as String?),
    ),
    // 재난문자 상세에서 여는 유형별 행동요령.
    GoRoute(
      path: '/guide-detail',
      parentNavigatorKey: rootNavigatorKey,
      // 딥링크·웹 새로고침처럼 extra 없이 들어오면 행동요령 탭으로 보낸다.
      redirect: (context, state) {
        final message = state.extra;
        return message is DisasterMessage &&
                DisasterGuide.of(message.category) != null
            ? null
            : '/guide';
      },
      builder: (context, state) {
        final message = state.extra as DisasterMessage;
        return GuideDetailPage(
          guide: DisasterGuide.of(message.category)!,
          disasterRegion:
              message.regionName.isEmpty ? null : message.regionName,
        );
      },
    ),
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
              routes: [
                GoRoute(
                  path: 'detail',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => DisasterDetailPage(
                    message: state.extra as DisasterMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shelter',
              builder: (context, state) => const ShelterPage(),
              routes: [
                GoRoute(
                  path: 'route',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => ShelterRoutePage(
                    target: state.extra as RouteTarget,
                  ),
                ),
              ],
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
              routes: [
                GoRoute(
                  path: 'complete',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final preview = state.extra;
                    return ShareCompletePage(
                      preview: preview is SafetySharePreview ? preview : null,
                    );
                  },
                ),
              ],
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
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => AddContactPage(
                        editing: state.extra as SafetyContact?,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'text-size',
                  builder: (context, state) => TextSizePage(
                    initialStep: textSizeStep.value,
                    onChanged: (fontSize) =>
                        setTextSizeStep(TextSizePage.fontSizes.indexOf(fontSize)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
