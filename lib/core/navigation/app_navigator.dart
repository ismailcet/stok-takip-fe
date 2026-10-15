import 'package:flutter/material.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/screens/account_picker_screen.dart';

/// MaterialApp'e `navigatorKey` olarak verilir; context'siz yönlendirme için.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

bool _handlingExpiry = false;

/// Oturum geçersizse (401) oturumu temizler ve giriş ekranına döner.
Future<void> handleSessionExpired() async {
  if (_handlingExpiry) return;
  _handlingExpiry = true;
  try {
    await AuthRepository().logout();
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccountPickerScreen()),
      (route) => false,
    );

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Oturum süresi doldu, tekrar giriş yap'),
            ),
          );
      });
    }
  } finally {
    _handlingExpiry = false;
  }
}
