import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../bloc/maintenance_bloc.dart';
import '../../bloc/maintenance_event.dart';
import '../../bloc/maintenance_state.dart';
import '../../data/models/maintenance_record.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../widgets/company_picker.dart';
import '../widgets/maintenance_tile.dart';
import 'create_maintenance_screen.dart';
import 'maintenance_detail_screen.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              MaintenanceBloc(repository: MaintenanceRepository())
                ..add(const MaintenanceRequested()),
      child: const _MaintenanceView(),
    );
  }
}

class _MaintenanceView extends StatelessWidget {
  const _MaintenanceView();

  Future<void> _openCreate(BuildContext context) async {
    final bloc = context.read<MaintenanceBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final created = await Navigator.of(context).push<MaintenanceRecord>(
      MaterialPageRoute(builder: (_) => const CreateMaintenanceScreen()),
    );
    if (created != null) {
      bloc.add(const MaintenanceRequested());
      messenger.showSnackBar(
        SnackBar(content: Text('${created.companyName} bakımı kaydedildi')),
      );
    }
  }

  void _openDetail(BuildContext context, MaintenanceRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaintenanceDetailScreen(record: record),
      ),
    );
  }

  Future<void> _pickCompany(
    BuildContext context,
    MaintenanceState state,
  ) async {
    final bloc = context.read<MaintenanceBloc>();
    final result = await showCompanyPicker(
      context,
      companies: state.companies,
      selectedId: state.selectedCompanyId,
      allowAll: true,
    );
    if (result != null) bloc.add(MaintenanceCompanySelected(result.companyId));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Session.current;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.text,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bakımlar',
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Servis ziyaretleri',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.background.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (currentUser != null) RoleBadge(role: currentUser.role),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Firma filtresi
            BlocBuilder<MaintenanceBloc, MaintenanceState>(
              buildWhen:
                  (p, c) =>
                      p.companies != c.companies ||
                      p.selectedCompanyId != c.selectedCompanyId,
              builder: (context, state) {
                if (state.companies.isEmpty) return const SizedBox(height: 12);
                final selectedName =
                    state.companies
                        .where((c) => c.id == state.selectedCompanyId)
                        .map((c) => c.name)
                        .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: PickerField(
                    text: 'Firma: ${selectedName ?? 'Hepsi'}',
                    highlighted: selectedName != null,
                    onTap: () => _pickCompany(context, state),
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
                builder: (context, state) {
                  switch (state.status) {
                    case MaintenanceStatus.initial:
                    case MaintenanceStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case MaintenanceStatus.failure:
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Bakımlar yüklenemedi.\n${state.errorMessage}',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed:
                                    () => context.read<MaintenanceBloc>().add(
                                      const MaintenanceRequested(),
                                    ),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      );
                    case MaintenanceStatus.success:
                      if (state.records.isEmpty) {
                        return const Center(
                          child: Text('Henüz bakım kaydı yok.'),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh:
                            () async => context.read<MaintenanceBloc>().add(
                              const MaintenanceRequested(),
                            ),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: state.records.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final record = state.records[index];
                            return MaintenanceTile(
                              record: record,
                              onTap: () => _openDetail(context, record),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'maintenance_fab',
        onPressed: () => _openCreate(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Bakım'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
