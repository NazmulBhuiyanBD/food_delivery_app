import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = true;
  bool emailUpdates = false;
  bool locationTracking = true;

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
                      "Settings",
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
                    _buildSectionHeader("Notifications"),
                    _buildSettingTile(
                      title: "Push Notifications",
                      subtitle: "Alerts for orders and deals",
                      value: pushNotifications,
                      onChanged: (v) => setState(() => pushNotifications = v),
                    ),
                    _buildSettingTile(
                      title: "Email Updates",
                      subtitle: "Weekly newsletter and offers",
                      value: emailUpdates,
                      onChanged: (v) => setState(() => emailUpdates = v),
                    ),
                    
                    const SizedBox(height: 30),
                    _buildSectionHeader("Privacy"),
                    _buildSettingTile(
                      title: "Location Tracking",
                      subtitle: "Improve delivery accuracy",
                      value: locationTracking,
                      onChanged: (v) => setState(() => locationTracking = v),
                    ),

                    const SizedBox(height: 30),
                    _buildSectionHeader("Account"),
                    _buildLinkTile("Delete Account", isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF4A2C2A).withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD35400),
            activeTrackColor: const Color(0xFFD35400).withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(String title, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDestructive ? Colors.red : const Color(0xFF4A2C2A),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDestructive ? Colors.red.withOpacity(0.3) : const Color(0xFF4A2C2A).withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
