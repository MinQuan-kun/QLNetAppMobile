import 'package:dio/dio.dart';
import '../api_client.dart';
import '../entities/service_details.dart';

class ServiceDetailsAPI {
  static final Dio _dio = ApiClient.dio;

  static Future<List<ServiceDetail>> fetchService(int serviceid) async {
    try {
      final response = await _dio.post(
        '/api/servicedetails/getinfo',
        data: {'ServiceID': serviceid},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((e) => ServiceDetail.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Không thể tải ServiceDetails: $e");
    }
  }
}
