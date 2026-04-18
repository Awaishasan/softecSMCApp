import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../views/dashboard_view.dart';

class AuthViewModel extends GetxController {
  final AuthServices _authServices = AuthServices();
  
  bool isLoading = false;
  bool isPasswordHidden = true;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  // Sign Up
  Future<void> signUp(String email, String password) async {
    isLoading = true;
    update(); 
    
    final result = await _authServices.signUp(email, password);
    
    isLoading = false;
    if (result != null) {
      Get.snackbar('Success', 'Account created successfully');
      Get.off(() => const DashboardView()); // Remove login from stack
    }
    update();
  }

  // Login
  Future<void> login(String email, String password) async {
    isLoading = true;
    update();
    
    final result = await _authServices.login(email, password);
    
    isLoading = false;
    if (result != null) {
      Get.snackbar('Success', 'Logged in successfully');
      Get.off(() => const DashboardView()); // Remove login from stack
    }
    update();
  }

  // Sign Out
  Future<void> signOut() async {
    isLoading = true;
    update();
    
    await _authServices.signOut();
    
    isLoading = false;
    update();
  }
}
