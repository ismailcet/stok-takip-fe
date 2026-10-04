import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginDigitAdded extends LoginEvent {
  final String digit;
  const LoginDigitAdded(this.digit);

  @override
  List<Object?> get props => [digit];
}

class LoginDigitRemoved extends LoginEvent {
  const LoginDigitRemoved();
}
