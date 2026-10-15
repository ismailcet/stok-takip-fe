import 'package:flutter/material.dart';
import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/screens/account_picker_screen.dart';
import 'features/home/presentation/screens/home_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthRepository().restoreSession();
  runApp(StokTakipApp(loggedIn: loggedIn));
}

class StokTakipApp extends StatelessWidget {
  final bool loggedIn;

  const StokTakipApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StokTakip',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: AppTheme.light(),
      home: loggedIn ? const HomeShellScreen() : const AccountPickerScreen(),
    );
  }
}
