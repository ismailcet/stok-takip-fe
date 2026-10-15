import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/account_repository.dart';

class ChangePinState extends Equatable {
  final bool saving;
  final bool success;
  final String? errorMessage;

  const ChangePinState({
    this.saving = false,
    this.success = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [saving, success, errorMessage];
}

class ChangePinCubit extends Cubit<ChangePinState> {
  ChangePinCubit({required AccountRepository repository})
    : _repository = repository,
      super(const ChangePinState());

  final AccountRepository _repository;
  static final _fourDigits = RegExp(r'^\d{4}$');

  Future<void> submit({
    required String current,
    required String newPin,
    required String confirm,
  }) async {
    if (!_fourDigits.hasMatch(current)) {
      emit(const ChangePinState(errorMessage: 'Mevcut PIN 4 haneli olmalı'));
      return;
    }
    if (!_fourDigits.hasMatch(newPin)) {
      emit(const ChangePinState(errorMessage: 'Yeni PIN 4 haneli olmalı'));
      return;
    }
    if (newPin != confirm) {
      emit(const ChangePinState(errorMessage: 'Yeni PIN\'ler aynı değil'));
      return;
    }
    if (newPin == current) {
      emit(
        const ChangePinState(errorMessage: 'Yeni PIN eskisiyle aynı olamaz'),
      );
      return;
    }

    emit(const ChangePinState(saving: true));
    try {
      await _repository.changeOwnPin(currentPin: current, newPin: newPin);
      emit(const ChangePinState(success: true));
    } catch (e) {
      emit(
        ChangePinState(
          errorMessage:
              e.toString().contains('(401)')
                  ? 'Mevcut PIN hatalı'
                  : 'Kaydedilemedi, tekrar deneyin',
        ),
      );
    }
  }
}
