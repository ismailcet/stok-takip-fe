import 'package:flutter/material.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/session/session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/account_picker_screen.dart';
import 'change_pin_screen.dart';
import 'manage_list_screen.dart';
import 'manage_users_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _changePin(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ChangePinScreen()));
    if (changed == true) {
      messenger.showSnackBar(const SnackBar(content: Text('PIN değiştirildi')));
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text('Çıkış yapılsın mı?'),
            content: const Text(
              'Tekrar giriş için hesabını seçip PIN girmen gerekecek.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Çıkış Yap'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    await AuthRepository().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccountPickerScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Session.current;
    final textTheme = Theme.of(context).textTheme;
    final canManage = currentUser?.role.canManage ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.text,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ayarlar',
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hesap',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.background.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentUser != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giriş yapan',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.text.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentUser.fullName,
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        RoleBadge(role: currentUser.role),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'PIN Değiştir',
                onTap: () => _changePin(context),
              ),
              if (canManage) ...[
                const SizedBox(height: 28),
                Text('Yönetim', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.business_outlined,
                  title: 'Firmalar',
                  onTap:
                      () => _open(
                        context,
                        const ManageListScreen(
                          title: 'Firmalar',
                          singular: 'Firma',
                          path: '/companies',
                          deleteBlockedMessage:
                              'Bu firmaya ait bakım kaydı var, silinemez',
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.inventory_outlined,
                  title: 'Dolaplar',
                  onTap:
                      () => _open(
                        context,
                        const ManageListScreen(
                          title: 'Dolaplar',
                          singular: 'Dolap',
                          path: '/cabinets',
                          deleteBlockedMessage:
                              'Bu dolapta parça var, silinemez',
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.people_outline,
                  title: 'Kullanıcılar',
                  onTap: () => _open(context, const ManageUsersScreen()),
                ),
              ],
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentDark),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
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
