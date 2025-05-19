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

    // Giảm kích thước ảnh xuống 400x400 nếu lớn hơn
    var resized = image;
    if (image.width > 400 || image.height > 400) {
      resized = img.copyResize(
        image,
        width: 400,
        height: 400,
        interpolation: img.Interpolation.linear,
      );
    }

    // Nén ảnh với chất lượng 60%
    final compressed = img.encodeJpg(resized, quality: 60);
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
        ..fields['quality'] = 'auto:good' // Tự động tối ưu chất lượng tốt
        ..fields['fetch_format'] = 'auto' // Tự động chọn định dạng tốt nhất
        ..fields['transformation'] = 'c_fill,w_200,h_200,g_face,q_auto,f_auto' // Thêm transformation
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
