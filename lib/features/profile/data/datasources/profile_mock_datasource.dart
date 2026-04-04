import '../../domain/entities/profile.dart';
import '../models/profile_model.dart';

abstract class ProfileMockDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileMockDataSourceImpl implements ProfileMockDataSource {
  ProfileModel? _cachedProfile;

  @override
  Future<ProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_cachedProfile != null) return _cachedProfile!;
    
    // Mock данные
    _cachedProfile = ProfileModel(
      firstName: '',
      lastName: '',
      goal: GoalType.maintenance,
    );
    return _cachedProfile!;
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedProfile = profile;
  }
}