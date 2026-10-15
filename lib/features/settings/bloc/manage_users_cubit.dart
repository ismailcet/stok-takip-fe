import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/user_role.dart';
import '../data/models/managed_user.dart';
import '../data/repositories/user_admin_repository.dart';

enum ManageUsersStatus { loading, ready, failure }

class ManageUsersState extends Equatable {
  final ManageUsersStatus status;
  final List<ManagedUser> users;
  final bool busy;
  final String? message;

  const ManageUsersState({
    this.status = ManageUsersStatus.loading,
    this.users = const [],
    this.busy = false,
    this.message,
  });

  ManageUsersState copyWith({
    ManageUsersStatus? status,
    List<ManagedUser>? users,
    bool? busy,
    String? message,
  }) {
    return ManageUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      busy: busy ?? this.busy,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, users, busy, message];
}

class ManageUsersCubit extends Cubit<ManageUsersState> {
  ManageUsersCubit({required UserAdminRepository repository})
    : _repository = repository,
      super(const ManageUsersState());

  final UserAdminRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ManageUsersStatus.loading));
    try {
      final users = await _repository.list();
      emit(state.copyWith(status: ManageUsersStatus.ready, users: users));
    } catch (_) {
      emit(state.copyWith(status: ManageUsersStatus.failure));
    }
  }

  Future<void> add({
    required String fullName,
    required UserRole role,
    required String pin,
  }) async {
    emit(state.copyWith(busy: true));
    try {
      await _repository.create(fullName: fullName, role: role, pin: pin);
      final users = await _repository.list();
      emit(
        state.copyWith(
          status: ManageUsersStatus.ready,
          users: users,
          busy: false,
          message: 'Kullanıcı eklendi',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          busy: false,
          message:
              e.toString().contains('(409)')
                  ? 'Bu isimde bir kullanıcı zaten var'
                  : 'Kullanıcı eklenemedi, tekrar deneyin',
        ),
      );
    }
  }

  Future<void> resetPin(int userId, String newPin) async {
    emit(state.copyWith(busy: true));
    try {
      await _repository.resetPin(userId, newPin);
      emit(state.copyWith(busy: false, message: 'PIN sıfırlandı'));
    } catch (_) {
      emit(
        state.copyWith(
          busy: false,
          message: 'PIN sıfırlanamadı, tekrar deneyin',
        ),
      );
    }
  }
}
