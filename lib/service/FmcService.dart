import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../provider/AuthProvider.dart';

class FcmService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static late String? token;

  Future<void> backgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.toString()}");
  }

  Future<void> saveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': FcmService.token});
  }

  Future<String?> registerDevice() async {
    _firebaseMessaging.requestPermission();

    // Lấy fcmToken
    String? fcmToken = await _firebaseMessaging.getToken();
    token = fcmToken;
    print("fcmToken:  $token");
    //Lưu fcmToken
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? uid = prefs.getString('uid');
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .set({'fcmToken': fcmToken});

    // // Đăng ký lắng nghe các sự kiện FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("remote mess : ${message.toString()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Xử lý thông báo khi ứng dụng đã được mở
      print("remote mess : ${message.toString()}");
    });

    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
    //   // Xử lý thông báo khi ứng dụng đang chạy ở background
    // });

    return fcmToken;
  }

  Future<void> sendNotification(
      String? token, String title, String body, String roomid) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA4a7bheA:APA91bGtTWwZKcp9KirLbTS1AaxisprOyf9aoNOYUr6kv6KJcRiC3BUSBgt_uBCJIgayEFM0QJB5zsPYZdv0EYb0Fv-k3EOWIYrc-0ecs2i8_70OxszazOBOR1hrgDNcg6OX9q9rsg8k',
      },
      body: jsonEncode({
        'notification': {'title': title, 'body': body, 'roomid': roomid},
        'to': token,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification.');
    }
  }

  void _handleMessage(RemoteMessage message) async {
    // DocumentSnapshot roomSnapshot =
    //     await _firestore.collection('chatrooms').doc(roomId).get();
  }
}
