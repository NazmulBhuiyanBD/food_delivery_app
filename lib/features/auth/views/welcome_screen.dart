import 'package:flutter/material.dart';
import 'package:food_delivery_app/features/auth/views/administration_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'customer_login_page.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Tonal Layer
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppTheme.surface,
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Magazine-style Headline
                  Text(
                    "NazEats\nExpress",
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 64,
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Atmospheric Luxury.\nGourmet Experiences.\nDelivered to your doorstep.",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      color: AppTheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Central Imagery Placeholder (Floating Icon with ambient shadow)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  
                  const Spacer(),

                  // Action Buttons
                  Column(
                    children: [
                      // Primary Button (Gradient)
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomerLoginPage()),
                            );
                          },
                          child: const Text("START BROWSING"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Secondary Button (Tonal)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceContainerHighest,
                            foregroundColor: AppTheme.onSurface,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdministrationScreen()),
                            );
                          },
                          child: Text(
                            "ADMINISTRATION",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Footer
                  Center(
                    child: Text(
                      "CURATED DINING EXPERIENCE • 2026",
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurface.withOpacity(0.4),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
