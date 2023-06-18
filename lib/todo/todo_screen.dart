import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/todo/firestore_methods.dart';
import '/utils/utils.dart';
import '/todo/task_model.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

/*
TODO: add cache sistem
have 2 map<string, task> saved locally, all the changes are done to it, 
save a task locally, add it to a toupdate queue
always check for data from firestore
have everything saved with sharedpreferences 
Categories



Subtasks
Time
Priority
*/

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleC = TextEditingController();

  Future<void> _displayDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a task'),
        content: TextField(
          controller: _titleC,
          decoration: const InputDecoration(hintText: 'Type your task'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _addTask(_titleC.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addTask(_titleC.text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future _addTask(String title) async {
    await FirestoreMethdods.addTask(Task(title: title));
    _titleC.clear();
  }

  Future _archiveTask(Task task) async {
    await FirestoreMethdods.archiveTask(task.uid);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyQ): _displayDialog,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(title: const Text('Todo')),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection(tasksS).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingCenter();
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final task = Task.fromSnap(snapshot.data!.docs[index]);
                  return ListTile(
                    key: ValueKey(task),
                    title: Text(task.title),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: task.isLoading
                          ? const CircularProgressIndicator()
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _archiveTask(task),
                            ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _displayDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
