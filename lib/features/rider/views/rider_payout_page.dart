import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';
import 'edit_bank_details.dart';

final riderBankDetailsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, riderId) {
  return ref.read(firestoreProvider)
      .collection('riders')
      .doc(riderId)
      .snapshots()
      .map((doc) => (doc.data()?['bankDetails'] as Map<String, dynamic>?) ?? {});
});

class RiderPayoutPage extends ConsumerWidget {
  const RiderPayoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final bankDetailsAsync = ref.watch(riderBankDetailsProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A2C2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payout Settings",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
        ),
        centerTitle: true,
      ),
      body: bankDetailsAsync.when(
        data: (details) => SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bank Account Details",
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
              ),
              const SizedBox(height: 20),
              _buildInfoCard("Bank Name", details['bankName'] ?? "Not Set"),
              _buildInfoCard("Account Holder", details['accountHolder'] ?? "Not Set"),
              _buildInfoCard("Account Number", details['accountNumber'] ?? "Not Set"),
              _buildInfoCard("Branch Name", details['branchName'] ?? "Not Set"),
              _buildInfoCard("Routing Number", details['routingNumber'] ?? "Not Set"),

              const SizedBox(height: 40),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditBankDetailsPage(currentDetails: details)),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text("Edit Bank Details"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD35400),
                    textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading details: $e")),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A).withOpacity(0.5))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A))),
        ],
      ),
    );
  }
}
