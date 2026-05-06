import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'dart:async';
import 'pickup_navigation_page.dart';

class NewOrderRequestPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const NewOrderRequestPage({super.key, required this.order});

  @override
  ConsumerState<NewOrderRequestPage> createState() => _NewOrderRequestPageState();
}

class _NewOrderRequestPageState extends ConsumerState<NewOrderRequestPage> {
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _acceptOrder() async {
    final riderId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreProvider);
    final orderId = widget.order['id'];

    try {
      await firestore.runTransaction((transaction) async {
        final orderDoc = await transaction.get(firestore.collection('orders').doc(orderId));
        
        if (orderDoc.exists && orderDoc.data()?['status'] == 'ready_for_pickup') {
          transaction.update(orderDoc.reference, {
            'status': 'assigned',
            'riderId': riderId,
            'assignedAt': DateTime.now().toIso8601String(),
          });
        } else {
          throw Exception("Order already accepted by another rider.");
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order accepted! Navigating to pickup..."), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PickupNavigationPage(order: widget.order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background Placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://st3.depositphotos.com/1000128/15535/v/450/depositphotos_155355604-stock-illustration-map-with-pin-vector-illustration.jpg"),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),

          // 2. Header Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                    onPressed: () {},
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
          ),

          // 3. Request Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge and Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B59B6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "HIGH VALUE",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              value: _secondsLeft / 30,
                              strokeWidth: 4,
                              backgroundColor: const Color(0xFFFFD1CC),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFAB2D00)),
                            ),
                          ),
                          Text(
                            "$_secondsLeft",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: Color(0xFFD35400), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "New Order Request",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD35400),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Payout Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD1CC).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFFD1CC).withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "ESTIMATED PAYOUT",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A2C2A).withOpacity(0.4),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${widget.order['payout'] ?? '18.50'}",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFAB2D00),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.route_outlined, size: 16, color: Color(0xFF4A2C2A)),
                            const SizedBox(width: 6),
                            Text("3.2 mi", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
                            const SizedBox(width: 15),
                            const CircleAvatar(radius: 2, backgroundColor: Colors.grey),
                            const SizedBox(width: 15),
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF4A2C2A)),
                            const SizedBox(width: 6),
                            Text("~22 min", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Locations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _buildLocationRow(
                          type: "PICKUP",
                          name: widget.order['restaurantName'] ?? "Le Petit Bistro",
                          address: widget.order['pickupAddress'] ?? "124 Culinary Ave, Downtown",
                          isPickup: true,
                        ),
                        const SizedBox(height: 25),
                        _buildLocationRow(
                          type: "DROPOFF",
                          name: widget.order['customerName'] ?? "Residential Client",
                          address: widget.order['deliveryAddress'] ?? "Apt 4B, 890 Heritage Lane",
                          isPickup: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 65,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD1CC).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.close_rounded, color: Color(0xFF4A2C2A), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "Reject",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF4A2C2A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: _acceptOrder,
                          child: Container(
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD35400).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "Accept",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required String type,
    required String name,
    required String address,
    required bool isPickup,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isPickup ? const Color(0xFFD35400) : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPickup ? Icons.restaurant_rounded : Icons.location_on_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (isPickup)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A).withOpacity(0.4),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
              Text(
                address,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A2C2A).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
