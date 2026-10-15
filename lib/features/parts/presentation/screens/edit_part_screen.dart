import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/edit_part/edit_part_bloc.dart';
import '../../bloc/edit_part/edit_part_event.dart';
import '../../bloc/edit_part/edit_part_state.dart';
import '../../data/models/part.dart';
import '../../data/repositories/cabinet_repository.dart';
import '../../data/repositories/part_repository.dart';

class EditPartScreen extends StatelessWidget {
  final Part part;

  const EditPartScreen({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => EditPartBloc(
            part: part,
            partRepository: PartRepository(),
            cabinetRepository: CabinetRepository(),
          )..add(const EditPartStarted()),
      child: _EditPartView(part: part),
    );
  }
}

class _EditPartView extends StatefulWidget {
  final Part part;
  const _EditPartView({required this.part});

  @override
  State<_EditPartView> createState() => _EditPartViewState();
}

class _EditPartViewState extends State<_EditPartView> {
  late final TextEditingController _brandController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.part.brand ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final part = widget.part;

    return MultiBlocListener(
      listeners: [
        BlocListener<EditPartBloc, EditPartState>(
          listenWhen:
              (p, c) => p.savedPart != c.savedPart && c.savedPart != null,
          listener:
              (context, state) => Navigator.of(context).pop(state.savedPart),
        ),
        BlocListener<EditPartBloc, EditPartState>(
          listenWhen:
              (p, c) =>
                  c.errorMessage != null && p.errorMessage != c.errorMessage,
          listener: (context, state) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
            'Parçayı Güncelle',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<EditPartBloc, EditPartState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(part.name, style: textTheme.headlineMedium),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            if (part.barcode != null &&
                                part.barcode!.isNotEmpty)
                              _ReadOnlyRow(
                                label: 'Barkod',
                                value: part.barcode!,
                              ),
                            if (part.productCode != null &&
                                part.productCode!.isNotEmpty)
                              _ReadOnlyRow(
                                label: 'Ürün Kodu',
                                value: part.productCode!,
                              ),
                            _ReadOnlyRow(label: 'ID', value: '#${part.id}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Stok', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepButton(
                          icon: Icons.remove,
                          onTap:
                              state.stock > 0
                                  ? () => context.read<EditPartBloc>().add(
                                    const EditPartStockChanged(-1),
                                  )
                                  : null,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${state.stock}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        _StepButton(
                          icon: Icons.add,
                          onTap:
                              () => context.read<EditPartBloc>().add(
                                const EditPartStockChanged(1),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Dolap', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (state.loadingCabinets)
                      const Center(child: CircularProgressIndicator())
                    else if (state.cabinets.isEmpty)
                      TextButton(
                        onPressed:
                            () => context.read<EditPartBloc>().add(
                              const EditPartStarted(),
                            ),
                        child: const Text('Dolaplar yüklenemedi, tekrar dene'),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final cabinet in state.cabinets)
                            ChoiceChip(
                              label: Text(cabinet.name),
                              selected: cabinet.id == state.cabinetId,
                              selectedColor: AppColors.accent,
                              backgroundColor: AppColors.surface,
                              showCheckmark: false,
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    cabinet.id == state.cabinetId
                                        ? AppColors.background
                                        : AppColors.text,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              onSelected:
                                  (_) => context.read<EditPartBloc>().add(
                                    EditPartCabinetSelected(cabinet.id),
                                  ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 28),
                    Text('Marka', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _brandController,
                      onChanged:
                          (v) => context.read<EditPartBloc>().add(
                            EditPartBrandChanged(v),
                          ),
                      decoration: const InputDecoration(hintText: 'Marka'),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          state.saving
                              ? null
                              : () => context.read<EditPartBloc>().add(
                                const EditPartSubmitted(),
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

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.text.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.accent : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Icon(
            icon,
            size: 34,
            color:
                enabled
                    ? AppColors.background
                    : AppColors.text.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
