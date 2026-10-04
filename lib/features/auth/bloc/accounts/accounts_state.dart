import 'package:equatable/equatable.dart';
import '../../data/models/user_account.dart';

enum AccountsStatus { initial, loading, success, failure }

class AccountsState extends Equatable {
  final AccountsStatus status;
  final List<UserAccount> accounts;
  final String? errorMessage;

  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  AccountsState copyWith({
    AccountsStatus? status,
    List<UserAccount>? accounts,
    String? errorMessage,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}
