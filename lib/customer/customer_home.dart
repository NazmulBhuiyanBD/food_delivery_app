import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../providers/cart_provider.dart';
import 'product_details_page.dart';

// State provider for the selected category filter (null = All)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// State provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => "");

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final productsAsync = ref.watch(productListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hello, Foodie 👋", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const Text(
                        "Hungry Today?",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  )
                ],
              ),
            ),

            // 2. Search Bar (NEW)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: "Search for food...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),

            // 3. Promo Banner (Only show if not searching to save space)
            if (searchQuery.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A00), Color(0xFFFFB347)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Get 30% OFF", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text("On your first order", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Text("Use Code: FOOD10", style: TextStyle(color: Color(0xFFFF8A00), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    const Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.fastfood, size: 140, color: Colors.white24),
                    )
                  ],
                ),
              ),

            // 4. Category Selector
            SizedBox(
              height: 100,
              child: categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
                data: (categories) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedCategory == null;
                        return GestureDetector(
                          onTap: () => ref.read(selectedCategoryProvider.notifier).state = null,
                          child: _CategoryPill(name: "All", icon: Icons.grid_view, isSelected: isSelected),
                        );
                      }
                      final cat = categories[index - 1];
                      final isSelected = selectedCategory == cat.id;
                      return GestureDetector(
                        onTap: () => ref.read(selectedCategoryProvider.notifier).state = cat.id,
                        child: _CategoryPill(name: cat.name, imageUrl: cat.imageUrl, isSelected: isSelected),
                      );
                    },
                  );
                },
              ),
            ),

            // 5. Filtered Product List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    searchQuery.isNotEmpty ? "Search Results" : "Popular Now", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  if (searchQuery.isEmpty) // Only show "See All" if not searching
                    TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(color: Color(0xFFFF8A00))))
                ],
              ),
            ),

            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (products) {
                  // 1. Filter by Search Query
                  var filteredList = products;
                  
                  if (searchQuery.isNotEmpty) {
                    filteredList = filteredList.where((p) => 
                      p.name.toLowerCase().contains(searchQuery.toLowerCase())
                    ).toList();
                  }

                  // 2. Filter by Category
                  if (selectedCategory != null) {
                    filteredList = filteredList.where((p) => p.categoryId == selectedCategory).toList();
                  }

                  // 3. Random 6 Logic (Only if NO search and NO category selected)
                  if (searchQuery.isEmpty && selectedCategory == null) {
                    // Create a copy to shuffle so we don't mess up original order in cache
                    var tempList = List.of(filteredList); 
                    tempList.shuffle(); 
                    // Take only first 6
                    filteredList = tempList.take(6).toList();
                  }

                  if (filteredList.isEmpty) {
                    return const Center(child: Text("No items found"));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final product = filteredList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_,__,___) => Container(color: Colors.grey[200]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "৳ ${product.price}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFF8A00)),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            ref.read(cartProvider.notifier).add(product);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Added to Cart"), duration: Duration(milliseconds: 600)),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Category Pills
class _CategoryPill extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final bool isSelected;

  const _CategoryPill({required this.name, this.imageUrl, this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF8A00) : const Color(0xFFF4F4F4),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: const Color(0xFFFF8A00), width: 2) : null,
            ),
            child: Center(
              child: imageUrl != null
                  ? ClipOval(child: Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover))
                  : Icon(icon, color: isSelected ? Colors.white : Colors.black54),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFFF8A00) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}