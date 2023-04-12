import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:myshop/model/UserModel.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _userModel;
  UserModel? get currentUser => _userModel;

  void login(UserModel currentUser) {
    _userModel = UserModel.fromUserModel(currentUser);
    notifyListeners();
  }

  void logout() {
    _userModel = null;
    notifyListeners();
  }
}
