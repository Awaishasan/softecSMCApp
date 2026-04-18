import 'package:get/get.dart';
import '../view_models/dashboard_controller.dart';
import '../view_models/auth_view_model.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<AuthViewModel>(() => AuthViewModel());
  }
}
