import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  Timestamp? create;
  String? type;

  MessageModel(
      {this.messageId,
      this.sender,
      this.text,
      this.seen,
      this.create,
      this.type});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    create = map['create'];
    type = map['type'];
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sender': sender,
      'text': text,
      'seen': seen,
      'create': create,
      'type': type
    };
  }
}
