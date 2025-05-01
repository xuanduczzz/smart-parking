import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryHelper {
  static const String cloudName = 'dqnbclzi5'; // Thay bằng Cloud Name của bạn
  static const String apiKey = '767631974229785'; // Thay bằng API Key của bạn
  static const String apiSecret = '01DHSQ0PMmEEmTOmVZ_cMNNn8eg'; // Thay bằng API Secret của bạn

  // Hàm tải hình ảnh lên Cloudinary
  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'avatar' // Bạn cần tạo upload preset trên Cloudinary
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();

      // Kiểm tra xem Cloudinary có phản hồi thành công không
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = jsonDecode(responseData.body);

        // Kiểm tra nếu URL được trả về
        if (jsonResponse['secure_url'] != null) {
          return jsonResponse['secure_url'];  // URL của hình ảnh đã được tải lên
        } else {
          // Nếu không có URL, in chi tiết lỗi
          print('Error: ${jsonResponse['error']}');
          throw Exception('Failed to upload image to Cloudinary.');
        }
      } else {
        // Nếu mã phản hồi không phải 200 (thành công), in ra thông tin chi tiết lỗi
        print('Error: Failed to upload image. Status code: ${response.statusCode}');
        throw Exception('Failed to upload image to Cloudinary.');
      }
    } catch (e) {
      // In lỗi nếu xảy ra sự cố kết nối hoặc trong quá trình tải ảnh
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }
}
