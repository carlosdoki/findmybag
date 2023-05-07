import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<DocumentReference<Object?>> addMessage(
      String content, String senderId) async {
    return await messagesCollection.add({
      'content': content,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> get messages {
    return messagesCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
