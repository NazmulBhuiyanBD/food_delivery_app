import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/features/admin/view_models/approval_provider.dart';
import 'package:food_delivery_app/models/app_user.dart';

class ProviderDetailsPage extends ConsumerWidget {
  final Map<String, dynamic> providerData;
  final bool isRestaurant;

  const ProviderDetailsPage({
    super.key,
    required this.providerData,
    required this.isRestaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = isRestaurant 
        ? (providerData['restaurantName'] ?? 'Unnamed Restaurant') 
        : (providerData['fullName'] ?? 'Unnamed Rider');
    
    final String statusStr = providerData['status'] ?? 'pending';
    final bool isPending = statusStr == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD35400), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRestaurant ? "Restaurant Review" : "Rider Review",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4A2C2A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Header Info
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFFFE8E5),
                    backgroundImage: providerData['profileImageUrl'] != null && providerData['profileImageUrl'].isNotEmpty
                        ? NetworkImage(providerData['profileImageUrl']) 
                        : const AssetImage("assets/profile.png"),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPending ? const Color(0xFFFFD1CC) : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusStr.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, 
                        fontWeight: FontWeight.w800, 
                        color: isPending ? const Color(0xFFD35400) : Colors.green.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text("BASIC INFORMATION", style: _sectionStyle()),
            const SizedBox(height: 15),
            _buildInfoCard([
              _InfoTile(label: "Email", value: providerData['email'] ?? 'N/A', icon: Icons.email_outlined),
              _InfoTile(label: "Phone", value: providerData['phone'] ?? 'N/A', icon: Icons.phone_outlined),
              _InfoTile(label: "Address", value: providerData['address'] ?? 'N/A', icon: Icons.location_on_outlined),
              if (!isRestaurant) _InfoTile(label: "DOB", value: providerData['dob'] ?? 'N/A', icon: Icons.calendar_today_outlined),
            ]),

            if (isRestaurant) ...[
              const SizedBox(height: 30),
              Text("RESTAURANT DETAILS", style: _sectionStyle()),
              const SizedBox(height: 15),
              _buildInfoCard([
                _InfoTile(label: "Cuisine", value: providerData['foodCategory'] ?? 'General', icon: Icons.restaurant_menu),
              ]),
            ] else ...[
              const SizedBox(height: 30),
              Text("VEHICLE DETAILS", style: _sectionStyle()),
              const SizedBox(height: 15),
              _buildInfoCard([
                _InfoTile(label: "Type", value: providerData['vehicleType'] ?? 'N/A', icon: Icons.delivery_dining),
                _InfoTile(label: "Model", value: providerData['vehicleNumber'] ?? 'N/A', icon: Icons.info_outline),
                _InfoTile(label: "Plate", value: providerData['plateNumber'] ?? 'N/A', icon: Icons.numbers),
              ]),
            ],

            const SizedBox(height: 30),
            Text("DOCUMENTS", style: _sectionStyle()),
            const SizedBox(height: 15),
            if (isRestaurant) ...[
              _DocumentTile(label: "Operating License", imageUrl: providerData['licenseImageUrl']),
              const SizedBox(height: 15),
              _DocumentTile(label: "Shop Banner", imageUrl: providerData['bannerImageUrl']),
            ] else ...[
              _DocumentTile(label: "NID / Passport", imageUrl: providerData['nidImageUrl']),
              const SizedBox(height: 15),
              _DocumentTile(label: "Driving License", imageUrl: providerData['licenseImageUrl']),
            ],

            const SizedBox(height: 50),
            
            // Action Buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "APPROVE",
                      color: const Color(0xFFD35400),
                      onPressed: () => _updateStatus(context, ref, UserStatus.approved),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _ActionButton(
                      label: "REJECT",
                      color: const Color(0xFFFFD1CC),
                      textColor: const Color(0xFFD35400),
                      onPressed: () => _updateStatus(context, ref, UserStatus.rejected),
                    ),
                  ),
                ],
              )
            else
              _ActionButton(
                label: "MOVE TO PENDING",
                color: Colors.white,
                textColor: const Color(0xFFD35400),
                isOutlined: true,
                onPressed: () => _updateStatus(context, ref, UserStatus.pending),
              ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF4A2C2A).withOpacity(0.4),
      letterSpacing: 1,
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  void _updateStatus(BuildContext context, WidgetRef ref, UserStatus status) {
    final collection = isRestaurant ? 'owners' : 'riders';
    ref.read(approvalControllerProvider.notifier).updateStatus(collection, providerData['id'], status);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Application ${status.name}")));
    Navigator.pop(context);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD35400), size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String label;
  final String? imageUrl;

  const _DocumentTile({required this.label, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (imageUrl != null) {
              showDialog(
                context: context,
                builder: (_) => Dialog(child: Image.network(imageUrl!, fit: BoxFit.contain)),
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E5).withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover) : null,
            ),
            child: imageUrl == null 
                ? const Center(child: Text("No document uploaded")) 
                : null,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _ActionButton({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isOutlined ? BorderSide(color: textColor.withOpacity(0.3)) : BorderSide.none,
          ),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }
}
