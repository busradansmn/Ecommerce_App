import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

//uygulamanın dış dünya ile iletişimini sağlar
//istekleri gönderir ve token'ları Hive de saklar

class AuthRepository {
  static const String baseUrl = "https://dummyjson.com";
  static const String boxName = "authBox";

  Future<Box> _getAuthBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }


  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {
          "username": username,
          "password": password,
          "expiresInMins": 30,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        await _saveUserData(data);
        return data;
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Sunucudan yanıt alınamadı.');
      }

      if (e.response?.statusCode == 400) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();

      if (token == null) {
        return null;
      }
      final response = await _dio.get(
        "/auth/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token", // access token
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveUserData(data);
        return data;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return null;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return null;
      }

      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final box = await _getAuthBox();
      final refreshTokenValue = box.get("refreshToken");

      if (refreshTokenValue == null) {
        return false;
      }

      final response = await _dio.post(
        "/auth/refresh",
        data: {
          "refreshToken": refreshTokenValue,
          "expiresInMins": 30,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await box.put("accessToken", data["accessToken"]);
        await box.put("refreshToken", data["refreshToken"]);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    try {
      final box = await _getAuthBox();

      if (data.containsKey("accessToken")) {
        await box.put("accessToken", data["accessToken"]);
      }
      if (data.containsKey("refreshToken")) {
        await box.put("refreshToken", data["refreshToken"]);
      }
      if (data.containsKey("id")) {
        await box.put("userId", data["id"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final box = await _getAuthBox();
      await box.clear();
    } catch (e) {
    }
  }

  Future<String?> getToken() async {
    try {
      final box = await _getAuthBox();
      final token = box.get("accessToken");
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<int?> getUserIdFromStorage() async {
    try {
      final box = await _getAuthBox();
      final userId = box.get("userId");
      return userId;
    } catch (e) {
      return null;
    }
  }
}