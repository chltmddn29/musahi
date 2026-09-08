import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:musahi/features/disaster/model/disaster_message.dart';

class DisasterRepository {
  DisasterRepository._();

  static final instance = DisasterRepository._();
  final _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'musahi',
  );

  Stream<List<DisasterMessage>> watchMessage({int limit = 50}) {
    return _db.collection('messages')
        .orderBy('sn', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => DisasterMessage.fromMap(d.data())).toList(),
        );
  }
}
