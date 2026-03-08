import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFE0F2FE),
                    backgroundImage: profileController.profileImageUrl.value.isNotEmpty 
                        ? NetworkImage(profileController.profileImageUrl.value) 
                        : null,
                    child: profileController.profileImageUrl.value.isEmpty
                        ? Text(
                            authController.user.value?.username[0].toUpperCase() ?? 'U',
                            style: GoogleFonts.inter(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF06B6D4),
                            ),
                          )
                        : null,
                  )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => profileController.pickImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF06B6D4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Boxicons.bx_camera, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // User Details
            _buildInfoCard(
              title: 'Username',
              value: authController.user.value?.username ?? '-',
              icon: Boxicons.bx_user,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Email',
              value: authController.user.value?.email ?? '-',
              icon: Boxicons.bx_envelope,
            ),
            
            const SizedBox(height: 40),
            
            // Save Changes (if needed, though image picks can auto-upload)
            Obx(() => profileController.isUpdating.value 
              ? const CircularProgressIndicator(color: Color(0xFF06B6D4))
              : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}
