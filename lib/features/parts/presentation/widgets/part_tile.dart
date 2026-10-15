import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/part.dart';

class PartTile extends StatelessWidget {
  final Part part;
  final VoidCallback? onTap;

  const PartTile({super.key, required this.part, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLow = part.stockQuantity <= 5;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        part.cabinetName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${part.stockQuantity}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isLow ? AppColors.danger : AppColors.text,
                    ),
                  ),
                  Text(
                    'adet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.text.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
