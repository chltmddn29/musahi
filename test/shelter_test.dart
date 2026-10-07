import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/utils/format_distance.dart';
import 'package:musahi/core/utils/format_duration.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/disaster/model/disaster_area.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';
import 'package:musahi/features/shelter/service/location_service.dart';
import 'package:musahi/features/shelter/widgets/nearby_shelter_list.dart';
import 'package:musahi/features/shelter/widgets/route_start_button.dart';

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

  group('formatDuration', () {
    test('1시간 미만은 분, 이상은 시간과 분 (초는 올림)', () {
      expect(formatDuration(const Duration(seconds: 30)), '1분');
      expect(formatDuration(const Duration(minutes: 45)), '45분');
      expect(formatDuration(const Duration(minutes: 60)), '1시간');
      expect(formatDuration(const Duration(minutes: 150)), '2시간 30분');
      expect(formatDuration(const Duration(minutes: 5868)), '97시간 48분');
    });
  });

  group('DisasterMessage.needsShelter', () {
    DisasterMessage message(String? category, String text) =>
        DisasterMessage.fromMap({'dstSeNm': category, 'msgCn': text});

    test('대피가 필요한 재난 유형이면 대피소를 안내한다', () {
      expect(message('지진', '규모 4.5 지진 발생').needsShelter, isTrue);
      expect(message('화재', '공장 화재로 연기 발생').needsShelter, isTrue);
      expect(message('호우', '하천 범람 우려').needsShelter, isTrue);
    });

    test('실종·교통·정전·폭염 등은 안내하지 않는다', () {
      expect(message('기타', '실종된 주민 선종도 님을 찾습니다').needsShelter, isFalse);
      expect(message('교통통제', '원효대교 전면 교통통제').needsShelter, isFalse);
      expect(message('정전', '연동 일대 정전 발생').needsShelter, isFalse);
      expect(message('폭염', '무더위쉼터를 이용하세요').needsShelter, isFalse);
      expect(message(null, '불꽃놀이 소음 발생 예정').needsShelter, isFalse);
    });

    test('유형이 기타여도 본문에서 대피를 요청하면 안내한다', () {
      expect(
        message('기타', '화재 발생. 인근 주민께서는 안전한 곳으로 즉시 대피하시고').needsShelter,
        isTrue,
      );
    });
  });

  group('LocationService.isRecent', () {
    final now = DateTime(2026, 9, 30, 12);

    test('5분 이내 위치만 쓴다', () {
      expect(LocationService.isRecent(now, now), isTrue);
      expect(
        LocationService.isRecent(now.subtract(const Duration(minutes: 5)), now),
        isTrue,
      );
      expect(
        LocationService.isRecent(
          now.subtract(const Duration(minutes: 5, seconds: 1)),
          now,
        ),
        isFalse,
      );
      expect(
        LocationService.isRecent(now.subtract(const Duration(days: 3)), now),
        isFalse,
      );
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

  group('RouteStartButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required int distance,
      required VoidCallback onPressed,
      Key? key,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteStartButton(
              key: key,
              distanceMeters: distance,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }

    testWidgets('도보 거리 이내면 한 번 눌러 바로 시작한다', (tester) async {
      var started = 0;
      await pumpButton(tester, distance: 4999, onPressed: () => started++);

      await tester.tap(find.text('경로 안내 시작'));
      expect(started, 1);
    });

    testWidgets('먼 거리면 첫 번째는 안내만, 두 번째에 시작한다', (tester) async {
      var started = 0;
      await pumpButton(tester, distance: 212367, onPressed: () => started++);

      await tester.tap(find.text('경로 안내 시작'));
      await tester.pump();
      expect(started, 0);
      expect(find.textContaining('도보로 가기엔 먼 거리입니다(212.4km)'), findsOneWidget);

      await tester.tap(find.text('한 번 더 눌러 경로 안내 시작'));
      expect(started, 1);
    });

    testWidgets('대피소(key)가 바뀌면 확인 상태를 초기화한다', (tester) async {
      var started = 0;
      await pumpButton(
        tester,
        key: const ValueKey('a'),
        distance: 10000,
        onPressed: () => started++,
      );
      await tester.tap(find.text('경로 안내 시작'));
      await tester.pump();
      expect(find.text('한 번 더 눌러 경로 안내 시작'), findsOneWidget);

      await pumpButton(
        tester,
        key: const ValueKey('b'),
        distance: 10000,
        onPressed: () => started++,
      );
      expect(find.text('경로 안내 시작'), findsOneWidget);
      await tester.tap(find.text('경로 안내 시작'));
      expect(started, 0);
    });
  });
}
