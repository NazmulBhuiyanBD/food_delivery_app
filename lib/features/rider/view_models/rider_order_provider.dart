import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

final riderOrdersProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref
      .read(firestoreProvider)
      .collection('orders')
      .where('riderId', isEqualTo: riderId)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final riderOnlineStatusProvider = StreamProvider.family<bool, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('riders')
      .doc(riderId)
      .snapshots()
      .map((s) => s.exists ? (s.data()?['isOnline'] ?? false) : false);
});

final riderOnlineStatusControllerProvider = Provider((ref) => RiderOnlineStatusController(ref));

class RiderOnlineStatusController {
  final Ref _ref;
  RiderOnlineStatusController(this._ref);

  Future<void> setStatus(String riderId, bool isOnline) async {
    await _ref.read(firestoreProvider).collection('riders').doc(riderId).set({
      'isOnline': isOnline,
      'lastStatusUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
