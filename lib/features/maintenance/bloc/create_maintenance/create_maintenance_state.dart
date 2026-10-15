import 'package:equatable/equatable.dart';
import '../../data/models/company.dart';
import '../../data/models/maintenance_record.dart';

class CreateMaintenanceState extends Equatable {
  final List<Company> companies;
  final bool loadingCompanies;
  final int? companyId;
  final DateTime date;
  final String? photoPath;
  final bool saving;
  final MaintenanceRecord? created;
  final String? errorMessage;

  const CreateMaintenanceState({
    this.companies = const [],
    this.loadingCompanies = false,
    this.companyId,
    required this.date,
    this.photoPath,
    this.saving = false,
    this.created,
    this.errorMessage,
  });

  CreateMaintenanceState copyWith({
    List<Company>? companies,
    bool? loadingCompanies,
    int? companyId,
    DateTime? date,
    String? photoPath,
    bool? saving,
    MaintenanceRecord? created,
    String? errorMessage,
  }) {
    return CreateMaintenanceState(
      companies: companies ?? this.companies,
      loadingCompanies: loadingCompanies ?? this.loadingCompanies,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      saving: saving ?? this.saving,
      created: created ?? this.created,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    companies,
    loadingCompanies,
    companyId,
    date,
    photoPath,
    saving,
    created,
    errorMessage,
  ];
}
