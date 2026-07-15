import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/theme/app_colors.dart';
import 'package:fantkora/core/theme/app_text_styles.dart';
import 'package:fantkora/core/di/injection.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  final String title;

  const ChatPage({super.key, required this.roomId, required this.title});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final SocialBloc _socialBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;
  List<ChatMessageEntity> _messages = [];

  @override
  void initState() {
    super.initState();
    _socialBloc = getIt<SocialBloc>();
    _socialBloc.add(FetchChatMessagesEvent(widget.roomId));

    // Setup simulated WebSockets via periodic short polling to keep the chat extremely dynamic!
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _socialBloc.add(FetchChatMessagesEvent(widget.roomId));
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages Listing
          Expanded(
            child: BlocProvider.value(
              value: _socialBloc,
              child: BlocConsumer<SocialBloc, SocialState>(
                listener: (context, state) {
                  if (state is ChatLoadedState) {
                    setState(() {
                      _messages = state.messages;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  }
                },
                builder: (context, state) {
                  if (state is SocialLoadingState && _messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_messages.isEmpty) {
                    return const Center(
                      child: Text('لا توجد رسائل سابقة في هذه الغرفة. ابدأ الدردشة حياً!'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg, isDark);
                    },
                  );
                },
              ),
            ),
          ),
          // Input panel
          _buildInputPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity msg, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: msg.isVip ? Colors.amber.withAlpha(40) : AppColors.primary.withAlpha(40),
            child: Text(
              msg.username[0],
              style: TextStyle(color: msg.isVip ? Colors.amber : AppColors.primary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.username,
                      style: AppTextStyles.bodySmall.bold.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (msg.isVip) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: 8.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0 + MediaQuery.of(context).viewInsets.bottom + 8.0,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا حباً بالرياضة...',
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13),
                border: InputBorder.none,
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                _socialBloc.add(SendChatMessageEvent(widget.roomId, text));
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
