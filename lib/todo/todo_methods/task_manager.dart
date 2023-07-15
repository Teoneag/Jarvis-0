import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firestore_methods.dart';
import '../task_model.dart';
import '/utils/utils.dart';
import 'date_methods.dart';

class TaskM {
  static final _prefs = SharedPreferences.getInstance();
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> loadTasks(Map<String, Task> tasks) async {
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

  static Future<void> saveTasksLocally(Map<String, Task> tasks) async {
    try {
      final prefs = await _prefs;
      final taskMap = tasks.map((key, value) {
        DateM.dateToText(value);
        return MapEntry(key, value.toJson());
      });
      await prefs.setString(tasksS, json.encode(taskMap));
    } catch (e) {
      print(e);
    }
  }

  static Future<void> syncTasks(Map<String, Task> tasks) async {
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
          FirestoreM.addOrModifyTask(taskPrefs);
        }
      }
      for (var doc in docs) {
        if (!tasks.containsKey(doc.id)) {
          tasks[doc.id] = Task.fromSnap(doc);
        }
      }
      await saveTasksLocally(tasks);
    } catch (e) {
      print(e);
    }
  }

  static Future saveTask(TaskObj tO, SyncObj sO) async {
    await syncFun(sO, () async {
      await saveTasksLocally(tO.tasks);
      await FirestoreM.addOrModifyTask(tO.task);
    });
  }
}

Future<void> syncFun(SyncObj sO, Function callback) async {
  sO.setState(() {
    sO.isSyncing.v = true;
  });
  await callback();
  sO.setState(() {
    sO.isSyncing.v = false;
  });
}
