import 'package:dio/dio.dart';
import '../api_client.dart';
import '../entities/computer.dart';

class ComputerAPI {
  static final Dio _dio = ApiClient.dio;

  /// Lấy danh sách máy
  static Future<List<Computer>> fetchComputers() async {
    try {
      final response = await _dio.get('/api/computers/getlist');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((e) => Computer.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi server: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách máy: $e');
    }
  }

  /// Cập nhật User đang dùng máy
  static Future<void> updateComputerUser(int idComputer, int idUser) async {
    try {
      await _dio.post(
        '/api/computers/updateUser',
        data: {'computerId': idComputer, 'userId': idUser},
      );
    } catch (e) {
      throw Exception("Không thể cập nhật máy: $e");
    }
  }

  /// Lấy thông tin máy theo ID
  static Future<Computer?> loadComputerById(int idComputer) async {
    try {
      final response = await _dio.post(
        '/api/computers/getbyid',
        data: {'ComputerID': idComputer},
      );
      return Computer.fromJson(response.data);
    } catch (e) {
      throw Exception("Không thể tải thông tin máy: $e");
    }
  }

  /// Mở máy tính theo ID
  static Future<void> openComputer(int idComputer) async {
    try {
      await _dio.post('/api/computers/open', data: {'ComputerID': idComputer});
    } catch (e) {
      throw Exception("Không thể mở máy: $e");
    }
  }

  /// Đóng máy theo ID
  static Future<void> closeComputer(int idComputer) async {
    try {
      await _dio.post('/api/computers/close', data: {'ComputerID': idComputer});
    } catch (e) {
      throw Exception("Không thể đóng máy: $e");
    }
  }

  /// Sử dụng máy
  static Future<void> usingComputer(
    int idComputer,
    int? userId,
    String phone,
    String? guestname,
  ) async {
    try {
      final data = {
        'ComputerId': idComputer,
        'phone': phone,
        if (userId != null && userId > 0)
          'UserId': userId
        else
          'guestname': (guestname?.isEmpty ?? true) ? "Khách" : guestname,
      };

      await _dio.post('/api/computers/usingcomputer', data: data);
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? "Không thể sử dụng máy.";
      throw Exception(msg);
    } catch (e) {
      throw Exception("Lỗi: $e");
    }
  }

  // static Future<void> stopUsingComputer(
  //   int idComputer,
  //   int? userId,
  //   String? name,
  //   String phone,
  // ) async {
  //   try {
  //     await _dio.post(
  //       '/api/computers/stopusing',
  //       data: {
  //         'ComputerId': idComputer,
  //         'UserId': userId,
  //         'guestname': name,
  //         'phone': phone,
  //       },
  //     );
  //   } catch (e) {
  //     throw Exception("Không thể dừng sử dụng máy: $e");
  //   }
  // }

  /// Mở toàn bộ máy
  static Future<void> openAllComputers() async{
    try{
      await _dio.get(
        '/api/computers/openall'
      );
    }
    catch(e)
    {
      throw Exception("Không thể mở máy: $e");
    }
  }

  /// Đóng toàn bộ máy
  static Future<void> closeAllComputers() async{
    try{
      await _dio.get(
          '/api/computers/closeall'
      );
    }
    catch(e)
    {
      throw Exception("Không thể mở máy: $e");
    }
  }
}
