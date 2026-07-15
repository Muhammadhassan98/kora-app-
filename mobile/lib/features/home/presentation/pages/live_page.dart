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

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkGuestStatus();
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          title: Text(
            'جدول المباريات',
            style: AppTextStyles.headingH2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'مباشر 🔴'),
              Tab(text: 'القادمة ⏳'),
              Tab(text: 'المنتهية 🏁'),
            ],
          ),
        ),
        body: BlocBuilder<MatchesBloc, MatchesState>(
          builder: (context, state) {
            if (state is MatchesLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MatchesLoadedState) {
              final liveMatches = state.matches.where((m) => m.status == 'live').toList();
              final upcomingMatches = state.matches.where((m) => m.status == 'upcoming').toList();
              final finishedMatches = state.matches.where((m) => m.status == 'finished').toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchList(context, liveMatches, isDark, 'live'),
                  _buildMatchList(context, upcomingMatches, isDark, 'upcoming'),
                  _buildMatchList(context, finishedMatches, isDark, 'finished'),
                ],
              );
            } else if (state is MatchesFailureState) {
              return Center(child: Text('حدث خطأ في تحميل البيانات: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildMatchList(BuildContext context, List<MatchEntity> matches, bool isDark, String category) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          category == 'live'
              ? 'لا توجد مباريات جارية حالياً'
              : category == 'upcoming'
                  ? 'لا توجد مباريات قادمة'
                  : 'لا توجد مباريات منتهية',
          style: TextStyle(
            fontSize: 16.0,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        final match = matches[index];
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              if (category == 'live')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(30),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'مباشر',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "د '${match.minute ?? 0}'",
                      style: AppTextStyles.bodySmall.bold.copyWith(color: AppColors.error),
                    ),
                  ],
                )
              else if (category == 'upcoming')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'قادمة',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(match.startTime),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'منتهية',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM hh:mm a').format(match.startTime),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              Row(
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
                        const Icon(Icons.shield, size: 32.0, color: AppColors.primary),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      category == 'upcoming' ? 'VS' : '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                      style: AppTextStyles.headingH3.copyWith(
                        color: match.status == 'live' ? AppColors.error : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield, size: 32.0, color: Colors.blueGrey),
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
              if (category == 'upcoming') ...[
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () => _showPredictionDialog(context, match),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'توقع المباراة',
                    style: AppTextStyles.bodyMedium.bold.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                  ElevatedButton(
                    onPressed: () {
                      String predictedWinner = 'draw';
                      if (homeScore > awayScore) {
                        predictedWinner = 'home';
                      } else if (awayScore > homeScore) {
                        predictedWinner = 'away';
                      }

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
