import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'note_editor_screen.dart';

class SharedNotesScreen extends StatelessWidget {
  final NoteService noteService = NoteService();

  SharedNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shared Notes'),
        ),
        body: const Center(
          child: Text("You're not logged in."),
        ),
      );
    }

    String extractPlainText(dynamic content) {
      if (content is List) {
        return content
            .map((item) =>
        item is Map && item['insert'] is String ? item['insert'] : '')
            .join();
      }
      if (content is String) return content;
      return 'No content';
    }


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Shared Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: noteService.getSharedNotes(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notes shared with you yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final sharedNotes = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: sharedNotes.length,
              itemBuilder: (context, index) {
                final note = sharedNotes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(
                          note: note,
                          isEditable: note.role == "edit",
                          isSharedNote: true,
                          sharedUserId: note.sharedUserId.toString(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          extractPlainText(note.content),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: (note.tags).map((tag) {
                                return Chip(
                                  label: Text(tag.toString()),
                                  backgroundColor: Colors.deepPurple.shade100,
                                );
                              }).toList(),
                            ),
                            Text(
                              note.role,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepPurple.shade300,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
