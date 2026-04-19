import 'package:get/get.dart';
import '../view_models/dashboard_controller.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/cash_flow_controller.dart';
import '../view_models/settings_view_model.dart';
import '../view_models/client_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<AuthViewModel>(() => AuthViewModel());
    Get.lazyPut<CashFlowController>(() => CashFlowController());
    Get.lazyPut<SettingsViewModel>(() => SettingsViewModel());
    Get.lazyPut<ClientController>(() => ClientController());
  }
}
