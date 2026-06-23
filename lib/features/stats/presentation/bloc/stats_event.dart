import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  // ✅ Убрали const, т.к. параметры не const
  LoadStats({
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshStats extends StatsEvent {
  @override
  List<Object?> get props => [];
}