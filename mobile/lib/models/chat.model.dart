import 'user.model.dart';

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final String type;
  final String? filePath;
  final DateTime? readAt;
  final DateTime createdAt;
  final User? sender;
  final List<Attachment> attachments;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.filePath,
    this.readAt,
    required this.createdAt,
    this.sender,
    required this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'] ?? '',
      type: json['type'],
      filePath: json['file_path'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      attachments: (json['attachments'] as List? ?? [])
          .map((a) => Attachment.fromJson(a))
          .toList(),
    );
  }
}

class Attachment {
  final int id;
  final String filePath;
  final String fileName;
  final String fileType;

  Attachment({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileType,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      filePath: json['file_path'],
      fileName: json['file_name'],
      fileType: json['file_type'],
    );
  }
}

class Conversation {
  final int id;
  final String type;
  final List<User> users;
  final Message? lastMessage;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.type,
    required this.users,
    this.lastMessage,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      type: json['type'],
      users: (json['users'] as List? ?? [])
          .map((u) => User.fromJson(u))
          .toList(),
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FriendRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final User sender;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.sender,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
      sender: User.fromJson(json['sender']),
    );
  }
}
