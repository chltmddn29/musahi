import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/utils/format_distance.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/model/disaster_area.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';
import 'package:musahi/features/shelter/widgets/nearby_shelter_list.dart';

Shelter _shelter(String id, {int distance = 100}) => Shelter(
  id: id,
  name: '대피소 $id',
  address: '부산광역시 해운대구 $id',
  location: const Coordinate(35.16, 129.16),
  distanceMeters: distance,
);

void main() {
  group('formatDistance', () {
    test('1km 미만은 m, 이상은 소수 한 자리 km', () {
      expect(formatDistance(0), '0m');
      expect(formatDistance(350), '350m');
      expect(formatDistance(999), '999m');
      expect(formatDistance(1000), '1.0km');
      expect(formatDistance(1240), '1.2km');
      expect(formatDistance(212367), '212.4km');
    });
  });

  group('모델 JSON 파싱', () {
    test('Shelter는 정수·실수 좌표와 거리를 모두 받는다', () {
      final shelter = Shelter.fromJson({
        'id': '3330000-S1',
        'name': '롯데캐슬',
        'address': '부산광역시 해운대구',
        'lat': 35,
        'lng': 129.163916,
        'distanceMeters': 231.0,
      });
      expect(shelter.location.latitude, 35.0);
      expect(shelter.location.longitude, 129.163916);
      expect(shelter.distanceMeters, 231);
    });

    test('ShelterRoute는 경로·거리·시간·첫 안내를 읽는다', () {
      final route = ShelterRoute.fromJson({
        'path': [
          [35.1, 129.1],
          [35.2, 129.2],
        ],
        'totalDistance': 634,
        'totalTime': 526,
        'steps': [
          {'direction': 'left', 'description': '좌회전 후 36m 이동'},
          {'direction': 'right', 'description': '우회전'},
        ],
      });
      expect(route.path.map((c) => c.latitude), [35.1, 35.2]);
      expect(route.remainingMeters, 634);
      expect(route.remainingTime, const Duration(seconds: 526));
      expect(route.nextStep.direction, TurnDirection.left);
      expect(route.nextStep.description, '좌회전 후 36m 이동');
    });

    test('안내 단계가 없으면 대피소 방향 안내, 모르는 방향은 직진', () {
      final noSteps = ShelterRoute.fromJson({
        'path': [],
        'totalDistance': 0,
        'totalTime': 0,
        'steps': [],
      });
      expect(noSteps.nextStep, RouteStep.headToShelter);

      final unknown = RouteStep.fromJson({
        'direction': 'u-turn',
        'description': '유턴',
      });
      expect(unknown.direction, TurnDirection.straight);
    });

    test('DisasterArea는 이름·중심·반경을 읽는다', () {
      final area = DisasterArea.fromJson({
        'name': '경기도 남양주시 진접읍',
        'center': {'lat': 37.72, 'lng': 127.19},
        'radiusMeters': 1998,
      });
      expect(area.name, '경기도 남양주시 진접읍');
      expect(area.center.latitude, 37.72);
      expect(area.radiusMeters, 1998.0);
    });
  });

  group('NearbyShelterList', () {
    Future<void> pumpList(
      WidgetTester tester, {
      required List<Shelter> shelters,
      required Shelter? selected,
      required ValueChanged<Shelter> onSelect,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: NearbyShelterList(
                title: '가까운 대피소',
                shelters: shelters,
                selected: selected,
                onSelect: onSelect,
              ),
            ),
          ),
        ),
      );
    }

    bool isSelected(WidgetTester tester, String name) => tester
        .widget<InfoCard>(
          find.ancestor(of: find.text(name), matching: find.byType(InfoCard)),
        )
        .selected;

    testWidgets('제목과 개수를 보여주고 선택된 카드만 강조한다', (tester) async {
      final shelters = [_shelter('a'), _shelter('b', distance: 1500)];
      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters[1],
        onSelect: (_) {},
      );

      expect(find.text('가까운 대피소'), findsOneWidget);
      expect(find.text('2곳'), findsOneWidget);
      expect(find.text('1.5km'), findsOneWidget);
      expect(isSelected(tester, '대피소 a'), isFalse);
      expect(isSelected(tester, '대피소 b'), isTrue);
    });

    testWidgets('카드를 누르면 그 대피소로 onSelect를 호출한다', (tester) async {
      final shelters = [_shelter('a'), _shelter('b')];
      Shelter? tapped;
      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters[0],
        onSelect: (s) => tapped = s,
      );

      await tester.tap(find.text('대피소 b'));
      expect(tapped?.id, 'b');
    });

    testWidgets('밖에서 선택이 바뀌면 화면 밖 카드가 보이도록 스크롤한다', (tester) async {
      final shelters = [for (var i = 0; i < 8; i++) _shelter('$i')];
      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters.first,
        onSelect: (_) {},
      );
      final lastCard = find.text('대피소 7');
      final listRect = tester.getRect(find.byType(NearbyShelterList));
      expect(tester.getRect(lastCard).top, greaterThan(listRect.bottom));

      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters.last,
        onSelect: (_) {},
      );
      await tester.pumpAndSettle();

      final card = find.ancestor(of: lastCard, matching: find.byType(InfoCard));
      expect(tester.getRect(card).bottom, lessThanOrEqualTo(listRect.bottom));
      expect(isSelected(tester, '대피소 7'), isTrue);
    });

    testWidgets('이미 보이는 카드를 선택하면 스크롤하지 않는다', (tester) async {
      final shelters = [for (var i = 0; i < 8; i++) _shelter('$i')];
      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters.first,
        onSelect: (_) {},
      );
      double scrollOffset() => tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels;
      final before = scrollOffset();

      await pumpList(
        tester,
        shelters: shelters,
        selected: shelters[1],
        onSelect: (_) {},
      );
      await tester.pumpAndSettle();

      expect(scrollOffset(), before);
    });
  });
}
