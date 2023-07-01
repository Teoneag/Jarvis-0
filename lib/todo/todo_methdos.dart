import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_0/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_methods.dart';
import '/todo/task_model.dart';

class TodoM {
  static final _prefs = SharedPreferences.getInstance();
  static final _firestore = FirebaseFirestore.instance;

  static Future displayDialog(
    Map<String, Task> tasks,
    TextEditingController titleC,
    BuildContext context,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a task'),
        content: TextField(
          controller: titleC,
          decoration: const InputDecoration(hintText: 'Type your task'),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            addTask(tasks, titleC, setState, isSyncing);
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
              addTask(tasks, titleC, setState, isSyncing);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future loadSyncTasks(
    Map<String, Task> tasks,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) async {
    setState(() {
      isSyncing.value = true;
    });
    await _loadTasks(tasks);
    setState(() {});
    await _syncTasks(tasks);
    setState(() {
      isSyncing.value = false;
    });
  }

  static Future syncTasks(
    Map<String, Task> tasks,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) async {
    setState(() {
      isSyncing.value = true;
    });
    await _syncTasks(tasks);
    setState(() {
      isSyncing.value = false;
    });
  }

  static void addTask(
    Map<String, Task> tasks,
    TextEditingController titleC,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) {
    try {
      final task = Task(title: titleC.text);
      tasks[task.uid] = task;
      titleC.clear();
      _saveTask(tasks, task, setState, isSyncing);
    } catch (e) {
      print(e);
    }
  }

  static void archiveTask(
    Map<String, Task> tasks,
    Task task,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) {
    try {
      task.dispose();
      tasks.remove(task.uid);
      setState(() {
        isSyncing.value = true;
      });
      _saveTasksLocally(tasks);
      FirestoreMethdods.archiveTask(task.uid);
      setState(() {
        isSyncing.value = false;
      });
    } catch (e) {
      print(e);
    }
  }

  static void markDoneTask(
    Map<String, Task> tasks,
    Task task,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) {
    try {
      task.dispose();
      tasks.remove(task.uid);
      setState(() {
        isSyncing.value = true;
      });
      _saveTasksLocally(tasks);
      FirestoreMethdods.markDoneTask(task.uid);
      setState(() {
        isSyncing.value = false;
      });
    } catch (e) {
      print(e);
    }
  }

  static void modifyTitle(
    String title,
    Map<String, Task> tasks,
    Task task,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) {
    try {
      task.title = title;
      task.lastModified = DateTime.now();
      _saveTask(tasks, task, setState, isSyncing);
    } catch (e) {
      print(e);
    }
  }

  static Future modifyDate(
    String uid,
    Map<String, Task> tasks,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) async {
    try {
      Task task = tasks[uid]!;
      if (task.date != null) task.dueDate = task.date;
      task.dueDate ??= DateTime.now();
      if (task.time != null) {
        task.dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
          task.time!.hour,
          task.time!.minute,
        );
      }
      // check with text
      task.lastModified = DateTime.now();
      tasks[uid] = task;
      task.isDateVisible = false;
      _saveTask(tasks, task, setState, isSyncing);
    } catch (e) {
      print(e);
    }
  }

  static Future _saveTask(
    Map<String, Task> tasks,
    Task task,
    StateSetter setState,
    BoolWrapper isSyncing,
  ) async {
    setState(() {
      isSyncing.value = true;
    });
    await _saveTasksLocally(tasks);
    await FirestoreMethdods.addOrModifyTask(task);
    setState(() {
      isSyncing.value = false;
    });
  }

  static Future _loadTasks(Map<String, Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(tasksS);
      final taskMap = json.decode(jsonString!);
      tasks.clear();
      taskMap.forEach((key, value) {
        tasks[key] = Task.fromJson(key, value);
      });
    } catch (e) {
      print(e);
    }
  }

  static Future _saveTasksLocally(Map<String, Task> tasks) async {
    try {
      final prefs = await _prefs;
      final taskMap = tasks.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(tasksS, json.encode(taskMap));
    } catch (e) {
      print(e);
    }
  }

  static Future _syncTasks(Map<String, Task> tasks) async {
    try {
      final List results = await Future.wait([
        _prefs,
        _firestore.collection(tasksS).get(),
        _firestore.collection(tasksArchivedS).get(),
        _firestore.collection(tasksDoneS).get(),
      ]);
      final snapArchived = results[2];
      final snapDone = results[3];
      final jsonString = results[0].getString(tasksS);
      final docs = results[1].docs;
      tasks.clear();
      if (jsonString != null) {
        final taskMap = json.decode(jsonString);
        for (var entry in taskMap.entries) {
          final uid = entry.key;
          final taskPrefs = Task.fromJson(uid, entry.value);
          if (docs.contains(uid)) {
            final taskFirestore =
                Task.fromSnap(docs.firstWhere((element) => element.id == uid));
            if (taskFirestore.lastModified.isAfter(taskPrefs.lastModified)) {
              tasks[uid] = taskFirestore;
              continue;
            }
          }
          if (snapArchived.docs.contains(uid) || snapDone.docs.contains(uid)) {
            continue;
          }
          tasks[uid] = taskPrefs;
          FirestoreMethdods.addOrModifyTask(taskPrefs);
        }
      }
      for (var doc in docs) {
        if (!tasks.containsKey(doc.id)) {
          tasks[doc.id] = Task.fromSnap(doc);
        }
      }
      await _saveTasksLocally(tasks);
    } catch (e) {
      print(e);
    }
  }
}
