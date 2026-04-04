import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
  }) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileField>(_onUpdateProfileField);
    on<SaveProfile>(_onSaveProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await getProfile(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки')),
      (profile) => emit(state.copyWith(profile: profile, isLoading: false)),
    );
  }

  void _onUpdateProfileField(UpdateProfileField event, Emitter<ProfileState> emit) {
    if (state.profile == null) return;
    final updated = event.update(state.profile!);
    emit(state.copyWith(profile: updated));
  }

  Future<void> _onSaveProfile(SaveProfile event, Emitter<ProfileState> emit) async {
    if (state.profile == null) return;
    emit(state.copyWith(isSaving: true));
    final result = await updateProfile(state.profile!);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: 'Ошибка сохранения')),
      (_) => emit(state.copyWith(isSaving: false)),
    );
  }
}