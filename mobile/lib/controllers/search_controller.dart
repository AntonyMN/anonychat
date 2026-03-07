import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/user.model.dart';

class UserSearchController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  
  var searchResults = <User>[].obs;
  var isLoading = false.obs;

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final response = await _api.get('/friends/search', queryParameters: {'query': query});
      searchResults.value = (response.data as List)
          .map((u) => User.fromJson(u))
          .toList();
    } catch (e) {
      print('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendFriendRequest(int userId) async {
    try {
      await _api.post('/friends/request', data: {'receiver_id': userId});
      Get.snackbar('Success', 'Friend request sent!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send friend request.');
    }
  }
}
