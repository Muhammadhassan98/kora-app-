import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/prediction_bloc.dart';
import '../bloc/prediction_event.dart';
import '../bloc/prediction_state.dart';
import '../../domain/entities/profile_entity.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<PredictionBloc>()..add(FetchLeaderboardEvent()),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 0.5,
          title: Text(
            'لوحة المتصدرين 🏆',
            style: AppTextStyles.headingH2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        body: BlocBuilder<PredictionBloc, PredictionState>(
          builder: (context, state) {
            if (state is PredictionLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LeaderboardLoadedState) {
              final profiles = state.profiles;
              if (profiles.isEmpty) {
                return Center(
                  child: Text(
                    'لا يوجد متصدرين حالياً',
                    style: TextStyle(
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 16.0),
                  // Top 3 header presentation
                  if (profiles.length >= 3) _buildTopThree(profiles.sublist(0, 3), isDark),
                  const SizedBox(height: 16.0),

                  // Remaining users list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: profiles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final rank = index + 1;
                        return _buildLeaderboardItem(profile, rank, isDark);
                      },
                    ),
                  ),
                ],
              );
            } else if (state is PredictionFailureState) {
              return Center(child: Text('خطأ في تحميل المتصدرين: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildTopThree(List<ProfileEntity> topThree, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (topThree.length >= 2)
            _buildPodiumUser(topThree[1], 2, Colors.grey[400]!, 70.0, isDark),
          // 1st Place
          if (topThree.isNotEmpty)
            _buildPodiumUser(topThree[0], 1, Colors.amber, 90.0, isDark),
          // 3rd Place
          if (topThree.length >= 3)
            _buildPodiumUser(topThree[2], 3, Colors.brown[400]!, 60.0, isDark),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(
      ProfileEntity profile, int rank, Color medalColor, double height, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 36.0 : 30.0,
              backgroundColor: AppColors.primary.withAlpha(30),
              child: Text(
                profile.username.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: rank == 1 ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          profile.username,
          style: AppTextStyles.bodyMedium.bold.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          '${profile.xpPoints} XP',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          width: rank == 1 ? 80.0 : 60.0,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withAlpha(40),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
          ),
          child: Center(
            child: Text(
              'مستوى ${profile.level}',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(ProfileEntity profile, int rank, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.0,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: AppTextStyles.bodyMedium.bold.copyWith(
                color: rank <= 3
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: AppColors.primary.withAlpha(20),
            child: Text(
              profile.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: AppTextStyles.bodyMedium.bold.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'المستوى ${profile.level}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${profile.xpPoints} XP',
                style: AppTextStyles.bodyMedium.bold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 14.0),
                  const SizedBox(width: 2.0),
                  Text(
                    '${profile.coinsBalance}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
