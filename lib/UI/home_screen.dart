import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myshop/UI/ChatRoom.dart';
import 'package:myshop/UI/SearchPage.dart';
import 'package:myshop/model/ChatRoomModel.dart';
import 'package:myshop/model/FirebaseHelper.dart';
import 'package:myshop/model/UserModel.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomeScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.userModel.photoURL.toString())),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(widget.userModel.displayName.toString()),
                ],
              ),
            ),
          );
        }));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tan Gau'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('member.${widget.userModel.uid}', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapShot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapShot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapShot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> memberjoin = chatRoomModel.member!;
                      List<String> memberUid = memberjoin.keys.toList();
                      memberUid.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(memberUid[0]),
                        builder: (context, userData) {
                          if (userData.data == null) {
                            return const Center(
                              child: Text('Chưa có tin nhắn nào ở đây'),
                            );
                          } else {
                            UserModel currentUser = userData.data as UserModel;
                            return ListTile(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomScreen(
                                      currentUser: currentUser,
                                      chatroom: chatRoomModel,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser);
                                }));
                              },
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(currentUser.photoURL!),
                              ),
                              title: Text(currentUser.displayName!),
                              subtitle:
                                  Text(chatRoomModel.lastMessage.toString()),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              return const Center(
                child: Text('Chưa có tin nhắn nào ở đây'),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone), label: 'Danh bạ'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Người dùng'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(7.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser);
            }));
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
    );
  }
}
