import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import 'package:dio/dio.dart' as dio;

class ProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthController _auth = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  var profileImageUrl = ''.obs;
  var isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    profileImageUrl.value = _auth.user.value?.profileImageUrl ?? '';
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await uploadImage(File(image.path));
    }
  }

  Future<void> uploadImage(File file) async {
    isUpdating.value = true;
    try {
      String fileName = file.path.split('/').last;
      dio.FormData formData = dio.FormData.fromMap({
        'profile_image': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _api.post('/profile/update', data: formData);
      if (response.statusCode == 200) {
        final updatedUser = response.data['user'];
        _auth.updateUser(updatedUser);
        profileImageUrl.value = _auth.user.value?.profileImageUrl ?? '';
        Get.snackbar('Success', 'Profile image updated!');
      }
    } catch (e) {
      print('Profile upload error: $e');
      Get.snackbar('Error', 'Failed to upload profile image.');
    } finally {
      isUpdating.value = false;
    }
  }
}
