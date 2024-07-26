
class Message {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;
  String? type;

  // Constructor
  Message({this.messageId,this.sender, this.text, this.seen, this.createdOn, this.type});

  // Named constructor to create an instance from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId:map['messageId'],
      sender: map['sender'],
      text: map['text'],
      seen: map['seen'],
      // createdOn: map['createdOn'],
        type : map['type']
    );
  }

  // Method to convert an instance to a map
  Map<String, dynamic> toMap() {
    return {
      'messageId':messageId,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdOn': createdOn,
      'type' : type
    };
  }
}
