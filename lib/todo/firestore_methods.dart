import 'package:cloud_firestore/cloud_firestore.dart';
import '/todo/task_model.dart';
import '/utils/utils.dart';

const tasksS = 'tasks';
const tasksArchivedS = 'tasksArchivedS';

class FirestoreMethdods {
  static final _firestore = FirebaseFirestore.instance;

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

  static Future<Task> getTask(String uid) async {
    try {
      final docSnap = await _firestore.collection(tasksS).doc(uid).get();
      return Task.fromSnap(docSnap);
    } catch (e) {
      print(e);
      return Task(title: 'Error');
    }
  }
}
