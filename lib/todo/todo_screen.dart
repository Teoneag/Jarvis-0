import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _selectDate(BuildContext context, Task task) async {
    final datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (datePicked != null) {
      setState(() {
        task.dueDate = datePicked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, Task task) async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (timePicked != null) {
      DateTime? dueDate = task.dueDate;
      dueDate ??= DateTime.now();
      task.dueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        timePicked.hour,
        timePicked.minute,
      );
      setState(() {});
    }
  }

  final TextEditingController _titleC = TextEditingController();
  final Map<String, Task> _tasks = {};
  final _prefs = SharedPreferences.getInstance();
  bool _isSyncing = false;

  Future _saveTasksLocally() async {
    final prefs = await _prefs;
    final taskMap = _tasks.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(tasksS, json.encode(taskMap));
  }

  Future _syncTasks() async {
    try {
      setState(() {
        _isSyncing = true;
      });
      final prefs = await _prefs;
      final jsonString = prefs.getString(tasksS);
      final querySnap =
          await FirebaseFirestore.instance.collection(tasksS).get();
      final docs = querySnap.docs;
      _tasks.clear();
      if (jsonString != null) {
        final taskMap = json.decode(jsonString);
        taskMap.forEach((uid, value) {
          final taskFirestore =
              Task.fromSnap(docs.firstWhere((element) => element.id == uid));
          final taskPrefs = Task.fromJson(uid, value);
          if (taskFirestore.lastModified.isAfter(taskPrefs.lastModified)) {
            _tasks[uid] = taskFirestore;
          } else {
            _tasks[uid] = taskPrefs;
            FirestoreMethdods.addOrModifyTask(taskPrefs);
          }
        });
      }
      for (var doc in docs) {
        if (_tasks.containsKey(doc.id)) {
          continue;
        }
        _tasks[doc.id] = Task.fromSnap(doc);
      }
      setState(() {});
      await _saveTasksLocally();
      setState(() {
        _isSyncing = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(tasksS);
      print(jsonString);
      final taskMap = json.decode(jsonString!);
      _tasks.clear();
      taskMap.forEach((key, value) {
        _tasks[key] = Task.fromJson(key, value);
      });
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _addTask(String title) {
    final task = Task(title: title);
    _tasks[task.uid] = task;
    _titleC.clear();
    setState(() {});
    _saveTasksLocally();
    FirestoreMethdods.addOrModifyTask(task);
  }

  void _archiveTask(Task task) {
    task.dispose();
    _tasks.remove(task.uid);
    setState(() {});
    _saveTasksLocally();
    FirestoreMethdods.archiveTask(task.uid);
  }

  void _markDoneTask(Task task) {
    task.dispose();
    _tasks.remove(task.uid);
    setState(() {});
    _saveTasksLocally();
    FirestoreMethdods.markDoneTask(task.uid);
  }

  void _pressedSync() {
    if (_isSyncing) {
      return;
    }
    _syncTasks();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _syncTasks();
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
          appBar: AppBar(
            title: const Text('Todo'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: IconButton(
                  icon: _isSyncing
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.sync),
                  onPressed: _pressedSync,
                ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks.values.elementAt(index);
              return ListTile(
                // key: ValueKey(task.uid), // only for reordering (not doing now)
                leading: IconButton(
                  icon: const Icon(Icons.check_box_outline_blank),
                  onPressed: () => _markDoneTask(task),
                ),
                title: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: task.textC,
                        decoration: const InputDecoration(isDense: true),
                        onChanged: (value) {
                          task.title = value;
                          task.lastModified = DateTime.now();
                          _saveTasksLocally();
                          FirestoreMethdods.addOrModifyTask(task);
                        },
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    IconButton(
                      onPressed: () => _selectDate(context, task),
                      icon: const Icon(Icons.calendar_today),
                    ),
                    IconButton(
                      onPressed: () => _selectTime(context, task),
                      icon: const Icon(Icons.access_time),
                    ),
                    Text('${task.dueDate ?? 0}'),
                  ],
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
