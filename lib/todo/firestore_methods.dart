import 'package:cloud_firestore/cloud_firestore.dart';
import '/todo/task_model.dart';
import '/utils/utils.dart';

const tasksS = 'tasks';
const tasksArchivedS = 'tasksArchivedS';

class FirestoreMethdods {
  static final _firestore = FirebaseFirestore.instance;

  static Future<String> addTask(Task task) async {
    try {
      _firestore.collection(tasksS).doc(task.uid).set(task.toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> archiveTask(String uid) async {
    try {
      final docSnap = await _firestore.collection(tasksS).doc(uid).get();
      await FirebaseFirestore.instance
          .collection(tasksArchivedS)
          .doc(uid)
          .set(docSnap.data()!);
      await FirebaseFirestore.instance.collection(tasksS).doc(uid).delete();
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }
}
