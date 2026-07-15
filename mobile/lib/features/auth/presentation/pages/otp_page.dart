import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  final String target;

  const OtpPage({super.key, required this.target});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitVerify(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthVerifyOtpEvent(
              target: widget.target,
              code: _codeController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      // Create Bloc and trigger SendOtpEvent initially
      create: (context) => getIt<AuthBloc>()..add(AuthSendOtpEvent(target: widget.target)),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpVerifiedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم التحقق وتفعيل الحساب بنجاح!'),
                backgroundColor: AppColors.success,
              ),
            );
            // Redirect to Onboarding Flow
            context.go('/onboarding');
          } else if (state is AuthFailureState) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                title: const Text('رمز تحقق خاطئ', style: TextStyle(color: Colors.red)),
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
                onPressed: () => context.go('/register'),
              ),
            ),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'رمز التحقق',
                        style: AppTextStyles.headingH1.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'أرسلنا رمز تحقق (OTP) إلى البريد الإلكتروني:\n${widget.target}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48.0),

                      // Code Input
                      Text(
                        'أدخل رمز التحقق (للتطوير أدخل: 1234)',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8.0,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: '0000',
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
                            return 'يرجى إدخال الرمز';
                          }
                          if (value.length < 4) {
                            return 'الرمز يتكون من 4 أرقام';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40.0),

                      // Submit Button
                      ElevatedButton(
                        onPressed: state is AuthLoadingState ? null : () => _submitVerify(context),
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
                                'تأكيد الرمز',
                                style: AppTextStyles.bodyLarge.bold.copyWith(color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 24.0),

                      // Resend Code Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لم يصلك الرمز؟ ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<AuthBloc>().add(AuthSendOtpEvent(target: widget.target));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم إعادة إرسال الرمز (1234)')),
                              );
                            },
                            child: Text(
                              'إعادة الإرسال',
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
            ),),
          );
        },
      ),
    );
  }
}
