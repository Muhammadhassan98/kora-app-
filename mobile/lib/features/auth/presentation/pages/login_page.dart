import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تسجيل الدخول بنجاح!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/home');
          } else if (state is AuthFailureState) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                title: const Text('خطأ في تسجيل الدخول', style: TextStyle(color: Colors.red)),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('حسنًا'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            body: Stack(
              children: [
                // Background Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.bgDark, AppColors.surfaceDark.withAlpha(204)]
                            : [AppColors.bgLight, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40.0),
                          // Brand Title
                          Center(
                            child: Text(
                              'FantKora',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Center(
                            child: Text(
                              'منصة التوقعات والفانتازي الاجتماعية',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60.0),

                          // Email Input
                          Text(
                            'البريد الإلكتروني',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                              hintText: 'user@example.com',
                              hintStyle: TextStyle(
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                              contentPadding: const EdgeInsets.all(16.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال البريد الإلكتروني';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'يرجى إدخال بريد إلكتروني صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24.0),

                          // Password Input
                          Text(
                            'كلمة المرور',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                              contentPadding: const EdgeInsets.all(16.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              if (value.length < 6) {
                                return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40.0),

                          // Submit Button
                          ElevatedButton(
                            onPressed: state is AuthLoadingState ? null : () => _submitLogin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: state is AuthLoadingState
                                ? const SizedBox(
                                    height: 20.0,
                                    width: 20.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Text(
                                    'تسجيل الدخول',
                                    style: AppTextStyles.bodyLarge.bold.copyWith(color: Colors.white),
                                  ),
                          ),
                          const SizedBox(height: 24.0),

                          // Toggle Sign Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ليس لديك حساب؟ ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: Text(
                                  'إنشاء حساب جديد',
                                  style: AppTextStyles.bodyMedium.bold.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
