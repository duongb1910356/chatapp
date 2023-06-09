import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? displayName;
  String? email;
  String? photoURL;
  String? phone;
  Timestamp? dob;
  Timestamp? lastOnline;
  String? fcmToken;

  UserModel(
      {this.uid,
      this.displayName,
      this.email,
      this.photoURL,
      this.phone,
      this.dob,
      this.lastOnline,
      this.fcmToken});

  factory UserModel.fromUserModel(UserModel obj) {
    return UserModel(
        uid: obj.uid,
        displayName: obj.displayName,
        email: obj.email,
        photoURL: obj.photoURL,
        phone: obj.phone,
        dob: obj.dob,
        lastOnline: obj.lastOnline,
        fcmToken: obj.fcmToken);
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    displayName = map['displayName'];
    email = map['email'];
    photoURL = map['photoURL'];
    phone = map['phone'];
    dob = map['dob'];
    lastOnline = map['lastOnline'];
    fcmToken = map['fcmToken'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phone': phone,
      'dob': dob,
      'lastOnline': lastOnline,
      'fcmToken': fcmToken
    };
  }
}
