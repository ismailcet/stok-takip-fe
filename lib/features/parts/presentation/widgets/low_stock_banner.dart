import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LowStockBanner extends StatelessWidget {
  final int count;
  final bool active;
  final VoidCallback onTap;

  const LowStockBanner({
    super.key,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              active
                  ? AppColors.accentLight.withOpacity(0.35)
                  : AppColors.accentLight.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.accentDark,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count parça bitiyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accentDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    active
                        ? 'Dokun, tüm parçaları göster'
                        : 'Dokun, sadece onları göster',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentDark.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
