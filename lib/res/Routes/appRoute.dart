import 'package:get/get.dart';

import '../../views/auth_view/login_view.dart';
import '../../views/dashboard_view.dart';
import '../../views/splash_screen.dart';
import '../../bindings/dashboard_binding.dart';

class AppRoute {
  static const String SPLASH = '/';
  static const String LOGIN = '/login';
  static const String SigUp = '/SignUp';
  static const String Dashboard = '/DashBoard';
}

class pageRoute {
  static final pages = [
    GetPage(
      name: AppRoute.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoute.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoute.Dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
