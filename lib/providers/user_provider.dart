import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';

final customerListProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.read(firestoreProvider);

  return db.collection('customers').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'role': 'Customer',
                  ...doc.data(),
                })
            .toList(),
      );
});
final riderListProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final db = ref.read(firestoreProvider);

  return db.collection('riders').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'role': 'Rider',
                  ...doc.data(),
                })
            .toList(),
      );
});
