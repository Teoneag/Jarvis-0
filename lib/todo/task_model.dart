import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const titleS = 'title';

class Task {
  String uid = const Uuid().v1();
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  static Task fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(title: data[titleS]);
  }

  Map<String, dynamic> toJson() => {
        titleS: title,
      };
}
