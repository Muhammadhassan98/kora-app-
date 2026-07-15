import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/like_post_usecase.dart';
import '../../domain/usecases/get_communities_usecase.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import 'social_event.dart';
import 'social_state.dart';

@injectable
class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final LikePostUseCase likePostUseCase;
  final GetCommunitiesUseCase getCommunitiesUseCase;
  final GetChatMessagesUseCase getChatMessagesUseCase;
  final SendChatMessageUseCase sendChatMessageUseCase;

  SocialBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.likePostUseCase,
    required this.getCommunitiesUseCase,
    required this.getChatMessagesUseCase,
    required this.sendChatMessageUseCase,
  }) : super(SocialInitialState()) {

    on<FetchPostsAndCommunitiesEvent>((event, emit) async {
      emit(SocialLoadingState());
      final postsResult = await getPostsUseCase();
      final commsResult = await getCommunitiesUseCase();

      postsResult.fold(
        (failure) => emit(SocialFailureState(failure.message)),
        (posts) {
          commsResult.fold(
            (failure) => emit(SocialFailureState(failure.message)),
            (comms) => emit(SocialLoadedState(posts: posts, communities: comms)),
          );
        },
      );
    });

    on<CreatePostEvent>((event, emit) async {
      final postsResult = await createPostUseCase(event.content);
      postsResult.fold(
        (failure) => emit(SocialFailureState(failure.message)),
        (newPost) {
          add(FetchPostsAndCommunitiesEvent());
        },
      );
    });

    on<LikePostEvent>((event, emit) async {
      final likeResult = await likePostUseCase(event.postId);
      likeResult.fold(
        (failure) => emit(SocialFailureState(failure.message)),
        (updatedPost) {
          add(FetchPostsAndCommunitiesEvent());
        },
      );
    });

    on<FetchChatMessagesEvent>((event, emit) async {
      emit(SocialLoadingState());
      final result = await getChatMessagesUseCase(event.roomId);
      result.fold(
        (failure) => emit(SocialFailureState(failure.message)),
        (messages) => emit(ChatLoadedState(messages)),
      );
    });

    on<SendChatMessageEvent>((event, emit) async {
      final result = await sendChatMessageUseCase(event.roomId, event.content);
      result.fold(
        (failure) => emit(SocialFailureState(failure.message)),
        (newMessage) {
          add(FetchChatMessagesEvent(event.roomId));
        },
      );
    });
  }
}
