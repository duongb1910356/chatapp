import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myshop/UI/auth/login_screen.dart';
import 'package:myshop/model/UserModel.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  late DateTime _dob;
  bool isUpdating = false;
  String? _imageURL;
  final picker = ImagePicker();
  File? _profilePicture;
  DateTime? selectedDate;

  Future<void> _updateImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profilePicture = File(pickedFile.path);
      }
    });
    print('da set ficture');
  }

  Future<void> _uploadImageToFireStore() async {
    if (_profilePicture != null) {
      final imageName = widget.userModel.uid.toString();
      final ref =
          FirebaseStorage.instance.ref().child('users').child(imageName);
      final uploadTask = ref.putFile(_profilePicture!);
      final snapshot =
          await uploadTask.whenComplete(() => {print('upload thanh cong')});
      setState(() {
        _imageURL = snapshot.ref.getDownloadURL() as String?;
      });
    }
  }

  void updateProfile() async {
    setState(() {
      isUpdating = true;
    });
    _uploadImageToFireStore();
    _formKey.currentState!.save();
    selectedDate ??= (widget.userModel.dob as Timestamp).toDate();
    _imageURL ??= widget.userModel.photoURL;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid!)
        .update({
      'phone': _phone,
      'displayName': _name,
      'dob': selectedDate,
      'photoURL': _imageURL
    });

    User? userCurrent = FirebaseAuth.instance.currentUser;
    userCurrent?.updateDisplayName(_name);
    userCurrent?.updatePhotoURL(_imageURL);

    widget.userModel.displayName = _name;
    widget.userModel.photoURL = _imageURL;
    widget.userModel.phone = _phone;
    widget.userModel.dob = Timestamp.fromDate(selectedDate!);

    setState(() {
      isUpdating = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
      ),
      body: SafeArea(
        child: Center(
          child: isUpdating
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    // CircleAvatar(
                    //   backgroundImage: NetworkImage(widget.userModel.photoURL!),
                    //   radius: 50,
                    // ),

                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profilePicture != null
                          ? Image.file(_profilePicture!).image
                          : NetworkImage(widget.userModel.photoURL.toString()),
                      child: IconButton(
                        onPressed: _updateImage,
                        icon: const Icon(Icons.camera_alt_outlined),
                        iconSize: 20,
                      ),
                    ),

                    Text(
                      widget.userModel.email.toString(),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 17),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(17),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue:
                                  widget.userModel.displayName.toString(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                label: const Text('Tên hiển thị'),
                              ),
                              onSaved: (value) {
                                _name = value!;
                              },
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            TextFormField(
                              onTap: () {
                                _selectDate(context);
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                label: const Text('Ngày sinh'),
                              ),
                              controller: TextEditingController(
                                  text: selectedDate == null
                                      ? DateFormat.yMd().format(
                                          widget.userModel.dob!.toDate())
                                      : DateFormat.yMd().format(selectedDate!)),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            TextFormField(
                              initialValue: widget.userModel.phone.toString(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_android),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                label: const Text('Số điện thoại'),
                              ),
                              onSaved: (value) {
                                _phone = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: const Size(50, 50),
                      ),
                      onPressed: () {
                        updateProfile();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Cập nhật',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(7.0),
        child: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // ignore: use_build_context_synchronously
            Navigator.popUntil(context, (route) => route.isFirst);
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const LoginScreen();
            }));
          },
          child: const Icon(Icons.logout_outlined),
        ),
      ),
    );
  }
}
