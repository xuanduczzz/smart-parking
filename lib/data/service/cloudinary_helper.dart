import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CloudinaryHelper {
  static const String cloudName = 'dqnbclzi5'; // Thay bằng Cloud Name của bạn
  static const String apiKey = '767631974229785'; // Thay bằng API Key của bạn
  static const String apiSecret = '01DHSQ0PMmEEmTOmVZ_cMNNn8eg'; // Thay bằng API Secret của bạn

  static Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    // Giảm kích thước ảnh xuống 800x800 nếu lớn hơn
    var resized = image;
    if (image.width > 800 || image.height > 800) {
      resized = img.copyResize(
        image,
        width: 800,
        height: 800,
        interpolation: img.Interpolation.linear,
      );
    }

    // Nén ảnh với chất lượng 85%
    final compressed = img.encodeJpg(resized, quality: 85);
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);
    return tempFile;
  }

  // Hàm tải hình ảnh lên Cloudinary
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Nén ảnh trước khi upload
      final compressedFile = await _compressImage(imageFile);
      
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'avatar_img'
        ..files.add(await http.MultipartFile.fromPath('file', compressedFile.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseData.body);

      // Xóa file tạm sau khi upload
      await compressedFile.delete();

      if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
        return jsonResponse['secure_url'];
      } else {
        print('Error: ${jsonResponse['error'] ?? 'Unknown error'}');
        print('Response: $jsonResponse');
        throw Exception('Failed to upload image to Cloudinary.');
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }
}
