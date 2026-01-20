import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/firebase_providers.dart';
import '../providers/admin_stats_provider.dart';

class VoucherManagementPage extends ConsumerWidget {
  const VoucherManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchersAsync = ref.watch(voucherListProvider);
    final db = ref.read(firestoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Vouchers")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8A00),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddVoucherDialog(context, ref),
      ),
      body: vouchersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (vouchers) {
          if (vouchers.isEmpty) return const Center(child: Text("No vouchers active"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              final percent = (voucher['percentage'] as num) * 100;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.purple),
                  title: Text(voucher['code'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Discount: ${percent.toStringAsFixed(0)}%"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      db.collection('vouchers').doc(voucher['id']).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddVoucherDialog(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Voucher"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: "Code (e.g. FOOD10)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: percentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Percentage (e.g. 10 for 10%)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final percentInput = double.tryParse(percentCtrl.text.trim());

              if (code.isNotEmpty && percentInput != null) {
                // Convert 10 -> 0.10
                final decimal = percentInput / 100;

                await ref.read(firestoreProvider).collection('vouchers').add({
                  'code': code,
                  'percentage': decimal,
                  'isActive': true,
                  'createdAt': DateTime.now(),
                });

                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}