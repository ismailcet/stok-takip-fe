import 'package:equatable/equatable.dart';
import '../data/models/part.dart';

enum PartsStatus { initial, loading, success, failure }

class PartsState extends Equatable {
  final PartsStatus status;
  final List<Part> parts;
  final String searchQuery;
  final bool lowStockOnly;
  final int lowStockCount;
  final String? errorMessage;

  const PartsState({
    this.status = PartsStatus.initial,
    this.parts = const [],
    this.searchQuery = '',
    this.lowStockOnly = false,
    this.lowStockCount = 0,
    this.errorMessage,
  });

  PartsState copyWith({
    PartsStatus? status,
    List<Part>? parts,
    String? searchQuery,
    bool? lowStockOnly,
    int? lowStockCount,
    String? errorMessage,
  }) {
    return PartsState(
      status: status ?? this.status,
      parts: parts ?? this.parts,
      searchQuery: searchQuery ?? this.searchQuery,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    parts,
    searchQuery,
    lowStockOnly,
    lowStockCount,
    errorMessage,
  ];
}
