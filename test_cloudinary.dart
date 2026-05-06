import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print("Starting upload test...");
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/dbnu2or6y/image/upload');
  
  // Create a dummy image
  final dummyFile = File('dummy.txt');
  await dummyFile.writeAsString('dummy content');

  try {
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'food_delivery'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          dummyFile.path,
        ),
      );

    print("Sending request...");
    final response = await request.send().timeout(Duration(seconds: 10));
    final responseBody = await response.stream.bytesToString();
    
    print("Status: ${response.statusCode}");
    print("Body: $responseBody");
  } catch (e) {
    print("Error: $e");
  } finally {
    if (await dummyFile.exists()) {
      await dummyFile.delete();
    }
  }
}
