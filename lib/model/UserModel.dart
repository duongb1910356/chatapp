class UserModel {
  String? uid;
  String? displayName;
  String? email;
  String? photoURL;
  String? phone;

  UserModel(
      {this.uid, this.displayName, this.email, this.photoURL, this.phone});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    displayName = map['displayName'];
    email = map['email'];
    photoURL = map['photoURL'];
    phone = map['phone'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phone': phone,
    };
  }
}
