import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCShipmentInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/General.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:food_delivery_app/cloudinary/cloudinary.dart';

import '../providers/cart_provider.dart';
import '../providers/current_user_provider.dart';
import '../core/firebase_providers.dart';
import '../models/cart_item.dart';
import '../services/widget_support.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final List<CartItem> cartItems;

  const CheckoutPage({
    super.key,
    required this.subtotal,
    required this.deliveryCharge,
    required this.discount,
    required this.total,
    required this.cartItems,
  });

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  String selectedPayment = "Cash on Delivery";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Delivery Address", style: AppWidget.SemiBoldTextField()),
              const SizedBox(height: 8),
              TextFormField(
                controller: addressCtrl,
                maxLines: 3,
                decoration: AppWidget.inputDecoration("Full Address", Icons.location_on),
                validator: (v) => v == null || v.isEmpty ? "Address required" : null,
              ),
              const SizedBox(height: 16),

              Text("Phone Number", style: AppWidget.SemiBoldTextField()),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: AppWidget.inputDecoration("Phone Number", Icons.phone),
                validator: (v) => v == null || v.isEmpty ? "Phone required" : null,
              ),
              const SizedBox(height: 25),

              Text("Payment Method", style: AppWidget.SemiBoldTextField()),
              const SizedBox(height: 10),

              _paymentOption("SSLCommerz"),
              _paymentOption("Cash on Delivery"),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Payable"),
                    Text(
                      "৳ ${widget.total.toStringAsFixed(2)}",
                      style: AppWidget.HeadlineTextField(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _placeOrder,
                  child: const Text(
                    "PLACE ORDER",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOption(String name) {
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPayment == name ? const Color(0xFFFF8A00) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (selectedPayment == name)
              const Icon(Icons.check_circle, color: Color(0xFFFF8A00))
          ],
        ),
      ),
    );
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPayment == "SSLCommerz") {
      _startSandboxPayment();
    } else {
      _saveOrder(paymentStatus: "pending", transactionId: "");
    }
  }

  Future<void> _startSandboxPayment() async {
    final trxId = "TRX_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}";
    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: SslcommerzConfig.storeId, 
        store_passwd: SslcommerzConfig.pass, 
        total_amount: widget.total, 
        
        currency: SSLCurrencyType.BDT,
        tran_id: trxId,
        product_category: "Food",
        sdkType: SSLCSdkType.TESTBOX,
      ),
    );

    // Add Product Info
    sslcommerz.addProductInitializer(
      sslcProductInitializer: SSLCProductInitializer(
        productName: "Food Order",
        productCategory: "Food",
        general: General(
          general: "Food Items",
          productProfile: "Food delivery",
        ),
      ),
    );

    // Add Customer Info
    sslcommerz.addCustomerInfoInitializer(
      customerInfoInitializer: SSLCCustomerInfoInitializer(
        customerName: "Customer",
        customerPhone: phoneCtrl.text.trim(),
        customerAddress1: addressCtrl.text.trim(),
        customerCity: "Dhaka",
        customerState: "Dhaka",
        customerPostCode: "1212",
        customerCountry: "Bangladesh",
        customerEmail: "user@test.com",
      ),
    );

    try {
      // Initiate Payment
      final SSLCTransactionInfoModel result = await sslcommerz.payNow();

      // Check Status
      if (result.status?.toLowerCase() == "valid" || result.status?.toLowerCase() == "success") {
        _saveOrder(
          paymentStatus: "paid",
          transactionId: result.tranId ?? trxId,
        );
      } else if (result.status?.toLowerCase() == "closed") {
        _snack("Payment cancelled", Colors.orange);
      } else {
        _snack("Payment failed: ${result.status}", Colors.red);
      }
    } catch (e) {
      debugPrint("SSL Error: $e");
      _snack("Payment initialization error. Check logs.", Colors.red);
    }
  }

  Future<void> _saveOrder({
    required String paymentStatus,
    required String transactionId,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = ref.read(firestoreProvider);
      final userId = ref.read(currentUserIdProvider);

      await db.collection("orders").add({
        "userId": userId,
        "address": addressCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "paymentMethod": selectedPayment,
        "paymentStatus": paymentStatus,
        "transactionId": transactionId,
        "subtotal": widget.subtotal,
        "deliveryCharge": widget.deliveryCharge,
        "discount": widget.discount,
        "totalAmount": widget.total,
        "items": widget.cartItems.map((i) => {
              "productId": i.product.id,
              "name": i.product.name,
              "price": i.product.price,
              "quantity": i.quantity,
              "imageUrl": i.product.imageUrl,
            }).toList(),
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;

      Navigator.pop(context); 
      Navigator.popUntil(context, (route) => route.isFirst);

      _snack("Order placed successfully!", Colors.green);
    } catch (e) {
      if(mounted) Navigator.pop(context); 
      _snack("Order failed: $e", Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}