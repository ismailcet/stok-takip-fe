import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/company_detail.dart';
import '../data/repositories/company_admin_repository.dart';

class CompanyFormState extends Equatable {
  final bool saving;
  final bool success;
  final String? errorMessage;

  const CompanyFormState({
    this.saving = false,
    this.success = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [saving, success, errorMessage];
}

class CompanyFormCubit extends Cubit<CompanyFormState> {
  CompanyFormCubit({required CompanyAdminRepository repository, this.companyId})
    : _repository = repository,
      super(const CompanyFormState());

  final CompanyAdminRepository _repository;

  /// null ise yeni firma oluşturulur, doluysa güncellenir.
  final int? companyId;

  Future<void> submit(CompanyInput input) async {
    emit(const CompanyFormState(saving: true));
    try {
      if (companyId == null) {
        await _repository.create(input);
      } else {
        await _repository.update(companyId!, input);
      }
      emit(const CompanyFormState(success: true));
    } catch (e) {
      final text = e.toString();
      emit(
        CompanyFormState(
          errorMessage:
              text.contains('(409)')
                  ? 'Bu isimde bir firma zaten var'
                  : text.contains('(400)')
                  ? 'Bilgileri kontrol edin'
                  : 'Kaydedilemedi, tekrar deneyin',
        ),
      );
    }
  }
}
