import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jarvis_0/todo/task_widget.dart';
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
    SyncObj sO,
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
            addTask(tasks, titleC, sO);
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
              addTask(tasks, titleC, sO);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static Future loadSyncTasks(Map<String, Task> tasks, SyncObj sO) async {
    await syncFun(sO, () => _loadTasks(tasks));
    await syncFun(sO, () => _syncTasks(tasks));
  }

  static Future syncTasks(Map<String, Task> tasks, SyncObj sO) async {
    await syncFun(sO, () => _syncTasks(tasks));
  }

  static void addTask(
      Map<String, Task> tasks, TextEditingController titleC, SyncObj sO) {
    try {
      final task = Task(title: titleC.text);
      tasks[task.uid] = task;
      titleC.clear();
      _saveTask(TaskObj(tasks, task), sO);
    } catch (e) {
      print(e);
    }
  }

  static void archiveTask(TaskObj tO, SyncObj sO) {
    try {
      tO.task.dispose();
      tO.tasks.remove(tO.task.uid);
      syncFun(sO, () async {
        await _saveTasksLocally(tO.tasks);
        await FirestoreMethdods.archiveTask(tO.task.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  static void doneTask(TaskObj tO, SyncObj sO) {
    try {
      tO.task.dispose();
      tO.tasks.remove(tO.task.uid);
      syncFun(sO, () async {
        await _saveTasksLocally(tO.tasks);
        await FirestoreMethdods.doneTask(tO.task.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  static void modifyTitle(TaskObj tO, String title, SyncObj sO) {
    try {
      tO.task.title = title;
      tO.task.lastModified = DateTime.now();
      _saveTask(TaskObj(tO.tasks, tO.task), sO);
    } catch (e) {
      print(e);
    }
  }

  static void modifyDate(
      String uid, Map<String, Task> tasks, SyncObj sO) async {
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
      _saveTask(TaskObj(tasks, task), sO);
    } catch (e) {
      print(e);
    }
  }

  static Future _saveTask(TaskObj tO, SyncObj sO) async {
    await syncFun(sO, () async {
      await _saveTasksLocally(tO.tasks);
      await FirestoreMethdods.addOrModifyTask(tO.task);
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

Future<void> syncFun(SyncObj sO, Function callback) async {
  sO.setState(() {
    sO.isSyncing.value = true;
  });
  await callback();
  sO.setState(() {
    sO.isSyncing.value = false;
  });
}

class SyncObj {
  final StateSetter setState;
  final BoolWrapper isSyncing;

  SyncObj(this.setState, this.isSyncing);
}

class TaskObj {
  final Map<String, Task> tasks;
  final Task task;

  TaskObj(this.tasks, this.task);
}
