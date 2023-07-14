import 'package:flutter/material.dart';
import 'package:jarvis_0/todo/todo_methods/date_methods.dart';
import 'package:jarvis_0/todo/todo_methods/tag_methods.dart';
import '../tag_model.dart';
import '/todo/todo_methods/task_manager.dart';
import '../firestore_methods.dart';
import '/todo/task_model.dart';

class TodoM {
  static Future displayDialog(
    Map<String, Task> tasks,
    TextEditingController titleC,
    BuildContext context,
    SyncObj sO,
  ) {
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
    await syncFun(sO, () => TaskM.loadTasks(tasks));
    await syncFun(sO, () => TaskM.syncTasks(tasks));
  }

  static Future syncTasks(Map<String, Task> tasks, SyncObj sO) async {
    await syncFun(sO, () => TaskM.syncTasks(tasks));
  }

  static void addTask(
      Map<String, Task> tasks, TextEditingController titleC, SyncObj sO) {
    try {
      final task = Task(title: titleC.text);
      tasks[task.uid] = task;
      titleC.clear();
      TaskM.saveTask(TaskObj(tasks, task), sO);
    } catch (e) {
      print(e);
    }
  }

  static Future archiveTask(TaskObj tO, SyncObj sO) async {
    try {
      tO.task.dispose();
      tO.tasks.remove(tO.task.uid);
      await syncFun(sO, () async {
        await TaskM.saveTasksLocally(tO.tasks);
        await FirestoreM.archiveTask(tO.task.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  static Future doneTask(TaskObj tO, SyncObj sO) async {
    try {
      tO.task.dispose();
      tO.tasks.remove(tO.task.uid);
      await syncFun(sO, () async {
        await TaskM.saveTasksLocally(tO.tasks);
        await FirestoreM.doneTask(tO.task.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  static void modifyTitle(
      Map<String, Tag> tags, TaskObj tO, String title, SyncObj sO) {
    try {
      tO.task.title = title;
      tO.task.lastModified = DateTime.now();
      DateM.titleToDate(title, tO, sO);
      TagM.titleToTag(title, tO, sO, tags);
      TaskM.saveTask(tO, sO);
    } catch (e) {
      print(e);
    }
  }
}
