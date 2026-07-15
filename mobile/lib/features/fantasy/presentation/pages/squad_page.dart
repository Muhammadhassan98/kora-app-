import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import 'package:fantkora/core/storage/local_storage.dart';
import '../bloc/fantasy_bloc.dart';
import '../bloc/fantasy_event.dart';
import '../bloc/fantasy_state.dart';
import '../../domain/entities/fantasy_squad_entity.dart';
import '../../domain/entities/squad_player_entity.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  late final FantasyBloc _fantasyBloc;
  final LocalStorage _localStorage = getIt<LocalStorage>();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _fantasyBloc = getIt<FantasyBloc>();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final guestFlag = await _localStorage.read('settings', 'is_guest') ?? false;
    setState(() {
      _isGuest = guestFlag;
    });
    if (!_isGuest) {
      _fantasyBloc.add(FetchSquadEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تشكيلتي (My Squad)',
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: _isGuest
          ? _buildGuestOverlay(isDark)
          : BlocProvider.value(
              value: _fantasyBloc,
              child: BlocBuilder<FantasyBloc, FantasyState>(
                builder: (context, state) {
                  if (state is FantasyLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FantasySquadLoadedState) {
                    return _buildSquadPitch(context, state.squad, isDark);
                  } else if (state is FantasyFailureState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('فشل تحميل التشكيلة: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _fantasyBloc.add(FetchSquadEvent()),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
    );
  }

  Widget _buildGuestOverlay(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'طور فريق أحلامك ونافس أصدقائك!',
              style: AppTextStyles.headingH2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'تحتاج إلى إنشاء حساب أو تسجيل الدخول لحفظ التشكيلة والمشاركة في تحديات الفانتازي وحصد النقاط.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _localStorage.write('settings', 'is_guest', false);
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'تسجيل الدخول / إنشاء حساب',
                style: AppTextStyles.bodyMedium.bold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquadPitch(BuildContext context, FantasySquadEntity squad, bool isDark) {
    // Separate squad into positions: GKP, DEF, MID, FWD, BENCH
    final players = squad.players;
    final gkpList = players.where((p) => p.player.position == 'GKP' && !p.isBench).toList();
    final defList = players.where((p) => p.player.position == 'DEF' && !p.isBench).toList();
    final midList = players.where((p) => p.player.position == 'MID' && !p.isBench).toList();
    final fwdList = players.where((p) => p.player.position == 'FWD' && !p.isBench).toList();
    final benchList = players.where((p) => p.isBench).toList();

    return Column(
      children: [
        // Budget & points info bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip('الميزانية المتبقية', '${squad.budget.toStringAsFixed(1)}M 🪙', isDark),
              _buildInfoChip('نقاط الجولة', '${squad.gameweekPoints} ن', isDark),
            ],
          ),
        ),
        // Green Soccer Pitch Representation
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(128), width: 3),
              ),
              child: Stack(
                children: [
                  // Pitch Markings: Center line & Circle
                  Center(
                    child: Container(
                      height: 2,
                      color: Colors.white.withAlpha(77),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withAlpha(77), width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Pitch Content arranged in rows: FWD, MID, DEF, GKP
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Forward Row
                      _buildPositionRow(fwdList, 'FWD', 3),
                      // Midfielder Row
                      _buildPositionRow(midList, 'MID', 5),
                      // Defender Row
                      _buildPositionRow(defList, 'DEF', 5),
                      // Goalkeeper Row
                      _buildPositionRow(gkpList, 'GKP', 1),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        // Bench Players Section
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مقاعد البدلاء (Bench)',
                style: AppTextStyles.bodyMedium.bold.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  // Render up to 4 bench players or empty slots
                  if (index < benchList.length) {
                    return _buildPlayerCard(benchList[index], isDark);
                  }
                  return _buildEmptySlotCard('BENCH', isDark);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark)),
          Text(value, style: AppTextStyles.bodyMedium.bold.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildPositionRow(List<SquadPlayerEntity> players, String position, int maxSlots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(maxSlots, (index) {
        if (index < players.length) {
          return _buildPlayerCard(players[index], true);
        }
        return _buildEmptySlotCard(position, true);
      }),
    );
  }

  Widget _buildPlayerCard(SquadPlayerEntity squadPlayer, bool isDark) {
    final player = squadPlayer.player;
    return GestureDetector(
      onTap: () {
        context.push('/transfers');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player Jersey Representation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 4.0),
          // Player Name Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player.name,
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2.0),
          // Player Points or Price Label
          Text(
            '${player.points} pts',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard(String position, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.push('/transfers');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(50),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(100), width: 1.5),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white70,
              size: 28,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(80),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              position,
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
