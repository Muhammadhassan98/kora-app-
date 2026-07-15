import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantkora/main.dart';
import 'package:fantkora/core/di/injection.dart';
import 'package:fantkora/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  MockAuthBloc() : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) {
      // Do nothing for smoke tests
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    // Register MockAuthBloc inside getIt to satisfy the dependency in LoginPage
    getIt.registerLazySingleton<AuthBloc>(() => MockAuthBloc());
  });

  testWidgets('Splash page loading smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FantKoraApp());
    await tester.pump(); // let GoRouter build the initial route

    // Verify that the brand name is found on Splash screen.
    expect(find.text('FantKora'), findsOneWidget);

    // Let the splash screen timer run out so the test cleans up cleanly.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(); // Let router complete transitions
  });
}
