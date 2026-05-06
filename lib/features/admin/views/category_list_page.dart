import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_drawer.dart';
import 'category_form_page.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/models/category_model.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFFFF4F3),
      body: Builder(
        builder: (context) => SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color(0xFFD35400)),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const Spacer(),
                    Text(
                      "NazEats Express",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFD35400),
                      ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage("assets/profile.png"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Categories",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A2C2A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CategoryFormPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD35400),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Curate and manage your global culinary\ntaxonomy with precision.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A2C2A).withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: TextField(
                          style: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFF4A2C2A), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Search categories...",
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF4A2C2A).withOpacity(0.4), fontWeight: FontWeight.w500),
                            icon: const Icon(Icons.search, color: Color(0xFFD35400), size: 22),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      // Dynamic Category List
                      categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Text(
                                  "No categories found. Add your first one!",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return _buildCategoryRow(context, ref, cat);
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                        error: (e, s) => Center(child: Text("Error loading categories: $e")),
                      ),
                      
                      const SizedBox(height: 120), // Bottom nav padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, WidgetRef ref, Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(category.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Collection", // Static for now or can count products
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A2C2A).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF4A2C2A), size: 20),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryFormPage(category: category),
                  ),
                );
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Category?"),
                    content: const Text("All products in this category might be affected."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(categoryControllerProvider.notifier).deleteCategory(category.id);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text("Edit")),
              const PopupMenuItem(value: 'delete', child: Text("Delete")),
            ],
          ),
        ],
      ),
    );
  }
}