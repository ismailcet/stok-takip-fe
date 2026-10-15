import 'package:equatable/equatable.dart';

sealed class CreateMaintenanceEvent extends Equatable {
  const CreateMaintenanceEvent();

  @override
  List<Object?> get props => [];
}

class CreateMaintenanceStarted extends CreateMaintenanceEvent {
  const CreateMaintenanceStarted();
}

class CreateMaintenanceCompanySelected extends CreateMaintenanceEvent {
  final int companyId;
  const CreateMaintenanceCompanySelected(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

class CreateMaintenanceDateChanged extends CreateMaintenanceEvent {
  final DateTime date;
  const CreateMaintenanceDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class CreateMaintenancePhotoSelected extends CreateMaintenanceEvent {
  final String path;
  const CreateMaintenancePhotoSelected(this.path);

  @override
  List<Object?> get props => [path];
}

class CreateMaintenanceSubmitted extends CreateMaintenanceEvent {
  const CreateMaintenanceSubmitted();
}
