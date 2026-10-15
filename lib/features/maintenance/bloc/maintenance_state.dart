import 'package:equatable/equatable.dart';
import '../data/models/company.dart';
import '../data/models/maintenance_record.dart';

enum MaintenanceStatus { initial, loading, success, failure }

class MaintenanceState extends Equatable {
  final MaintenanceStatus status;
  final List<MaintenanceRecord> records;
  final List<Company> companies;
  final int? selectedCompanyId;
  final String? errorMessage;

  const MaintenanceState({
    this.status = MaintenanceStatus.initial,
    this.records = const [],
    this.companies = const [],
    this.selectedCompanyId,
    this.errorMessage,
  });

  MaintenanceState copyWith({
    MaintenanceStatus? status,
    List<MaintenanceRecord>? records,
    List<Company>? companies,
    int? selectedCompanyId,
    bool clearCompany = false,
    String? errorMessage,
  }) {
    return MaintenanceState(
      status: status ?? this.status,
      records: records ?? this.records,
      companies: companies ?? this.companies,
      selectedCompanyId:
          clearCompany ? null : (selectedCompanyId ?? this.selectedCompanyId),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    records,
    companies,
    selectedCompanyId,
    errorMessage,
  ];
}
