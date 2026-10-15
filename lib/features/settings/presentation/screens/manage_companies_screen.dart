import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/manage_companies_cubit.dart';
import '../../data/models/company_detail.dart';
import '../../data/repositories/company_admin_repository.dart';
import 'company_form_screen.dart';

class ManageCompaniesScreen extends StatelessWidget {
  const ManageCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ManageCompaniesCubit(repository: CompanyAdminRepository())
                ..load(),
      child: const _ManageCompaniesView(),
    );
  }
}

class _ManageCompaniesView extends StatelessWidget {
  const _ManageCompaniesView();

  Future<void> _openForm(
    BuildContext context, {
    CompanyDetail? existing,
  }) async {
    final cubit = context.read<ManageCompaniesCubit>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CompanyFormScreen(existing: existing)),
    );
    if (saved == true) cubit.load();
  }

  Future<void> _delete(BuildContext context, CompanyDetail company) async {
    final cubit = context.read<ManageCompaniesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text('Firma silinsin mi?'),
            content: Text(company.name),
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
    if (confirmed == true) cubit.remove(company.id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ManageCompaniesCubit, ManageCompaniesState>(
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
            'Firmalar',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ManageCompaniesCubit, ManageCompaniesState>(
            builder: (context, state) {
              switch (state.status) {
                case ManageCompaniesStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case ManageCompaniesStatus.failure:
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Liste yüklenemedi.', style: textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => context.read<ManageCompaniesCubit>().load(),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                case ManageCompaniesStatus.ready:
                  if (state.companies.isEmpty) {
                    return const Center(child: Text('Henüz firma yok.'));
                  }
                  return Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: state.companies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final company = state.companies[index];
                          return _CompanyCard(
                            company: company,
                            busy: state.busy,
                            onTap: () => _openForm(context, existing: company),
                            onToggleHidden:
                                () => context
                                    .read<ManageCompaniesCubit>()
                                    .setHidden(company.id, !company.hidden),
                            onDelete: () => _delete(context, company),
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
          heroTag: 'manage_companies_fab',
          onPressed: () => _openForm(context),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          icon: const Icon(Icons.add),
          label: const Text('Firma Ekle'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final CompanyDetail company;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onToggleHidden;
  final VoidCallback onDelete;

  const _CompanyCard({
    required this.company,
    required this.busy,
    required this.onTap,
    required this.onToggleHidden,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyMedium?.copyWith(
      color: AppColors.text.withOpacity(0.65),
    );

    final taxParts = <String>[
      if (company.taxOffice != null && company.taxOffice!.isNotEmpty)
        company.taxOffice!,
      if (company.taxNumber != null && company.taxNumber!.isNotEmpty)
        company.taxNumber!,
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Opacity(
                  opacity: company.hidden ? 0.6 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.name, style: textTheme.titleMedium),
                      if (company.hidden) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.visibility_off_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('Gizli', style: textTheme.bodyMedium),
                          ],
                        ),
                      ],
                      if (company.hasMissingInfo) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.dangerDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Bilgiler eksik, düzenle',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.dangerDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (taxParts.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(taxParts.join(' · '), style: muted),
                      ],
                      if (company.address != null &&
                          company.address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(company.address!, style: muted),
                      ],
                      if (company.phone != null &&
                          company.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(company.phone!, style: muted),
                      ],
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: company.hidden ? 'Göster' : 'Gizle',
                    onPressed: busy ? null : onToggleHidden,
                    icon: Icon(
                      company.hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sil',
                    onPressed: busy ? null : onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.dangerDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
