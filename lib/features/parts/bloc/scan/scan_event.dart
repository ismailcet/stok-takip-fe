import 'package:equatable/equatable.dart';

sealed class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanCodeDetected extends ScanEvent {
  final String code;
  const ScanCodeDetected(this.code);

  @override
  List<Object?> get props => [code];
}

class ScanProductCodeSubmitted extends ScanEvent {
  final String productCode;
  const ScanProductCodeSubmitted(this.productCode);

  @override
  List<Object?> get props => [productCode];
}

class ScanRetried extends ScanEvent {
  const ScanRetried();
}
