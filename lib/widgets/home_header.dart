import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hidden Bites',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover hidden cafés, local food, and cozy corners.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}
