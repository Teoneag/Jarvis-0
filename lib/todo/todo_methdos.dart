import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_methods.dart';
import '/todo/task_model.dart';

class TodoMethods {
  static final _prefs = SharedPreferences.getInstance();
  static final _firestore = FirebaseFirestore.instance;

  static Future displayDialog(tasks, titleC, context, setState) async {
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
            addTask(tasks, titleC, setState);
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
              addTask(tasks, titleC, setState);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future loadSyncTasks(tasks, setState, isSyncing) async {
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

  static Future syncTasks(tasks, setState, isSyncing) async {
    setState(() {
      isSyncing.value = true;
    });
    await _syncTasks(tasks);
    setState(() {
      isSyncing.value = false;
    });
  }

  static Future _loadTasks(tasks) async {
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

  static Future _saveTasksLocally(tasks) async {
    try {
      final prefs = await _prefs;
      final taskMap = tasks.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(tasksS, json.encode(taskMap));
    } catch (e) {
      print(e);
    }
  }

  static Future _syncTasks(tasks) async {
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

  static void addTask(tasks, titleC, setState) {
    final task = Task(title: titleC.text);
    tasks[task.uid] = task;
    titleC.clear();
    setState(() {});
    _saveTasksLocally(tasks);
    FirestoreMethdods.addOrModifyTask(task);
  }

  static void archiveTask(task, tasks, setState) {
    task.dispose();
    tasks.remove(task.uid);
    setState(() {});
    _saveTasksLocally(tasks);
    FirestoreMethdods.archiveTask(task.uid);
  }

  static void markDoneTask(task, tasks, setState) {
    task.dispose();
    tasks.remove(task.uid);
    setState(() {});
    _saveTasksLocally(tasks);
    FirestoreMethdods.markDoneTask(task.uid);
  }

  static void modifyTitle(title, task, tasks, setState) {
    task.title = title;
    task.lastModified = DateTime.now();
    setState(() {});
    _saveTasksLocally(tasks);
    FirestoreMethdods.addOrModifyTask(task);
  }
}
