import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late Dio dio;
  final storage = GetStorage();

  // Change this to your server IP or 10.0.2.2 for Android Emulator
  static const String baseUrl = 'http://192.168.100.122:8000/api'; 

  Future<ApiService> init() async {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = storage.read('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle unauthorized (session expired)
          storage.remove('auth_token');
          // Get.offAllNamed('/login'); // We will define this route later
        }
        return handler.next(e);
      },
    ));

    return this;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
