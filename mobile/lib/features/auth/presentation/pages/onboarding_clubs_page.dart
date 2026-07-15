import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/storage/local_storage.dart';

class OnboardingClubsPage extends StatefulWidget {
  final String? mode;
  final String? interests;

  const OnboardingClubsPage({super.key, this.mode, this.interests});

  @override
  State<OnboardingClubsPage> createState() => _OnboardingClubsPageState();
}

class _OnboardingClubsPageState extends State<OnboardingClubsPage> {
  final List<Map<String, dynamic>> _clubs = [
    {
      'id': 'ahly',
      'name': 'النادي الأهلي',
      'color': Colors.red,
      'secondaryColor': Colors.amber,
      'symbol': '🦅',
    },
    {
      'id': 'zamalek',
      'name': 'نادي الزمالك',
      'color': Colors.white,
      'secondaryColor': Colors.red,
      'symbol': '🏹',
    },
    {
      'id': 'real_madrid',
      'name': 'ريال مدريد',
      'color': Colors.white,
      'secondaryColor': Colors.blue,
      'symbol': '👑',
    },
    {
      'id': 'barcelona',
      'name': 'برشلونة',
      'color': Colors.blue,
      'secondaryColor': Colors.red,
      'symbol': '🔴🔵',
    },
    {
      'id': 'liverpool',
      'name': 'ليفربول',
      'color': Colors.red,
      'secondaryColor': Colors.teal,
      'symbol': '🔴🟢',
    },
    {
      'id': 'man_city',
      'name': 'مانشستر سيتي',
      'color': Colors.lightBlue,
      'secondaryColor': Colors.white,
      'symbol': '🚢',
    },
  ];

  String? _selectedClubId;
  final LocalStorage _localStorage = LocalStorage();

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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/onboarding/interests?mode=${widget.mode}');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر ناديك المفضل ⚽',
                style: AppTextStyles.headingH2.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'سنقوم بتخصيص خلاصة أخبارك وإحصائياتك لتتناسب مع ناديك المفضل.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: ListView.separated(
                  itemCount: _clubs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final club = _clubs[index];
                    final isSelected = _selectedClubId == club['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedClubId = club['id'] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: (club['color'] as Color).withAlpha(40),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: club['secondaryColor'] as Color,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  club['symbol'] as String,
                                  style: const TextStyle(fontSize: 22.0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              club['name'] as String,
                              style: AppTextStyles.bodyLarge.bold.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24.0,
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
                onPressed: _selectedClubId == null
                    ? null
                    : () async {
                        // Save configurations locally
                        await _localStorage.write('settings', 'favorite_club', _selectedClubId);
                        await _localStorage.write('settings', 'interests', widget.interests);

                        if (!mounted) return;

                        if (widget.mode == 'guest') {
                          // Save guest flag
                          await _localStorage.write('settings', 'is_guest', true);
                          // Go to Home
                          if (context.mounted) {
                            context.go('/home');
                          }
                        } else {
                          // Save configurations locally for registration transfer
                          // and go to Registration / verify
                          if (context.mounted) {
                            context.go('/register');
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'بدء التجربة',
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
