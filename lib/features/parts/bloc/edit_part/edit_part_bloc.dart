import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/part.dart';
import '../../data/repositories/cabinet_repository.dart';
import '../../data/repositories/part_repository.dart';
import 'edit_part_event.dart';
import 'edit_part_state.dart';

class EditPartBloc extends Bloc<EditPartEvent, EditPartState> {
  EditPartBloc({
    required Part part,
    required PartRepository partRepository,
    required CabinetRepository cabinetRepository,
  }) : _part = part,
       _partRepository = partRepository,
       _cabinetRepository = cabinetRepository,
       super(
         EditPartState(
           cabinetId: part.cabinetId,
           stock: part.stockQuantity,
           brand: part.brand ?? '',
         ),
       ) {
    on<EditPartStarted>(_onStarted);
    on<EditPartStockChanged>(_onStockChanged);
    on<EditPartCabinetSelected>(_onCabinetSelected);
    on<EditPartBrandChanged>(_onBrandChanged);
    on<EditPartSubmitted>(_onSubmitted);
  }

  final Part _part;
  final PartRepository _partRepository;
  final CabinetRepository _cabinetRepository;

  Future<void> _onStarted(
    EditPartStarted event,
    Emitter<EditPartState> emit,
  ) async {
    emit(state.copyWith(loadingCabinets: true));
    try {
      final cabinets = await _cabinetRepository.list();
      emit(state.copyWith(cabinets: cabinets, loadingCabinets: false));
    } catch (_) {
      emit(
        state.copyWith(
          loadingCabinets: false,
          errorMessage: 'Dolaplar yüklenemedi',
        ),
      );
    }
  }

  void _onStockChanged(
    EditPartStockChanged event,
    Emitter<EditPartState> emit,
  ) {
    final next = state.stock + event.delta;
    if (next < 0) return;
    emit(state.copyWith(stock: next));
  }

  void _onCabinetSelected(
    EditPartCabinetSelected event,
    Emitter<EditPartState> emit,
  ) {
    emit(state.copyWith(cabinetId: event.cabinetId));
  }

  void _onBrandChanged(
    EditPartBrandChanged event,
    Emitter<EditPartState> emit,
  ) {
    emit(state.copyWith(brand: event.brand));
  }

  Future<void> _onSubmitted(
    EditPartSubmitted event,
    Emitter<EditPartState> emit,
  ) async {
    emit(state.copyWith(saving: true));
    try {
      final brand = state.brand.trim();
      final saved = await _partRepository.update(
        _part.id,
        cabinetId: state.cabinetId,
        stockQuantity: state.stock,
        brand: brand.isEmpty ? null : brand,
      );
      emit(state.copyWith(saving: false, savedPart: saved));
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
