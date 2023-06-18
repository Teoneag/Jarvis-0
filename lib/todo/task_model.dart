import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const titleS = 'title';

class Task {
  String uid;
  String title;
  // bool isCompleted = false;
  // bool isLoading = false;
  final textC = TextEditingController();

  Task({required this.title, String? uid}) : uid = uid ?? const Uuid().v1() {
    textC.text = title;
  }

  factory Task.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(title: data[titleS], uid: snap.id);
  }

  factory Task.fromJson(String uid, Map<String, dynamic> json) {
    return Task(
      title: json[titleS],
      uid: uid,
    );
  }

  Map<String, dynamic> toJson() => {
        titleS: title,
      };

  void dispose() {
    textC.dispose();
  }
}
