import 'package:equatable/equatable.dart';

sealed class PartsEvent extends Equatable {
  const PartsEvent();

  @override
  List<Object?> get props => [];
}

class PartsRequested extends PartsEvent {
  const PartsRequested();
}

class PartsSearchChanged extends PartsEvent {
  final String query;
  const PartsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class PartsLowStockFilterToggled extends PartsEvent {
  const PartsLowStockFilterToggled();
}
