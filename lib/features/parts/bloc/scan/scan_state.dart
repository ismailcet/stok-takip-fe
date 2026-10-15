import 'package:equatable/equatable.dart';
import '../../data/models/part.dart';

enum ScanStatus { scanning, lookingUp, found, notFound }

class ScanState extends Equatable {
  final ScanStatus status;
  final Part? part;
  final String? message;

  const ScanState({this.status = ScanStatus.scanning, this.part, this.message});

  @override
  List<Object?> get props => [status, part, message];
}
