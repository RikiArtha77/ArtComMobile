import 'package:flutter/material.dart';

class ErrorIndicator extends StatelessWidget {
  final String message;
  final VoidCallback onTryAgain;

  const ErrorIndicator({
    super.key,
    required this.message,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    // Bungkus dengan SingleChildScrollView untuk mencegah overflow
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Oops, terjadi kesalahan',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTryAgain,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}