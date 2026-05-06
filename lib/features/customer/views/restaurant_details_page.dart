import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'package:food_delivery_app/features/customer/view_models/restaurant_provider.dart';
import 'package:food_delivery_app/features/customer/views/product_details_page.dart';
import 'package:food_delivery_app/features/customer/view_models/cart_provider.dart';

class RestaurantDetailsPage extends ConsumerWidget {
  final String restaurantId;
  const RestaurantDetailsPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantProvider(restaurantId));
    final productsAsync = ref.watch(restaurantProductsProvider(restaurantId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: restaurantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (restaurant) {
          if (restaurant == null) {
            return const Center(child: Text("Restaurant not found"));
          }

          return CustomScrollView(
            slivers: [
              // 1. Restaurant Header (Banner)
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppTheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (restaurant.bannerImageUrl != null)
                        Image.network(restaurant.bannerImageUrl!, fit: BoxFit.cover)
                      else
                        Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.surface.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // 2. Restaurant Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.restaurantName,
                              style: textTheme.displaySmall?.copyWith(fontSize: 28),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppTheme.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "4.8",
                                  style: textTheme.labelLarge?.copyWith(color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        restaurant.description,
                        style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.phone,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "MENU",
                        style: textTheme.labelLarge?.copyWith(
                          letterSpacing: 2,
                          color: AppTheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // 3. Product List
              productsAsync.when(
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text("Error: $e"))),
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text("No items available in the menu yet."),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [AppTheme.ambientShadow],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        product.imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.description,
                                            style: textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "৳${product.price}",
                                            style: GoogleFonts.beVietnamPro(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(cartProvider.notifier).add(product);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Added to cart"),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(milliseconds: 1000),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }
}
