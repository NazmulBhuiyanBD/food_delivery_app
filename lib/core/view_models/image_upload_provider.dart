import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_delivery_app/services/cloudinary_service.dart';

final imageUploadProvider =
    AsyncNotifierProvider<ImageUploadNotifier, String?>(
  ImageUploadNotifier.new,
);

class ImageUploadNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null; // initial state (no image)
  }

  Future<void> pickAndUpload() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final picker = ImagePicker();
      final picked =
          await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) {
        return null;
      }

      final imageUrl =
          await CloudinaryService.uploadImage(File(picked.path));

      return imageUrl;
    });
  }

  void setImageUrl(String url) {
    state = AsyncData(url);
  }

  void clear() {
    state = const AsyncData(null);
  }
}
