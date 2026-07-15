import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthRegisterEvent extends AuthEvent {
  final String? email;
  final String? phoneNumber;
  final String password;
  final String username;

  const AuthRegisterEvent({
    this.email,
    this.phoneNumber,
    required this.password,
    required this.username,
  });

  @override
  List<Object?> get props => [email, phoneNumber, password, username];
}

class AuthLoginEvent extends AuthEvent {
  final String? email;
  final String? phoneNumber;
  final String password;

  const AuthLoginEvent({
    this.email,
    this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [email, phoneNumber, password];
}

class AuthSendOtpEvent extends AuthEvent {
  final String target;

  const AuthSendOtpEvent({required this.target});

  @override
  List<Object?> get props => [target];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String target;
  final String code;

  const AuthVerifyOtpEvent({required this.target, required this.code});

  @override
  List<Object?> get props => [target, code];
}

class AuthLogoutEvent extends AuthEvent {}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final UserEntity user;
  const AuthSuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthOtpSentState extends AuthState {
  final String target;
  const AuthOtpSentState(this.target);

  @override
  List<Object?> get props => [target];
}

class AuthOtpVerifiedState extends AuthState {
  final String target;
  const AuthOtpVerifiedState(this.target);

  @override
  List<Object?> get props => [target];
}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  AuthBloc({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(AuthInitialState()) {
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLoginEvent>(_onLogin);
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await registerUseCase(
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      username: event.username,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccessState(user)),
    );
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await loginUseCase(
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthSuccessState(user)),
    );
  }

  Future<void> _onSendOtp(AuthSendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await sendOtpUseCase(target: event.target);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (success) => emit(AuthOtpSentState(event.target)),
    );
  }

  Future<void> _onVerifyOtp(AuthVerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await verifyOtpUseCase(target: event.target, code: event.code);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (success) => emit(AuthOtpVerifiedState(event.target)),
    );
  }

  void _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) {
    emit(AuthInitialState());
  }
}
