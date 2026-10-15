import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/part_repository.dart';
import 'parts_event.dart';
import 'parts_state.dart';

class PartsBloc extends Bloc<PartsEvent, PartsState> {
  PartsBloc({required PartRepository partRepository})
    : _partRepository = partRepository,
      super(const PartsState()) {
    on<PartsRequested>((event, emit) => _fetch(emit));
    on<PartsSearchChanged>(_onSearchChanged);
    on<PartsLowStockFilterToggled>(_onLowStockToggled);
  }

  final PartRepository _partRepository;

  Future<void> _onSearchChanged(
    PartsSearchChanged event,
    Emitter<PartsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _fetch(emit);
  }

  Future<void> _onLowStockToggled(
    PartsLowStockFilterToggled event,
    Emitter<PartsState> emit,
  ) async {
    emit(state.copyWith(lowStockOnly: !state.lowStockOnly));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<PartsState> emit) async {
    emit(state.copyWith(status: PartsStatus.loading));
    try {
      final parts = await _partRepository.list(
        search: state.searchQuery,
        lowStockOnly: state.lowStockOnly,
      );

      final lowStockCount =
          state.lowStockOnly
              ? parts.length
              : (await _partRepository.list(lowStockOnly: true)).length;

      emit(
        state.copyWith(
          status: PartsStatus.success,
          parts: parts,
          lowStockCount: lowStockCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: PartsStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
