import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to Auth after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/auth');
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
