import '../task_model.dart';
import '/utils/utils.dart';
import '/todo/firestore_methods.dart';
import '../tag_model.dart';

class TagM {
  static Future titleToTag(String title, TaskObj tO, SyncObj sO) async {
    try {
      RegExp r = RegExp(r'\B#\w*[a-zA-Z]\w*\b');
      final match = r.firstMatch(title);
      if (match == null || match.group(0) == null) return;

      final tagTitle = match.group(0)!.substring(1);
      tO.task.title = tO.task.title.replaceAll(match.group(0)!, '');
      tO.task.title = tO.task.title.replaceAll('  ', ' ');
      tO.task.titleC.text = tO.task.title;

      tO.task.tagsIds.add(tagTitle);
      await addTag(Tag(title: tagTitle), sO);
    } catch (e) {
      print(e);
    }
  }

  static Future addTag(Tag tag, SyncObj sO) async {
    try {
      BoolW boolW = BoolW(false);
      await FirestoreM.existsTag(tag, boolW);
      if (boolW.v) return;
      await FirestoreM.addOrModifyTag(tag);
    } catch (e) {
      print(e);
    }
  }
}
