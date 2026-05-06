import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_wrapper.dart';
import 'package:food_delivery_app/core/theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 1-second delay as requested
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Circle (Placeholder for later asset)
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [AppTheme.ambientShadow],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu, 
                        size: 65,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // App Name
                  Text(
                    'NazEats',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'Express',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NAZEATS EXPRESS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                  // Animated Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _dotController,
                        builder: (context, child) {
                          // Offset waves for each dot
                          double delay = index * 0.4;
                          double val = (math.sin((_dotController.value * 2 * math.pi) - delay) + 1) / 2;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.3 + (val * 0.7)),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preparing your table...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Footer
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'CURATED DINING EXPERIENCE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
