import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/auth/view_models/current_user_provider.dart';

class EditBankDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentDetails;
  const EditBankDetailsPage({super.key, required this.currentDetails});

  @override
  ConsumerState<EditBankDetailsPage> createState() => _EditBankDetailsPageState();
}

class _EditBankDetailsPageState extends ConsumerState<EditBankDetailsPage> {
  late TextEditingController bankNameCtrl;
  late TextEditingController holderNameCtrl;
  late TextEditingController accNumberCtrl;
  late TextEditingController branchNameCtrl;
  late TextEditingController routingNumberCtrl;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.currentDetails;
    bankNameCtrl = TextEditingController(text: data['bankName'] ?? '');
    holderNameCtrl = TextEditingController(text: data['accountHolder'] ?? '');
    accNumberCtrl = TextEditingController(text: data['accountNumber'] ?? '');
    branchNameCtrl = TextEditingController(text: data['branchName'] ?? '');
    routingNumberCtrl = TextEditingController(text: data['routingNumber'] ?? '');
  }

  @override
  void dispose() {
    bankNameCtrl.dispose();
    holderNameCtrl.dispose();
    accNumberCtrl.dispose();
    branchNameCtrl.dispose();
    routingNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    setState(() => isSaving = true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final details = {
        'bankDetails': {
          'bankName': bankNameCtrl.text.trim(),
          'accountHolder': holderNameCtrl.text.trim(),
          'accountNumber': accNumberCtrl.text.trim(),
          'branchName': branchNameCtrl.text.trim(),
          'routingNumber': routingNumberCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }
      };

      await ref.read(firestoreProvider).collection('riders').doc(userId).set(
        details, SetOptions(merge: true)
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bank details updated!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A2C2A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Bank Details", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildField("Bank Name", bankNameCtrl, Icons.account_balance_rounded),
            const SizedBox(height: 15),
            _buildField("Account Holder Name", holderNameCtrl, Icons.person_rounded),
            const SizedBox(height: 15),
            _buildField("Account Number", accNumberCtrl, Icons.numbers_rounded),
            const SizedBox(height: 15),
            _buildField("Branch Name", branchNameCtrl, Icons.location_on_rounded),
            const SizedBox(height: 15),
            _buildField("Routing Number", routingNumberCtrl, Icons.tag_rounded),
            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: isSaving ? null : _saveDetails,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFD35400), Color(0xFFE67E22)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFFD35400).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Center(
                  child: isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Update Details", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TextFormField(
        controller: ctrl,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF4A2C2A).withOpacity(0.4)),
          prefixIcon: Icon(icon, color: const Color(0xFFD35400), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
