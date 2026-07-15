import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/fantasy_bloc.dart';
import '../bloc/fantasy_event.dart';
import '../bloc/fantasy_state.dart';
import '../../domain/entities/player_entity.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  State<TransfersPage> createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  late final FantasyBloc _fantasyBloc;
  String? _selectedPosition;
  String _searchQuery = '';
  
  // Local list of selected players in the transfer cart
  final List<PlayerEntity> _selectedPlayers = [];
  double _budget = 100.0;

  @override
  void initState() {
    super.initState();
    _fantasyBloc = getIt<FantasyBloc>();
    _fantasyBloc.add(FetchPlayersEvent());
    _loadCurrentSquad();
  }

  void _loadCurrentSquad() {
    final state = _fantasyBloc.state;
    if (state is FantasySquadLoadedState) {
      setState(() {
        for (var sp in state.squad.players) {
          _selectedPlayers.add(sp.player);
        }
        _recalculateBudget();
      });
    }
  }

  void _recalculateBudget() {
    double totalCost = 0.0;
    for (var p in _selectedPlayers) {
      totalCost += p.price;
    }
    setState(() {
      _budget = 100.0 - totalCost;
    });
  }

  void _togglePlayerSelection(PlayerEntity player) {
    setState(() {
      if (_selectedPlayers.any((p) => p.id == player.id)) {
        _selectedPlayers.removeWhere((p) => p.id == player.id);
      } else {
        // Enforce max squad size limit of 15
        if (_selectedPlayers.length >= 15) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الحد الأقصى للتشكيلة هو 15 لاعباً')),
          );
          return;
        }
        _selectedPlayers.add(player);
      }
      _recalculateBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'سوق الانتقالات (Transfer Market)',
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider.value(
        value: _fantasyBloc,
        child: Column(
          children: [
            // Search and filters section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _fantasyBloc.add(FetchPlayersEvent(
                        position: _selectedPosition,
                        search: _searchQuery,
                      ));
                    },
                    decoration: InputDecoration(
                      hintText: 'البحث عن لاعب...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Position Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterChip('الكل', null, isDark),
                      _buildFilterChip('حارس', 'GKP', isDark),
                      _buildFilterChip('دفاع', 'DEF', isDark),
                      _buildFilterChip('وسط', 'MID', isDark),
                      _buildFilterChip('هجوم', 'FWD', isDark),
                    ],
                  ),
                ],
              ),
            ),
            // Players List Section
            Expanded(
              child: BlocBuilder<FantasyBloc, FantasyState>(
                builder: (context, state) {
                  if (state is FantasyLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FantasyPlayersLoadedState) {
                    final playersList = state.players;
                    if (playersList.isEmpty) {
                      return const Center(child: Text('لا توجد نتائج مطابقة لبحثك'));
                    }
                    return ListView.builder(
                      itemCount: playersList.isEmpty ? 0 : playersList.length,
                      itemBuilder: (context, index) {
                        final player = playersList[index];
                        final isSelected = _selectedPlayers.any((p) => p.id == player.id);
                        return _buildPlayerRow(player, isSelected, isDark);
                      },
                    );
                  } else if (state is FantasyFailureState) {
                    return Center(child: Text('خطأ في جلب اللاعبين: ${state.message}'));
                  }
                  return const Center(child: Text('ابدأ بتصفح سوق الانتقالات'));
                },
              ),
            ),
            // Bottom Transfer cart summary panel
            _buildSummaryPanel(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? position, bool isDark) {
    final isSelected = _selectedPosition == position;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      selected: isSelected,
      onSelected: (val) {
        setState(() {
          _selectedPosition = position;
        });
        _fantasyBloc.add(FetchPlayersEvent(
          position: _selectedPosition,
          search: _searchQuery,
        ));
      },
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
  }

  Widget _buildPlayerRow(PlayerEntity player, bool isSelected, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Jersey representation icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade900.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12.0),
          // Name and position info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTextStyles.bodyMedium.bold.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${player.club} · ${player.position}',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark),
                ),
              ],
            ),
          ),
          // Price and points info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player.price.toStringAsFixed(1)}M 🪙',
                style: AppTextStyles.bodyMedium.bold.copyWith(color: AppColors.primary),
              ),
              Text(
                '${player.points} pts',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark),
              ),
            ],
          ),
          const SizedBox(width: 12.0),
          // Add/Remove selection button
          IconButton(
            icon: Icon(
              isSelected ? Icons.remove_circle : Icons.add_circle,
              color: isSelected ? Colors.red : AppColors.primary,
              size: 28,
            ),
            onPressed: () => _togglePlayerSelection(player),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(bool isDark) {
    final isBudgetExceeded = _budget < 0;
    
    return BlocListener<FantasyBloc, FantasyState>(
      listener: (context, state) {
        if (state is FantasyTransfersSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ تشكيلتك بنجاح!')),
          );
          // Go back to squad dashboard
          context.pop();
        } else if (state is FantasyFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حفظ الانتقالات: ${state.message}')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cost and Count Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الميزانية المتبقية', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark)),
                    Text(
                      '${_budget.toStringAsFixed(1)}M 🪙',
                      style: AppTextStyles.bodyLarge.bold.copyWith(
                        color: isBudgetExceeded ? Colors.red : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('اللاعبين المختارين', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark)),
                    Text(
                      '${_selectedPlayers.length}/15',
                      style: AppTextStyles.bodyLarge.bold.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Confirm Transfers Action Button
            ElevatedButton(
              onPressed: isBudgetExceeded
                  ? null
                  : () {
                      final ids = _selectedPlayers.map((p) => p.id).toList();
                      _fantasyBloc.add(UpdateSquadTransfersEvent(ids));
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'تأكيد وحفظ التشكيلة',
                style: AppTextStyles.bodyMedium.bold.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
