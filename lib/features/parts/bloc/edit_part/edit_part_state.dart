import 'package:equatable/equatable.dart';
import '../../data/models/cabinet.dart';
import '../../data/models/part.dart';

class EditPartState extends Equatable {
  final List<Cabinet> cabinets;
  final int cabinetId;
  final int stock;
  final String brand;
  final bool loadingCabinets;
  final bool saving;
  final Part? savedPart;
  final String? errorMessage;

  const EditPartState({
    this.cabinets = const [],
    required this.cabinetId,
    required this.stock,
    required this.brand,
    this.loadingCabinets = false,
    this.saving = false,
    this.savedPart,
    this.errorMessage,
  });

  EditPartState copyWith({
    List<Cabinet>? cabinets,
    int? cabinetId,
    int? stock,
    String? brand,
    bool? loadingCabinets,
    bool? saving,
    Part? savedPart,
    String? errorMessage,
  }) {
    return EditPartState(
      cabinets: cabinets ?? this.cabinets,
      cabinetId: cabinetId ?? this.cabinetId,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      loadingCabinets: loadingCabinets ?? this.loadingCabinets,
      saving: saving ?? this.saving,
      savedPart: savedPart ?? this.savedPart,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    cabinets,
    cabinetId,
    stock,
    brand,
    loadingCabinets,
    saving,
    savedPart,
    errorMessage,
  ];
}
