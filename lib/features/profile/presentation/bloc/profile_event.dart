import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfileField extends ProfileEvent {
  final Profile Function(Profile) update;
  UpdateProfileField(this.update);
  
  @override
  List<Object> get props => [update];
}

class SaveProfile extends ProfileEvent {}