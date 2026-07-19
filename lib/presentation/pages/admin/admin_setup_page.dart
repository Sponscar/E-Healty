import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/auth_provider.dart';

class AdminSetupPage extends StatefulWidget {
  const AdminSetupPage({super.key});

  @override
  State<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _adminExists = false;

  @override
  void initState() {
    super.initState();
    _checkAdminExists();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminExists() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      setState(() {
        _adminExists = snapshot.docs.isNotEmpty;
        _isLoading = false;
      });

      if (_adminExists && mounted) {
        // Admin already exists, redirect to login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();

    try {
      // Register with admin role
      await auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        phoneController.text.trim(),
      );

      // Update role to admin in Firestore
      if (auth.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.user!.uid)
            .update({'role': 'admin'});
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin berhasil dibuat! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Logout and go to login
        await auth.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (_adminExists) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text(
                  'Admin Sudah Ada',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Halaman setup admin hanya bisa digunakan sekali.\nAnda akan diarahkan ke halaman login.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppColors.primaryBlue,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Admin Setup',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Buat akun admin pertama untuk aplikasi E-Healthy',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person,
                      validator: Validators.validateName,
                    ),
                    
                    CustomTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email,
                      validator: Validators.validateEmail,
                    ),
                    
                    CustomTextField(
                      controller: phoneController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    
                    CustomTextField(
                      controller: passwordController,
                      label: 'Password',
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
                    
                    _isLoading
                        ? const LoadingIndicator()
                        : CustomButton(
                            text: 'Buat Admin',
                            onPressed: _createAdmin,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
