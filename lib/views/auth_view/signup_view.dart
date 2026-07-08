import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/auth_view_model.dart';

class SignupView extends StatefulWidget {
  SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _confirmHidden = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: w > 500 ? 40 : w * 0.08),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.05),

                // ── Logo ─────────────────────────────────────────────
                Text('Mera Hisab',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue)),
                SizedBox(height: h * 0.015),
                Container(
                  width: w * 0.20,
                  height: w * 0.20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Center(
                    child: Text('₹',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: h * 0.025),

                // ── Heading ───────────────────────────────────────────
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blackText)),
                const SizedBox(height: 8),
                const Text(
                  'Start managing your business cash flow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.grayText),
                ),
                SizedBox(height: h * 0.04),

                // ── Form card ─────────────────────────────────────────
                GetBuilder<AuthViewModel>(
                  init: AuthViewModel(),
                  builder: (ctrl) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email_outlined,
                                  color: AppColors.iconBlue),
                              labelText: 'Email address',
                              border: InputBorder.none,
                            ),
                            validator: (v) {
                              if (v == null ||
                                  v.isEmpty ||
                                  !v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 4),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: ctrl.isPasswordHidden,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.lock_outline,
                                  color: AppColors.iconBlue),
                              labelText: 'Password',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  ctrl.isPasswordHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.iconBlue,
                                  size: 20,
                                ),
                                onPressed: ctrl.togglePasswordVisibility,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'At least 6 characters required';
                              }
                              return null;
                            },
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 4),

                          // Confirm Password — own toggle state
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _confirmHidden,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.lock_person_outlined,
                                  color: AppColors.iconBlue),
                              labelText: 'Confirm password',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _confirmHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.iconBlue,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _confirmHidden = !_confirmHidden),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 20),

                          // ── Sign Up button ──────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.navyGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ElevatedButton(
                                onPressed: ctrl.isLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();
                                        if (_formKey.currentState!
                                            .validate()) {
                                          ctrl.signUp(
                                            _emailCtrl.text.trim(),
                                            _passwordCtrl.text.trim(),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: ctrl.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : const Text('Create Account',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Terms notice ────────────────────────────
                          const Center(
                            child: Text(
                              'By signing up you agree to our\nTerms of Service and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grayText,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: h * 0.04),

                // ── Already have account ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppColors.blackText)),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text('Log In',
                          style: TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.04),
              ],
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}
