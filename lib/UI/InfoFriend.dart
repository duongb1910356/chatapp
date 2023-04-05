import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myshop/model/UserModel.dart';

class InfoFriend extends StatelessWidget {
  // final String name;
  // final String avatarImage;
  // final String dateOfBirth;
  // final String gender;
  // final String phoneNumber;

  final UserModel user;

  const InfoFriend({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 48.0,
              backgroundImage: NetworkImage(user.photoURL!),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName!,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Ngày sinh: ${DateFormat.yMd().format(user.dob!.toDate())}',
                    style: const TextStyle(fontSize: 17),
                  ),

                  const SizedBox(height: 8.0),
                  // Text('Giới tính: ${user.gender}'),
                  const SizedBox(height: 8.0),
                  Text(
                    'Số điện thoại: ${user.phone}',
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
