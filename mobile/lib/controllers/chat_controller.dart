import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laravel_echo/laravel_echo.dart';
import '../services/api_service.dart';
import '../models/chat.model.dart';
import '../models/user.model.dart';
import 'auth_controller.dart';
import 'home_controller.dart';

class ChatController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthController _auth = Get.find<AuthController>();
  final HomeController _home = Get.find<HomeController>();

  var messages = <Message>[].obs;
  var isLoading = false.obs;
  late Conversation activeConversation;
  
  final ScrollController scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  Echo? get echo => _home.echo;

  @override
  void onInit() {
    super.onInit();
    activeConversation = Get.arguments as Conversation;
    fetchMessages();
    _setupConversationEcho();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/chat/${activeConversation.id}');
      messages.value = (response.data['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
      _scrollToBottom();
      _markAsRead();
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupConversationEcho() {
    if (echo == null) return;

    echo!.private('conversation.${activeConversation.id}')
        .listen('MessageSent', (e) {
          final msg = Message.fromJson(e['message']);
          if (msg.senderId != _auth.user.value!.id) {
            messages.add(msg);
            _scrollToBottom();
            _markAsRead();
          }
        })
        .listen('MessageRead', (e) {
           // Update read status for messages
           // messages.forEach(...)
        });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final content = messageController.text;
    messageController.clear();

    try {
      final response = await _api.post('/chat/${activeConversation.id}/message', data: {
        'content': content,
      });

      final msg = Message.fromJson(response.data);
      messages.add(msg);
      messages.refresh();
      _scrollToBottom();
      _home.fetchDashboard(); // Refresh last message in sidebar
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message.');
    }
  }

  void _markAsRead() async {
    try {
      await _api.post('/chat/${activeConversation.id}/read');
    } catch (e) {
      // Ignore
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    echo?.leave('conversation.${activeConversation.id}');
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
