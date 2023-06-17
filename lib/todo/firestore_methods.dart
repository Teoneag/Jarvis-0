import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_0/todo/task_model.dart';
import '/utils/utils.dart';

const tasksS = 'tasks';

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
}
