import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin.dart';


class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  final _db = FirebaseFirestore.instance;


  CollectionReference<Map<String, dynamic>> _checkinsCol(String storeId) =>
      _db.collection('stores').doc(storeId).collection('checkins');


  Future<void> saveCheckin(Checkin c) async {
    await _checkinsCol(c.storeId).doc(c.id).set(c.toMap(), SetOptions(merge: true));
  }


  Future<List<Checkin>> fetchWeek(String storeId, DateTime weekStartUtc) async {
    final start = Timestamp.fromDate(weekStartUtc);
    final end = Timestamp.fromDate(weekStartUtc.add(const Duration(days: 7)));
    final q = await _checkinsCol(storeId)
        .where('date', isGreaterThanOrEqualTo: start.toDate().toIso8601String())
        .where('date', isLessThan: end.toDate().toIso8601String())
        .get();
    return q.docs.map((d) => Checkin.fromMap(d.id, d.data())).toList();
  }
}