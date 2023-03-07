import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myshop/UI/SearchPage.dart';
import 'package:myshop/model/ChatRoomModel.dart';
import 'package:myshop/model/MessageModel.dart';
import 'package:myshop/model/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel currentUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomScreen(
      {Key? key,
      required this.currentUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        create: Timestamp.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatRoomId)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatRoomId)
          .update({'lastMessage': msg});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.currentUser.photoURL!),
            ),
            const SizedBox(width: 10),
            Text(widget.currentUser.displayName!)
          ],
        ),
      ),
      body: SafeArea(
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: Column(children: [
            Expanded(
                // ignore: avoid_unnecessary_containers
                child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(widget.chatroom.chatRoomId)
                    .collection('messages')
                    .orderBy('create', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          // return Text(currentMessage.text.toString());

                          if (currentMessage.sender.toString() ==
                              widget.userModel.uid.toString()) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Text(
                                    DateFormat('HH:mm:ss').format(
                                        currentMessage.create!.toDate()),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 206, 201, 201)),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 215, 239, 249),
                                      border:
                                          Border.all(color: Colors.lightBlue),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(30)),
                                    ),
                                    child: Text(currentMessage.text!.toString(),
                                        style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 225, 229, 230),
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 123, 126, 127)),
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(30)),
                                    ),
                                    child: Text(currentMessage.text!.toString(),
                                        style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, left: 10),
                                  child: Text(
                                    DateFormat('HH:mm:ss').format(
                                        currentMessage.create!.toDate()),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 206, 201, 201)),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                            'Lỗi xảy ra khi tải tin nhắn! Vui lòng kiểm tra kết nối'),
                      );
                    } else {
                      return const Center(
                        child: Text('Bắt đầu cuộc hội thoại'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )),

            // ignore: avoid_unnecessary_containers
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          color: const Color.fromARGB(255, 212, 212, 204),
                        ),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                // hintStyle: TextStyle(color: Colors.blueAccent),
                                border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.image),
                          color: const Color.fromARGB(255, 212, 212, 204),
                        ),
                      ],
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
