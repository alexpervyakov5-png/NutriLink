import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

class ProfileState extends Equatable {
  final Profile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  @override
  List<Object?> get props => [profile, isLoading, isSaving, error];
}