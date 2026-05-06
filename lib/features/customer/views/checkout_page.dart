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
import 'package:flutter_sslcommerz/model/sslproductinitilizer/PhysicalGoods.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:food_delivery_app/core/config.dart';
import 'package:food_delivery_app/features/customer/view_models/cart_provider.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/models/cart_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/customer/views/saved_addresses_page.dart';

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
  int currentStep = 0; // 0: Address, 1: Payment
  String selectedAddressLabel = "The Residence";
  String selectedPayment = "Online Payment";
  
  final TextEditingController addressCtrl = TextEditingController(text: "120 Central Park South, Apt 14B\nNew York, NY 10019");
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4F3), Color(0xFFFFE8E5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentStep == 1) {
                          setState(() => currentStep = 0);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A2C2A)),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "NazEats Express",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFD35400),
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/profile.png"),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: currentStep == 0 ? _buildAddressStep() : _buildPaymentStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Delivery Address",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4A2C2A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Where should we deliver your culinary experience?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A2C2A).withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 30),

          // Search/Map Card Mockup
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: const DecorationImage(
                image: NetworkImage("https://media.wired.com/photos/59269cd37034dc3f91d07ee8/master/pass/GoogleMap-660x440.jpg"),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Color(0xFFD35400)),
                      const SizedBox(width: 10),
                      Text("Search a new location...", style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                const Center(
                  child: Icon(Icons.location_on, size: 40, color: Color(0xFFD35400)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),
          Text(
            "Saved Locations",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 20),

          Consumer(
            builder: (context, ref, child) {
              final userId = ref.watch(currentUserIdProvider);
              if (userId.isEmpty) return const SizedBox();
              return StreamBuilder(
                stream: ref.watch(firestoreProvider)
                    .collection('customers')
                    .doc(userId)
                    .collection('addresses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD35400)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "No saved addresses found. Please add a new location below.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF4A2C2A).withOpacity(0.5),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data();
                      final title = data['label'] ?? 'Location';
                      final fullAddress = data['address'] ?? '';
                      final isPrimary = data['isPrimary'] == true;

                      // Automatically select primary if nothing selected
                      if (selectedAddressLabel == "The Residence" && isPrimary) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && selectedAddressLabel == "The Residence") {
                            setState(() {
                              selectedAddressLabel = doc.id;
                              addressCtrl.text = fullAddress;
                            });
                          }
                        });
                      }

                      return _buildAddressTile(
                        id: doc.id,
                        label: title,
                        address: fullAddress,
                        icon: title.toLowerCase().contains('work') ? Icons.work_rounded : Icons.home_rounded,
                        isDefault: isPrimary,
                        fullAddressText: fullAddress,
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),
          // Add New Address Button
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesPage()));
            },
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1CC).withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_location_alt_rounded, color: Color(0xFFD35400), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Add New Address",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD35400),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
          _buildGradientButton("Confirm Selection", () => setState(() => currentStep = 1)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Method",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Select how you'd like to complete your order.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 35),

                _buildPaymentCard(
                  title: "Cash on Delivery",
                  subtitle: "Pay our delivery partner in cash upon arrival.",
                  icon: Icons.payments_rounded,
                  name: "Cash on Delivery",
                ),
                const SizedBox(height: 20),
                _buildPaymentCard(
                  title: "Online Payment",
                  subtitle: "Securely pay via SSLCommerz (Cards, MFS, Net Banking).",
                  icon: Icons.account_balance_wallet_rounded,
                  name: "Online Payment",
                  showLogos: true,
                ),
              ],
            ),
          ),
        ),

        // Bottom Summary Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Color(0xFFFFE8E5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TOTAL AMOUNT",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4A2C2A).withOpacity(0.5),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "৳ ${widget.total.toStringAsFixed(2)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4A2C2A),
                        ),
                      ),
                      Text(
                        "Includes taxes and delivery fees",
                        style: TextStyle(fontSize: 11, color: const Color(0xFF4A2C2A).withOpacity(0.4)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildGradientButton("Confirm Order", _placeOrder, showArrow: true),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTile({required String id, required String label, required String address, required IconData icon, bool isDefault = false, required String fullAddressText}) {
    bool isSelected = selectedAddressLabel == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressLabel = id;
          addressCtrl.text = fullAddressText;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFFD35400) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFFD35400) : Colors.grey.shade300,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: const Color(0xFFD35400)),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFE8E5), borderRadius: BorderRadius.circular(8)),
                          child: Text("DEFAULT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFD35400))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address,
                    style: TextStyle(fontSize: 13, color: const Color(0xFF4A2C2A).withOpacity(0.6), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({required String title, required String subtitle, required IconData icon, required String name, bool showLogos = false}) {
    bool isSelected = selectedPayment == name;
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = name),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected ? const Color(0xFFD35400) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFFFE8E5), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFD35400), size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: const Color(0xFF4A2C2A).withOpacity(0.5), height: 1.4),
            ),
            if (showLogos) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniLogo("VISA"),
                  const SizedBox(width: 8),
                  _buildMiniLogo("MC"),
                  const SizedBox(width: 8),
                  _buildMiniLogo("MFS"),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLogo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey.shade500)),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap, {bool showArrow = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFD35400), Color(0xFFE67E22)]),
          borderRadius: BorderRadius.circular(31),
          boxShadow: [BoxShadow(color: const Color(0xFFD35400).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            if (showArrow) ...[
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  void _placeOrder() {
    if (selectedPayment == "Online Payment") {
      _startSandboxPayment();
    } else {
      _saveOrder(paymentStatus: "pending", transactionId: "");
    }
  }

  Future<void> _startSandboxPayment() async {
    if (widget.total <= 0) {
      _snack("Invalid total amount", Colors.red);
      return;
    }

    final trxId = "TRX${DateTime.now().millisecondsSinceEpoch}";
    debugPrint("Initializing SSLCommerz with TRX: $trxId, Amount: ${widget.total}");

    // Using official test credentials if the ones in config are failing
    // store_id: "testbox", store_passwd: "qwerty"
    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: SslcommerzConfig.storeId.trim(), 
        store_passwd: SslcommerzConfig.pass.trim(), 
        total_amount: double.parse(widget.total.toStringAsFixed(2)), 
        currency: SSLCurrencyType.BDT,
        tran_id: trxId,
        product_category: "Food",
        sdkType: SSLCSdkType.TESTBOX,
      ),
    );

    // Minimal Customer Info (Often required for initialization)
    sslcommerz.addCustomerInfoInitializer(
      customerInfoInitializer: SSLCCustomerInfoInitializer(
        customerName: "Test Customer",
        customerPhone: "01700000000",
        customerAddress1: "Dhaka",
        customerCity: "Dhaka",
        customerPostCode: "1212",
        customerCountry: "Bangladesh",
        customerEmail: "test@test.com", customerState: '',
      ),
    );

    try {
      final SSLCTransactionInfoModel result = await sslcommerz.payNow();
      debugPrint("SSLCommerz Result Status: ${result.status}");
      
      if (result.status?.toLowerCase() == "valid" || result.status?.toLowerCase() == "success") {
        _saveOrder(paymentStatus: "paid", transactionId: result.tranId ?? trxId);
      } else if (result.status?.toLowerCase() == "closed") {
        // If it closes immediately, it's likely a credential or network issue.
        _snack("Payment Closed/Cancelled. Verify credentials in config.dart.", Colors.orange);
      } else {
        _snack("Payment failed: ${result.status ?? 'Error'}", Colors.red);
      }
    } catch (e) {
      debugPrint("SSLCommerz Exception: $e");
      _snack("SSLCommerz Error. Check internet or credentials.", Colors.red);
    }
  }

  Future<void> _saveOrder({required String paymentStatus, required String transactionId}) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final db = ref.read(firestoreProvider);
      final userId = ref.read(currentUserIdProvider);
      final restaurantId = widget.cartItems.isNotEmpty ? widget.cartItems.first.product.restaurantId : '';
      
      await db.collection("orders").add({
        "userId": userId,
        "restaurantId": restaurantId,
        "address": addressCtrl.text.trim(),
        "phone": "01700000000",
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}