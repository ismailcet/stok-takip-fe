import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/user_account.dart';

class AccountTile extends StatelessWidget {
  final UserAccount account;
  final VoidCallback onTap;

  const AccountTile({super.key, required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUsta = account.role == UserRole.usta;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    isUsta ? AppColors.accent : AppColors.accentGreen,
                child: Text(
                  account.fullName.isNotEmpty
                      ? account.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.role.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
