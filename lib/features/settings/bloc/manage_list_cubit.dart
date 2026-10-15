import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/named_item.dart';
import '../data/repositories/named_item_repository.dart';

enum ManageListStatus { loading, ready, failure }

class ManageListState extends Equatable {
  final ManageListStatus status;
  final List<NamedItem> items;
  final bool busy;
  final String? errorMessage;

  const ManageListState({
    this.status = ManageListStatus.loading,
    this.items = const [],
    this.busy = false,
    this.errorMessage,
  });

  ManageListState copyWith({
    ManageListStatus? status,
    List<NamedItem>? items,
    bool? busy,
    String? errorMessage,
  }) {
    return ManageListState(
      status: status ?? this.status,
      items: items ?? this.items,
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, busy, errorMessage];
}

class ManageListCubit extends Cubit<ManageListState> {
  ManageListCubit({
    required NamedItemRepository repository,
    required String deleteBlockedMessage,
  }) : _repository = repository,
       _deleteBlockedMessage = deleteBlockedMessage,
       super(const ManageListState());

  final NamedItemRepository _repository;
  final String _deleteBlockedMessage;

  static const _duplicateMessage = 'Bu isim zaten kayıtlı';

  /// Türkçe harfleri de gözeten, büyük/küçük harf ve boşluktan bağımsız karşılaştırma anahtarı.
  static String _key(String s) =>
      s.trim().replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  bool _isDuplicate(String name, {int? exceptId}) {
    final key = _key(name);
    return state.items.any((e) => e.id != exceptId && _key(e.name) == key);
  }

  Future<void> load() async {
    emit(state.copyWith(status: ManageListStatus.loading));
    try {
      final items = await _repository.list();
      emit(state.copyWith(status: ManageListStatus.ready, items: items));
    } catch (_) {
      emit(state.copyWith(status: ManageListStatus.failure));
    }
  }

  Future<void> add(String name) {
    if (_isDuplicate(name)) {
      emit(state.copyWith(errorMessage: _duplicateMessage));
      return Future.value();
    }
    return _mutate(
      () => _repository.create(name),
      conflictMessage: _duplicateMessage,
    );
  }

  Future<void> rename(int id, String name) {
    if (_isDuplicate(name, exceptId: id)) {
      emit(state.copyWith(errorMessage: _duplicateMessage));
      return Future.value();
    }
    return _mutate(
      () => _repository.rename(id, name),
      conflictMessage: _duplicateMessage,
    );
  }

  Future<void> remove(int id) => _mutate(
    () => _repository.delete(id),
    conflictMessage: _deleteBlockedMessage,
  );

  Future<void> _mutate(
    Future<void> Function() action, {
    required String conflictMessage,
  }) async {
    emit(state.copyWith(busy: true));
    try {
      await action();
      final items = await _repository.list();
      emit(
        state.copyWith(
          status: ManageListStatus.ready,
          items: items,
          busy: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          busy: false,
          errorMessage:
              e.toString().contains('(409)')
                  ? conflictMessage
                  : 'İşlem başarısız, tekrar deneyin',
        ),
      );
    }
  }
}
