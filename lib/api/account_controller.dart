import 'package:dio/dio.dart';
import 'dart:io';
import '../api_client.dart';
import '../entities/user_account.dart';
import '../token_service.dart';

class AccountAPI {
  static final Dio _dio = ApiClient.dio;

  /// Đăng nhập: trả về token
  static Future<Map<String, dynamic>?> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {"UserName": username, "UserPassword": password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return {
          "token": response.data["token"],
          // "userId": response.data["userId"],
        };
      } else {
        throw Exception("Đăng nhập thất bại");
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data["msg"] ?? "Đăng nhập thất bại";
        throw msg;
      }
    } catch (e) {
      throw Exception("Lỗi không xác định: $e");
    }
    return null;
  }

  /// Đăng xuất:
  static Future<bool> logout() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;
      final response = await _dio.post(
        '/api/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await StorageService.removeToken();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Lấy thông tin tài khoản đăng nhập
  static Future<Accounts?> infor() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;
      final response = await _dio.post(
        '/api/useraccount/userinfo',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Accounts.fromJson(response.data);
      }
    } catch (e) {
      throw Exception("Không thể tải account: $e");
    }
    return null;
  }

  /// Lấy danh sách account theo role
  static Future<List<Accounts>> fetchByroleAccounts(int userId) async {
    try {
      final response = await _dio.post(
        '/api/useraccount/getlistbyrole',
        data: {'userid': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data['data'];
        return jsonList.map((e) => Accounts.fromJson(e)).toList();
      }
      throw Exception('Lỗi server: ${response.statusMessage}');
    } catch (e) {
      throw Exception('Không thể tải danh sách người dùng: $e');
    }
  }

  /// Lấy thông tin account theo ID
  static Future<Accounts?> loadAccountById(int userId) async {
    try {
      final response = await _dio.post(
        '/api/useraccount/searchbyid',
        data: {'userid': userId},
      );

      if (response.statusCode == 200) {
        return Accounts.fromJson(response.data);
      }
    } catch (e) {
      throw Exception("Không thể tải account: $e");
    }
    return null;
  }

  static Future<Accounts?> loadAccountByPhone(String phone) async {
    try {
      final response = await _dio.post(
        '/api/useraccount/searchbyphone',
        data: {'phone': phone},
      );
      if (response.statusCode == 200) {
        return Accounts.fromJson(response.data);
      }
    } catch (e) {
      throw Exception("Không thể tải account: $e");
    }
    return null;
  }

  /// Reset mật khẩu
  static Future<Map<String, String>> resetUserPassword({
    required int idUser,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        '/api/useraccount/resetpassword',
        data: {"password": "", "id": idUser, "username": username},
      );

      if (response.statusCode == 200) {
        return {
          "msg": response.data["msg"] ?? "Đặt lại mật khẩu thành công",
          "newPassword": response.data["newPassword"] ?? "",
        };
      } else {
        throw Exception("Lỗi server: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Lỗi khi reset mật khẩu: $e");
    }
  }

  /// Tạo tài khoản mới
  static Future<String> createAccount({
    required String username,
    required String password,
    required String phone,
    required String gender,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        "/api/users/register",
        data: {
          "Username": username,
          "Password": password,
          "Phone": phone,
          "Gender": gender,
          "Role": role,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["msg"] ?? "Đăng ký thành công!";
      } else {
        return response.data["msg"] ?? "Đăng ký thất bại!";
      }
    } on DioException catch (e) {
      // Trả về lỗi chi tiết server gửi xuống
      if (e.response != null && e.response?.data != null) {
        return e.response?.data["msg"] ?? "Lỗi API";
      }
      return "Lỗi kết nối: ${e.message}";
    }
  }

  /// Upload / cập nhật profile
  static Future<bool> uploadProfile({
    required int userId,
    File? imgAvatar,
    File? imgBackground,
    String? signature,
    String? nickname,
    String? gender,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'userId': userId,
        if (signature != null && signature.trim().isNotEmpty)
          'signature': signature.trim(),
        if (nickname != null && nickname.trim().isNotEmpty)
          'displayname': nickname.trim(),
        if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
      };

      if (imgAvatar != null) {
        final avatarExt = imgAvatar.path.split('.').last;
        dataMap['avatar'] = await MultipartFile.fromFile(
          imgAvatar.path,
          filename: 'avatar.$avatarExt',
        );
      }

      if (imgBackground != null) {
        final bgExt = imgBackground.path.split('.').last;
        dataMap['background'] = await MultipartFile.fromFile(
          imgBackground.path,
          filename: 'background.$bgExt',
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _dio.post(
        '/api/users/updateProfile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Không thể upload profile: $e");
    }
  }

  /// Đổi tiền trong tài khoản ra giờ chơi
  static Future<String> deposittimeusing({
    required int userid,
    required int money,
  }) async {
    try {
      final response = await _dio.post(
        "/api/users/converttime",
        data: {"userid": userid, "money": money},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["msg"]?.toString() ?? "Nạp thành công";
      } else {
        throw Exception("Thất bại: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("API lỗi: ${e.response?.data ?? e.message}");
    }
  }

  static Future<String> decreaseTimeUser(int userId, {int minutes = 1}) async {
    try {
      final response = await _dio.post(
        '/api/users/decreasetime',
        data: {'userId': userId, 'minutes': minutes},
      );

      if (response.statusCode == 200) {
        return response.data["msg"]?.toString() ?? "Đã trừ thời gian";
      } else {
        throw Exception("Thất bại: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("API lỗi: ${e.response?.data ?? e.message}");
    }
  }

  /// Xóa tài khoản
  static Future<String> deleteuser({required int userId}) async {
    try {
      final response = await _dio.post(
        '/api/users/deleteuser',
        data: {'userId': userId},
      );
      if (response.statusCode == 200) {
        return response.data["msg"]?.toString() ?? "Đã xóa thành công";
      } else {
        throw Exception("Thất bại: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception("API lỗi: ${e.response?.data ?? e.message}");
    }
  }
}
