import 'package:get/get.dart';
import '../services/auth_services.dart';
import '../res/Routes/appRoute.dart';

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
      Get.offAllNamed(AppRoute.Dashboard); // ✅ Uses binding, controllers pre-registered
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
      Get.offAllNamed(AppRoute.Dashboard); // ✅ Uses binding, controllers pre-registered
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
    
    // Redirect to Login
    Get.offAllNamed('/login'); // Assuming AppRoute.LOGIN is '/login'
  }
}
