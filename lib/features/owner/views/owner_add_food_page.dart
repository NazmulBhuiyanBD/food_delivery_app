import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/features/admin/view_models/product_provider.dart';
import 'package:food_delivery_app/models/category_model.dart';
import 'package:food_delivery_app/services/cloudinary_service.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart';

import 'package:food_delivery_app/models/product_model.dart';

class OwnerAddFoodPage extends ConsumerStatefulWidget {
  final Product? initialProduct;
  const OwnerAddFoodPage({super.key, this.initialProduct});

  @override
  ConsumerState<OwnerAddFoodPage> createState() => _OwnerAddFoodPageState();
}

class _OwnerAddFoodPageState extends ConsumerState<OwnerAddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  bool _isChefsSelection = false;
  String? _selectedCategoryId;
  bool _isLoading = false;
  int _descLength = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      final p = widget.initialProduct!;
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _descController.text = p.description;
      _isChefsSelection = p.isChefSelection;
      _selectedCategoryId = p.categoryId;
      _descLength = p.description.length;
      
      // Seed the image provider if editing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageUploadProvider.notifier).setImageUrl(p.imageUrl);
      });
    } else {
      // Clear image for new entry
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageUploadProvider.notifier).clear();
      });
    }
    
    _descController.addListener(() {
      setState(() {
        _descLength = _descController.text.length;
      });
    });
  }

  Future<void> _pickImage() async {
    await ref.read(imageUploadProvider.notifier).pickAndUpload();
  }

  Future<void> _saveItem() async {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    final imageUrl = ref.read(imageUploadProvider).value;
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an image")));
      return;
    }

    final user = ref.read(authProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not authenticated")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.initialProduct != null) {
        await ref.read(productControllerProvider.notifier).updateProduct(
          id: widget.initialProduct!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
          restaurantId: user.uid,
          isActive: widget.initialProduct!.isActive,
          isChefSelection: _isChefsSelection,
        );
      } else {
        await ref.read(productControllerProvider.notifier).addProduct(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl,
          categoryId: _selectedCategoryId!,
          restaurantId: user.uid,
          isActive: true,
          isChefSelection: _isChefsSelection,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dish added successfully")));
        ref.read(imageUploadProvider.notifier).clear(); // Clear for next use
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error saving item: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Dish?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(productControllerProvider.notifier).deleteProduct(widget.initialProduct!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dish deleted")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final imageState = ref.watch(imageUploadProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFD35400)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.initialProduct != null ? "Refine Masterpiece" : "Curate New Dish",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A2C2A),
                          ),
                        ),
                        Text(
                          widget.initialProduct != null 
                              ? "Updating the details of your culinary creation."
                              : "Add a new culinary masterpiece to the menu.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4A2C2A).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.initialProduct != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: _deleteItem,
                    ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upload Block
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E5).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: imageState.when(
                            data: (imageUrl) {
                              if (imageUrl != null) {
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: Color(0xFFD35400), size: 20),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFD35400), size: 30),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Upload Masterpiece Imagery",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF4A2C2A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "High-resolution photography required. This\nimage will represent the dish in the gallery.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD1CC),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Choose File",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFD35400),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: CircularProgressIndicator(color: Color(0xFFD35400)),
                              ),
                            ),
                            error: (e, s) => Center(
                              child: Text(
                                "Error: $e",
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Dish Details Section
                      _buildSectionTitle("Dish Details"),
                      const SizedBox(height: 20),
                      _buildInputLabel("ITEM NAME"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: "e.g. Truffle Infused Risotto",
                        validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("PRICE (\$)"),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _priceController,
                                  hint: "0.00", 
                                  prefix: "\$",
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return "Required";
                                    if (double.tryParse(val) == null) return "Invalid";
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel("CATEGORY"),
                                const SizedBox(height: 8),
                                _buildCategoryDropdown(categoriesAsync),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Culinary Narrative Section
                      _buildSectionTitle("Culinary Narrative"),
                      const SizedBox(height: 20),
                      _buildInputLabel("DESCRIPTION"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descController,
                        hint: "Describe the flavors, ingredients,\nand inspiration behind this dish...",
                        maxLines: 4,
                        validator: (val) => val == null || val.isEmpty ? "Description is required" : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "$_descLength/200 characters",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A2C2A).withOpacity(0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Checkbox
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isChefsSelection = !_isChefsSelection),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isChefsSelection ? const Color(0xFFD35400) : Colors.grey.shade400,
                                  width: 2,
                                ),
                                color: _isChefsSelection ? const Color(0xFFD35400) : Colors.transparent,
                              ),
                              child: _isChefsSelection
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Mark as \"Chef's Selection\" (Featured)",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A2C2A).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD35400),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: (_isLoading || imageState.isLoading) ? null : _saveItem,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD35400).withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                  children: (_isLoading || imageState.isLoading)
                                      ? [const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))]
                                      : [
                                          Text(
                                            "Save Item",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4A2C2A),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF4A2C2A).withOpacity(0.5),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
    String? prefix,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4A2C2A),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.3), fontSize: 14),
        prefixIcon: prefix != null 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Text(prefix, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD35400))),
            ) 
          : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF4A2C2A).withOpacity(0.3), size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildCategoryDropdown(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildTextField(
            hint: "No categories available",
            suffixIcon: Icons.warning_amber_rounded,
          );
        }
        
        // Ensure _selectedCategoryId is valid
        if (_selectedCategoryId != null && 
            !categories.any((cat) => cat.id == _selectedCategoryId)) {
          // If the selected category is no longer in the list, reset it
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedCategoryId = null;
            });
          });
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat.id,
              child: Text(
                cat.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A2C2A),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategoryId = val;
            });
          },
          validator: (val) => val == null ? "Required" : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF4A2C2A).withOpacity(0.3), size: 20),
          decoration: InputDecoration(
            hintText: "Select Category",
            hintStyle: TextStyle(color: const Color(0xFF4A2C2A).withOpacity(0.3), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFFFE8E5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
        );
      },
      loading: () => _buildTextField(
        hint: "Loading categories...",
        suffixIcon: Icons.hourglass_empty,
      ),
      error: (err, stack) => _buildTextField(
        hint: "Error loading categories",
        suffixIcon: Icons.error_outline,
      ),
    );
  }
}

