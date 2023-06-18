import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const titleS = 'title';

class Task {
  String uid;
  String title;
  bool isCompleted = false;
  bool isLoading = false;

  Task({required this.title, String? uid}) : uid = uid ?? const Uuid().v1();

  static Task fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(title: data[titleS], uid: snap.id);
  }

  Map<String, dynamic> toJson() => {
        titleS: title,
      };
}
