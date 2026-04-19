import 'package:dio/dio.dart';
import '../api_client.dart';
import '../entities/menu.dart';

class MenuAPI {
  static final Dio _dio = ApiClient.dio;

  /// Lấy toàn bộ danh sách menu
  static Future<List<Menu>> fetchMenu() async {
    try {
      final response = await _dio.get('/api/menu/getlist');
      final List<dynamic> jsonList = response.data['data'] ?? response.data;
      return jsonList.map((e) => Menu.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách menu: $e');
    }
  }

  /// Lấy chi tiết món ăn theo ID
  static Future<Menu?> fetchFoodById(int foodId) async {
    try {
      final response = await _dio.post(
        '/api/menu/foodid',
        data: {'foodID': foodId},
      );
      return Menu.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết món: $e');
    }
  }

  /// Cập nhật món ăn
  static Future<bool> updateFood({
    required int foodId,
    required String foodName,
    required int foodPrice,
    required int quantity,
    required int? categoryId,
    required String notes,
    MultipartFile? foodImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'foodID': foodId,
        'foodName': foodName,
        'foodPrice': foodPrice,
        'quantity': quantity,
        'categoryID': categoryId,
        'notes': notes,
        if (foodImage != null) 'foodImage': foodImage,
      });

      await _dio.post('/api/menu/updatefood', data: formData);
      return true;
    } catch (e) {
      throw Exception('Không thể cập nhật món: $e');
    }
  }
}