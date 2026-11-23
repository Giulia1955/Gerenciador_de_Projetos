import 'package:flutter/material.dart';

import '../providers/wisdom_provider.dart';
import '../theme/app_theme.dart';

class OwlWisdomPill extends StatelessWidget {
  const OwlWisdomPill({super.key, required this.provider});
  final WisdomProvider provider;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: AppTheme.deepBlue,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35))),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.accent),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    '${provider.quote.text}\n— ${provider.quote.author}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            if (provider.isLoading)
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
