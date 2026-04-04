import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class TabTapped extends NavigationEvent {
  final int index;
  TabTapped(this.index);
  
  @override
  List<Object> get props => [index];
}