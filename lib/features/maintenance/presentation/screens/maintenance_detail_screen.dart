import 'package:flutter/material.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/session/session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/auth_network_image.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../data/models/maintenance_record.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final MaintenanceRecord record;

  const MaintenanceDetailScreen({super.key, required this.record});

  String get _photoUrl =>
      '${ApiConfig.baseUrl}/maintenance-records/${record.id}/photo';

  @override
  Widget build(BuildContext context) {
    final currentUser = Session.current;
    final textTheme = Theme.of(context).textTheme;
    final createdAt = record.createdAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.text,
        foregroundColor: AppColors.background,
        toolbarHeight: 72,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              record.companyName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatDate(record.visitDate),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.background.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: RoleBadge(role: currentUser.role)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: 'Firma', value: record.companyName),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Tarih',
                value: formatDate(record.visitDate),
                subValue:
                    createdAt == null
                        ? null
                        : 'Kayıt: ${formatDateTime(createdAt)}',
              ),
              const SizedBox(height: 10),
              _InfoRow(label: 'Kaydeden', value: record.recordedByUserName),
              const SizedBox(height: 28),
              Text('Talep formu', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Büyütmek için fotoğrafa dokun',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => _PhotoViewerScreen(url: _photoUrl),
                      ),
                    ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 380,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: AuthNetworkImage(url: _photoUrl),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;

  const _InfoRow({required this.label, required this.value, this.subValue});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.text.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: textTheme.titleMedium,
                  ),
                  if (subValue != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subValue!,
                      textAlign: TextAlign.end,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors.text.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final String url;

  const _PhotoViewerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: AuthNetworkImage(url: url),
          ),
        ),
      ),
    );
  }
}
