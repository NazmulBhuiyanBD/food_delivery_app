import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_delivery_app/features/customer/view_models/favorite_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/core/theme.dart';
import 'package:food_delivery_app/features/admin/view_models/product_provider.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/features/customer/view_models/cart_provider.dart';
import 'product_details_page.dart';
import 'restaurant_details_page.dart';
import 'package:food_delivery_app/features/customer/view_models/restaurant_provider.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => "");

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final productsAsync = ref.watch(productListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NazEats",
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 42,
                            height: 0.9,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          "Express",
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 42,
                            height: 0.9,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    // Floating Action Button Style Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [AppTheme.ambientShadow],
                      ),
                      child: const Icon(Icons.notifications_none, color: AppTheme.onSurface),
                    )
                  ],
                ),
              ),
            ),
          ),

          // 2. Search & Filter Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                    decoration: const InputDecoration(
                      hintText: "Search culinary delights...",
                      prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 3. Category Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (categories) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 25),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _CategoryItem(
                          name: "All", 
                          icon: Icons.auto_awesome_mosaic_rounded, 
                          isSelected: selectedCategory == null,
                          onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
                        );
                      }
                      final cat = categories[index - 1];
                      return _CategoryItem(
                        name: cat.name, 
                        imageUrl: cat.imageUrl, 
                        isSelected: selectedCategory == cat.id,
                        onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat.id,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 4. Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Row(
                children: [
                  Text(
                    searchQuery.isNotEmpty ? "SEARCH RESULTS" : "GOURMET SELECTION",
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.tune_rounded, size: 20, color: AppTheme.primary),
                ],
              ),
            ),
          ),

          // 5. Product Grid (Asymmetric & Tonal)
          productsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
            data: (products) {
              var filteredList = products;
              if (searchQuery.isNotEmpty) {
                filteredList = filteredList.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
              }
              if (selectedCategory != null) {
                filteredList = filteredList.where((p) => p.categoryId == selectedCategory).toList();
              }

              if (filteredList.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No delicacies found.")));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 25,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredList[index];
                      return _GourmetProductCard(product: product);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({required this.name, this.imageUrl, this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                ] : [AppTheme.ambientShadow],
              ),
              child: Center(
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(imageUrl!, width: 45, height: 45, fit: BoxFit.cover),
                      )
                    : Icon(icon, color: isSelected ? Colors.white : AppTheme.primary, size: 30),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.primary : AppTheme.onSurface.withOpacity(0.5),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GourmetProductCard extends ConsumerWidget {
  final dynamic product;
  const _GourmetProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [AppTheme.ambientShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceContainerHighest),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final favorites = ref.watch(favoriteProvider);
                        final isFav = favorites.contains(product.id);
                        return GestureDetector(
                          onTap: () {
                            ref.read(favoriteProvider.notifier).toggleFavorite(product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFav ? Colors.red : AppTheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final restaurantAsync = ref.watch(restaurantProvider(product.restaurantId));
                      return restaurantAsync.when(
                        data: (restaurant) => GestureDetector(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => RestaurantDetailsPage(restaurantId: product.restaurantId))
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 14, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  restaurant?.restaurantName ?? "Restaurant",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface.withOpacity(0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading: () => const SizedBox(height: 14),
                        error: (_, __) => const SizedBox(height: 14),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "৳${product.price}",
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Delicacy added to cart"), 
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}