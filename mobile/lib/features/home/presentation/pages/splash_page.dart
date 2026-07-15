import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fantkora/core/storage/local_storage.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate after checking local storage session
    Future.delayed(const Duration(seconds: 2), () async {
      final localStorage = LocalStorage();
      final token = await localStorage.read<String>('auth', 'token');
      final isGuest = await localStorage.read<bool>('settings', 'is_guest');

      if (context.mounted) {
        if (token != null || isGuest == true) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80.0, color: Colors.green),
            SizedBox(height: 16.0),
            Text(
              'FantKora',
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
