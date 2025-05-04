import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  String id;
  String title;
  dynamic content; // rich text content (as JSON)
  String? sharedFrom;
  String? sharedUserId; // Added sharedUserId field
  String role;
  bool isPinned;
  List<String> tags;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.sharedFrom,
    this.sharedUserId, // Initialize sharedUserId
    required this.role,
    required this.isPinned,
    required this.tags,
  });

  // Add sharedUserId to the Firestore data
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      sharedFrom: data['sharedFrom'],
      sharedUserId: data['sharedUserId'], // Read sharedUserId
      role: data['role'] ?? 'owner',
      isPinned: data['isPinned'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'sharedFrom': sharedFrom,
      'sharedUserId': sharedUserId, // Include sharedUserId in the saved data
      'role': role,
      'isPinned': isPinned,
      'tags': tags,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

