import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';

class OnboardingInterestsPage extends StatefulWidget {
  final String? mode;

  const OnboardingInterestsPage({super.key, this.mode});

  @override
  State<OnboardingInterestsPage> createState() => _OnboardingInterestsPageState();
}

class _OnboardingInterestsPageState extends State<OnboardingInterestsPage> {
  final List<Map<String, dynamic>> _interests = [
    {
      'id': 'predictions',
      'title': 'توقعات المباريات',
      'icon': Icons.insights,
      'desc': 'توقع نتائج المباريات واربح جوائز قيمة',
    },
    {
      'id': 'fantasy',
      'title': 'دوري الفانتازي',
      'icon': Icons.sports_soccer,
      'desc': 'اصنع فريق أحلامك ونافس أصدقائك',
    },
    {
      'id': 'chat',
      'title': 'دردشة الجماهير',
      'icon': Icons.forum,
      'desc': 'ناقش وحلّل المباريات مع آلاف المشجعين',
    },
    {
      'id': 'news',
      'title': 'أخبار حصرية',
      'icon': Icons.feed,
      'desc': 'تابع أخبار أنديتك المفضلة لحظة بلحظة',
    },
    {
      'id': 'stats',
      'title': 'إحصائيات متقدمة',
      'icon': Icons.analytics,
      'desc': 'تحليل شامل لأرقام اللاعبين والفرق',
    },
    {
      'id': 'rooms',
      'title': 'البث الصوتي المباشر',
      'icon': Icons.radio,
      'desc': 'استمع للتعليق الصوتي والتحليلات الحية',
    },
  ];

  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ما الذي يثير اهتمامك؟ 🤔',
                style: AppTextStyles.headingH2.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'اختر الاهتمامات التي تفضلها لتخصيص تجربتك الفريدة داخل فانتكورا.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final item = _interests[index];
                    final id = item['id'] as String;
                    final isSelected = _selectedIds.contains(id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(id);
                          } else {
                            _selectedIds.add(id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(20)
                              : (isDark ? AppColors.surfaceDark : Colors.white),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(40),
                                    blurRadius: 8.0,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                  size: 28.0,
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 20.0,
                                  ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              item['title'] as String,
                              style: AppTextStyles.bodyLarge.bold.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              item['desc'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () {
                        // Move to Favorite Club selection page
                        context.push(
                          '/onboarding/clubs?mode=${widget.mode}&interests=${_selectedIds.join(',')}',
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'المتابعة',
                  style: AppTextStyles.bodyLarge.bold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
