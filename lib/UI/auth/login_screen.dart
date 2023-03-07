import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myshop/UI/auth/register_screen.dart';
import 'package:myshop/UI/home_screen.dart';
import 'package:myshop/model/FirebaseHelper.dart';
import 'package:myshop/model/UserModel.dart';

import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/safe_area_values.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../model/FirebaseHelper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final _auth = FirebaseAuth.instance;

  Future<void> submitFormLogin() async {
    User? user = await signIn();
    print('USER DANG NHAP $user');
    if (user != null) {
      UserModel? userModel = await FirebaseHelper.getUserModelById(user.uid);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    userModel: userModel!,
                    firebaseUser: _auth.currentUser!,
                  )));
    }
  }

  Future<User?> signIn() async {
    _formKey.currentState!.save();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showTopSnackBar(
          // ignore: use_build_context_synchronously
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Không tìm thấy người dùng có email như trên',
          ),
        );
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showTopSnackBar(
          // ignore: use_build_context_synchronously
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Mật khẩu bị sai',
          ),
        );
      } else {
        showTopSnackBar(
          // ignore: use_build_context_synchronously
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'Kiểm tra lại trường email và password',
          ),
        );
      }
      print(e);
      return null;
    } catch (e) {
      print("LOI DANG NHAP");
      showTopSnackBar(
        // ignore: use_build_context_synchronously
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại',
        ),
      );
      return null;
    }
  }

  void _navigateToRegisterScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/chatcoin-chat-logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _email = value.trim(),
                onSaved: (value) {
                  _email = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _password = value.trim(),
                onSaved: (value) {
                  _password = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: submitFormLogin
                // Navigator.of(context).pushReplacement(
                //     MaterialPageRoute(builder: (_) => const HomeScreen()));
                ,
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _navigateToRegisterScreen,
                child: const Text('Chưa có tài khoản? Đăng ký ngay',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Login'),
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child: Form(
    //       key: _formKey,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.stretch,
    //         children: [
    //           TextFormField(
    //             decoration: const InputDecoration(labelText: 'Email'),
    //             validator: (value) {
    //               if (value == null || value.isEmpty) {
    //                 return 'Vui lòng nhập email';
    //               }
    //               return null;
    //             },
    //             onChanged: (value) => _email = value.trim(),
    //           ),
    //           const SizedBox(height: 16),
    //           TextFormField(
    //             decoration: const InputDecoration(labelText: 'Password'),
    //             obscureText: true,
    //             validator: (value) {
    //               if (value == null || value.isEmpty) {
    //                 return 'Vui lòng nhập password';
    //               }
    //               return null;
    //             },
    //             onChanged: (value) => _password = value.trim(),
    //           ),
    //           const SizedBox(height: 32),
    //           ElevatedButton(
    //             onPressed: () async {
    //               Navigator.of(context).pushReplacement(
    //                 MaterialPageRoute(builder: (context) => const HomeScreen()),
    //               );
    //               // if (_formKey.currentState!.validate()) {
    //               //   try {
    //               //     await FirebaseAuth.instance.signInWithEmailAndPassword(
    //               //       email: _email,
    //               //       password: _password,
    //               //     );
    //               //     Navigator.of(context).pushReplacement(
    //               //       MaterialPageRoute(builder: (_) => HomePage()),
    //               //     );
    //               //   } on FirebaseAuthException catch (e) {
    //               //     ScaffoldMessenger.of(context).showSnackBar(
    //               //       SnackBar(
    //               //         content: Text(e.message ?? 'An error occurred'),
    //               //       ),
    //               //     );
    //               //   }
    //               // }
    //             },
    //             child: const Text('Sign In'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
