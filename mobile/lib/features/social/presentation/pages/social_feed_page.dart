import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import 'package:fantkora/core/storage/local_storage.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/community_entity.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  late final SocialBloc _socialBloc;
  final TextEditingController _postController = TextEditingController();
  final LocalStorage _localStorage = getIt<LocalStorage>();
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _socialBloc = getIt<SocialBloc>();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final guestFlag = await _localStorage.read('settings', 'is_guest') ?? false;
    setState(() {
      _isGuest = guestFlag;
    });
    if (!_isGuest) {
      _socialBloc.add(FetchPostsAndCommunitiesEvent());
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _showNewPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
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
              Text(
                'شارك منشور جديد بالساحة 📣',
                style: AppTextStyles.headingH3.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _postController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'ماذا يدور في ذهنك اليوم يا بطل؟...',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final text = _postController.text.trim();
                  if (text.isNotEmpty) {
                    _socialBloc.add(CreatePostEvent(text));
                    _postController.clear();
                    Navigator.pop(modalCtx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('أنشر الآن', style: AppTextStyles.bodyMedium.bold.copyWith(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
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
          'الساحة والمجتمعات (Social Hub)',
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _isGuest
          ? null
          : FloatingActionButton(
              onPressed: () => _showNewPostSheet(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_comment, color: Colors.white),
            ),
      body: _isGuest
          ? _buildGuestOverlay(isDark)
          : BlocProvider.value(
              value: _socialBloc,
              child: BlocBuilder<SocialBloc, SocialState>(
                builder: (context, state) {
                  if (state is SocialLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SocialLoadedState) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _socialBloc.add(FetchPostsAndCommunitiesEvent());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Communities Horizontal Row
                            _buildCommunitiesSection(state.communities, isDark),
                            const Divider(),
                            // Posts Vertical Feed
                            _buildFeedSection(state.posts, isDark),
                          ],
                        ),
                      ),
                    );
                  } else if (state is SocialFailureState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('فشل تحميل الساحة: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _socialBloc.add(FetchPostsAndCommunitiesEvent()),
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
                Icons.people_outline,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'انضم لمجتمعات الجماهير وشارك بالساحة!',
              style: AppTextStyles.headingH2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'يتطلب دخول الساحة الاجتماعية والدردشة مع جماهير الأندية تسجيل الدخول وإنشاء حسابك الشخصي.',
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

  Widget _buildCommunitiesSection(List<CommunityEntity> communities, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'مجتمعات الأندية الرسمية (Fan Leagues)',
            style: AppTextStyles.headingH3.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final comm = communities[index];
              return GestureDetector(
                onTap: () {
                  context.push('/chat?roomId=${comm.id}&title=${Uri.encodeComponent(comm.name)}');
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withAlpha(100), width: 1.5),
                        ),
                        child: Center(
                          child: Text(comm.symbol ?? '⚽', style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        comm.name,
                        style: AppTextStyles.bodySmall.bold.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${comm.memberCount} عضو',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedSection(List<PostEntity> posts, bool isDark) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('لا توجد منشورات حالياً في الساحة. كن أول من يشارك!')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha(40),
                    child: Text(post.username[0], style: const TextStyle(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: AppTextStyles.bodyMedium.bold.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          post.createdAt.toLocal().toString().substring(0, 16),
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content
              Text(
                post.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like button
                  IconButton(
                    icon: Row(
                      children: [
                        const Icon(Icons.favorite_border, color: AppColors.primary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likesCount}',
                          style: AppTextStyles.bodySmall.bold.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    onPressed: () {
                      _socialBloc.add(LikePostEvent(post.id));
                    },
                  ),
                  // Comments indicator
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${post.comments.length}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              // Comments preview
              if (post.comments.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...post.comments.map((comment) => Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${comment.username}: ',
                            style: AppTextStyles.bodySmall.bold.copyWith(color: AppColors.primary),
                          ),
                          Expanded(
                            child: Text(
                              comment.content,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}
