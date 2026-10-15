import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../bloc/create_maintenance/create_maintenance_bloc.dart';
import '../../bloc/create_maintenance/create_maintenance_event.dart';
import '../../bloc/create_maintenance/create_maintenance_state.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../widgets/company_picker.dart';

class CreateMaintenanceScreen extends StatelessWidget {
  const CreateMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              CreateMaintenanceBloc(repository: MaintenanceRepository())
                ..add(const CreateMaintenanceStarted()),
      child: const _CreateMaintenanceView(),
    );
  }
}

class _CreateMaintenanceView extends StatelessWidget {
  const _CreateMaintenanceView();

  Future<void> _pickCompany(
    BuildContext context,
    CreateMaintenanceState state,
  ) async {
    final bloc = context.read<CreateMaintenanceBloc>();
    final result = await showCompanyPicker(
      context,
      companies: state.companies,
      selectedId: state.companyId,
    );
    final id = result?.companyId;
    if (id != null) bloc.add(CreateMaintenanceCompanySelected(id));
  }

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final bloc = context.read<CreateMaintenanceBloc>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1800,
      );
      if (file != null) bloc.add(CreateMaintenancePhotoSelected(file.path));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf alınamadı (kamera/galeri izni?)'),
        ),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final bloc = context.read<CreateMaintenanceBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) bloc.add(CreateMaintenanceDateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<CreateMaintenanceBloc, CreateMaintenanceState>(
          listenWhen: (p, c) => p.created != c.created && c.created != null,
          listener:
              (context, state) => Navigator.of(context).pop(state.created),
        ),
        BlocListener<CreateMaintenanceBloc, CreateMaintenanceState>(
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
            'Yeni Bakım',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CreateMaintenanceBloc, CreateMaintenanceState>(
            builder: (context, state) {
              final bloc = context.read<CreateMaintenanceBloc>();
              final selectedName =
                  state.companies
                      .where((c) => c.id == state.companyId)
                      .map((c) => c.name)
                      .firstOrNull;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Firma', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (state.loadingCompanies)
                      const Center(child: CircularProgressIndicator())
                    else if (state.companies.isEmpty)
                      TextButton(
                        onPressed:
                            () => bloc.add(const CreateMaintenanceStarted()),
                        child: const Text('Firma bulunamadı, tekrar dene'),
                      )
                    else
                      PickerField(
                        text: selectedName ?? 'Firma seç',
                        isPlaceholder: selectedName == null,
                        onTap: () => _pickCompany(context, state),
                      ),
                    const SizedBox(height: 28),
                    Text('Gün', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatDate(state.date),
                                style: textTheme.titleMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _pickDate(context, state.date),
                              child: const Text('Değiştir'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Talep formu fotoğrafı', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (state.photoPath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          File(state.photoPath!),
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                () => _pickPhoto(context, ImageSource.camera),
                            icon: const Icon(Icons.photo_camera),
                            label: const Text('Çek'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                () => _pickPhoto(context, ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galeri'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          state.saving
                              ? null
                              : () =>
                                  bloc.add(const CreateMaintenanceSubmitted()),
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
