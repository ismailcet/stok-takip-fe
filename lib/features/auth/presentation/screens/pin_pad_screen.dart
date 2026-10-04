import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pin_keypad.dart';

class PinPadScreen extends StatelessWidget {
  final UserAccount account;

  const PinPadScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              LoginBloc(authRepository: AuthRepository(), userId: account.id),
      child: _PinPadView(account: account),
    );
  }
}

class _PinPadView extends StatelessWidget {
  final UserAccount account;

  const _PinPadView({required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(account.fullName)),
      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              // TODO: Parçalar/ana ekran hazır olduğunda buraya yönlendir.
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Giriş başarılı')));
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Şifreni gir',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      PinDots(
                        filled: state.pin.length,
                        length: 4,
                        hasError: state.status == LoginStatus.failure,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 26,
                        child:
                            state.status == LoginStatus.failure
                                ? Text(
                                  state.errorMessage ?? '',
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                  ),
                                )
                                : (state.status == LoginStatus.submitting
                                    ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                    : null),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              PinKeypad(
                onDigit:
                    (d) => context.read<LoginBloc>().add(LoginDigitAdded(d)),
                onBackspace:
                    () => context.read<LoginBloc>().add(
                      const LoginDigitRemoved(),
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
