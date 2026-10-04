import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/accounts/accounts_bloc.dart';
import '../../bloc/accounts/accounts_event.dart';
import '../../bloc/accounts/accounts_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/account_tile.dart';
import 'pin_pad_screen.dart';

class AccountPickerScreen extends StatelessWidget {
  const AccountPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AccountsBloc(authRepository: AuthRepository())
                ..add(const AccountsRequested()),
      child: const _AccountPickerView(),
    );
  }
}

class _AccountPickerView extends StatelessWidget {
  const _AccountPickerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üçel Forklift')),
      body: SafeArea(
        child: BlocBuilder<AccountsBloc, AccountsState>(
          builder: (context, state) {
            switch (state.status) {
              case AccountsStatus.initial:
              case AccountsStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case AccountsStatus.failure:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hesaplar yüklenemedi.\n${state.errorMessage}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed:
                              () => context.read<AccountsBloc>().add(
                                const AccountsRequested(),
                              ),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                );
              case AccountsStatus.success:
                if (state.accounts.isEmpty) {
                  return const Center(child: Text('Kayıtlı hesap bulunamadı.'));
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kim giriyor?',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: state.accounts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final account = state.accounts[index];
                          return AccountTile(
                            account: account,
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PinPadScreen(account: account),
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
