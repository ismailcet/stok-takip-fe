import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../bloc/manage_users_cubit.dart';
import '../../data/repositories/user_admin_repository.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ManageUsersCubit(repository: UserAdminRepository())..load(),
      child: const _ManageUsersView(),
    );
  }
}

class _ManageUsersView extends StatelessWidget {
  const _ManageUsersView();

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<ManageUsersCubit>();
    final result = await showDialog<_NewUser>(
      context: context,
      builder: (_) => const _NewUserDialog(),
    );
    if (result != null) {
      cubit.add(fullName: result.name, role: result.role, pin: result.pin);
    }
  }

  Future<void> _resetPin(BuildContext context, int id, String name) async {
    final cubit = context.read<ManageUsersCubit>();
    final pin = await showDialog<String>(
      context: context,
      builder: (_) => _ResetPinDialog(userName: name),
    );
    if (pin != null) cubit.resetPin(id, pin);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ManageUsersCubit, ManageUsersState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.text,
          foregroundColor: AppColors.background,
          toolbarHeight: 72,
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            'Kullanıcılar',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ManageUsersCubit, ManageUsersState>(
            builder: (context, state) {
              switch (state.status) {
                case ManageUsersStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ManageUsersStatus.failure:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Liste yüklenemedi.', style: textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<ManageUsersCubit>().load(),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                case ManageUsersStatus.ready:
                  return Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: state.users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.fullName,
                                          style: textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        RoleBadge(role: user.role),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'PIN sıfırla',
                                    onPressed:
                                        state.busy
                                            ? null
                                            : () => _resetPin(
                                              context,
                                              user.id,
                                              user.fullName,
                                            ),
                                    icon: const Icon(Icons.lock_reset),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (state.busy)
                        const Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                    ],
                  );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'manage_users_fab',
          onPressed: () => _add(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Kullanıcı Ekle'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _NewUser {
  final String name;
  final UserRole role;
  final String pin;

  const _NewUser(this.name, this.role, this.pin);
}

class _NewUserDialog extends StatefulWidget {
  const _NewUserDialog();

  @override
  State<_NewUserDialog> createState() => _NewUserDialogState();
}

class _NewUserDialogState extends State<_NewUserDialog> {
  final _name = TextEditingController();
  final _pin = TextEditingController();
  UserRole _role = UserRole.cirak;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final pin = _pin.text;
    if (name.isEmpty) {
      setState(() => _error = 'İsim boş olamaz');
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _error = 'PIN 4 haneli olmalı');
      return;
    }
    Navigator.of(context).pop(_NewUser(name, _role, pin));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text('Yeni Kullanıcı'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Ad Soyad'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final role in UserRole.values)
                  ChoiceChip(
                    label: Text(role.label),
                    selected: _role == role,
                    onSelected: (_) => setState(() => _role = role),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              decoration: const InputDecoration(
                hintText: '4 haneli PIN',
                counterText: '',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.dangerDark),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        TextButton(onPressed: _submit, child: const Text('Ekle')),
      ],
    );
  }
}

class _ResetPinDialog extends StatefulWidget {
  final String userName;

  const _ResetPinDialog({required this.userName});

  @override
  State<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends State<_ResetPinDialog> {
  final _pin = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  void _submit() {
    if (!RegExp(r'^\d{4}$').hasMatch(_pin.text)) {
      setState(() => _error = 'PIN 4 haneli olmalı');
      return;
    }
    Navigator.of(context).pop(_pin.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text('${widget.userName} için yeni PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _pin,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 4,
            decoration: const InputDecoration(
              hintText: '4 haneli PIN',
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.dangerDark)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        TextButton(onPressed: _submit, child: const Text('Kaydet')),
      ],
    );
  }
}
