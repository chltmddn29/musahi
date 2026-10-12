import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('added contacts survive a reload from SharedPreferences', () async {
    final store = SafetyContactStore.instance;
    await store.load();
    expect(store.contacts.value, isEmpty);

    store.add(
      SafetyContact(id: '1', name: 'Kim Minsu', phone: '010-1234-5678', relation: '가족'),
    );
    await pumpEventQueue();

    // 새 인스턴스가 아니라 같은 싱글턴이므로, 메모리 값을 지우고
    // SharedPreferences에 저장된 값으로 다시 load() 해서 실제 영속 여부를 검증한다.
    store.contacts.value = [];
    await store.load();

    expect(store.contacts.value, hasLength(1));
    expect(store.contacts.value.first.name, 'Kim Minsu');
    expect(store.contacts.value.first.phone, '010-1234-5678');
  });

  test('removed contacts stay removed after reload', () async {
    final store = SafetyContactStore.instance;
    store.contacts.value = [];
    await store.load();

    final contact = SafetyContact(
      id: '2',
      name: 'Lee Younghee',
      phone: '010-9876-5432',
      relation: '친구',
    );
    store.add(contact);
    await pumpEventQueue();
    store.remove(contact);
    await pumpEventQueue();

    store.contacts.value = [];
    await store.load();

    expect(store.contacts.value, isEmpty);
  });
}
