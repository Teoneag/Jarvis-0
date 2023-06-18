import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/todo/task_model.dart';
import '/todo/firestore_methods.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
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

  final TextEditingController _titleC = TextEditingController();
  final Map<String, Task> _tasks = {};

  void _addTask(String title) {
    final task = Task(title: title);
    _tasks[task.uid] = task;
    _titleC.clear();
    setState(() {});
    _saveTasks();
  }

  void _archiveTask(Task task) {
    task.dispose();
    _tasks.remove(task.uid);
    setState(() {});
    _saveTasks();
  }

  Future _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskMap = _tasks.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(tasksS, json.encode(taskMap));
  }

  Future _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(tasksS);
      if (jsonString != null) {
        final taskMap = json.decode(jsonString);
        _tasks.clear();
        taskMap.forEach((key, value) {
          _tasks[key] = Task.fromJson(key, value);
        });
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
          body: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks.values.elementAt(index);
              return ListTile(
                key: ValueKey(task.uid),
                title: TextField(
                  controller: task.textC,
                  onChanged: (value) {
                    task.title = value;
                    _saveTasks();
                  },
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _archiveTask(task),
                  ),
                ),
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
