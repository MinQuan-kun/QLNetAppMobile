import 'package:dio/dio.dart';
import '../api_client.dart';
import '../entities/service.dart';

class ServiceAPI {
  static final Dio _dio = ApiClient.dio;

  /// Lấy toàn bộ danh sách service
  static Future<List<Service>> fetchService() async {
    try {
      final response = await _dio.get('/api/service/getlist');
      final List<dynamic> jsonList = response.data['data'] ?? response.data;
      return jsonList.map((e) => Service.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách Service: $e');
    }
  }

  /// Bắt đầu dịch vụ (mở máy / gọi món ăn)
  static Future<Map<String, dynamic>> startService({
    required String phone,
    int? userId,
    String? guestName,
    int? staffId,
    required int computerId,
    int? foodId,
    int? price,
    int quantity = 1,
  }) async {
    try {
      final data = {
        "phone": phone,
        if (userId != null) "UserID": userId,
        if (guestName != null) "GuestName": guestName,
        if (staffId != null) "StaffId": staffId,
        "Computerid": computerId,
        if (foodId != null) "FoodID": foodId,
        "Price": price ?? 0,
        "quantity": quantity,
      };

      final response = await _dio.post('/api/service/StartService', data: data);
      return response.data;
    } catch (e) {
      throw Exception("Không thể bắt đầu service: $e");
    }
  }

  /// Dừng dịch vụ (tính tiền máy + đồ ăn)
  static Future<Map<String, dynamic>> stopService({
    required int computerId,
  }) async {
    try {
      final data = {
        "Computerid": computerId,
      };
      final response = await _dio.post('/api/service/StopService', data: data);
      return response.data;
    } catch (e) {
      throw Exception("Không thể dừng service: $e");
    }
  }

  /// Nạp tiền
  static Future<String> rechargeUser({
    required int userId,
    required int amount,
    required int staffId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/service/Deposit',
        data: {
          'UserID': userId,
          'StaffID': staffId,
          'Amount': amount,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["msg"]?.toString() ?? "Nạp tiền thành công";
      } else {
        throw Exception("Thất bại: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("API lỗi: ${e.response?.data ?? e.message}");
    }
  }
}