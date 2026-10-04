import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/account_picker_screen.dart';

void main() {
  runApp(const StokTakipApp());
}

class StokTakipApp extends StatelessWidget {
  const StokTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StokTakip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AccountPickerScreen(),
    );
  }
}
