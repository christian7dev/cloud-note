import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get notes for the current user
  Stream<List<NoteModel>> getUserNotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }

  /// Add a new note
  Future<void> addNote({
    required String userId,
    required String title,
    required dynamic content, // rich text JSON
    bool isPinned = false,
    List<String> tags = const [],
  }) async {
    await _firestore.collection('users').doc(userId).collection('notes').add({
      'title': title,
      'content': content,
      'role': 'owner',
      'isPinned': isPinned,
      'tags': tags,
      'timestamp': FieldValue.serverTimestamp(), // timestamp added here
    });
  }

  /// Update an existing note
  Future<void> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required dynamic content,
    bool? isPinned,
    List<String>? tags,
    String? sharedUserId, // Pass sharedUserId
  }) async {
    final updateData = <String, dynamic>{
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (isPinned != null) {
      updateData['isPinned'] = isPinned;
    }
    if (tags != null) {
      updateData['tags'] = tags;
    }

    if (sharedUserId != null && sharedUserId.isNotEmpty) {
      // Update ONLY the shared copy in users/{sharedUserId}/shared/{noteId}
      await _firestore
          .collection('users')
          .doc(sharedUserId)
          .collection('shared')
          .doc(noteId)
          .update(updateData);
    } else {
      // Update ONLY the owner’s note in users/{userId}/notes/{noteId}
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .update(updateData);
    }
  }



  /// Delete a note
  Future<void> deleteNote(String userId, String noteId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  /// Get shared notes for the current user
  Stream<List<NoteModel>> getSharedNotes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('shared')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }

  /// Share a note with another user by email
  Future<void> shareNote({
    required String receiverEmail,
    required NoteModel note,
    required String role, // "edit" or "view"
  }) async {
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: receiverEmail)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      final receiverId = userQuery.docs.first.id;

      final senderEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unknown';
      final noteData = note.toFirestore();

      noteData['role'] = role;
      noteData['sharedFrom'] = senderEmail;
      noteData['timestamp'] = FieldValue.serverTimestamp(); // add timestamp here too

      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('shared')
          .doc(note.id)
          .set(noteData);
    } else {
      throw Exception('User with email $receiverEmail not found.');
    }
  }

  /// Unshare a note
  Future<void> unshareNote({
    required String receiverUserId,
    required String noteId,
  }) async {
    await _firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('shared')
        .doc(noteId)
        .delete();
  }
}
