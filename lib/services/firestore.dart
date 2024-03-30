import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  //get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //CREATE ( to add new notes )
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //READ ( to get notes added from the database )
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //UPDATE( to change the notes )
  Future<void> updateNote(String docID, String newNote) {
    return notes.doc(docID).update({
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //DELETE ( to delete the notes )
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
