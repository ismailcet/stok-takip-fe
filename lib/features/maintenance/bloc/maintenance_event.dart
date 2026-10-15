import 'package:equatable/equatable.dart';

sealed class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();

  @override
  List<Object?> get props => [];
}

class MaintenanceRequested extends MaintenanceEvent {
  const MaintenanceRequested();
}

/// companyId null ise "Hepsi".
class MaintenanceCompanySelected extends MaintenanceEvent {
  final int? companyId;
  const MaintenanceCompanySelected(this.companyId);

  @override
  List<Object?> get props => [companyId];
}
