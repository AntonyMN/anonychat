import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../models/user.model.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final storage = GetStorage();

  var user = Rxn<User>();
  var isLoading = false.obs;

  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    final userData = storage.read('user_data');
    if (userData != null) {
      user.value = User.fromJson(userData);
    }
  }

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await _api.post('/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = User.fromJson(response.data['user']);

      await storage.write('auth_token', token);
      await storage.write('user_data', response.data['user']);
      
      user.value = userData;
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Invalid credentials or connection issue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String username, String password, {String? email}) async {
    isLoading.value = true;
    try {
      final response = await _api.post('/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userData = User.fromJson(response.data['user']);

      await storage.write('auth_token', token);
      await storage.write('user_data', response.data['user']);
      
      user.value = userData;
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Registration failed. Username might be taken.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (e) {
      // Ignore logout error if token is already invalid
    } finally {
      await storage.remove('auth_token');
      await storage.remove('user_data');
      user.value = null;
      Get.offAllNamed('/login');
    }
  }
}
