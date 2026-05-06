import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiderDocumentsPage extends StatelessWidget {
  const RiderDocumentsPage({super.key});

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
        title: Text(
          "Documents & Compliance",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Compliance Status",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
            ),
            const SizedBox(height: 20),
            _buildDocTile("NID Card / Passport", "Verified", Icons.badge_outlined, Colors.green),
            _buildDocTile("Driving License", "Verified", Icons.drive_eta_outlined, Colors.green),
            _buildDocTile("Vehicle Insurance", "Expired", Icons.security_outlined, Colors.red),
            _buildDocTile("Trade License", "Not Provided", Icons.business_center_outlined, Colors.grey),
            
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFFD35400)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Please update your expired insurance to avoid account suspension.",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFD35400)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocTile(String title, String status, IconData icon, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD35400)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
