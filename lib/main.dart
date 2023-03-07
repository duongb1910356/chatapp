import 'package:flutter/material.dart';
import 'package:myshop/UI/auth/login_screen.dart';
import 'package:myshop/UI/auth/register_screen.dart';
import 'package:myshop/UI/chat_screen.dart';
import 'package:myshop/UI/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tan Gau',
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                centerTitle: true,
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    backgroundColor: Colors.blue))),
        home: const LoginScreen()
        // routes: {
        //   '/home': (context) => const HomeScreen(),
        //   '/chat': (context) => const ChatScreen(),
        //}
        );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
