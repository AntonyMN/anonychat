import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/search_controller.dart';
import '../../models/chat.model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('AnonyChat', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Boxicons.bx_search, color: Colors.cyan),
          ),
          IconButton(
            onPressed: () => authController.logout(),
            icon: const Icon(Boxicons.bx_log_out, color: Colors.pinkAccent),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: homeController.fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Friend Requests'),
              Obx(() => homeController.friendRequests.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text('No pending requests.', style: TextStyle(color: Color(0xFF64748B))),
                    )
                  : SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: homeController.friendRequests.length,
                        itemBuilder: (context, index) {
                          final req = homeController.friendRequests[index];
                          return _buildRequestCard(req, homeController);
                        },
                      ),
                    )),
              _buildSectionTitle('Active Chats'),
              Obx(() => homeController.conversations.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        children: [
                          Icon(Boxicons.bx_chat, size: 64, color: Colors.white10),
                          SizedBox(height: 16),
                          Text('No conversations yet.', style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeController.conversations.length,
                      itemBuilder: (context, index) {
                        final conv = homeController.conversations[index];
                        return _buildChatTile(conv);
                      },
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchDialog(context),
        backgroundColor: Colors.cyan,
        child: const Icon(Boxicons.bx_plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildRequestCard(FriendRequest req, HomeController controller) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.cyan.withOpacity(0.1),
            child: Text(req.sender.username[0].toUpperCase(), style: const TextStyle(color: Colors.cyan)),
          ),
          const SizedBox(height: 8),
          Text(req.sender.username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => controller.acceptFriendRequest(req.id),
                icon: const Icon(Boxicons.bx_check, color: Colors.greenAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.declineFriendRequest(req.id),
                icon: const Icon(Boxicons.bx_x, color: Colors.pinkAccent, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChatTile(Conversation conv) {
    final otherUser = conv.users[0]; // Assuming private chat
    final lastMsg = conv.lastMessage;
    
    return ListTile(
      onTap: () => Get.toNamed('/chat', arguments: conv),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            otherUser.profileImageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(otherUser.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(
        lastMsg?.content ?? 'Start a conversation...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      ),
      trailing: Text(
        lastMsg != null ? DateFormat.jm().format(lastMsg.createdAt) : '',
        style: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = Get.put(UserSearchController());
    
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Search User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type username...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Boxicons.bx_search, color: Colors.cyan),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onChanged: (value) => searchController.searchUsers(value),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Obx(() => searchController.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchController.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchController.searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white12,
                              child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(user.username, style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              onPressed: () => searchController.sendFriendRequest(user.id),
                              icon: const Icon(Boxicons.bx_user_plus, color: Colors.cyan),
                            ),
                          );
                        },
                      )),
              ),
            ],
          ),
        ),
      )
    );
  }
}
