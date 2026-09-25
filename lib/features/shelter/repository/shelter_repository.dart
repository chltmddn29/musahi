import 'package:musahi/features/shelter/model/shelter.dart';

typedef NearbyShelters = ({Coordinate origin, List<Shelter> shelters});

/// 대피소 데이터 소스. 현재는 목업이며, 위치 권한·대피소 API 연동 시 교체한다.
class ShelterRepository {
  ShelterRepository._();

  static final instance = ShelterRepository._();

  static const _origin = Coordinate(35.1631, 129.1636);

  static const _mockShelters = [
    Shelter(
      id: 'shelter-1',
      name: '해운대초등학교',
      address: '부산 해운대구 해운대로 612',
      location: Coordinate(35.1658, 129.1609),
      distanceMeters: 350,
    ),
    Shelter(
      id: 'shelter-2',
      name: '해운대구청 지하주차장',
      address: '부산 해운대구 중동2로 11',
      location: Coordinate(35.1672, 129.1668),
      distanceMeters: 610,
    ),
    Shelter(
      id: 'shelter-3',
      name: '해운대도서관',
      address: '부산 해운대구 해운대로 395',
      location: Coordinate(35.1598, 129.1701),
      distanceMeters: 890,
    ),
  ];

  /// 현재 위치 기준 가까운 대피소를 거리순으로 반환한다.
  Future<NearbyShelters> fetchNearby() async {
    final shelters = [..._mockShelters]
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return (origin: _origin, shelters: shelters);
  }
}
