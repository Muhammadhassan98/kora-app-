import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import 'package:fantkora/core/storage/local_storage.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';
import '../../../prediction/presentation/bloc/prediction_bloc.dart';
import '../../../prediction/presentation/bloc/prediction_event.dart';
import '../../domain/entities/match_entity.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGuest = false;
  int _coinsBalance = 150;

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    _loadCoinsBalance();
  }

  Future<void> _loadCoinsBalance() async {
    final localStorage = LocalStorage();
    final coins = await localStorage.read<int>('profile', 'coins') ?? 150;
    if (mounted) {
      setState(() {
        _coinsBalance = coins;
      });
    }
  }

  Future<void> _checkGuestStatus() async {
    final localStorage = LocalStorage();
    final guest = await localStorage.read<bool>('settings', 'is_guest') ?? false;
    if (mounted) {
      setState(() {
        _isGuest = guest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchesBloc>(
          create: (context) => getIt<MatchesBloc>()..add(FetchMatchesEvent()),
        ),
        BlocProvider<PredictionBloc>(
          create: (context) => getIt<PredictionBloc>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 0.5,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withAlpha(40),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً بك، كابتن',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'moooo',
                    style: AppTextStyles.headingH4.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Level badge & Coins balance
            GestureDetector(
              onTap: () async {
                await context.push('/rewards');
                _loadCoinsBalance();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 18.0),
                    const SizedBox(width: 4.0),
                    Text(
                      '$_coinsBalance',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  'مستوى 2',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Points / XP Bar
                _buildXpBar(isDark),
                const SizedBox(height: 24.0),

                // Title
                Text(
                  'المباراة القادمة الكبرى ⚽',
                  style: AppTextStyles.headingH3.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12.0),

                // Featured upcoming match card
                BlocBuilder<MatchesBloc, MatchesState>(
                  builder: (context, state) {
                    if (state is MatchesLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MatchesLoadedState) {
                      final matches = List<MatchEntity>.from(state.matches);
                      final upcoming = matches.firstWhere(
                        (m) => m.status == 'upcoming',
                        orElse: () => matches.first,
                      );
                      return _buildFeaturedMatchCard(context, upcoming, isDark);
                    } else if (state is MatchesFailureState) {
                      return Center(child: Text('خطأ في تحميل البيانات: ${state.message}'));
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 28.0),

                // Today matches feed title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مباريات اليوم الجارية',
                      style: AppTextStyles.headingH3.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // Matches list
                BlocBuilder<MatchesBloc, MatchesState>(
                  builder: (context, state) {
                    if (state is MatchesLoadedState) {
                      final liveAndFinished = state.matches
                          .where((m) => m.status != 'upcoming')
                          .toList();
                      if (liveAndFinished.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'لا توجد مباريات جارية حالياً',
                              style: TextStyle(
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: liveAndFinished.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          return _buildMatchItem(context, liveAndFinished[index], isDark);
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildXpBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم إلى مستوى 3',
                style: AppTextStyles.bodyMedium.bold.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '140 / 200 XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: 140 / 200,
              minHeight: 8.0,
              backgroundColor: isDark ? AppColors.borderDark : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMatchCard(BuildContext context, MatchEntity match, bool isDark) {
    final timeStr = DateFormat('hh:mm a').format(match.startTime);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.surfaceDark, AppColors.bgDark]
              : [Colors.white, AppColors.bgLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'الجولة 1',
                  style: AppTextStyles.bodySmall.bold.copyWith(color: AppColors.primary),
                ),
              ),
              Text(
                timeStr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Team
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.shield, size: 56.0, color: AppColors.primary),
                    const SizedBox(height: 8.0),
                    Text(
                      match.homeTeam,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.bold.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'VS',
                style: AppTextStyles.headingH2.copyWith(color: AppColors.accent),
              ),
              // Away Team
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.shield, size: 56.0, color: Colors.blueGrey),
                    const SizedBox(height: 8.0),
                    Text(
                      match.awayTeam,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.bold.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28.0),
          ElevatedButton(
            onPressed: () => _showPredictionDialog(context, match),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'توقع النتيجة الآن',
              style: AppTextStyles.bodyLarge.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchItem(BuildContext context, MatchEntity match, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  match.homeTeam,
                  style: AppTextStyles.bodyMedium.bold.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.shield, size: 24.0, color: AppColors.primary),
              ],
            ),
          ),
          // Scores
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: match.status == 'live' ? AppColors.error.withAlpha(20) : Colors.black.withAlpha(20),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                  style: AppTextStyles.headingH3.copyWith(
                    color: match.status == 'live' ? AppColors.error : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.shield, size: 24.0, color: Colors.blueGrey),
                const SizedBox(width: 8.0),
                Text(
                  match.awayTeam,
                  style: AppTextStyles.bodyMedium.bold.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPredictionDialog(BuildContext context, MatchEntity match) {
    if (_isGuest) {
      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            title: const Text('عذراً، هذه الميزة للمسجلين ⚽', textAlign: TextAlign.right),
            content: const Text(
              'لتوقع نتائج المباريات والحصول على نقاط وصعود قائمة المتصدرين، يرجى إنشاء حسابك.',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تصفح لاحقاً', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('سجل الآن', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
      return;
    }

    int homeScore = 0;
    int awayScore = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'توقع نتيجة المباراة',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingH2.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Predict layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home Goal adjust
                      Column(
                        children: [
                          Text(match.homeTeam, style: AppTextStyles.bodyMedium.bold),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                onPressed: () {
                                  if (homeScore > 0) {
                                    setModalState(() => homeScore--);
                                  }
                                },
                              ),
                              Text('$homeScore', style: AppTextStyles.metricsLarge),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                onPressed: () {
                                  setModalState(() => homeScore++);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      Text(':', style: AppTextStyles.metricsLarge),
                      // Away Goal adjust
                      Column(
                        children: [
                          Text(match.awayTeam, style: AppTextStyles.bodyMedium.bold),
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                onPressed: () {
                                  if (awayScore > 0) {
                                    setModalState(() => awayScore--);
                                  }
                                },
                              ),
                              Text('$awayScore', style: AppTextStyles.metricsLarge),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                onPressed: () {
                                  setModalState(() => awayScore++);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),

                  // Submit Prediction button
                  ElevatedButton(
                    onPressed: () {
                      String predictedWinner = 'draw';
                      if (homeScore > awayScore) {
                        predictedWinner = 'home';
                      } else if (awayScore > homeScore) {
                        predictedWinner = 'away';
                      }

                      // Dispatch prediction event
                      BlocProvider.of<PredictionBloc>(context).add(
                        SubmitPredictionEvent(
                          matchId: match.id,
                          predictedWinner: predictedWinner,
                          predictedHomeScore: homeScore,
                          predictedAwayScore: awayScore,
                        ),
                      );

                      Navigator.pop(modalCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل توقعك بنجاح!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text('حفظ التوقع', style: AppTextStyles.bodyLarge.bold.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
