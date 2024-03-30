import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController textController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void openAddNotes({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => Form(
        key: formKey,
        child: AlertDialog(
          content: TextFormField(
            maxLength: 50,
            validator: (note) {
              if (note == null ||
                  note.isEmpty ||
                  note.trim().length <= 1 ||
                  note.trim().length > 51) {
                return 'Must be between 1 to 50 characters.';
              }
              return null;
            },
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'write your notes...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //validate the text
                if (formKey.currentState!.validate()) {
                  //create or update
                  if (docID == null) {
                    fireStoreService.addNote(textController.text);
                  } else {
                    fireStoreService.updateNote(docID, textController.text);
                  }
                  //clear the textfield and close the alertbox
                  textController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Add',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          'N O T E S  ✍🏻',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddNotes,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //has error
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
            //has no data
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No notes added yet...'),
            );
            //has data
          } else {
            //if we have data,get all the docs
            List notesList = snapshot.data!.docs;
            //display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;
                //get note from each doc
                final data = document.data() as Map<String, dynamic>;
                String note = data['note'];
                //display as a list tile
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        note,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => openAddNotes(docID: docID),
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => fireStoreService.deleteNote(docID),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
