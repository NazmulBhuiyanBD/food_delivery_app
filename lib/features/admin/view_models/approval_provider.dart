import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/models/app_user.dart';

/// Stream of pending applications
final pendingOwnersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('owners')
      .where('status', isEqualTo: UserStatus.pending.name)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final pendingRidersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('riders')
      .where('status', isEqualTo: UserStatus.pending.name)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

/// Stream of active (approved) partners
final activeOwnersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('owners')
      .where('status', isEqualTo: UserStatus.approved.name)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final activeRidersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider)
      .collection('riders')
      .where('status', isEqualTo: UserStatus.approved.name)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

/// Controller for approval actions
final approvalControllerProvider = NotifierProvider<ApprovalController, void>(ApprovalController.new);

class ApprovalController extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateStatus(String collection, String id, UserStatus status) async {
    await ref.read(firestoreProvider)
        .collection(collection)
        .doc(id)
        .update({'status': status.name});
  }
}
