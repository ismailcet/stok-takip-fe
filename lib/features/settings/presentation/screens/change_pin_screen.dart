import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/change_pin_cubit.dart';
import '../../data/repositories/account_repository.dart';

class ChangePinScreen extends StatelessWidget {
  const ChangePinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChangePinCubit(repository: AccountRepository()),
      child: const _ChangePinView(),
    );
  }
}

class _ChangePinView extends StatefulWidget {
  const _ChangePinView();

  @override
  State<_ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends State<_ChangePinView> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Widget _pinField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 4,
      decoration: InputDecoration(hintText: hint, counterText: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<ChangePinCubit, ChangePinState>(
          listenWhen: (p, c) => !p.success && c.success,
          listener: (context, state) => Navigator.of(context).pop(true),
        ),
        BlocListener<ChangePinCubit, ChangePinState>(
          listenWhen:
              (p, c) =>
                  c.errorMessage != null && p.errorMessage != c.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.text,
          foregroundColor: AppColors.background,
          toolbarHeight: 72,
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            'PIN Değiştir',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ChangePinCubit, ChangePinState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mevcut PIN', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _pinField(_current, '4 haneli PIN'),
                    const SizedBox(height: 24),
                    Text('Yeni PIN', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _pinField(_new, '4 haneli yeni PIN'),
                    const SizedBox(height: 24),
                    Text('Yeni PIN (tekrar)', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _pinField(_confirm, 'Yeni PIN\'i tekrar yaz'),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          state.saving
                              ? null
                              : () => context.read<ChangePinCubit>().submit(
                                current: _current.text,
                                newPin: _new.text,
                                confirm: _confirm.text,
                              ),
                      child:
                          state.saving
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.background,
                                ),
                              )
                              : const Text('Kaydet'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed:
                          state.saving
                              ? null
                              : () => Navigator.of(context).pop(),
                      child: const Text('Vazgeç'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
