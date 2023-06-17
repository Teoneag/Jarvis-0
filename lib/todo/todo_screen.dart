import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/todo/task_model.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

/*
Categories

Subtasks
Time
Priority
*/

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = [
    Task(title: 'Glases'),
    Task(title: 'Math'),
    Task(title: 'Info'),
    Task(title: 'Money'),
  ];
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

  void _addTask(String title) {
    setState(() {
      _tasks.add(Task(title: title));
    });
    _titleC.clear();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
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
          body: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final item = _tasks.removeAt(oldIndex);
                _tasks.insert(newIndex, item);
              });
            },
            itemCount: _tasks.length,
            itemBuilder: (context, index) => ListTile(
              key: ValueKey(_tasks[index]),
              title: Text(_tasks[index].title),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
              ),
            ),
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
