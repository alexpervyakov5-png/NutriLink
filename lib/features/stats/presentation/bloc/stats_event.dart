import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  
  LoadStats({this.startDate, this.endDate});
  
  @override
  List<Object?> get props => [startDate, endDate];
}