import 'package:hive/hive.dart';
import '../models/user_profile_model.dart';

class SettingsLocalRepository {
  final Box box = Hive.box('budgetsBox');

  static const _key = 'user_profile';

  UserProfileModel getProfile() {
    try {
      final data = box.get(_key);
      if (data == null) {
        return UserProfileModel(
          businessName: '',
          phone: '',
        );
      }
      return UserProfileModel.fromMap(Map.from(data));
    } catch (e) {
      return UserProfileModel(
        businessName: '',
        phone: '',
      );
    }
  }

  void saveProfile(UserProfileModel profile) {
    box.put(_key, profile.toMap());
  }
}
