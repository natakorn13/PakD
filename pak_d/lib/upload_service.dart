import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UploadService {
  final String baseUrl = 'http://192.168.1.134:8000/upload';

  Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("📥 Upload success: $data");
        return {
          "status": "success",
          "result": data['result'],
        };
      } else {
        debugPrint("❌ Upload failed: ${response.statusCode}");
        return {
          "status": "error",
          "message": "อัปโหลดไม่สำเร็จ (${response.statusCode})",
        };
      }
    } catch (e) {
      debugPrint("❌ Error uploading image: $e");
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }
}
