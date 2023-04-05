import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myshop/UI/auth/login_screen.dart';
import 'package:myshop/model/NotificationModel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _email, _password, _username, _phoneNumber;
  File? _profilePicture;
  final picker = ImagePicker();
  final _firebaseStorage = FirebaseStorage.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseFireStore = FirebaseFirestore.instance;
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path);
      }
    });
  }

  Future<void> submitForm() async {
    _formKey.currentState!.save();
    NotificationModel.showLoadingDialog(context, 'Đang tạo tài khoản mới...');

    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: _email, password: _password);
      String userId = userCredential.user!.uid;

      final imageName = userId;
      final ref = _firebaseStorage.ref().child('users').child(imageName);
      final uploadTask = ref.putFile(_profilePicture!);
      final snapshot =
          await uploadTask.whenComplete(() => {print('upload thanh cong')});
      final photoURL = await snapshot.ref.getDownloadURL();

      final userData = {
        'uid': userId,
        'displayName': _username,
        'email': _email,
        'photoURL': photoURL,
        'lastOnline': DateTime.now(),
        'phone': _phoneNumber,
        'dob': Timestamp.now(),
      };

      await _firebaseFireStore.collection('users').doc(userId).set(userData);
      User user = userCredential.user!;
      await user.updateDisplayName(_username);
      await user.updatePhotoURL(photoURL);

      // ignore: use_build_context_synchronously
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('Loi dang ky $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter an email address.';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter a password.';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên người dùng'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter a username.';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter a phone number.';
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              const SizedBox(height: 16),
              // Center(
              //   child: GestureDetector(
              //     onTap: () {
              //       _getImage();
              //     },
              //     child: Container(
              //       width: 100,
              //       height: 100,
              //       decoration: const BoxDecoration(
              //         shape: BoxShape.circle,
              //         image: DecorationImage(
              //           image:
              //               // _profilePicture != null
              //               //     ? FileImage(_profilePicture)
              //               AssetImage(
              //                       'assets/images/default_profile_picture.jpg')
              //                   as ImageProvider,
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Stack(children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: _profilePicture != null
                        ? Image.file(_profilePicture!).image
                        : const AssetImage(
                            'assets/images/default_profile_picture.png'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _getImage,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ]),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  submitForm();
                },
                child: const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
