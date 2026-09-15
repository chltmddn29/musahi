import 'package:flutter/foundation.dart';
import 'package:musahi/features/setting/model/region_model.dart';

/// 관심지역 목록의 전역 상태.
///
/// 별도 상태관리 패키지가 없어 [textSizeStep]처럼 전역 [ValueNotifier]로 관리한다.
/// 화면은 `ValueListenableBuilder`로 구독하면 된다.
class InterestRegionStore {
  InterestRegionStore._();

  static final instance = InterestRegionStore._();

  final ValueNotifier<List<RegionItem>> regions = ValueNotifier([]);

  /// 대표 지역의 지역코드(cd). 목록이 비면 null.
  final ValueNotifier<String?> primaryCd = ValueNotifier(null);

  void add(RegionItem region) {
    if (regions.value.any((r) => r.cd == region.cd)) return;
    regions.value = [...regions.value, region];
    primaryCd.value ??= region.cd;
  }

  void remove(RegionItem region) {
    regions.value = regions.value.where((r) => r.cd != region.cd).toList();
    if (primaryCd.value == region.cd) {
      primaryCd.value = regions.value.isEmpty ? null : regions.value.first.cd;
    }
  }

  void setPrimary(RegionItem region) {
    primaryCd.value = region.cd;
  }
}
