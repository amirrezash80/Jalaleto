import 'package:get_storage/get_storage.dart';

class UserDataStorage {
  final _userDataStorage = GetStorage();
  static const _userDataKey = 'userData';

  Map<String, dynamic> get userData =>
      _userDataStorage.read(_userDataKey) ?? {};

  void saveUserData(Map<String, dynamic> data) {
    _userDataStorage.write(_userDataKey, data);
  }

  void clearUserData() {
    _userDataStorage.remove(_userDataKey);
  }
}

final userDataStorage = UserDataStorage();
