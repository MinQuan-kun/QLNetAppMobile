import 'package:dio/dio.dart';
import '../api_client.dart';
import '../entities/category.dart';

class CategoryAPI {
  static final Dio _dio = ApiClient.dio;

  ///Lấy danh sách thể loại
  static Future<List<Category>> fetchCategory() async {
    try {
      final response = await _dio.get('/api/category/getlist');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách thể loại: $e');
    }
  }
}
