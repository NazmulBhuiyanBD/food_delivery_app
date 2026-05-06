import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A2C2A)),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Payment Methods",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 38),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildPaymentCard(
                      label: "Visa Card",
                      sublabel: "**** **** **** 4242",
                      icon: Icons.credit_card_rounded,
                      color: const Color(0xFF1A1A1A),
                    ),
                    const SizedBox(height: 20),
                    _buildPaymentCard(
                      label: "bKash Wallet",
                      sublabel: "+880 17XX XXX 123",
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFFE2136E),
                    ),
                    const SizedBox(height: 30),
                    
                    // Add Method
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF4A2C2A).withOpacity(0.1),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: Color(0xFF4A2C2A)),
                          SizedBox(width: 10),
                          Text(
                            "Add New Method",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4A2C2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xFFD35400), size: 24),
        ],
      ),
    );
  }
}
