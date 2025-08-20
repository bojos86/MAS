import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Welcome to MAS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('AI Mobile Banking • Prototype build'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Accounts (Demo)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('KWD Current – 12XXXXXXXX34 • 4,250.000 KWD'),
                Text('USD Savings – 22XXXXXXXX56 • 18,120.00 USD'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
