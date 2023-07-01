import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jarvis_0/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/todo/task_model.dart';
import '../components/AddTaskDialog.dart';
import 'firestore_methods.dart';

class TaskSyncObject {
  late StateSetter setState;
  late BoolWrapper isSyncing;

  TaskSyncObject(this.setState, this.isSyncing);
}

Future<void> reloadStateTask(
    TaskSyncObject syncObject, Function runFunc) async {
  syncObject.setState(() {
    syncObject.isSyncing.value = true;
  });
  await runFunc();
  syncObject.setState(() {
    syncObject.isSyncing.value = false;
  });
}

class TodoMethods {
  static final _prefs = SharedPreferences.getInstance();
  static final _firestore = FirebaseFirestore.instance;

  static Future displayDialog(
    TaskSyncObject taskSyncObject,
    Map<String, Task> tasks,
    TextEditingController titleC,
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        titleC: titleC,
        taskSyncObject: taskSyncObject,
        tasks: tasks,
      ),
    );
  }

  static Future loadSyncTasks(
    TaskSyncObject taskSyncObject,
    Map<String, Task> tasks,
  ) async {
    await reloadStateTask(taskSyncObject, () async {
      await _loadTasks(tasks);

      taskSyncObject.setState(() {});
      await _syncTasks(tasks);
    });
  }

  static Future syncTasks(
    TaskSyncObject taskSyncObject,
    Map<String, Task> tasks,
  ) async {
    await reloadStateTask(taskSyncObject, () async {
      await _syncTasks(tasks);
    });
  }

  static void addTask(
    TaskSyncObject taskSyncObject,
    Map<String, Task> tasks,
    TextEditingController titleC,
  ) {
    try {
      final task = Task(title: titleC.text);
      tasks[task.uid] = task;
      titleC.clear();

      _saveTask(tasks, task, taskSyncObject);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void archiveTask(
    TaskSyncObject taskSyncObject,
    Map<String, Task> tasks,
    Task task,
  ) {
    try {
      task.dispose();
      tasks.remove(task.uid);
      reloadStateTask(taskSyncObject, () async {
        _saveTasksLocally(tasks);
        FirestoreMethdods.archiveTask(task.uid);
      }).then((value) => null);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void markDoneTask(
    Map<String, Task> tasks,
    Task task,
    TaskSyncObject taskSyncObject,
  ) {
    try {
      task.dispose();
      tasks.remove(task.uid);

      reloadStateTask(taskSyncObject, () async {
        _saveTasksLocally(tasks);
        FirestoreMethdods.markDoneTask(task.uid);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void modifyTitle(String title, Map<String, Task> tasks, Task task,
      TaskSyncObject taskSyncObject) {
    try {
      task.title = title;
      task.lastModified = DateTime.now();
      _saveTask(tasks, task, taskSyncObject);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future modifyDate(
    String uid,
    Map<String, Task> tasks,
    TaskSyncObject taskSyncObject,
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
      _saveTask(tasks, task, taskSyncObject);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future _saveTask(
    Map<String, Task> tasks,
    Task task,
    TaskSyncObject taskSyncObject,
  ) async {
    await reloadStateTask(taskSyncObject, () async {
      await _saveTasksLocally(tasks);
      await FirestoreMethdods.addOrModifyTask(task);
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
      debugPrint(e.toString());
    }
  }

  static Future _saveTasksLocally(Map<String, Task> tasks) async {
    try {
      final prefs = await _prefs;
      final taskMap = tasks.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(tasksS, json.encode(taskMap));
    } catch (e) {
      debugPrint(e.toString());
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

      _parseTaskJson(jsonString, docs, tasks, snapArchived, snapDone);
      for (var doc in docs) {
        if (!tasks.containsKey(doc.id)) {
          tasks[doc.id] = Task.fromSnap(doc);
        }
      }
      await _saveTasksLocally(tasks);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void _parseTaskJson(
      jsonString, docs, Map<String, Task> tasks, snapArchived, snapDone) {
    if (jsonString == null) return;

    final taskMap = json.decode(jsonString);

    for (var entry in taskMap.entries) {
      final uid = entry.key;
      final taskPrefs = Task.fromJson(uid, entry.value);

      if (docs.contains(uid)) {
        final taskFirestore =
            Task.fromSnap(docs.firstWhere((element) => element.id == uid));
        final bool isModified =
            taskFirestore.lastModified.isAfter(taskPrefs.lastModified);

        if (isModified) {
          tasks[uid] = taskFirestore;
          continue;
        }
      }

      final bool isArchived = snapArchived.docs.contains(uid);
      final bool isDone = snapDone.docs.contains(uid);
      if (isArchived || isDone) {
        continue;
      }
      tasks[uid] = taskPrefs;
      FirestoreMethdods.addOrModifyTask(taskPrefs);
    }
  }
}
