import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'أهلاً بك في فانتكورا',
      'description': 'المنصة التفاعلية الأولى لعشاق الكرة الفانتازي والتوقعات الرياضية.',
    },
    {
      'title': 'ساحة التوقعات المباشرة',
      'description': 'توقع نتائج المباريات الكبرى، واجمع النقاط لتنافس على صدارة الترتيب العام.',
    },
    {
      'title': 'شكّل فريق أحلامك',
      'description': 'اشترِ اللاعبين، ودر تشكيلتك، ونافس أصدقائك في دوريات خاصة ومثيرة.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to main app
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'تخطي',
                    style: AppTextStyles.bodyMedium.bold.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder Icon for slide illustration
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.sports_soccer
                                : index == 1
                                    ? Icons.analytics_outlined
                                    : Icons.group_work_outlined,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48.0),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingH1.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          slide['description']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Indicator & Next Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        height: 8.0,
                        width: _currentIndex == index ? 24.0 : 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? AppColors.primary : AppColors.textMutedDark,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // Next button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      _currentIndex == _slides.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: AppTextStyles.bodyMedium.bold.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
