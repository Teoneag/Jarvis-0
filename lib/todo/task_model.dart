import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const titleS = 'title';
const lastModifiedS = 'lastModified';
const dueDateS = 'dueDate';

class Task {
  String uid;
  DateTime lastModified;
  String title;
  final textC = TextEditingController();
  // final dateC = TextEditingController();
  // final timeC = TextEditingController();

  DateTime? dueDate;

  Task({required this.title, String? uid, DateTime? lastModified, this.dueDate})
      : uid = uid ?? const Uuid().v1(),
        lastModified = lastModified ?? DateTime.now() {
    textC.text = title;
  }

  factory Task.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(
      uid: snap.id,
      lastModified: DateTime.tryParse(data[lastModifiedS]),
      title: data[titleS],
      dueDate: DateTime.tryParse(data[dueDateS]),
    );
  }

  factory Task.fromJson(String uid, Map<String, dynamic> json) {
    return Task(
      uid: uid,
      lastModified: DateTime.tryParse(json[lastModifiedS]),
      title: json[titleS],
      dueDate: DateTime.tryParse(json[dueDateS].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        lastModifiedS: lastModified.toString(),
        titleS: title,
        dueDateS: dueDate.toString(),
      };

  void dispose() {
    textC.dispose();
    // dateC.dispose();
    // timeC.dispose();
  }
}
