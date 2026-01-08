import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';

final orderListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref
      .read(firestoreProvider)
      .collection('orders')
      .snapshots()
      .map((s) => s.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList());
});
