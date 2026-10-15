import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/session/session.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../bloc/parts_bloc.dart';
import '../../bloc/parts_event.dart';
import '../../bloc/parts_state.dart';
import '../../data/models/part.dart';
import '../../data/repositories/part_repository.dart';
import '../widgets/low_stock_banner.dart';
import '../widgets/part_tile.dart';
import 'barcode_scan_screen.dart';
import 'create_part_screen.dart';
import 'part_detail_screen.dart';

class PartsScreen extends StatelessWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              PartsBloc(partRepository: PartRepository())
                ..add(const PartsRequested()),
      child: const _PartsView(),
    );
  }
}

class _PartsView extends StatefulWidget {
  const _PartsView();

  @override
  State<_PartsView> createState() => _PartsViewState();
}

class _PartsViewState extends State<_PartsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(BuildContext context, Part part) async {
    final bloc = context.read<PartsBloc>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PartDetailScreen(part: part)));
    bloc.add(const PartsRequested());
  }

  Future<void> _openScanner(BuildContext context) async {
    final bloc = context.read<PartsBloc>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BarcodeScanScreen()));
    bloc.add(const PartsRequested());
  }

  Future<void> _openCreate(BuildContext context) async {
    final bloc = context.read<PartsBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final created = await Navigator.of(
      context,
    ).push<Part>(MaterialPageRoute(builder: (_) => const CreatePartScreen()));
    if (created != null) {
      bloc.add(const PartsRequested());
      messenger.showSnackBar(
        SnackBar(content: Text('${created.name} eklendi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Session.current;
    final canEdit = currentUser?.role.canEditParts ?? false;

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
                    'Parçalar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dükkan deposu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.background.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              IconButton(
                onPressed: () => _openCreate(context),
                tooltip: 'Yeni parça',
                icon: const Icon(
                  Icons.add_circle,
                  size: 32,
                  color: AppColors.accentLight,
                ),
              ),
            if (currentUser != null) RoleBadge(role: currentUser.role),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged:
                    (q) => context.read<PartsBloc>().add(PartsSearchChanged(q)),
                decoration: const InputDecoration(
                  hintText: 'Parça ara',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            BlocBuilder<PartsBloc, PartsState>(
              buildWhen:
                  (p, c) =>
                      p.lowStockCount != c.lowStockCount ||
                      p.lowStockOnly != c.lowStockOnly,
              builder: (context, state) {
                if (state.lowStockCount == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: LowStockBanner(
                    count: state.lowStockCount,
                    active: state.lowStockOnly,
                    onTap:
                        () => context.read<PartsBloc>().add(
                          const PartsLowStockFilterToggled(),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PartsBloc, PartsState>(
                builder: (context, state) {
                  switch (state.status) {
                    case PartsStatus.initial:
                    case PartsStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case PartsStatus.failure:
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Parçalar yüklenemedi.\n${state.errorMessage}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed:
                                    () => context.read<PartsBloc>().add(
                                      const PartsRequested(),
                                    ),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                      );
                    case PartsStatus.success:
                      if (state.parts.isEmpty) {
                        return const Center(child: Text('Parça bulunamadı.'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: state.parts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final part = state.parts[index];
                          return PartTile(
                            part: part,
                            onTap: () => _openDetail(context, part),
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'parts_fab',
        onPressed: () => _openScanner(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Barkod Tara'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
