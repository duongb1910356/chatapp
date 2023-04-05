import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myshop/UI/InfoFriend.dart';
import 'package:myshop/UI/SearchPage.dart';
import 'package:myshop/model/ChatRoomModel.dart';
import 'package:myshop/model/MessageModel.dart';
import 'package:myshop/model/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  bool showEmoij = false;

  void sendMessage(String type, String msg) async {
    // String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        sender: widget.userModel.uid,
        create: Timestamp.now(),
        text: msg,
        seen: false,
        type: type,
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

  Future<String> uploadFile(Uint8List data, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final task = ref.putData(data);

    final snapshot = await task.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return InfoFriend(
                    user: widget.currentUser,
                  );
                }));
              },
              icon: const Icon(Icons.info)),
        ],
      ),
      body: SafeArea(
        //ignore: avoid_unnecessary_containers
        child: WillPopScope(
          onWillPop: () {
            if (showEmoij) {
              setState(() {
                showEmoij = !showEmoij;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Column(children: [
              Expanded(
                  // ignore: avoid_unnecessary_containers
                  child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Text(
                                      DateFormat('HH:mm:ss').format(
                                          currentMessage.create!.toDate()),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 206, 201, 201)),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 215, 239, 249),
                                          border: Border.all(
                                              color: Colors.lightBlue),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20)),
                                        ),
                                        child: currentMessage.type == 'text'
                                            ? Text(
                                                currentMessage.text!.toString(),
                                                style: GoogleFonts.openSans(
                                                  textStyle: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ))
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  currentMessage.text!,
                                                  fit: BoxFit.contain,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                    return const Text(
                                                        'Failed to load image');
                                                  },
                                                ))),
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            bottomRight: Radius.circular(20)),
                                      ),
                                      child: currentMessage.type == 'text'
                                          ? Text(
                                              currentMessage.text!.toString(),
                                              style: GoogleFonts.openSans(
                                                textStyle: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                currentMessage.text!,
                                                fit: BoxFit.contain,
                                                loadingBuilder:
                                                    (BuildContext context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object error,
                                                    StackTrace? stackTrace) {
                                                  return const Text(
                                                      'Failed to load image');
                                                },
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
                                          color: Color.fromARGB(
                                              255, 206, 201, 201)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                        child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                showEmoij = !showEmoij;
                              });
                            },
                            icon: const Icon(Icons.emoji_emotions_outlined),
                            color: const Color.fromARGB(255, 212, 212, 204),
                          ),
                          Expanded(
                            child: TextField(
                              onTap: () {
                                if (showEmoij) {
                                  setState(() {
                                    showEmoij = !showEmoij;
                                  });
                                }
                              },
                              controller: messageController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  hintText: 'Nhập tin nhắn...',
                                  // hintStyle: TextStyle(color: Colors.blueAccent),
                                  border: InputBorder.none),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70);
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                final String urlImage =
                                    await uploadFile(bytes, uuid.v1());
                                sendMessage('image', urlImage);
                              }
                            },
                            icon: const Icon(Icons.image),
                            color: const Color.fromARGB(255, 212, 212, 204),
                          ),
                        ],
                      ),
                    )),
                    IconButton(
                        onPressed: () {
                          sendMessage('text', messageController.text.trim());
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                  ],
                ),
              ),

              if (showEmoij)
                SizedBox(
                  height: 200,
                  child: EmojiPicker(
                      textEditingController: messageController,
                      // ignore: prefer_const_constructors
                      config: Config(
                          bgColor: const Color.fromARGB(255, 234, 248, 255),
                          initCategory: Category.RECENT,
                          columns: 8,
                          emojiSizeMax: 30 * (Platform.isIOS ? 1.30 : 1.0))),
                )
            ]),
          ),
        ),
      ),
    );
  }
}
