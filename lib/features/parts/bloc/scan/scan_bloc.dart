import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/part.dart';
import '../../data/repositories/part_repository.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({required PartRepository partRepository})
    : _partRepository = partRepository,
      super(const ScanState()) {
    on<ScanCodeDetected>(_onCodeDetected);
    on<ScanProductCodeSubmitted>(_onManualCodeSubmitted);
    on<ScanRetried>((event, emit) => emit(const ScanState()));
  }

  final PartRepository _partRepository;

  Future<void> _onCodeDetected(
    ScanCodeDetected event,
    Emitter<ScanState> emit,
  ) async {
    // Arama sürerken gelen tekrar okumaları yok say.
    if (state.status != ScanStatus.scanning) return;
    emit(const ScanState(status: ScanStatus.lookingUp));
    await _lookup(
      emit,
      () => _partRepository.lookup(barcode: event.code),
      'Barkod okunmadı veya sistemde yok',
    );
  }

  Future<void> _onManualCodeSubmitted(
    ScanProductCodeSubmitted event,
    Emitter<ScanState> emit,
  ) async {
    emit(const ScanState(status: ScanStatus.lookingUp));
    await _lookup(
      emit,
      () => _partRepository.lookupByAnyCode(event.productCode),
      'Bu kodla parça bulunamadı',
    );
  }

  Future<void> _lookup(
    Emitter<ScanState> emit,
    Future<Part?> Function() search,
    String notFoundMessage,
  ) async {
    try {
      final part = await search();
      if (part == null) {
        emit(ScanState(status: ScanStatus.notFound, message: notFoundMessage));
      } else {
        emit(ScanState(status: ScanStatus.found, part: part));
      }
    } catch (_) {
      emit(
        const ScanState(
          status: ScanStatus.notFound,
          message: 'Sunucuya ulaşılamadı',
        ),
      );
    }
  }
}
