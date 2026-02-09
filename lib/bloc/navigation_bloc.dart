import 'package:bloc/bloc.dart';

abstract class NavigationEvent {}

class TabTapped extends NavigationEvent {
  final int index;
  TabTapped(this.index);
}

class NavigationState {
  final int index;
  NavigationState(this.index);
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(0)) {
    on<TabTapped>((event, emit) {
      emit(NavigationState(event.index));
    });
  }
}