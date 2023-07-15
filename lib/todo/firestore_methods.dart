import 'package:cloud_firestore/cloud_firestore.dart';
import '/todo/task_model.dart';
import '/utils/utils.dart';
import 'tag_model.dart';

const tasksS = 'tasks';
const tasksArchivedS = 'tasksArchived';
const tasksDoneS = 'tasksDone';
const tagsS = 'tags';

class FirestoreM {
  static final _firestore = FirebaseFirestore.instance;

  static Future<String> existsTag(Tag tag, BoolW boolW) async {
    try {
      final docSnap = await _firestore.collection(tagsS).doc(tag.title).get();
      boolW.v = docSnap.exists;
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> addOrModifyTag(Tag tag) async {
    try {
      await _firestore.collection(tagsS).doc(tag.title).set(tag.toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> addOrModifyTask(Task task) async {
    try {
      await _firestore.collection(tasksS).doc(task.uid).set(task.toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> archiveTask(String uid) async {
    try {
      final docSnap = await _firestore.collection(tasksS).doc(uid).get();
      await _firestore.collection(tasksArchivedS).doc(uid).set(docSnap.data()!);
      await _firestore.collection(tasksS).doc(uid).delete();
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> doneTask(String uid) async {
    try {
      final docSnap = await _firestore.collection(tasksS).doc(uid).get();
      await _firestore.collection(tasksDoneS).doc(uid).set(docSnap.data()!);
      await _firestore.collection(tasksS).doc(uid).delete();
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }
}
