import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/company_detail.dart';
import '../data/repositories/company_admin_repository.dart';

enum ManageCompaniesStatus { loading, ready, failure }

class ManageCompaniesState extends Equatable {
  final ManageCompaniesStatus status;
  final List<CompanyDetail> companies;
  final bool busy;
  final String? message;

  const ManageCompaniesState({
    this.status = ManageCompaniesStatus.loading,
    this.companies = const [],
    this.busy = false,
    this.message,
  });

  ManageCompaniesState copyWith({
    ManageCompaniesStatus? status,
    List<CompanyDetail>? companies,
    bool? busy,
    String? message,
  }) {
    return ManageCompaniesState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      busy: busy ?? this.busy,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, companies, busy, message];
}

class ManageCompaniesCubit extends Cubit<ManageCompaniesState> {
  ManageCompaniesCubit({required CompanyAdminRepository repository})
    : _repository = repository,
      super(const ManageCompaniesState());

  final CompanyAdminRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ManageCompaniesStatus.loading));
    try {
      final companies = await _repository.list();
      emit(
        state.copyWith(
          status: ManageCompaniesStatus.ready,
          companies: companies,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ManageCompaniesStatus.failure));
    }
  }

  Future<void> setHidden(int id, bool hidden) async {
    emit(state.copyWith(busy: true));
    try {
      await _repository.setHidden(id, hidden);
      final companies = await _repository.list();
      emit(
        state.copyWith(
          status: ManageCompaniesStatus.ready,
          companies: companies,
          busy: false,
          message:
              hidden
                  ? 'Firma gizlendi, yeni bakım kaydında görünmeyecek'
                  : 'Firma tekrar görünür',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(busy: false, message: 'İşlem başarısız, tekrar deneyin'),
      );
    }
  }

  Future<void> remove(int id) async {
    emit(state.copyWith(busy: true));
    try {
      await _repository.delete(id);
      final companies = await _repository.list();
      emit(
        state.copyWith(
          status: ManageCompaniesStatus.ready,
          companies: companies,
          busy: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          busy: false,
          message:
              e.toString().contains('(409)')
                  ? 'Bu firmaya ait bakım kaydı var, silinemez. İstersen firmayı gizleyebilirsin'
                  : 'Silinemedi, tekrar deneyin',
        ),
      );
    }
  }
}
