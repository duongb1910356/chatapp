import 'package:flutter/material.dart';

class NotificationModel {
  static void showLoadingDialog(BuildContext context, String content) {
    AlertDialog loadingDialog = AlertDialog(
        content: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 30,
          ),
          Text(content)
        ],
      ),
    ));

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loadingDialog;
        });
  }
}
