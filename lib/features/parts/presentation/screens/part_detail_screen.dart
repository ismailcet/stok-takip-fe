import 'package:flutter/material.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/session/session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../data/models/part.dart';
import 'edit_part_screen.dart';

class PartDetailScreen extends StatefulWidget {
  final Part part;

  const PartDetailScreen({super.key, required this.part});

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late Part _part;

  @override
  void initState() {
    super.initState();
    _part = widget.part;
  }

  // "Dolap B3" -> "B3"
  String get _cabinetCode => _part.cabinetName.replaceFirst(
    RegExp(r'^dolap\s*', caseSensitive: false),
    '',
  );

  String get _subtitle => [
    _part.brand,
    _part.category,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

  bool _hasValue(String? v) => v != null && v.isNotEmpty;

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Part>(
      MaterialPageRoute(builder: (_) => EditPartScreen(part: _part)),
    );
    if (updated != null && mounted) {
      setState(() => _part = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Parça güncellendi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Session.current;
    final canEdit = currentUser?.role.canEditParts ?? false;
    final isLow = _part.stockQuantity <= 5;

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
              _part.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.background),
            ),
            if (_subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                _subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.background.withOpacity(0.6),
                ),
              ),
            ],
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
            children: [
              Text(
                'Şu dolapta',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.text.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DOLAP',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.background.withOpacity(0.85),
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _cabinetCode,
                            style: const TextStyle(
                              fontSize: 64,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _InfoRow(
                label: 'Stokta',
                value: '${_part.stockQuantity} adet',
                valueColor: isLow ? AppColors.danger : AppColors.text,
              ),
              if (_hasValue(_part.brand)) ...[
                const SizedBox(height: 10),
                _InfoRow(label: 'Marka', value: _part.brand!),
              ],
              if (_hasValue(_part.barcode)) ...[
                const SizedBox(height: 10),
                _InfoRow(label: 'Barkod', value: _part.barcode!),
              ],
              if (_hasValue(_part.productCode)) ...[
                const SizedBox(height: 10),
                _InfoRow(label: 'Ürün Kodu', value: _part.productCode!),
              ],
              if (canEdit) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _openEdit,
                  child: const Text('Güncelle'),
                ),
              ],
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
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.text.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
