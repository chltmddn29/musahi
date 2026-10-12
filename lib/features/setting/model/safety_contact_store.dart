import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 안전 연락처 목록의 전역 상태.
///
/// 별도 상태관리 패키지가 없어 [InterestRegionStore]처럼 전역 [ValueNotifier]로 관리한다.
/// 화면은 `ValueListenableBuilder`로 구독하면 된다.
/// [load]로 불러온 뒤에는 [SharedPreferences]에 JSON으로 저장해 앱을 재실행해도 유지된다.
class SafetyContactStore {
  SafetyContactStore._();

  static final instance = SafetyContactStore._();

  static const _prefsKey = 'safety_contacts';

  final ValueNotifier<List<SafetyContact>> contacts = ValueNotifier([]);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    contacts.value = decoded
        .map((e) => SafetyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void add(SafetyContact contact) {
    contacts.value = [...contacts.value, contact];
    _save();
  }

  void remove(SafetyContact contact) {
    contacts.value = contacts.value.where((c) => c.id != contact.id).toList();
    _save();
  }

  void update(SafetyContact contact) {
    contacts.value = [
      for (final c in contacts.value)
        if (c.id == contact.id) contact else c,
    ];
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(contacts.value.map((c) => c.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }
}
