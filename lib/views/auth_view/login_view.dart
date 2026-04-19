import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/auth_view_model.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  Text(
                    'Mera Hisab',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlue,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  Container(
                    width: screenWidth * 0.22,
                    height: screenWidth * 0.22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '₹',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track income, expenses & pending easily.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayText,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),


                  GetBuilder<AuthViewModel>(
                    init: AuthViewModel(),
                    builder: (controller) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [

                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.email, color: AppColors.iconBlue),
                                labelText: 'Email',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return "Enter Correct Email";
                                }
                                return null;
                              },
                            ),
                            const Divider(),

                            TextFormField(
                              controller: passwordController,
                              obscureText: controller.isPasswordHidden,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.lock, color: AppColors.iconBlue),
                                labelText: 'Password',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.iconBlue,
                                  ),
                                  onPressed: () => controller.togglePasswordVisibility(),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const Divider(),
                            const SizedBox(height: 15),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    if (!controller.isLoading) {
                                      controller.login(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Forgot Password
                            // TextButton(
                            //   onPressed: () {
                            //     // Action for forgot password
                            //   },
                            //   child: const Text(
                            //     'Forgot Password?',
                            //     style: TextStyle(
                            //       color: AppColors.accentOrange,
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.1),

                  // Bottom Text Section
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text(
                  //       "Don't have an account? ",
                  //       style: TextStyle(color: AppColors.blackText),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         // Navigate to Signup
                  //       },
                  //       child: const Text(
                  //         "Sign Up",
                  //         style: TextStyle(
                  //           color: AppColors.accentOrange,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
