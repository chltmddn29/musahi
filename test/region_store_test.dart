import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

RegionItem _legacy(String name, String fullAddr) => RegionItem(
  addrName: name,
  cd: name,
  fullAddr: fullAddr,
  yCoor: '',
  xCoor: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final store = InterestRegionStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store.regions.value = [];
    store.primaryCd.value = null;
  });

  test('손상된 저장값은 버리고 빈 목록으로 시작한다', () async {
    SharedPreferences.setMockInitialValues({'interest_regions': '{not json'});
    await expectLater(store.load(), completes);
    expect(store.regions.value, isEmpty);

    SharedPreferences.setMockInitialValues({'interest_regions': '[1, 2]'});
    await expectLater(store.load(), completes);
    expect(store.regions.value, isEmpty);
  });

  test('같은 서버 지역으로 전환되는 레거시 지역은 하나만 남긴다', () async {
    store.regions.value = [
      _legacy('a', 'Seoul Jongno Cheongun'),
      _legacy('b', 'Seoul Jongno Cheongun'),
    ];
    final server = RegionItem.fromDisasterRegion({
      'code': '236',
      'name': 'Seoul Jongno Cheongun',
    });

    await store.migrateLegacyRegions([server]);

    expect(store.regions.value, [server]);
  });

  test('복원에 실패하면 남은 대표 지역 코드도 버린다', () async {
    SharedPreferences.setMockInitialValues({
      'interest_regions': '{not json',
      'interest_region_primary_cd': '999',
    });
    await store.load();
    expect(store.regions.value, isEmpty);
    expect(store.primaryCd.value, isNull);

    final added = RegionItem.fromDisasterRegion({
      'code': '236',
      'name': 'Seoul',
    });
    store.add(added);
    expect(store.primaryCd.value, added.cd);
  });

  test('목록에 있는 대표 지역 코드는 그대로 복원한다', () async {
    final region = RegionItem.fromDisasterRegion({
      'code': '236',
      'name': 'Seoul',
    });
    store.add(region);
    await pumpEventQueue();
    store.regions.value = [];
    store.primaryCd.value = null;
    await store.load();
    expect(store.primaryCd.value, region.cd);
  });
}
