import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/company_form_cubit.dart';
import '../../data/models/company_detail.dart';
import '../../data/repositories/company_admin_repository.dart';

class CompanyFormScreen extends StatelessWidget {
  /// null ise yeni firma, doluysa düzenleme.
  final CompanyDetail? existing;

  const CompanyFormScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => CompanyFormCubit(
            repository: CompanyAdminRepository(),
            companyId: existing?.id,
          ),
      child: _CompanyFormView(existing: existing),
    );
  }
}

class _CompanyFormView extends StatefulWidget {
  final CompanyDetail? existing;

  const _CompanyFormView({this.existing});

  @override
  State<_CompanyFormView> createState() => _CompanyFormViewState();
}

class _CompanyFormViewState extends State<_CompanyFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.existing?.address ?? '',
  );
  late final TextEditingController _taxOffice = TextEditingController(
    text: widget.existing?.taxOffice ?? '',
  );
  late final TextEditingController _taxNumber = TextEditingController(
    text: widget.existing?.taxNumber ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.existing?.phone ?? '',
  );

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _taxOffice.dispose();
    _taxNumber.dispose();
    _phone.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label boş olamaz' : null;

  String? _validateTaxNumber(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Vergi numarası boş olamaz';
    if (value.length != 10 && value.length != 11) {
      return 'Vergi numarası 10 veya 11 haneli olmalı';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null; // opsiyonel
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || value.length > 20)
      return 'Geçerli bir telefon numarası girin';
    return null;
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<CompanyFormCubit>().submit(
      CompanyInput(
        name: _name.text.trim(),
        address: _address.text.trim(),
        taxOffice: _taxOffice.text.trim(),
        taxNumber: _taxNumber.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          inputFormatters: formatters,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, counterText: ''),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<CompanyFormCubit, CompanyFormState>(
          listenWhen: (p, c) => !p.success && c.success,
          listener: (context, state) => Navigator.of(context).pop(true),
        ),
        BlocListener<CompanyFormCubit, CompanyFormState>(
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
            _isEdit ? 'Firmayı Düzenle' : 'Yeni Firma',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.background,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CompanyFormCubit, CompanyFormState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(
                        label: 'Firma Adı',
                        controller: _name,
                        hint: 'Örn. Acme Lojistik',
                        capitalization: TextCapitalization.words,
                        maxLength: 150,
                        validator: (v) => _required(v, 'Firma adı'),
                      ),
                      _field(
                        label: 'Adres',
                        controller: _address,
                        hint: 'Mahalle, cadde, ilçe / il',
                        capitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        maxLength: 500,
                        validator: (v) => _required(v, 'Adres'),
                      ),
                      _field(
                        label: 'Vergi Dairesi',
                        controller: _taxOffice,
                        hint: 'Örn. Seyhan',
                        capitalization: TextCapitalization.words,
                        maxLength: 100,
                        validator: (v) => _required(v, 'Vergi dairesi'),
                      ),
                      _field(
                        label: 'Vergi Numarası',
                        controller: _taxNumber,
                        hint: '10 veya 11 haneli',
                        keyboardType: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 11,
                        validator: _validateTaxNumber,
                      ),
                      _field(
                        label: 'Telefon (opsiyonel)',
                        controller: _phone,
                        hint: 'Örn. 0322 123 45 67',
                        keyboardType: TextInputType.phone,
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+()\-\s]'),
                          ),
                        ],
                        maxLength: 20,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: state.saving ? null : () => _submit(context),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
