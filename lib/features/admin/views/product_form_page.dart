import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/models/product_model.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/features/admin/view_models/product_provider.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart';
import 'package:food_delivery_app/models/category_model.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  
  String? selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameCtrl.text = widget.product!.name;
      descCtrl.text = widget.product!.description;
      priceCtrl.text = widget.product!.price.toString();
      selectedCategoryId = widget.product!.categoryId;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageUploadProvider.notifier).setImageUrl(widget.product!.imageUrl);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(imageUploadProvider.notifier).clear();
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final imageUrl = ref.read(imageUploadProvider).value;
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an image")));
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final controller = ref.read(productControllerProvider.notifier);
      if (widget.product == null) {
        await controller.addProduct(
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
          price: double.parse(priceCtrl.text.trim()),
          imageUrl: imageUrl,
          categoryId: selectedCategoryId!,
          restaurantId: '', // Admins might need to select a restaurant eventually
        );
      } else {
        await controller.updateProduct(
          id: widget.product!.id,
          name: nameCtrl.text.trim(),
          description: descCtrl.text.trim(),
          price: double.parse(priceCtrl.text.trim()),
          imageUrl: imageUrl,
          categoryId: selectedCategoryId!,
          restaurantId: widget.product!.restaurantId,
          isActive: widget.product!.isActive,
          isChefSelection: widget.product!.isChefSelection,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A2C2A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product == null ? "New Product" : "Edit Product",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A2C2A),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildSectionTitle("Visual Identity"),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFFFE8E5), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: imageState.when(
                      data: (url) => url != null 
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(url, fit: BoxFit.cover),
                                Container(color: Colors.black12, child: const Icon(Icons.edit, color: Colors.white, size: 30)),
                              ],
                            )
                          : const Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFFD35400))),
                      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                      error: (e, _) => Center(child: Text("Error: $e")),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),
              _buildSectionTitle("Product Details"),
              const SizedBox(height: 20),

              _buildLabel("PRODUCT NAME"),
              _buildTextField(controller: nameCtrl, hint: "e.g. Wagyu Beef Steak"),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("PRICE (\$)"),
                        _buildTextField(controller: priceCtrl, hint: "0.00", keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("CATEGORY"),
                        _buildCategoryDropdown(categoriesAsync),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel("DESCRIPTION"),
              _buildTextField(controller: descCtrl, hint: "Enter description...", maxLines: 4),

              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (_isLoading || imageState.isLoading) ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          widget.product == null ? "Publish Product" : "Update Product",
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF4A2C2A).withOpacity(0.5), letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildCategoryDropdown(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      data: (list) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategoryId,
            hint: const Text("Select"),
            isExpanded: true,
            items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => selectedCategoryId = v),
          ),
        ),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text("Error"),
    );
  }
}
