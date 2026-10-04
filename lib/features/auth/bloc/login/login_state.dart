import 'package:equatable/equatable.dart';

enum LoginStatus { entering, submitting, success, failure }

class LoginState extends Equatable {
  final String pin;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.pin = '',
    this.status = LoginStatus.entering,
    this.errorMessage,
  });

  LoginState copyWith({
    String? pin,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      pin: pin ?? this.pin,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [pin, status, errorMessage];
}
