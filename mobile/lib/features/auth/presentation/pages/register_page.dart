import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterEvent(
              username: _usernameController.text.trim(),
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
                content: Text('تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني.'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // Redirect to OTP verification screen
            context.go('/otp?target=${Uri.encodeComponent(_emailController.text.trim())}');
          } else if (state is AuthFailureState) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                title: const Text('خطأ في التسجيل', style: TextStyle(color: Colors.red)),
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                onPressed: () => context.go('/login'),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'إنشاء حساب جديد',
                        style: AppTextStyles.headingH1.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'انضم إلى مجتمع فانتكورا الآن وابدأ التحدي والتوقعات',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Username Input
                      Text(
                        'اسم المستخدم',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                          hintText: 'ex: ahmad_kora',
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
                            return 'يرجى إدخال اسم المستخدم';
                          }
                          if (value.length < 3) {
                            return 'يجب أن يتكون اسم المستخدم من 3 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),

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
                        onPressed: state is AuthLoadingState ? null : () => _submitRegister(context),
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
                                'إنشاء الحساب',
                                style: AppTextStyles.bodyLarge.bold.copyWith(color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 24.0),

                      // Link to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟ ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'تسجيل الدخول',
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
          );
        },
      ),
    );
  }
}
