import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../models/note_model.dart';
import '../services/note_service.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService _noteService = NoteService();
  final user = FirebaseAuth.instance.currentUser;
  String? selectedTag;

  void _togglePin(NoteModel note) async {
    await _noteService.updateNote(
      userId: user!.uid,
      noteId: note.id!,
      title: note.title,
      content: note.content,
      isPinned: !note.isPinned,
      tags: note.tags,
    );
  }

  void _openEditor(BuildContext context, NoteModel? note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
  }

  List<NoteModel> _filterNotesByTag(List<NoteModel> notes) {
    if (selectedTag == null) return notes;
    return notes.where((note) => note.tags.contains(selectedTag)).toList();
  }

  List<String> _extractAllTags(List<NoteModel> notes) {
    final tagSet = <String>{};
    for (var note in notes) {
      tagSet.addAll(note.tags);
    }
    return tagSet.toList();
  }

  String _getPlainText(dynamic content) {
    try {
      final doc = Document.fromJson(List<Map<String, dynamic>>.from(content));
      return doc.toPlainText().trim();
    } catch (e) {
      return "Invalid content format";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Notes", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Note", style: TextStyle(color: Colors.white)),
        onPressed: () => _openEditor(context, null),
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: _noteService.getUserNotes(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notes"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!;
          final filteredNotes = _filterNotesByTag(notes);
          final pinnedNotes = filteredNotes.where((note) => note.isPinned).toList();
          final unpinnedNotes = filteredNotes.where((note) => !note.isPinned).toList();
          final allTags = _extractAllTags(notes);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allTags.isNotEmpty) ...[
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allTags.length,
                      itemBuilder: (context, index) {
                        final tag = allTags[index];
                        final isSelected = tag == selectedTag;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: Colors.deepPurple.shade200,
                            onSelected: (_) {
                              setState(() {
                                selectedTag = isSelected ? null : tag;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (pinnedNotes.isNotEmpty) ...[
                  const Text("Pinned", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pinnedNotes.length,
                      itemBuilder: (context, index) {
                        final note = pinnedNotes[index];
                        return GestureDetector(
                          onTap: () => _openEditor(context, note),
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        _getPlainText(note.content),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      children: note.tags.map((tag) => Chip(
                                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                                        backgroundColor: Colors.deepPurple.shade50,
                                      )).toList(),
                                    )
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.push_pin, size: 20, color: Colors.deepPurple),
                                    onPressed: () => _togglePin(note),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text("Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: unpinnedNotes.length,
                    itemBuilder: (context, index) {
                      final note = unpinnedNotes[index];
                      return GestureDetector(
                        onTap: () => _openEditor(context, note),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(note.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepPurple)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.push_pin_outlined),
                                  onPressed: () => _togglePin(note),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(_getPlainText(note.content),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  children: note.tags
                                      .map((tag) => Chip(
                                    label: Text(tag,
                                        style: const TextStyle(
                                            fontSize: 11)),
                                    backgroundColor:
                                    Colors.deepPurple.shade50,
                                  ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
