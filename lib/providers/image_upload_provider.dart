import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

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

  void clear() {
    state = const AsyncData(null);
  }
}
