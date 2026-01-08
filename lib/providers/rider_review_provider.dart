import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';

final riderReviewProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, riderId) {
  return ref
      .read(firestoreProvider)
      .collection('reviews')
      .where('riderId', isEqualTo: riderId)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});
