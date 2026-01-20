import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/firebase_providers.dart'; // ✅ Added to access Firestore
import '../providers/cart_provider.dart';
import '../services/widget_support.dart';
import 'checkout_page.dart';

// Simple provider to hold the voucher discount percentage for the session
final voucherProvider = StateProvider<double>((ref) => 0.0);

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final voucherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final discountPercent = ref.watch(voucherProvider);

    // Calculations
    double subtotal = notifier.subtotal;
    double deliveryCharge = 60.0; // Fixed delivery charge
    double discountAmount = subtotal * discountPercent;
    double total = subtotal + deliveryCharge - discountAmount;

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text("Your cart is empty"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to home
                    },
                    child: const Text("Start Shopping"),
                  )
                ],
              ),
            )
          : Column(
              children: [
                // 1. Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFFF4F4F4),
                              ),
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => notifier.add(item.product),
                                  ),
                                  Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () => notifier.decrease(item.product),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(item.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 15),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: AppWidget.SemiBoldTextField()),
                                  Text("৳ ${item.product.price}", style: AppWidget.SimpleTextField()),
                                  Text("Total: ৳ ${item.total}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A00))),
                                ],
                              ),
                            ),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => notifier.remove(item.product.id),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 2. Voucher & Totals Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Voucher Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: voucherController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: "Enter Voucher Code",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                            // ✅ UPDATED: Validate against Firestore
                            onPressed: () async {
                              final inputCode = voucherController.text.trim().toUpperCase();
                              if (inputCode.isEmpty) return;

                              FocusScope.of(context).unfocus(); // Close keyboard

                              try {
                                final db = ref.read(firestoreProvider);
                                
                                // Query Firestore for the voucher
                                final snapshot = await db
                                    .collection('vouchers')
                                    .where('code', isEqualTo: inputCode)
                                    .where('isActive', isEqualTo: true)
                                    .get();

                                if (snapshot.docs.isNotEmpty) {
                                  final data = snapshot.docs.first.data();
                                  final discount = (data['percentage'] as num).toDouble();

                                  // Apply Discount
                                  ref.read(voucherProvider.notifier).state = discount;
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Voucher Applied! ${(discount * 100).toInt()}% Off"), 
                                        backgroundColor: Colors.green
                                      )
                                    );
                                  }
                                } else {
                                  // Invalid
                                  ref.read(voucherProvider.notifier).state = 0.0;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Invalid or Expired Voucher"), 
                                        backgroundColor: Colors.red
                                      )
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e"))
                                  );
                                }
                              }
                            },
                            child: const Text("Apply", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Cost Summary
                      _buildSummaryRow("Subtotal", subtotal),
                      _buildSummaryRow("Delivery", deliveryCharge),
                      if (discountAmount > 0)
                        _buildSummaryRow("Discount", -discountAmount, color: Colors.green),
                      const Divider(),
                      _buildSummaryRow("Total", total, isBold: true),

                      const SizedBox(height: 20),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  subtotal: subtotal,
                                  deliveryCharge: deliveryCharge,
                                  discount: discountAmount,
                                  total: total,
                                  cartItems: cartItems,
                                ),
                              ),
                            );
                          },
                          child: const Text("CHECKOUT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            "৳ ${value.toStringAsFixed(1)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}