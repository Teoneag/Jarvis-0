import '/todo/firestore_methods.dart';
import '/todo/todo_methods/task_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tag_model.dart';

class TagM {
  static Future titleToTag(
      String title, TaskObj tO, SyncObj sO, Map<String, Tag> tags) async {
    try {
      RegExp r = RegExp(r'\B#\w*[a-zA-Z]\w*\b');
      final match = r.firstMatch(title);
      if (match == null || match.group(0) == null) return;

      final tagTitle = match.group(0)!.substring(1);
      tO.task.title = tO.task.title.replaceAll(match.group(0)!, '');
      tO.task.title = tO.task.title.replaceAll('  ', ' ');
      tO.task.titleC.text = tO.task.title;
      if (tags.containsKey(tagTitle)) return;

      tO.task.tagsIds.add(tagTitle);
      await addTag(TagObj(Tag(title: tagTitle), tags), sO);
    } catch (e) {
      print(e);
    }
  }

  static Future addTag(TagObj tO, SyncObj sO) async {
    try {
      tO.tags[tO.tag.title] = tO.tag;
      saveTag(tO, sO);
    } catch (e) {
      print(e);
    }
  }

  static Future saveTag(TagObj tO, SyncObj sO) async {
    await syncFun(sO, () async {
      await saveTagsLocally(tO.tags);
      await FirestoreM.addOrModifyTag(tO.tag);
    });
  }

  static Future saveTagsLocally(Map<String, Tag> tags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsMap = tags.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(tagsS, tagsMap.toString());
    } catch (e) {
      print(e);
    }
  }
}

class TagObj {
  final Map<String, Tag> tags;
  final Tag tag;

  TagObj(this.tag, this.tags);
}
