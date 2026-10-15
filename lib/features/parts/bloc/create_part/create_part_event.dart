import 'package:equatable/equatable.dart';

enum CodeType { barcode, productCode }

sealed class CreatePartEvent extends Equatable {
  const CreatePartEvent();

  @override
  List<Object?> get props => [];
}

class CreatePartStarted extends CreatePartEvent {
  const CreatePartStarted();
}

class CreatePartNameChanged extends CreatePartEvent {
  final String value;
  const CreatePartNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class CreatePartCodeTypeChanged extends CreatePartEvent {
  final CodeType type;
  const CreatePartCodeTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class CreatePartCodeChanged extends CreatePartEvent {
  final String value;
  const CreatePartCodeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class CreatePartBrandChanged extends CreatePartEvent {
  final String value;
  const CreatePartBrandChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class CreatePartCategoryChanged extends CreatePartEvent {
  final String value;
  const CreatePartCategoryChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class CreatePartCabinetSelected extends CreatePartEvent {
  final int cabinetId;
  const CreatePartCabinetSelected(this.cabinetId);

  @override
  List<Object?> get props => [cabinetId];
}

class CreatePartStockChanged extends CreatePartEvent {
  final int delta;
  const CreatePartStockChanged(this.delta);

  @override
  List<Object?> get props => [delta];
}

class CreatePartSubmitted extends CreatePartEvent {
  const CreatePartSubmitted();
}
