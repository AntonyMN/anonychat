import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/search_controller.dart';
import '../../models/chat.model.dart';
import '../../widgets/demo_banner.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Boxicons.bxs_chat, color: Color(0xFF06B6D4), size: 18),
            ),
            const SizedBox(width: 10),
            Text('AnonyChat', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Boxicons.bx_search, color: Color(0xFF64748B)),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Get.toNamed('/profile');
              } else if (value == 'logout') {
                authController.logout();
              }
            },
            icon: const Icon(Boxicons.bx_dots_vertical_rounded, color: Color(0xFF64748B)),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Boxicons.bx_user, size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Text('Profile', style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Boxicons.bx_log_out, size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 10),
                    Text('Logout', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: homeController.fetchDashboard,
        color: const Color(0xFF06B6D4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Demo Banner
              Obx(() => homeController.isDemoMode.value
                  ? DemoBanner(nextResetAt: homeController.nextResetAt.value)
                  : const SizedBox.shrink()),
              
              // Friend Requests
              Obx(() => homeController.friendRequests.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Friend Requests'),
                        SizedBox(
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
                        ),
                      ],
                    )),
              _buildSectionTitle('Messages'),
              Obx(() => homeController.conversations.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Boxicons.bx_chat, size: 48, color: Color(0xFFCBD5E1)),
                          ),
                          const SizedBox(height: 16),
                          Text('No conversations yet.',
                              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 15)),
                          const SizedBox(height: 8),
                          Text('Search for friends to start chatting!',
                              style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeController.conversations.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        backgroundColor: const Color(0xFF06B6D4),
        elevation: 2,
        child: const Icon(Boxicons.bx_plus, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildRequestCard(FriendRequest req, HomeController controller) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF06B6D4).withOpacity(0.1),
            child: Text(
              req.sender.username[0].toUpperCase(),
              style: GoogleFonts.inter(color: const Color(0xFF06B6D4), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            req.sender.username,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton(
                icon: Boxicons.bx_check,
                color: const Color(0xFF10B981),
                onTap: () => controller.acceptFriendRequest(req.id),
              ),
              const SizedBox(width: 8),
              _actionButton(
                icon: Boxicons.bx_x,
                color: const Color(0xFFEF4444),
                onTap: () => controller.declineFriendRequest(req.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildChatTile(Conversation conv) {
    // In our app, conversations are between 2 users. We want the one that isn't the current user.
    final auth = Get.find<AuthController>();
    final otherUser = conv.users.firstWhere((u) => u.id != auth.user.value?.id, orElse: () => conv.users[0]);
    final lastMsg = conv.lastMessage;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed('/chat', arguments: conv),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE0F2FE),
                backgroundImage: otherUser.profileImageUrl.isNotEmpty ? NetworkImage(otherUser.profileImageUrl) : null,
                onBackgroundImageError: (_, __) {},
                child: Text(
                  otherUser.username[0].toUpperCase(),
                  style: GoogleFonts.inter(color: const Color(0xFF06B6D4), fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser.username,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMsg?.content ?? 'Start a conversation...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: lastMsg != null ? const Color(0xFF64748B) : const Color(0xFF94A3B8), 
                        fontSize: 14,
                        fontStyle: lastMsg != null ? FontStyle.normal : FontStyle.italic
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (lastMsg != null)
                Text(
                  DateFormat.jm().format(lastMsg.createdAt),
                  style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = Get.put(UserSearchController());

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find Users',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                style: GoogleFonts.inter(color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Search username...',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Boxicons.bx_search, color: Color(0xFF94A3B8), size: 20),
                ),
                onChanged: (value) => searchController.searchUsers(value),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Obx(() => searchController.isLoading.value
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchController.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchController.searchResults[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE0F2FE),
                              child: Text(user.username[0].toUpperCase(),
                                  style: GoogleFonts.inter(color: const Color(0xFF06B6D4), fontWeight: FontWeight.w600)),
                            ),
                            title: Text(user.username,
                                style: GoogleFonts.inter(color: const Color(0xFF0F172A), fontWeight: FontWeight.w500)),
                            trailing: _buildSearchAction(user, searchController, context),
                          );
                        },
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAction(dynamic user, UserSearchController searchController, BuildContext context) {
    if (user.isFriend) {
      return IconButton(
        onPressed: () {
          Get.back(); // Close dialog
          _startConversation(user.id);
        },
        icon: const Icon(Boxicons.bx_message_rounded_dots, color: Color(0xFF06B6D4)),
        tooltip: 'Start Chat',
      );
    }

    if (user.requestSent) {
      return const Text('Pending', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12));
    }

    if (user.requestReceived) {
      return const Text('Check Requests', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 12));
    }

    return IconButton(
      onPressed: () => searchController.sendFriendRequest(user.id),
      icon: const Icon(Boxicons.bx_user_plus, color: Color(0xFF06B6D4)),
      tooltip: 'Add Friend',
    );
  }

  void _startConversation(int userId) async {
    final homeController = Get.find<HomeController>();
    try {
      final response = await Get.find<ApiService>().post('/conversations/start', data: {'user_id': userId});
      final conv = Conversation.fromJson(response.data);
      Get.toNamed('/chat', arguments: conv);
      homeController.fetchDashboard(); // Refresh chat list
    } catch (e) {
      print('Start conversation error: $e');
      Get.snackbar('Error', 'Failed to start conversation.');
    }
  }
}
