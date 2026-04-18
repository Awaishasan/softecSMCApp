import 'package:get/get.dart';

import '../../views/auth_view/login_view.dart';
import '../../views/dashboard_view.dart';
import '../../bindings/dashboard_binding.dart';

class AppRoute {
  static const String LOGIN = '/login';
  static const String SigUp = '/SignUp';
  static const String Dashboard = '/DashBoard';
}

class pageRoute {
  static final pages = [
    GetPage(
      name: AppRoute.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoute.Dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(), // ✅ Controllers registered BEFORE widget builds
    ),
  ];
}