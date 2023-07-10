import 'package:jarvis_0/todo/firestore_methods.dart';

import '/todo/todo_methods/task_manager.dart';

class TagM {
  static void addTag(String input, TaskObj tO, SyncObj sO) {
    try {
      RegExp r = RegExp(r'\B#\w*[a-zA-Z]\w*\b');
      final match = r.firstMatch(input);
      if (match != null && match.group(0) != null) {
        final tag = match.group(0)!.substring(1);
        if (tO.task.tags.contains(tag)) return;
        tO.task.tags.add(tag);
        FirestoreM.tagTask(tag, tO.task.uid);
        print(tO.task.tags);
      }
    } catch (e) {
      print(e);
    }
  }
}
