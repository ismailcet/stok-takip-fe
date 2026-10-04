import 'package:equatable/equatable.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class AccountsRequested extends AccountsEvent {
  const AccountsRequested();
}
