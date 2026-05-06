import 'dart:convert';
import 'dart:io';
import 'package:food_delivery_app/core/config.dart';
import 'package:http/http.dart' as http;


class CloudinaryService {
  static Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

    final response = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      throw Exception(
        'Cloudinary upload failed: $responseBody',
      );
    }
  }
}
