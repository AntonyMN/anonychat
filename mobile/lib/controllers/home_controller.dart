import 'package:get/get.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';
import '../services/api_service.dart';
import '../models/chat.model.dart';
import '../models/user.model.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthController _auth = Get.find<AuthController>();

  var conversations = <Conversation>[].obs;
  var friendRequests = <FriendRequest>[].obs;
  var friends = <User>[].obs;
  var isLoading = false.obs;

  Echo? echo;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to user changes to setup/teardown Echo
    ever(_auth.user, (user) {
      if (user != null) {
        setupEcho();
        fetchDashboard();
      } else {
        echo?.disconnect();
        echo = null;
        conversations.clear();
        friendRequests.clear();
        friends.clear();
      }
    });

    if (_auth.isLoggedIn) {
      setupEcho();
      fetchDashboard();
    }
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/dashboard');
      
      conversations.value = (response.data['conversations'] as List)
          .map((c) => Conversation.fromJson(c))
          .toList();
      
      friendRequests.value = (response.data['friendRequests'] as List)
          .map((f) => FriendRequest.fromJson(f))
          .toList();
      
      friends.value = (response.data['friends'] as List)
          .map((u) => User.fromJson(u))
          .toList();
    } catch (e) {
      print('Error fetching dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setupEcho() {
    final token = _auth.storage.read('auth_token');
    if (token == null) {
      print('Echo Setup: Missing auth token');
      return;
    }

    print('Echo Setup: Initializing with host chat.orellepos.com');

    PusherOptions options = PusherOptions(
      host: 'chat.orellepos.com',
      wsPort: 443,
      wssPort: 443,
      encrypted: true,
      auth: PusherAuth(
        'https://chat.orellepos.com/api/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    // Use the correct Reverb key from .env: 9hnxdlgeeojuxglm2xxv
    PusherClient pusher = PusherClient('9hnxdlgeeojuxglm2xxv', options, autoConnect: true, enableLogging: true);

    echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: pusher,
    );

    echo!.private('notifications.${_auth.user.value!.id}')
        .listen('FriendRequestSent', (e) {
          final req = FriendRequest.fromJson(e['friendRequest']);
          friendRequests.add(req);
          Get.snackbar('New Friend Request', '${req.sender.username} wants to be friends!');
        });
  }

  Future<void> acceptFriendRequest(int requestId) async {
    try {
      await _api.post('/friends/request/$requestId/accept');
      friendRequests.removeWhere((r) => r.id == requestId);
      fetchDashboard(); // Refresh to get active conversation if any
      Get.snackbar('Success', 'Friend request accepted.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request.');
    }
  }

  Future<void> declineFriendRequest(int requestId) async {
    try {
      await _api.post('/friends/request/$requestId/decline');
      friendRequests.removeWhere((r) => r.id == requestId);
      Get.snackbar('Success', 'Friend request declined.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline request.');
    }
  }

  @override
  void onClose() {
    echo?.disconnect();
    super.onClose();
  }
}
