import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../data/models/maintenance_record.dart';

class MaintenanceTile extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback? onTap;

  const MaintenanceTile({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.companyName, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(record.visitDate),
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kaydeden: ${record.recordedByUserName}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.text.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
