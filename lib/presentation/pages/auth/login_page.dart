import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/utils/network_helper.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthProvider auth) async {
    auth.clearError();

    if (!_formKey.currentState!.validate()) return;

    // Cek koneksi internet sebelum login
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada koneksi internet. Periksa koneksi Anda."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Login berhasil"),
      ),
    );

    // ADMIN NAVIGATION - DISABLED (Firebase Console access required)
    // final role = auth.user?.role ?? 'user';
    // if (role == 'admin') {
    //   Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    // } else {
    //   Navigator.pushReplacementNamed(context, AppRoutes.home);
    // }
    
    // All users go to home page
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset('assets/images/logo.png', width: 260, height: 260),

            const SizedBox(height: 16),

            Text(
              "Selamat Datang di E-Healthy",
              textAlign: TextAlign.center,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    validator: Validators.validateEmail,
                  ),

                  CustomTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: 24),

                  auth.isLoading
                      ? const LoadingIndicator()
                      : CustomButton(
                          text: "Login",
                          onPressed: () => _handleLogin(auth),
                        ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.register,
                          );
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
