import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/maintenance_repository.dart';
import 'create_maintenance_event.dart';
import 'create_maintenance_state.dart';

class CreateMaintenanceBloc
    extends Bloc<CreateMaintenanceEvent, CreateMaintenanceState> {
  CreateMaintenanceBloc({required MaintenanceRepository repository})
    : _repository = repository,
      super(CreateMaintenanceState(date: _today())) {
    on<CreateMaintenanceStarted>(_onStarted);
    on<CreateMaintenanceCompanySelected>(
      (e, emit) => emit(state.copyWith(companyId: e.companyId)),
    );
    on<CreateMaintenanceDateChanged>(
      (e, emit) => emit(state.copyWith(date: e.date)),
    );
    on<CreateMaintenancePhotoSelected>(
      (e, emit) => emit(state.copyWith(photoPath: e.path)),
    );
    on<CreateMaintenanceSubmitted>(_onSubmitted);
  }

  final MaintenanceRepository _repository;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _onStarted(
    CreateMaintenanceStarted event,
    Emitter<CreateMaintenanceState> emit,
  ) async {
    emit(state.copyWith(loadingCompanies: true));
    try {
      final companies = await _repository.listCompanies();
      emit(state.copyWith(companies: companies, loadingCompanies: false));
    } catch (_) {
      emit(
        state.copyWith(
          loadingCompanies: false,
          errorMessage: 'Firmalar yüklenemedi',
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    CreateMaintenanceSubmitted event,
    Emitter<CreateMaintenanceState> emit,
  ) async {
    if (state.companyId == null) {
      emit(state.copyWith(errorMessage: 'Firma seçin'));
      return;
    }
    if (state.photoPath == null) {
      emit(state.copyWith(errorMessage: 'Talep formunun fotoğrafını ekleyin'));
      return;
    }

    emit(state.copyWith(saving: true));
    try {
      final record = await _repository.create(
        companyId: state.companyId!,
        visitDate: state.date,
        photoPath: state.photoPath!,
      );
      emit(state.copyWith(saving: false, created: record));
    } catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: 'Kaydedilemedi, tekrar deneyin',
        ),
      );
    }
  }
}
