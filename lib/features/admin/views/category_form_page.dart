import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery_app/models/category_model.dart';
import 'package:food_delivery_app/features/admin/view_models/category_provider.dart';
import 'package:food_delivery_app/core/view_models/image_upload_provider.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final Category? category;
  const CategoryFormPage({super.key, this.category});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameCtrl.text = widget.category!.name;
    }
    // Clear image state when opening form
    Future.microtask(() => ref.read(imageUploadProvider.notifier).clear());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);
    final isEditing = widget.category != null;

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
          isEditing ? "Edit Category" : "New Category",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4A2C2A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Visual Identity",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 15),
            
            // Image Picker Area
            GestureDetector(
              onTap: () => ref.read(imageUploadProvider.notifier).pickAndUpload(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFD35400).withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: imageState.when(
                    data: (imageUrl) {
                      final effectiveUrl = imageUrl ?? widget.category?.imageUrl;
                      if (effectiveUrl != null) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(effectiveUrl, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withOpacity(0.2),
                              child: const Center(
                                child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40),
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: const Color(0xFFD35400).withOpacity(0.5), size: 50),
                          const SizedBox(height: 12),
                          Text(
                            "Upload Cover Image",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A2C2A).withOpacity(0.4),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD35400))),
                    error: (e, s) => Center(child: Text("Error: $e")),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Text(
              "Taxonomy Details",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 15),
            
            // Name Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: nameCtrl,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF4A2C2A)),
                decoration: InputDecoration(
                  hintText: "e.g. Italian Cuisine",
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final imageUrl = ref.read(imageUploadProvider).value ?? widget.category?.imageUrl;
                  final name = nameCtrl.text.trim();
                  
                  if (name.isEmpty || imageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please provide name and image")),
                    );
                    return;
                  }
                  
                  final controller = ref.read(categoryControllerProvider.notifier);
                  
                  try {
                    if (isEditing) {
                      await controller.updateCategory(widget.category!.id, name, imageUrl);
                    } else {
                      await controller.addCategory(name, imageUrl);
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD35400),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleType(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? "Update Category" : "Publish Category",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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

class RoundedRectangleType extends OutlinedBorder {
  final BorderRadius borderRadius;
  const RoundedRectangleType({required this.borderRadius});

  @override
  OutlinedBorder copyWith({BorderSide? side, BorderRadius? borderRadius}) {
    return RoundedRectangleType(borderRadius: borderRadius ?? this.borderRadius);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final Paint paint = Paint()
      ..color = side.color
      ..strokeWidth = side.width
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return RoundedRectangleType(borderRadius: borderRadius * t);
  }
}
