import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/maintenance_repository.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  MaintenanceBloc({required MaintenanceRepository repository})
    : _repository = repository,
      super(const MaintenanceState()) {
    on<MaintenanceRequested>(_onRequested);
    on<MaintenanceCompanySelected>(_onCompanySelected);
  }

  final MaintenanceRepository _repository;

  Future<void> _onRequested(
    MaintenanceRequested event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(status: MaintenanceStatus.loading));
    await _fetch(emit);
  }

  Future<void> _onCompanySelected(
    MaintenanceCompanySelected event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MaintenanceStatus.loading,
        selectedCompanyId: event.companyId,
        clearCompany: event.companyId == null,
      ),
    );
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<MaintenanceState> emit) async {
    try {
      final results = await Future.wait([
        _repository.listRecords(companyId: state.selectedCompanyId),
        _repository.listCompanies(),
      ]);
      emit(
        state.copyWith(
          status: MaintenanceStatus.success,
          records: results[0] as dynamic,
          companies: results[1] as dynamic,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MaintenanceStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
