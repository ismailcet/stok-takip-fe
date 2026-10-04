import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AccountsState()) {
    on<AccountsRequested>(_onAccountsRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onAccountsRequested(
    AccountsRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(status: AccountsStatus.loading));
    try {
      final accounts = await _authRepository.fetchAccounts();
      emit(state.copyWith(status: AccountsStatus.success, accounts: accounts));
    } catch (e) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
