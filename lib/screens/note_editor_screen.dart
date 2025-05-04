import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final bool isEditable;
  final bool isSharedNote;
  final String  sharedUserId;

  const NoteEditorScreen({
    Key? key,
    this.note,
    this.isEditable = true,
    this.isSharedNote = false,
    this.sharedUserId = "",
  }) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteService _noteService = NoteService();
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _tagsController.text = widget.note!.tags.join(', ');

      // Initialize Quill controller with existing note content
      _quillController = quill.QuillController(
        document: quill.Document.fromJson(widget.note!.content),
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      // Initialize empty Quill controller for a new note
      _quillController = quill.QuillController.basic();
    }
  }

  void _saveNote() async {
    if (!widget.isEditable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission to edit this note.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final content = _quillController.document.toDelta().toJson(); // Get content from Quill
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty note!')),
      );
      return;
    }

    if (widget.note == null) {
      await _noteService.addNote(
        userId: user!.uid,
        title: title,
        content: content,
        tags: tags,
      );
    } else {
      await _noteService.updateNote(
        userId: user!.uid,
        noteId: widget.note!.id,
        title: title,
        content: content,
        tags: tags,
        sharedUserId: widget.sharedUserId
      );
    }

    Navigator.pop(context);
  }

  void _deleteNote() async {
    if (widget.note == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Delete'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.isSharedNote) {
        // If shared note, remove from shared_notes collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('shared')
            .doc(widget.note!.id)
            .delete();
      } else {
        // If it's your own note
        await _noteService.deleteNote(user!.uid, widget.note!.id);
      }
      Navigator.pop(context);
    }
  }


  void _shareNote() async {
    final emailController = TextEditingController();
    String selectedRole = 'view';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Share Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Receiver Email',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Permission'),
                  items: const [
                    DropdownMenuItem(value: 'view', child: Text('Read Only')),
                    DropdownMenuItem(value: 'edit', child: Text('Edit')),
                  ],
                  onChanged: (value) {
                    selectedRole = value ?? 'view';
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Share'),
                onPressed: () async {
                  final receiverEmail = emailController.text.trim();
                  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

                  if (receiverEmail == currentUserEmail) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You can't share a note with yourself.")),
                    );
                    return;
                  }

                  try {
                    final query = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: receiverEmail)
                        .limit(1)
                        .get();

                    if (query.docs.isEmpty) {
                      Navigator.pop(context); // close dialog first
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error: Email not found.")),
                      );
                      return;
                    }

                    final sharedUserId = query.docs.first.id;


                    await _noteService.shareNote(
                      receiverEmail: receiverEmail,
                      note: widget.note!,
                      role: selectedRole,
                    );

                    await _noteService.updateNote(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      noteId: widget.note!.id,
                      title: widget.note!.title,
                      content: widget.note!.content,
                      tags: widget.note!.tags,
                      sharedUserId: sharedUserId, // Save sharedUserId
                    );

                    Navigator.pop(context); // close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Note shared successfully!")),
                    );
                  } catch (e) {
                    Navigator.pop(context); // close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.note == null ? 'New Note' : widget.isEditable ? 'Edit Note' : 'View Note',
          style: const TextStyle(color: Colors.deepPurple),
        ),
        actions: [
          if (widget.note != null && !widget.isSharedNote)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.deepPurple),
              onPressed: _shareNote,
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteNote,
            ),
          if (widget.isEditable)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.deepPurple),
              onPressed: _saveNote,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quill Toolbar
            quill.QuillSimpleToolbar(controller: _quillController),
            const SizedBox(height: 10),
            // Title field
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Title",
                border: InputBorder.none,
              ),
              readOnly: !widget.isEditable,
            ),
            const SizedBox(height: 10),
            // Quill Editor for content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4.0, offset: Offset(0, 4)),
                  ],
                ),
              child: quill.QuillEditor.basic(
                controller: _quillController,
              ),
              ),
            ),
            const SizedBox(height: 10),
            // Tags input field
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: "Tags (separated by commas)",
                prefixIcon: const Icon(Icons.tag, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              readOnly: !widget.isEditable,
            ),
          ],
        ),
      ),
    );
  }
}
