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
      print('🔵 LOGIN: İstek gönderiliyor...');
      print('🔵 URL: $baseUrl/auth/login');
      print('🔵 Username: $username');

      final response = await _dio.post(
        "/auth/login",
        data: {
          "username": username,
          "password": password,
          "expiresInMins": 30,
        },
      );

      print('🟢 LOGIN: Response alındı - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('🟢 LOGIN: Data başarılı - User ID: ${data['id']}');
        await _saveUserData(data);
        return data;
      }

      print('🔴 LOGIN: Başarısız status code: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('🔴 DIO EXCEPTION:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout) {
        print('🔴 TIMEOUT: Bağlantı zaman aşımına uğradı');
        throw Exception('Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        print('🔴 TIMEOUT: Yanıt alınamadı');
        throw Exception('Sunucudan yanıt alınamadı.');
      }

      if (e.response?.statusCode == 400) {
        print('🔴 LOGIN: 400 - Hatalı kullanıcı adı/şifre');
        return null;
      }

      print('🔴 LOGIN: Beklenmeyen hata');
      rethrow;
    } catch (e) {
      print('🔴 GENEL HATA: $e');
      print('🔴 HATA TİPİ: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      print('🔵 Token kontrol ediliyor...');
      final token = await getToken();

      if (token == null) {
        print('🟡 GET_USER: Token bulunamadı');
        return null;
      }

      print('🔵 GET_USER: Token bulundu, istek gönderiliyor...');
      final response = await _dio.get(
        "/auth/me",
        options: Options(
          headers: {
            "Authorization": "Bearer $token", // access token
          },
        ),
      );

      print('🟢 GET_USER: Response alındı - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('🟢 GET_USER: User ID: ${data['id']}');
        await _saveUserData(data);
        return data;
      }

      print('🔴 GET_USER: Başarısız status code: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      print('🔴 GET_USER DIO EXCEPTION: ${e.type} - ${e.message}');

      if (e.response?.statusCode == 401) {
        print('🔴 GET_USER: 401 - Token geçersiz');
        return null;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        print('🔴 GET_USER: Timeout hatası');
        return null;
      }

      rethrow;
    } catch (e) {
      print('🔴 GET_USER GENEL HATA: $e');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    try {
      print('🔵 REFRESH: Token yenileniyor...');
      final box = await _getAuthBox();
      final refreshTokenValue = box.get("refreshToken");

      if (refreshTokenValue == null) {
        print('🔴 REFRESH: Refresh token bulunamadı');
        return false;
      }

      final response = await _dio.post(
        "/auth/refresh",
        data: {
          "refreshToken": refreshTokenValue,
          "expiresInMins": 30,
        },
      );

      print('🟢 REFRESH: Response alındı - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        await box.put("accessToken", data["accessToken"]);
        await box.put("refreshToken", data["refreshToken"]);
        print('🟢 REFRESH: Token başarıyla yenilendi');
        return true;
      }

      print('🔴 REFRESH: Başarısız status code: ${response.statusCode}');
      return false;
    } catch (e) {
      print('🔴 REFRESH HATA: $e');
      return false;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    try {
      print('💾 SAVE: Veri kaydediliyor...');
      final box = await _getAuthBox();

      if (data.containsKey("accessToken")) {
        await box.put("accessToken", data["accessToken"]);
        print('💾 SAVE: accessToken kaydedildi');
      }
      if (data.containsKey("refreshToken")) {
        await box.put("refreshToken", data["refreshToken"]);
        print('💾 SAVE: refreshToken kaydedildi');
      }
      if (data.containsKey("id")) {
        await box.put("userId", data["id"]);
        print('💾 SAVE: userId kaydedildi: ${data["id"]}');
      }

      print('🟢 SAVE: Tüm veriler başarıyla kaydedildi');
    } catch (e) {
      print('🔴 SAVE HATA: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      print('🔵 LOGOUT: Çıkış yapılıyor...');
      final box = await _getAuthBox();
      await box.clear();
      print('🟢 LOGOUT: Başarılı');
    } catch (e) {
      print('🔴 LOGOUT HATA: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final box = await _getAuthBox();
      final token = box.get("accessToken");
      print('🔑 TOKEN: ${token != null ? "Var" : "Yok"}');
      return token;
    } catch (e) {
      print('🔴 GET_TOKEN HATA: $e');
      return null;
    }
  }

  Future<int?> getUserIdFromStorage() async {
    try {
      final box = await _getAuthBox();
      final userId = box.get("userId");
      print('👤 USER_ID: ${userId ?? "Yok"}');
      return userId;
    } catch (e) {
      print('🔴 GET_USER_ID HATA: $e');
      return null;
    }
  }
}