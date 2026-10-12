import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 관심지역 목록의 전역 상태.
///
/// 별도 상태관리 패키지가 없어 [textSizeStep]처럼 전역 [ValueNotifier]로 관리한다.
/// 화면은 `ValueListenableBuilder`로 구독하면 된다.
/// [load]로 불러온 뒤에는 [SharedPreferences]에 JSON으로 저장해 앱을 재실행해도 유지된다.
class InterestRegionStore {
  InterestRegionStore._();

  static final instance = InterestRegionStore._();

  static const _regionsKey = 'interest_regions';
  static const _primaryCdKey = 'interest_region_primary_cd';

  final ValueNotifier<List<RegionItem>> regions = ValueNotifier([]);

  /// 대표 지역의 지역코드(cd). 목록이 비면 null.
  final ValueNotifier<String?> primaryCd = ValueNotifier(null);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_regionsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      regions.value = decoded
          .map((e) => RegionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    primaryCd.value = prefs.getString(_primaryCdKey);
  }

  void add(RegionItem region) {
    if (regions.value.any(
      (r) => r.cd == region.cd && r.notificationCode == region.notificationCode,
    )) {
      return;
    }
    regions.value = [...regions.value.where((r) => r.cd != region.cd), region];
    primaryCd.value ??= region.cd;
    _save();
  }

  void remove(RegionItem region) {
    regions.value = regions.value.where((r) => r.cd != region.cd).toList();
    if (primaryCd.value == region.cd) {
      primaryCd.value = regions.value.isEmpty ? null : regions.value.first.cd;
    }
    _save();
  }

  void setPrimary(RegionItem region) {
    primaryCd.value = region.cd;
    _save();
  }

  /// 기존 SGIS 관심지역을 재난문자 서버의 지역코드로 안전하게 전환한다.
  ///
  /// 전체 주소가 정확히 일치하는 서버 지역이 하나일 때만 바꾼다. 이름만 같은
  /// 지역을 임의로 구독하지 않도록, 일치하지 않거나 모호한 항목은 보존한다.
  Future<void> migrateLegacyRegions(List<RegionItem> serverRegions) async {
    final matchesByName = <String, List<RegionItem>>{};
    for (final region in serverRegions) {
      matchesByName
          .putIfAbsent(_normalizeAddress(region.displayName), () => [])
          .add(region);
    }

    var changed = false;
    String? migratedPrimaryCd;
    final migrated = regions.value.map((region) {
      if (region.notificationCode != null) return region;
      final matches = matchesByName[_normalizeAddress(region.displayName)];
      if (matches == null || matches.length != 1) return region;

      final replacement = matches.single;
      if (primaryCd.value == region.cd) {
        migratedPrimaryCd = replacement.cd;
      }
      changed = true;
      return replacement;
    }).toList();

    if (!changed) return;
    regions.value = migrated;
    primaryCd.value = migratedPrimaryCd ?? primaryCd.value;
    await _save();
  }

  static String _normalizeAddress(String address) =>
      normalizeRegionName(address);

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(regions.value.map((r) => r.toJson()).toList());
    await prefs.setString(_regionsKey, encoded);
    if (primaryCd.value == null) {
      await prefs.remove(_primaryCdKey);
    } else {
      await prefs.setString(_primaryCdKey, primaryCd.value!);
    }
  }
}
