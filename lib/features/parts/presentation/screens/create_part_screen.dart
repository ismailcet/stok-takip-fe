import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/create_part/create_part_bloc.dart';
import '../../bloc/create_part/create_part_event.dart';
import '../../bloc/create_part/create_part_state.dart';
import '../../data/repositories/cabinet_repository.dart';
import '../../data/repositories/part_repository.dart';
import 'barcode_capture_screen.dart';

class CreatePartScreen extends StatelessWidget {
  const CreatePartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => CreatePartBloc(
            partRepository: PartRepository(),
            cabinetRepository: CabinetRepository(),
          )..add(const CreatePartStarted()),
      child: const _CreatePartView(),
    );
  }
}

class _CreatePartView extends StatefulWidget {
  const _CreatePartView();

  @override
  State<_CreatePartView> createState() => _CreatePartViewState();
}

class _CreatePartViewState extends State<_CreatePartView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _scanCode(BuildContext context) async {
    final bloc = context.read<CreatePartBloc>();
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeCaptureScreen()),
    );
    if (code == null || code.isEmpty) return;
    _codeController.text = code;
    bloc.add(CreatePartCodeChanged(code));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<CreatePartBloc, CreatePartState>(
          listenWhen:
              (p, c) => p.createdPart != c.createdPart && c.createdPart != null,
          listener:
              (context, state) => Navigator.of(context).pop(state.createdPart),
        ),
        BlocListener<CreatePartBloc, CreatePartState>(
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
            'Yeni Parça',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CreatePartBloc, CreatePartState>(
            builder: (context, state) {
              final bloc = context.read<CreatePartBloc>();
              final isBarcode = state.codeType == CodeType.barcode;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parça adı', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (v) => bloc.add(CreatePartNameChanged(v)),
                      decoration: const InputDecoration(
                        hintText: 'Örn. Fren Balatası',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Kod tipi', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeChip(
                            label: 'Barkod',
                            selected: isBarcode,
                            onTap:
                                () => bloc.add(
                                  const CreatePartCodeTypeChanged(
                                    CodeType.barcode,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TypeChip(
                            label: 'Ürün Kodu',
                            selected: !isBarcode,
                            onTap:
                                () => bloc.add(
                                  const CreatePartCodeTypeChanged(
                                    CodeType.productCode,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      onChanged: (v) => bloc.add(CreatePartCodeChanged(v)),
                      decoration: InputDecoration(
                        hintText: isBarcode ? 'Barkod numarası' : 'Ürün kodu',
                        suffixIcon: IconButton(
                          tooltip: 'Kamerayla oku',
                          onPressed: () => _scanCode(context),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Dolap', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (state.loadingCabinets)
                      const Center(child: CircularProgressIndicator())
                    else if (state.cabinets.isEmpty)
                      TextButton(
                        onPressed: () => bloc.add(const CreatePartStarted()),
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
                                  (_) => bloc.add(
                                    CreatePartCabinetSelected(cabinet.id),
                                  ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Text('Başlangıç stoğu', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepButton(
                          icon: Icons.remove,
                          onTap:
                              state.stock > 0
                                  ? () =>
                                      bloc.add(const CreatePartStockChanged(-1))
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
                              () => bloc.add(const CreatePartStockChanged(1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Marka (isteğe bağlı)', style: textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) => bloc.add(CreatePartBrandChanged(v)),
                      decoration: const InputDecoration(hintText: 'Marka'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Kategori (isteğe bağlı)',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (v) => bloc.add(CreatePartCategoryChanged(v)),
                      decoration: const InputDecoration(hintText: 'Örn. Fren'),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed:
                          state.saving
                              ? null
                              : () => bloc.add(const CreatePartSubmitted()),
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

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.background : AppColors.text,
              ),
            ),
          ),
        ),
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
