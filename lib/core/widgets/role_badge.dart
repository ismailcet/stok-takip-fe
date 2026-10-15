import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (role) {
      case UserRole.admin:
        bg = AppColors.accentDark;
        fg = AppColors.background;
      case UserRole.usta:
        bg = AppColors.accentLight;
        fg = AppColors.accentDark;
      case UserRole.cirak:
        bg = AppColors.accentGreen.withOpacity(0.35);
        fg = AppColors.accentGreenDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role.label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
