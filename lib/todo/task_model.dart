import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const titleS = 'title';
const lastModifiedS = 'lastModifiedS';

class Task {
  String uid;
  DateTime lastModified;
  String title;
  final textC = TextEditingController();

  Task({required this.title, String? uid, DateTime? lastModified})
      : uid = uid ?? const Uuid().v1(),
        lastModified = lastModified ?? DateTime.now() {
    textC.text = title;
  }

  factory Task.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(
      uid: snap.id,
      lastModified: DateTime.parse(data[lastModifiedS]),
      title: data[titleS],
    );
  }

  factory Task.fromJson(String uid, Map<String, dynamic> json) {
    return Task(
      uid: uid,
      lastModified: DateTime.parse(json[lastModifiedS]),
      title: json[titleS],
    );
  }

  Map<String, dynamic> toJson() => {
        lastModifiedS: lastModified.toString(),
        titleS: title,
      };

  void dispose() {
    textC.dispose();
  }
}
