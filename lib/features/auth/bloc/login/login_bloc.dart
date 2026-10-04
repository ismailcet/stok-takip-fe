import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository, required int userId})
    : _authRepository = authRepository,
      _userId = userId,
      super(const LoginState()) {
    on<LoginDigitAdded>(_onDigitAdded);
    on<LoginDigitRemoved>(_onDigitRemoved);
  }

  static const _pinLength = 4;

  final AuthRepository _authRepository;
  final int _userId;

  Future<void> _onDigitAdded(
    LoginDigitAdded event,
    Emitter<LoginState> emit,
  ) async {
    if (state.status == LoginStatus.submitting) return;
    if (state.pin.length >= _pinLength) return;

    final pin = state.pin + event.digit;
    emit(
      state.copyWith(
        pin: pin,
        status: LoginStatus.entering,
        errorMessage: null,
      ),
    );

    if (pin.length == _pinLength) {
      await _submit(pin, emit);
    }
  }

  void _onDigitRemoved(LoginDigitRemoved event, Emitter<LoginState> emit) {
    if (state.status == LoginStatus.submitting || state.pin.isEmpty) return;
    emit(state.copyWith(pin: state.pin.substring(0, state.pin.length - 1)));
  }

  Future<void> _submit(String pin, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.login(userId: _userId, pin: pin);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          pin: '',
          status: LoginStatus.failure,
          errorMessage: 'PIN hatalı, tekrar deneyin',
        ),
      );
    }
  }
}
