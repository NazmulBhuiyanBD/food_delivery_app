import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/features/owner/view_models/owner_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/features/admin/view_models/product_provider.dart';
import 'package:food_delivery_app/models/category_model.dart';
import 'package:food_delivery_app/models/product_model.dart';
import 'owner_add_food_page.dart';

class OwnerMenuPage extends ConsumerWidget {
  const OwnerMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final currentUser = ref.watch(authProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const Spacer(),
                      Text(
                        ref.watch(ownerProfileProvider).when(
                              data: (p) => p['restaurantName'] ?? "NazEats Express",
                              loading: () => "...",
                              error: (_, __) => "NazEats Express",
                            ),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFD35400),
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: ref.watch(ownerProfileProvider).when(
                              data: (p) => p['bannerImageUrl'] != null ? NetworkImage(p['bannerImageUrl']) : null,
                              loading: () => null,
                              error: (_, __) => null,
                            ) as ImageProvider?,
                        child: ref.watch(ownerProfileProvider).when(
                              data: (p) => p['bannerImageUrl'] == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
                              loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                              error: (_, __) => const Icon(Icons.error),
                            ),
                      ),
                    ],
                  ),
                ),

                // Menu List
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      return categoriesAsync.when(
                        data: (categories) {
                          if (currentUser == null) return const SizedBox();

                          final myProducts = products.where((p) => p.restaurantId == currentUser.uid).toList();
                          
                          if (myProducts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu_rounded, size: 64, color: const Color(0xFFD35400).withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No dishes added yet.\nTap the + button to create a masterpiece.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Group by category
                          final Map<String, List<Product>> grouped = {};
                          for (var p in myProducts) {
                            final cat = categories.firstWhere(
                              (c) => c.id == p.categoryId, 
                              orElse: () => Category(id: '', name: 'Uncategorized', imageUrl: '')
                            );
                            grouped.putIfAbsent(cat.name.toUpperCase(), () => []).add(p);
                          }

                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            children: [
                              for (final entry in grouped.entries) ...[
                                _buildSectionHeader(entry.key),
                                const SizedBox(height: 15),
                                for (final product in entry.value) ...[
                                  _buildMenuItem(
                                    context: context,
                                    ref: ref,
                                    product: product,
                                  ),
                                  const SizedBox(height: 25),
                                ],
                                const SizedBox(height: 10),
                              ],
                              const SizedBox(height: 120),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                        error: (err, stack) => Center(child: Text("Error: $err")),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                    error: (err, stack) => Center(child: Text("Error: $err")),
                  ),
                ),
              ],
            ),
            
            // Floating Action Button
            Positioned(
              bottom: 100, // Above the bottom nav bar
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerAddFoodPage()),
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD35400).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4A2C2A).withOpacity(0.5),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required Product product,
  }) {
    final isActive = product.isActive;
    final badge = product.isChefSelection ? "CHEF'S SPECIAL" : (!isActive ? "UNAVAILABLE" : null);
    final badgeColor = product.isChefSelection ? const Color(0xFF9B59B6) : (!isActive ? Colors.grey : null);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerAddFoodPage(initialProduct: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
              colorFilter: isActive ? null : ColorFilter.mode(
                Colors.white.withOpacity(0.6),
                BlendMode.lighten,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Stack(
            children: [
              // Price Badge
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD35400),
                    ),
                  ),
                ),
              ),
              
              // Custom Badge
              if (badge != null)
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: badgeColor != null ? Colors.white : const Color(0xFF4A2C2A),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        
        // Details Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isActive ? const Color(0xFF4A2C2A) : const Color(0xFF4A2C2A).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A2C2A).withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            
            // Switch
            GestureDetector(
              onTap: () {
                ref.read(productControllerProvider.notifier).updateProduct(
                  id: product.id,
                  name: product.name,
                  description: product.description,
                  price: product.price,
                  imageUrl: product.imageUrl,
                  categoryId: product.categoryId,
                  restaurantId: product.restaurantId,
                  isActive: !product.isActive,
                  isChefSelection: product.isChefSelection,
                );
              },
              child: Container(
                width: 50,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isActive ? const Color(0xFFD35400) : const Color(0xFFFFD1CC),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      top: 2,
                      left: isActive ? 24 : 2,
                      right: isActive ? 2 : 24,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: isActive 
                            ? const Icon(Icons.check, size: 14, color: Color(0xFFD35400))
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }
}

