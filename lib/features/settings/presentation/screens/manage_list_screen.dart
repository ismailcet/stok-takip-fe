import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/manage_list_cubit.dart';
import '../../data/repositories/named_item_repository.dart';

class ManageListScreen extends StatelessWidget {
  /// Başlık, örn. "Firmalar"
  final String title;

  /// Tekil ad, örn. "Firma"
  final String singular;

  /// API yolu, örn. "/companies"
  final String path;

  /// Silme 409 dönerse gösterilecek mesaj.
  final String deleteBlockedMessage;

  const ManageListScreen({
    super.key,
    required this.title,
    required this.singular,
    required this.path,
    required this.deleteBlockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ManageListCubit(
            repository: NamedItemRepository(path: path),
            deleteBlockedMessage: deleteBlockedMessage,
          )..load(),
      child: _ManageListView(title: title, singular: singular),
    );
  }
}

class _ManageListView extends StatelessWidget {
  final String title;
  final String singular;

  const _ManageListView({required this.title, required this.singular});

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<ManageListCubit>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: 'Yeni $singular'),
    );
    if (name != null && name.isNotEmpty) cubit.add(name);
  }

  Future<void> _rename(BuildContext context, int id, String current) async {
    final cubit = context.read<ManageListCubit>();
    final name = await showDialog<String>(
      context: context,
      builder:
          (_) =>
              _NameDialog(title: '$singular adını düzenle', initial: current),
    );
    if (name != null && name.isNotEmpty && name != current)
      cubit.rename(id, name);
  }

  Future<void> _delete(BuildContext context, int id, String name) async {
    final cubit = context.read<ManageListCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text('$singular silinsin mi?'),
            content: Text(name),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
    if (confirmed == true) cubit.remove(id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ManageListCubit, ManageListState>(
      listenWhen:
          (p, c) => c.errorMessage != null && p.errorMessage != c.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.text,
          foregroundColor: AppColors.background,
          toolbarHeight: 72,
          centerTitle: false,
          titleSpacing: 0,
          title: Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ManageListCubit, ManageListState>(
            builder: (context, state) {
              switch (state.status) {
                case ManageListStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ManageListStatus.failure:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Liste yüklenemedi.', style: textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<ManageListCubit>().load(),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                case ManageListStatus.ready:
                  if (state.items.isEmpty) {
                    return Center(child: Text('Henüz $singular yok.'));
                  }
                  return Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: textTheme.titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Düzenle',
                                    onPressed:
                                        state.busy
                                            ? null
                                            : () => _rename(
                                              context,
                                              item.id,
                                              item.name,
                                            ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Sil',
                                    onPressed:
                                        state.busy
                                            ? null
                                            : () => _delete(
                                              context,
                                              item.id,
                                              item.name,
                                            ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.dangerDark,
                                    ),
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
          heroTag: 'manage_fab',
          onPressed: () => _add(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          icon: const Icon(Icons.add),
          label: Text('$singular Ekle'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  final String title;
  final String? initial;

  const _NameDialog({required this.title, this.initial});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: 'İsim'),
        onSubmitted: (_) => _submit(),
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
