import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/home/home_view.dart';
import '../views/chat/chat_view.dart';
import '../views/home/profile_view.dart';

class AppRoutes {
  static const initial = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const chat = '/chat';
  static const profile = '/profile';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: chat,
      page: () => const ChatView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      transition: Transition.cupertino,
    ),
  ];
}
