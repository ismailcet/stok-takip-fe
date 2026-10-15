import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/cabinet_repository.dart';
import '../../data/repositories/part_repository.dart';
import 'create_part_event.dart';
import 'create_part_state.dart';

class CreatePartBloc extends Bloc<CreatePartEvent, CreatePartState> {
  CreatePartBloc({
    required PartRepository partRepository,
    required CabinetRepository cabinetRepository,
  }) : _partRepository = partRepository,
       _cabinetRepository = cabinetRepository,
       super(const CreatePartState()) {
    on<CreatePartStarted>(_onStarted);
    on<CreatePartNameChanged>((e, emit) => emit(state.copyWith(name: e.value)));
    on<CreatePartCodeTypeChanged>(
      (e, emit) => emit(state.copyWith(codeType: e.type)),
    );
    on<CreatePartCodeChanged>((e, emit) => emit(state.copyWith(code: e.value)));
    on<CreatePartBrandChanged>(
      (e, emit) => emit(state.copyWith(brand: e.value)),
    );
    on<CreatePartCategoryChanged>(
      (e, emit) => emit(state.copyWith(category: e.value)),
    );
    on<CreatePartCabinetSelected>(
      (e, emit) => emit(state.copyWith(cabinetId: e.cabinetId)),
    );
    on<CreatePartStockChanged>(_onStockChanged);
    on<CreatePartSubmitted>(_onSubmitted);
  }

  final PartRepository _partRepository;
  final CabinetRepository _cabinetRepository;

  Future<void> _onStarted(
    CreatePartStarted event,
    Emitter<CreatePartState> emit,
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
    CreatePartStockChanged event,
    Emitter<CreatePartState> emit,
  ) {
    final next = state.stock + event.delta;
    if (next < 0) return;
    emit(state.copyWith(stock: next));
  }

  String? _nullIfBlank(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _onSubmitted(
    CreatePartSubmitted event,
    Emitter<CreatePartState> emit,
  ) async {
    final name = state.name.trim();
    final code = state.code.trim();

    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Parça adı yazın'));
      return;
    }
    if (code.isEmpty) {
      emit(
        state.copyWith(
          errorMessage:
              state.codeType == CodeType.barcode
                  ? 'Barkod yazın'
                  : 'Ürün kodu yazın',
        ),
      );
      return;
    }
    if (state.cabinetId == null) {
      emit(state.copyWith(errorMessage: 'Dolap seçin'));
      return;
    }

    emit(state.copyWith(saving: true));
    try {
      final created = await _partRepository.create(
        name: name,
        barcode: state.codeType == CodeType.barcode ? code : null,
        productCode: state.codeType == CodeType.productCode ? code : null,
        brand: _nullIfBlank(state.brand),
        category: _nullIfBlank(state.category),
        cabinetId: state.cabinetId!,
        stockQuantity: state.stock,
      );
      emit(state.copyWith(saving: false, createdPart: created));
    } catch (e) {
      final message =
          e.toString().contains('(409)')
              ? 'Bu barkod / ürün kodu zaten kayıtlı'
              : 'Kaydedilemedi, tekrar deneyin';
      emit(state.copyWith(saving: false, errorMessage: message));
    }
  }
}
