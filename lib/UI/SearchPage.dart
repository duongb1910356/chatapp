import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myshop/UI/ChatRoom.dart';
import 'package:myshop/model/ChatRoomModel.dart';
import 'package:myshop/model/UserModel.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel currentUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('member.${widget.userModel.uid}', isEqualTo: true)
        .where('member.${currentUser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print('Chatroom da ton tai');
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatRoom;
    } else {
      print('Chatroom chua ton tai, tao chatroom');
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        member: {
          widget.userModel.uid.toString(): true,
          currentUser.uid.toString(): true,
        },
      );
      chatRoom = newChatRoom;

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm bạn'),
      ),
      body: SafeArea(
        // ignore: avoid_unnecessary_containers
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    labelText: 'Nhập số điện thoại tìm kiếm'),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text('Tìm kiếm'),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('phone', isEqualTo: searchController.text)
                    .where('phone', isNotEqualTo: widget.userModel.phone)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchUser = UserModel.fromMap(userMap);

                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoomModel =
                                await getChatRoomModel(searchUser);
                            if (chatRoomModel != null) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatRoomScreen(
                                  currentUser: searchUser,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatroom: chatRoomModel,
                                );
                              }));
                            }
                          },
                          leading: CircleAvatar(
                              radius: 35,
                              backgroundImage:
                                  NetworkImage(searchUser.photoURL!)),
                          title: Text(searchUser.displayName!),
                          subtitle: Text(searchUser.email!),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return const Text('Không tìm thấy người dùng phù hợp');
                      }
                    } else if (snapshot.hasError) {
                      return const Text('Lỗi xảy ra khi tìm kiếm');
                    } else {
                      return const Text('Không tìm thấy người dùng phù hợp');
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
