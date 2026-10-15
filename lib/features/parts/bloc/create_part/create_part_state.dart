import 'package:equatable/equatable.dart';
import '../../data/models/cabinet.dart';
import '../../data/models/part.dart';
import 'create_part_event.dart';

class CreatePartState extends Equatable {
  final String name;
  final CodeType codeType;
  final String code;
  final String brand;
  final String category;
  final int? cabinetId;
  final int stock;
  final List<Cabinet> cabinets;
  final bool loadingCabinets;
  final bool saving;
  final Part? createdPart;
  final String? errorMessage;

  const CreatePartState({
    this.name = '',
    this.codeType = CodeType.barcode,
    this.code = '',
    this.brand = '',
    this.category = '',
    this.cabinetId,
    this.stock = 0,
    this.cabinets = const [],
    this.loadingCabinets = false,
    this.saving = false,
    this.createdPart,
    this.errorMessage,
  });

  CreatePartState copyWith({
    String? name,
    CodeType? codeType,
    String? code,
    String? brand,
    String? category,
    int? cabinetId,
    int? stock,
    List<Cabinet>? cabinets,
    bool? loadingCabinets,
    bool? saving,
    Part? createdPart,
    String? errorMessage,
  }) {
    return CreatePartState(
      name: name ?? this.name,
      codeType: codeType ?? this.codeType,
      code: code ?? this.code,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      cabinetId: cabinetId ?? this.cabinetId,
      stock: stock ?? this.stock,
      cabinets: cabinets ?? this.cabinets,
      loadingCabinets: loadingCabinets ?? this.loadingCabinets,
      saving: saving ?? this.saving,
      createdPart: createdPart ?? this.createdPart,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    codeType,
    code,
    brand,
    category,
    cabinetId,
    stock,
    cabinets,
    loadingCabinets,
    saving,
    createdPart,
    errorMessage,
  ];
}
