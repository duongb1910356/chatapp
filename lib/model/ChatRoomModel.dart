// ignore: file_names
class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? member;
  String? lastMessage;

  ChatRoomModel({this.chatRoomId, this.member, this.lastMessage});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatroomid'];
    member = map['member'];
    lastMessage = map['lastMessage'];
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatRoomId,
      'member': member,
      'lastMessage': lastMessage
    };
  }
}
