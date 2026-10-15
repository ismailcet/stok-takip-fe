import 'package:equatable/equatable.dart';

sealed class EditPartEvent extends Equatable {
  const EditPartEvent();

  @override
  List<Object?> get props => [];
}

class EditPartStarted extends EditPartEvent {
  const EditPartStarted();
}

class EditPartStockChanged extends EditPartEvent {
  final int delta;
  const EditPartStockChanged(this.delta);

  @override
  List<Object?> get props => [delta];
}

class EditPartCabinetSelected extends EditPartEvent {
  final int cabinetId;
  const EditPartCabinetSelected(this.cabinetId);

  @override
  List<Object?> get props => [cabinetId];
}

class EditPartBrandChanged extends EditPartEvent {
  final String brand;
  const EditPartBrandChanged(this.brand);

  @override
  List<Object?> get props => [brand];
}

class EditPartSubmitted extends EditPartEvent {
  const EditPartSubmitted();
}
