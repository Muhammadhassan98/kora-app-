import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import 'package:fantkora/core/storage/local_storage.dart';
import '../bloc/economy_bloc.dart';
import '../bloc/economy_event.dart';
import '../bloc/economy_state.dart';
import '../../domain/entities/coin_transaction_entity.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  late final EconomyBloc _economyBloc;
  final LocalStorage _localStorage = getIt<LocalStorage>();
  int _coinsBalance = 0;
  bool _isAdWatching = false;
  int _adCountdown = 5;
  Timer? _adTimer;
  List<CoinTransactionEntity> _transactionsList = [];
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _economyBloc = getIt<EconomyBloc>();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final guestFlag = await _localStorage.read('settings', 'is_guest') ?? false;
    setState(() {
      _isGuest = guestFlag;
    });
    if (!_isGuest) {
      _economyBloc.add(FetchTransactionsEvent());
      // Retrieve initial coins locally if cached
      final cachedCoins = await _localStorage.read('profile', 'coins') ?? 150; // default 150 coins
      setState(() {
        _coinsBalance = cachedCoins;
      });
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _startAdSimulation() {
    setState(() {
      _isAdWatching = true;
      _adCountdown = 5;
    });

    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adCountdown > 1) {
        setState(() {
          _adCountdown--;
        });
      } else {
        _adTimer?.cancel();
        setState(() {
          _isAdWatching = false;
        });
        // Dispatch ad claim event
        _economyBloc.add(ClaimAdRewardEvent());
      }
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
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'متجر المكافآت (Rewards & Store)',
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: _isGuest
          ? _buildGuestOverlay(isDark)
          : BlocProvider.value(
              value: _economyBloc,
              child: BlocListener<EconomyBloc, EconomyState>(
                listener: (context, state) {
                  if (state is EconomyActionSuccessState) {
                    setState(() {
                      _coinsBalance = state.profile.coinsBalance;
                    });
                    _localStorage.write('profile', 'coins', state.profile.coinsBalance);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                    // Refresh transaction logs
                    _economyBloc.add(FetchTransactionsEvent());
                  } else if (state is EconomyTransactionsLoadedState) {
                    setState(() {
                      _transactionsList = state.transactions;
                    });
                  } else if (state is EconomyFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('حدث خطأ: ${state.message}')),
                    );
                  }
                },
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Coin Balance Header
                          _buildCoinsBalanceHeader(isDark),
                          const SizedBox(height: 24.0),
                          // Rewarded Ads Section
                          _buildRewardedAdsCard(isDark),
                          const SizedBox(height: 24.0),
                          // Items Store Section
                          _buildStoreSection(isDark),
                          const SizedBox(height: 24.0),
                          // Transactions History Section
                          _buildTransactionsHistory(isDark),
                        ],
                      ),
                    ),
                    // Video Ad Playback Overlay
                    if (_isAdWatching) _buildAdVideoOverlay(),
                  ],
                ),
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
              'متجر المكافآت والعملات الحصري!',
              style: AppTextStyles.headingH2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'أنشئ حساباً لمشاهدة الإعلانات وكسب العملات مجاناً وشراء إطارات الملف الشخصي وشارات الـ VIP الحصرية.',
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

  Widget _buildCoinsBalanceHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blue.shade900, Colors.teal.shade900]
              : [Colors.blue.shade600, Colors.teal.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(64),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'رصيدك الحالي من العملات',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_coinsBalance',
                style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8.0),
              const Text(
                '🪙',
                style: TextStyle(fontSize: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardedAdsCard(bool isDark) {
    return Card(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ondemand_video,
                color: Colors.amber,
                size: 32,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عملات فيديو مجانية',
                    style: AppTextStyles.bodyMedium.bold.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'احصل على +٢٠ عملة بمشاهدة فيديو إعلاني قصير',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _startAdSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('شاهد الإعلان', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متجر العناصر المميزة (VIP Items)',
          style: AppTextStyles.headingH3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            // Neon Avatar Frame Card
            Expanded(
              child: _buildStoreItemCard(
                title: 'إطار نيون لملفك',
                cost: 100,
                itemId: 'neon_avatar_frame',
                symbol: '🔥',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12.0),
            // VIP Pass Card
            Expanded(
              child: _buildStoreItemCard(
                title: 'VIP 7 أيام',
                cost: 250,
                itemId: 'vip_access_7d',
                symbol: '👑',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoreItemCard({
    required String title,
    required int cost,
    required String itemId,
    required String symbol,
    required bool isDark,
  }) {
    final canBuy = _coinsBalance >= cost;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(symbol, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: AppTextStyles.bodyMedium.bold.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            '$cost 🪙',
            style: AppTextStyles.bodyMedium.bold.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: canBuy
                ? () {
                    _economyBloc.add(PurchaseItemEvent(itemId));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('شراء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHistory(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل المعاملات الأخيرة (Transactions)',
          style: AppTextStyles.headingH3.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12.0),
        if (_transactionsList.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('لا توجد معاملات سابقة لحسابك حتى الآن'),
            ),
          )
        else
          ..._transactionsList.map((tx) => _buildTransactionRow(tx, isDark)),
      ],
    );
  }

  Widget _buildTransactionRow(CoinTransactionEntity tx, bool isDark) {
    final isEarn = tx.amount > 0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isEarn ? Icons.add_circle : Icons.remove_circle,
            color: isEarn ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  tx.createdAt.toLocal().toString().substring(0, 16),
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMutedDark),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? "+" : ""}${tx.amount} 🪙',
            style: AppTextStyles.bodyMedium.bold.copyWith(
              color: isEarn ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdVideoOverlay() {
    return Container(
      color: Colors.black.withAlpha(220),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 24),
            const Text(
              'جاري عرض الفيديو الإعلاني المجزي...',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'سوف تحصل على مكافأتك خلال $_adCountdown ثوانٍ',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
