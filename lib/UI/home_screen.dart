import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myshop/UI/ChatRoom.dart';
import 'package:myshop/UI/ProfileScreen.dart';
import 'package:myshop/UI/SearchPage.dart';
import 'package:myshop/model/ChatRoomModel.dart';
import 'package:myshop/model/FirebaseHelper.dart';
import 'package:myshop/model/NotificationModel.dart';
import 'package:myshop/model/UserModel.dart';
import 'package:myshop/provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/FmcService.dart';

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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (!_initialized) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      final FcmService fcmService = FcmService();
      await fcmService.registerDevice();
      _initialized = true;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(userModel: widget.userModel)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool _showConfirm = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChipTalk'),
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
                .where('member.${authProvider.currentUser?.uid}',
                    isEqualTo: true)
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
                      memberUid.remove(authProvider.currentUser?.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(memberUid[0]),
                        builder: (context, userData) {
                          if (userData.data == null) {
                            return const SizedBox(
                              height: 0,
                              width: 0,
                            );
                          } else {
                            UserModel currentUser = userData.data as UserModel;

                            return Dismissible(
                              key: Key(userData.data?.uid as String),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .where(
                                        'member.${authProvider.currentUser?.uid}',
                                        isEqualTo: true)
                                    .where('member.${userData.data?.uid}',
                                        isEqualTo: true)
                                    .get()
                                    .then((querySnapshot) {
                                  for (var element in querySnapshot.docs) {
                                    element.reference.update({
                                      'member.${userData.data?.uid}': false
                                    });
                                  }
                                });
                              },
                              // ignore: sort_child_properties_last
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ChatRoomScreen(
                                        currentUser: currentUser,
                                        chatroom: chatRoomModel,
                                        userModel: authProvider.currentUser!,
                                        firebaseUser: widget.firebaseUser);
                                  }));
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(currentUser.photoURL!),
                                    ),
                                    title: Text(currentUser.displayName!),
                                    subtitle: Text(
                                      chatRoomModel.lastMessage.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    // trailing: Text(
                                    //   DateFormat('HH:mm:ss').format(
                                    //       currentUser.lastOnline!.toDate()),
                                    // ),
                                  ),
                                ),
                              ),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 4,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) {
                                return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Xác nhận'),
                                        content: const Text(
                                            'Bạn có chắc muốn xoá cuộc trò chuyện này?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('chatrooms')
                                                    .where(
                                                        'member.${authProvider.currentUser?.uid}',
                                                        isEqualTo: true)
                                                    .where(
                                                        'member.${userData.data?.uid}',
                                                        isEqualTo: true)
                                                    .get()
                                                    .then((querySnapshot) {
                                                  for (var element
                                                      in querySnapshot.docs) {
                                                    print(
                                                        "uid ${userData.data?.uid}");
                                                    element.reference.update({
                                                      'member.${authProvider.currentUser?.uid}':
                                                          false
                                                    });
                                                  }
                                                });

                                                Navigator.pop(context);
                                                setState(() {
                                                  _showConfirm = false;
                                                });
                                              },
                                              child: const Text('Có')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _showConfirm = false;
                                                });
                                              },
                                              child: const Text('Không'))
                                        ],
                                      );
                                    });
                              },
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
              icon: Icon(Icons.account_box), label: 'Người dùng'),
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
