import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/company.dart';

/// Seçici sonucu. `companyId == null` "Hepsi" demektir.
/// Panel seçim yapılmadan kapatılırsa `showCompanyPicker` null döner.
class CompanyPickResult {
  final int? companyId;
  const CompanyPickResult(this.companyId);
}

Future<CompanyPickResult?> showCompanyPicker(
  BuildContext context, {
  required List<Company> companies,
  int? selectedId,
  bool allowAll = false,
}) {
  return showModalBottomSheet<CompanyPickResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder:
        (_) => _CompanyPickerSheet(
          companies: companies,
          selectedId: selectedId,
          allowAll: allowAll,
        ),
  );
}

class _Entry {
  final int? id;
  final String name;
  const _Entry(this.id, this.name);
}

String _normalize(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

class _CompanyPickerSheet extends StatefulWidget {
  final List<Company> companies;
  final int? selectedId;
  final bool allowAll;

  const _CompanyPickerSheet({
    required this.companies,
    required this.selectedId,
    required this.allowAll,
  });

  @override
  State<_CompanyPickerSheet> createState() => _CompanyPickerSheetState();
}

class _CompanyPickerSheetState extends State<_CompanyPickerSheet> {
  String _query = '';

  List<_Entry> get _entries {
    final q = _normalize(_query.trim());
    final all = <_Entry>[
      if (widget.allowAll) const _Entry(null, 'Hepsi'),
      for (final c in widget.companies) _Entry(c.id, c.name),
    ];
    if (q.isEmpty) return all;
    return all.where((e) => _normalize(e.name).contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final entries = _entries;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.text.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Firma seç', style: textTheme.titleLarge),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Firma ara',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  entries.isEmpty
                      ? const Center(child: Text('Firma bulunamadı.'))
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final selected = entry.id == widget.selectedId;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap:
                                () => Navigator.of(
                                  context,
                                ).pop(CompanyPickResult(entry.id)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.name,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            selected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                        color:
                                            selected
                                                ? AppColors.accentDark
                                                : AppColors.text,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.check,
                                      color: AppColors.accent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dokununca seçici açan, input görünümlü alan.
class PickerField extends StatelessWidget {
  final String text;
  final bool isPlaceholder;
  final bool highlighted;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.text,
    required this.onTap,
    this.isPlaceholder = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isPlaceholder ? FontWeight.w500 : FontWeight.w700,
                    color:
                        highlighted
                            ? AppColors.background
                            : (isPlaceholder
                                ? AppColors.text.withOpacity(0.5)
                                : AppColors.text),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: highlighted ? AppColors.background : AppColors.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
