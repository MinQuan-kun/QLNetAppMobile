import 'package:dio/dio.dart';
import 'dart:io';
import '../api_client.dart';
import '../entities/import.dart';

class ImportAPI{
  static final Dio _dio = ApiClient.dio;
  static Future<List<Import>> fetchImport() async {
    try {
      final response = await _dio.get('/api/import/getlist');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((e) => Import.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách: $e');
    }
  }

  static Future<String> importMenu({
    required int staffid,
    required int foodid,
    required int quantum,
  }) async {
    try {
      final response = await _dio.post(
        '/api/import/updatestock',
        data: {
          'staffid': staffid,
          'foodid': foodid,
          'quantum': quantum,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["msg"]?.toString() ?? "Thêm số lượng thành công";
      } else {
        throw Exception("Thất bại: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("API lỗi: ${e.response?.data ?? e.message}");
    }
  }
}